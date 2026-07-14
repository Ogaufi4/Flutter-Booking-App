import {initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {FieldValue, getFirestore, Timestamp} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {defineBoolean, defineString} from "firebase-functions/params";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onDocumentCreated, onDocumentUpdated} from "firebase-functions/v2/firestore";
import {setGlobalOptions} from "firebase-functions/v2";

initializeApp();
setGlobalOptions({region: "us-central1", maxInstances: 10});
const db = getFirestore();
const replyToEmail = defineString("REPLY_TO_EMAIL", {default: ""});
const metaEnabled = defineBoolean("META_WHATSAPP_ENABLED", {default: false});

type Booking = Record<string, unknown> & {userId: string; fullName: string; email: string; phone: string; destination: string; status: string; ownerResponse?: string; declineReason?: string};
const manager = (token: Record<string, unknown>) => token.role === "owner" || token.role === "staff";
const normalized = (status: unknown) => status === "submitted" ? "new" : String(status ?? "new");
const transitions: Record<string, string[]> = {new: ["reviewing"], reviewing: ["approved", "declined"], approved: ["completed"]};

export const updateBookingStatus = onCall(async (request) => {
  if (!request.auth || !manager(request.auth.token)) throw new HttpsError("permission-denied", "Owner or staff access is required.");
  const bookingId = String(request.data?.bookingId ?? "");
  const next = String(request.data?.status ?? "");
  const ownerResponse = String(request.data?.ownerResponse ?? "").trim();
  const declineReason = String(request.data?.declineReason ?? "").trim();
  if (!bookingId || !["reviewing", "approved", "declined", "completed"].includes(next)) throw new HttpsError("invalid-argument", "Invalid booking transition.");
  if (next === "declined" && !declineReason) throw new HttpsError("invalid-argument", "A decline reason is required.");
  const ref = db.collection("bookings").doc(bookingId);
  await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(ref);
    if (!snapshot.exists) throw new HttpsError("not-found", "Booking not found.");
    const current = normalized(snapshot.get("status"));
    if (!transitions[current]?.includes(next)) throw new HttpsError("failed-precondition", `Cannot move ${current} to ${next}.`);
    const update: Record<string, unknown> = {status: next, ownerResponse, statusUpdatedAt: FieldValue.serverTimestamp(), statusUpdatedBy: request.auth!.uid, updatedAt: FieldValue.serverTimestamp()};
    if (next === "approved") Object.assign(update, {approvedAt: FieldValue.serverTimestamp(), approvedBy: request.auth!.uid, declineReason: ""});
    if (next === "declined") Object.assign(update, {declinedAt: FieldValue.serverTimestamp(), declinedBy: request.auth!.uid, declineReason});
    tx.update(ref, update);
  });
  return {ok: true};
});

export const cancelBooking = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in first.");
  const bookingId = String(request.data?.bookingId ?? "");
  const ref = db.collection("bookings").doc(bookingId);
  await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(ref);
    if (!snapshot.exists) throw new HttpsError("not-found", "Booking not found.");
    if (snapshot.get("userId") !== request.auth!.uid) throw new HttpsError("permission-denied", "This is not your booking.");
    const current = normalized(snapshot.get("status"));
    if (!["new", "reviewing"].includes(current)) throw new HttpsError("failed-precondition", "Only new or reviewing bookings can be cancelled.");
    tx.update(ref, {status: "cancelled", cancelledAt: FieldValue.serverTimestamp(), cancelledBy: request.auth!.uid, statusUpdatedAt: FieldValue.serverTimestamp(), statusUpdatedBy: request.auth!.uid, updatedAt: FieldValue.serverTimestamp()});
  });
  return {ok: true};
});

async function claimEvent(eventId: string, bookingId: string, type: string) {
  const ref = db.collection("notification_events").doc(eventId);
  try { await ref.create({bookingId, type, status: "processing", attempts: 1, createdAt: FieldValue.serverTimestamp()}); return ref; } catch { return null; }
}
async function deviceTokens(userIds: string[]) {
  const tokens: string[] = [];
  for (const uid of userIds) {
    const snapshot = await db.collection("users").doc(uid).collection("devices").where("enabled", "==", true).get();
    snapshot.forEach((doc) => { const token = doc.get("token"); if (typeof token === "string") tokens.push(token); });
  }
  return tokens;
}
async function managers() {
  const snapshot = await db.collection("users").where("role", "in", ["owner", "staff"]).get();
  return {
    ids: snapshot.docs.map((doc) => doc.id),
    emails: snapshot.docs.map((doc) => doc.get("email")).filter((value): value is string => typeof value === "string" && value.length > 0),
  };
}
async function push(userIds: string[], title: string, body: string, bookingId: string) {
  const tokens = await deviceTokens(userIds); if (!tokens.length) return 0;
  const result = await getMessaging().sendEachForMulticast({tokens, notification: {title, body}, data: {bookingId, route: "bookingDetails"}, android: {priority: "high", notification: {channelId: "travel365_bookings"}}});
  return result.successCount;
}
async function email(to: string | string[], subject: string, heading: string, body: string, bookingId: string) {
  if (!to || (Array.isArray(to) && !to.length)) return;
  const mail: Record<string, unknown> = {to, message: {subject, html: `<div style="font-family:Arial;color:#262261"><h2 style="color:#E46225">${heading}</h2><p>${body}</p><p><strong>Booking reference:</strong> ${bookingId}</p><p>Travel365</p></div>`}, createdAt: FieldValue.serverTimestamp()};
  if (replyToEmail.value()) mail.replyTo = replyToEmail.value();
  await db.collection("mail").add(mail);
}
async function sendMetaWhatsApp(_booking: Booking, template: string, _text: string) {
  if (!metaEnabled.value()) return {enabled: false, sent: false, template};
  // Production adapter boundary: add Graph API call only after Meta credentials and templates are approved.
  return {enabled: true, sent: false, template};
}

// Single source for notification wording so push, email, and WhatsApp stay
// aligned. Every customer-facing body keeps the booking reference,
// destination, status, and support details visible.
type ChannelMessage = {title: string; subject: string; heading: string; body: string};
type SupportContact = {phone: string; email: string};
const reference = (bookingId: string) => bookingId.slice(0, 8).toUpperCase();

// Support contact is owner-editable at settings/support, so it is read per
// event rather than baked into deploy config. A missing or half-filled doc
// yields no support line at all -- never a placeholder number.
async function supportContact(): Promise<SupportContact> {
  const snapshot = await db.collection("settings").doc("support").get();
  const phone = snapshot.get("phone");
  const email = snapshot.get("email");
  return {
    phone: typeof phone === "string" ? phone.trim() : "",
    email: typeof email === "string" ? email.trim() : "",
  };
}
function supportLine(support: SupportContact) {
  const channels = [];
  if (support.phone) channels.push(`call ${support.phone}`);
  if (support.email) channels.push(`email ${support.email}`);
  return channels.length ? ` Questions? Please ${channels.join(" or ")}.` : "";
}
function bookingMessage(kind: string, booking: Booking, bookingId: string, support: SupportContact): ChannelMessage {
  const ref = reference(bookingId);
  switch (kind) {
  case "created_managers":
    return {title: "New Travel365 booking", subject: "New Travel365 booking", heading: "New booking received", body: `${booking.fullName} submitted booking ${ref} for ${booking.destination}.`};
  case "created_customer":
    return {title: "Travel365 booking received", subject: "Travel365 booking received", heading: "We received your booking", body: `Hello ${booking.fullName}, your booking ${ref} to ${booking.destination} is awaiting review.${supportLine(support)}`};
  case "declined":
    return {title: "Booking declined", subject: "Travel365 booking declined", heading: "Your booking was declined", body: `Your booking ${ref} to ${booking.destination} was declined: ${booking.declineReason || "Please contact Travel365."}${supportLine(support)}`};
  case "cancelled_managers":
    return {title: "Booking cancelled", subject: "Travel365 booking cancelled", heading: "Booking cancelled", body: `${booking.fullName} cancelled booking ${ref} for ${booking.destination}.`};
  default:
    return {title: `Booking ${kind}`, subject: `Travel365 booking ${kind}`, heading: `Your booking is ${kind}`, body: `Your booking ${ref} to ${booking.destination} is now ${kind}.${booking.ownerResponse ? ` ${booking.ownerResponse}` : ""}${supportLine(support)}`};
  }
}

export const onBookingCreated = onDocumentCreated("bookings/{bookingId}", async (event) => {
  const bookingId = event.params.bookingId; const booking = event.data?.data() as Booking | undefined; if (!booking) return;
  const marker = await claimEvent(`${bookingId}_created`, bookingId, "created"); if (!marker) return;
  try {
    const [managerContacts, support] = await Promise.all([managers(), supportContact()]);
    const forManagers = bookingMessage("created_managers", booking, bookingId, support);
    const forCustomer = bookingMessage("created_customer", booking, bookingId, support);
    const [pushCount, , , whatsapp] = await Promise.all([
      push(managerContacts.ids, forManagers.title, forManagers.body, bookingId),
      email(managerContacts.emails, forManagers.subject, forManagers.heading, forManagers.body, bookingId),
      email(booking.email, forCustomer.subject, forCustomer.heading, forCustomer.body, bookingId),
      sendMetaWhatsApp(booking, "new_booking", forCustomer.body),
    ]);
    await marker.update({status: "sent", pushCount, whatsapp, completedAt: FieldValue.serverTimestamp()});
  } catch (error) { await marker.update({status: "failed", error: String(error), completedAt: FieldValue.serverTimestamp()}); }
});

export const onBookingUpdated = onDocumentUpdated("bookings/{bookingId}", async (event) => {
  const before = event.data?.before.data() as Booking | undefined; const after = event.data?.after.data() as Booking | undefined; if (!before || !after) return;
  const previous = normalized(before.status); const current = normalized(after.status); if (previous === current) return;
  const bookingId = event.params.bookingId; const marker = await claimEvent(`${bookingId}_${current}`, bookingId, `status_${current}`); if (!marker) return;
  try {
    let pushCount = 0;
    let whatsapp: Record<string, unknown> = {enabled: metaEnabled.value(), sent: false};
    const support = await supportContact();
    if (["approved", "declined", "completed"].includes(current)) {
      const message = bookingMessage(current, after, bookingId, support);
      pushCount = await push([after.userId], message.title, message.body, bookingId);
      await email(after.email, message.subject, message.heading, message.body, bookingId);
      whatsapp = await sendMetaWhatsApp(after, `booking_${current}`, message.body);
    } else if (current === "cancelled") {
      const message = bookingMessage("cancelled_managers", after, bookingId, support);
      const managerContacts = await managers();
      pushCount = await push(managerContacts.ids, message.title, message.body, bookingId);
      await email(managerContacts.emails, message.subject, message.heading, message.body, bookingId);
      whatsapp = await sendMetaWhatsApp(after, "booking_cancelled", message.body);
    }
    await marker.update({status: "sent", pushCount, whatsapp, previousStatus: previous, completedAt: FieldValue.serverTimestamp()});
  } catch (error) { await marker.update({status: "failed", error: String(error), completedAt: FieldValue.serverTimestamp()}); }
});

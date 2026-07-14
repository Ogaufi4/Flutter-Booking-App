import {FieldValue} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {db} from "../config";
import {normalized} from "../types";

const manager = (token: Record<string, unknown>) =>
  token.role === "owner" || token.role === "staff";

/** Only these moves are legal; anything else is rejected server-side. */
const transitions: Record<string, string[]> = {
  new: ["reviewing"],
  reviewing: ["approved", "declined"],
  approved: ["completed"],
};

export const updateBookingStatus = onCall(async (request) => {
  if (!request.auth || !manager(request.auth.token)) {
    throw new HttpsError("permission-denied", "Owner or staff access is required.");
  }
  const bookingId = String(request.data?.bookingId ?? "");
  const next = String(request.data?.status ?? "");
  const ownerResponse = String(request.data?.ownerResponse ?? "").trim();
  const declineReason = String(request.data?.declineReason ?? "").trim();

  if (!bookingId || !["reviewing", "approved", "declined", "completed"].includes(next)) {
    throw new HttpsError("invalid-argument", "Invalid booking transition.");
  }
  if (next === "declined" && !declineReason) {
    throw new HttpsError("invalid-argument", "A decline reason is required.");
  }

  const ref = db.collection("bookings").doc(bookingId);
  await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(ref);
    if (!snapshot.exists) throw new HttpsError("not-found", "Booking not found.");
    const current = normalized(snapshot.get("status"));
    if (!transitions[current]?.includes(next)) {
      throw new HttpsError("failed-precondition", `Cannot move ${current} to ${next}.`);
    }
    const update: Record<string, unknown> = {
      status: next,
      ownerResponse,
      statusUpdatedAt: FieldValue.serverTimestamp(),
      statusUpdatedBy: request.auth!.uid,
      updatedAt: FieldValue.serverTimestamp(),
    };
    if (next === "approved") {
      Object.assign(update, {approvedAt: FieldValue.serverTimestamp(), approvedBy: request.auth!.uid, declineReason: ""});
    }
    if (next === "declined") {
      Object.assign(update, {declinedAt: FieldValue.serverTimestamp(), declinedBy: request.auth!.uid, declineReason});
    }
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
    if (snapshot.get("userId") !== request.auth!.uid) {
      throw new HttpsError("permission-denied", "This is not your booking.");
    }
    const current = normalized(snapshot.get("status"));
    if (!["new", "reviewing"].includes(current)) {
      throw new HttpsError("failed-precondition", "Only new or reviewing bookings can be cancelled.");
    }
    tx.update(ref, {
      status: "cancelled",
      cancelledAt: FieldValue.serverTimestamp(),
      cancelledBy: request.auth!.uid,
      statusUpdatedAt: FieldValue.serverTimestamp(),
      statusUpdatedBy: request.auth!.uid,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
  return {ok: true};
});

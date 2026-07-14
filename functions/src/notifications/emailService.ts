import {FieldValue} from "firebase-admin/firestore";
import {db, replyToEmail} from "../config";
import {emailHtml} from "../templates/emailTemplates";
import type {ChannelMessage, SendResult} from "../types";

/**
 * Queues a document into the `mail` collection, which the Firebase Trigger
 * Email extension (firestore-send-email) delivers. Nothing is sent until that
 * extension is installed -- the docs simply accumulate.
 */
async function queue(to: string[], message: ChannelMessage, bookingId: string): Promise<SendResult> {
  const recipients = to.map((value) => value.trim().toLowerCase()).filter(Boolean);
  const unique = [...new Set(recipients)];
  if (!unique.length) return {sent: false, recipient: "", error: "no recipient address"};

  try {
    const mail: Record<string, unknown> = {
      to: unique,
      message: {
        subject: message.subject,
        html: emailHtml(message.heading, message.body, bookingId),
      },
      createdAt: FieldValue.serverTimestamp(),
    };
    if (replyToEmail.value()) mail.replyTo = replyToEmail.value();
    const document = await db.collection("mail").add(mail);
    return {sent: true, recipient: unique.join(", "), messageId: document.id};
  } catch (error) {
    return {sent: false, recipient: unique.join(", "), error: String(error)};
  }
}

export const sendCustomerConfirmation = (
  to: string,
  message: ChannelMessage,
  bookingId: string,
): Promise<SendResult> => queue([to], message, bookingId);

export const sendAdminBookingAlert = (
  to: string[],
  message: ChannelMessage,
  bookingId: string,
): Promise<SendResult> => queue(to, message, bookingId);

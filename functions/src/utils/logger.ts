import {FieldValue} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {db} from "../config";
import type {SendResult} from "../types";

export type Channel = "email" | "whatsapp" | "push";

/**
 * Persists one row per notification attempt to notification_logs. A silent
 * failure is worse than a loud one: every send records status "sent" or
 * "failed" with the provider error, so a channel that stops working is visible
 * in Firestore rather than only in Cloud Logging.
 */
export async function logNotification(
  bookingId: string,
  channel: Channel,
  provider: string,
  result: SendResult,
): Promise<void> {
  try {
    await db.collection("notification_logs").add({
      bookingId,
      channel,
      provider,
      recipient: result.recipient,
      status: result.sent ? "sent" : "failed",
      error: result.error ?? "",
      messageId: result.messageId ?? "",
      timestamp: FieldValue.serverTimestamp(),
    });
  } catch (error) {
    // Logging must never break a booking, so swallow and fall back to stdout.
    logger.error("notification_logs write failed", {bookingId, channel, error: String(error)});
  }
}

/**
 * Idempotency marker. Firestore create() fails if the document already exists,
 * so a retried or duplicated trigger claims nothing and returns null instead of
 * sending twice.
 */
export async function claimEvent(eventId: string, bookingId: string, type: string) {
  const ref = db.collection("notification_events").doc(eventId);
  try {
    await ref.create({
      bookingId,
      type,
      status: "processing",
      attempts: 1,
      createdAt: FieldValue.serverTimestamp(),
    });
    return ref;
  } catch {
    return null;
  }
}

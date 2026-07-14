import {getMessaging} from "firebase-admin/messaging";
import {logger} from "firebase-functions";
import {db} from "../config";
import type {ChannelMessage, SendResult} from "../types";

/**
 * Only devices whose owner granted notification permission are targeted. The
 * client writes enabled:false when permission is denied or later revoked, and
 * FCM issues a token either way -- so the flag, not the token, decides.
 */
async function deviceTokens(userIds: string[]): Promise<string[]> {
  const tokens: string[] = [];
  for (const uid of userIds) {
    const snapshot = await db
      .collection("users").doc(uid)
      .collection("devices").where("enabled", "==", true)
      .get();
    snapshot.forEach((doc) => {
      const token = doc.get("token");
      if (typeof token === "string" && token) tokens.push(token);
    });
  }
  return [...new Set(tokens)];
}

export async function sendPush(
  userIds: string[],
  message: ChannelMessage,
  bookingId: string,
): Promise<SendResult> {
  try {
    const tokens = await deviceTokens(userIds);
    if (!tokens.length) return {sent: false, recipient: "", error: "no enabled device tokens"};

    const result = await getMessaging().sendEachForMulticast({
      tokens,
      notification: {title: message.title, body: message.body},
      data: {bookingId, route: "bookingDetails"},
      android: {priority: "high", notification: {channelId: "travel365_bookings"}},
    });

    const recipient = `${tokens.length} device(s)`;
    if (!result.successCount) {
      return {sent: false, recipient, error: `all ${tokens.length} sends failed`};
    }
    return {sent: true, recipient: `${result.successCount}/${tokens.length} device(s)`};
  } catch (error) {
    logger.error("Push send threw", {bookingId, error: String(error)});
    return {sent: false, recipient: "", error: String(error)};
  }
}

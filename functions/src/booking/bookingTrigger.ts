import {FieldValue} from "firebase-admin/firestore";
import {onDocumentCreated, onDocumentUpdated} from "firebase-functions/v2/firestore";
import {wasenderApiToken} from "../config";
import {notifyBookingCreated, notifyBookingStatusChanged} from "../notifications/notificationService";
import {claimEvent} from "../utils/logger";
import {normalized} from "../types";
import type {Booking} from "../types";

export const onBookingCreated = onDocumentCreated(
  {document: "bookings/{bookingId}", secrets: [wasenderApiToken]},
  async (event) => {
    const bookingId = event.params.bookingId;
    const booking = event.data?.data() as Booking | undefined;
    if (!booking) return;

    const marker = await claimEvent(`${bookingId}_created`, bookingId, "created");
    if (!marker) return;

    try {
      const results = await notifyBookingCreated(booking, bookingId);
      await marker.update({status: "sent", results, completedAt: FieldValue.serverTimestamp()});
    } catch (error) {
      await marker.update({status: "failed", error: String(error), completedAt: FieldValue.serverTimestamp()});
    }
  },
);

export const onBookingUpdated = onDocumentUpdated(
  {document: "bookings/{bookingId}", secrets: [wasenderApiToken]},
  async (event) => {
    const before = event.data?.before.data() as Booking | undefined;
    const after = event.data?.after.data() as Booking | undefined;
    if (!before || !after) return;

    const previous = normalized(before.status);
    const current = normalized(after.status);
    if (previous === current) return;

    const bookingId = event.params.bookingId;
    const marker = await claimEvent(`${bookingId}_${current}`, bookingId, `status_${current}`);
    if (!marker) return;

    try {
      const results = await notifyBookingStatusChanged(after, bookingId, current);
      await marker.update({
        status: "sent",
        results,
        previousStatus: previous,
        completedAt: FieldValue.serverTimestamp(),
      });
    } catch (error) {
      await marker.update({status: "failed", error: String(error), completedAt: FieldValue.serverTimestamp()});
    }
  },
);

export type Booking = Record<string, unknown> & {
  userId: string;
  fullName: string;
  email: string;
  phone: string;
  destination: string;
  status: string;
  ownerResponse?: string;
  declineReason?: string;
};

/** Contact shown TO customers inside their notifications. Owner-editable. */
export type SupportContact = {phone: string; email: string};

/** Where owner/admin alerts are SENT. Owner-editable. */
export type CompanySettings = {agencyName: string; adminEmail: string; adminWhatsapp: string};

export type ChannelMessage = {
  title: string;
  subject: string;
  heading: string;
  body: string;
  receiptBody?: string;
};

export type SendResult = {sent: boolean; recipient: string; error?: string; messageId?: string};

export const BOOKING_STATUSES = ["new", "reviewing", "approved", "declined", "completed", "cancelled"] as const;

export const normalized = (status: unknown) =>
  status === "submitted" ? "new" : String(status ?? "new");

export const reference = (bookingId: string) => bookingId.slice(0, 8).toUpperCase();

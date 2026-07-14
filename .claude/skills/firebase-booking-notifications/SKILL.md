---
name: firebase-booking-notifications
description: Implements Firebase booking notifications using Firestore triggers, Email, and Meta WhatsApp Cloud API for a Flutter travel agency booking application.
---

# Firebase Booking Notifications Skill

## Purpose

This skill implements an event-driven notification system for a Flutter Travel Agency application using Firebase.

The Flutter application ONLY creates bookings.

Firebase Cloud Functions handle all notifications.

The goal is to keep business logic outside the mobile application.

---

# Architecture

```
Flutter App
      │
      ▼
Firebase Authentication
      │
      ▼
Cloud Firestore
      │
      ▼
Booking Created
      │
      ▼
Firebase Cloud Function
      │
      ▼
Notification Service
      │
 ┌────┴───────────┐
 │                │
 ▼                ▼
Email Service   WhatsApp Service
 │                │
 ▼                ▼
Customer      Travel Agency Admin
               (Owner)
```

---

# Responsibilities

## Flutter

Responsible ONLY for:

- Authentication
- Booking creation
- Viewing bookings
- Booking history

Flutter must NEVER:

- Send emails
- Send WhatsApp messages
- Store API keys
- Call Meta Graph API directly

---

## Firestore

Collections

```
users/

packages/

bookings/

settings/

notification_logs/
```

---

## Booking Document

```
bookings/{bookingId}

customerId

customerName

customerEmail

customerPhone

packageId

packageName

travelDate

numberOfGuests

pickupLocation

totalPrice

status

createdAt
```

Example

```json
{
  "customerName":"John Doe",
  "customerEmail":"john@gmail.com",
  "customerPhone":"26771234567",
  "packageName":"Victoria Falls Tour",
  "travelDate":"2026-08-20",
  "numberOfGuests":2,
  "totalPrice":3500,
  "status":"Pending"
}
```

---

# Settings Collection

```
settings/company
```

Example

```json
{
    "agencyName":"Travel365",

    "adminEmail":"bookings@travel365.com",

    "adminWhatsapp":"26771234567"
}
```

Do NOT hardcode these values.

Always read them from Firestore.

---

# Notification Flow

```
Customer Books

↓

Firestore

↓

Cloud Function Trigger

↓

Load Booking

↓

Load Company Settings

↓

Send Customer Email

↓

Send Admin Email

↓

Send Admin WhatsApp

↓

Save Notification Log
```

---

# Notification Rules

## Customer

Receive

✔ Booking Confirmation Email

No WhatsApp.

---

## Travel Agency Admin

Receive

✔ New Booking Email

✔ WhatsApp Alert

---

# Email Template (Customer)

Subject

```
Booking Confirmation
```

Body

```
Hello {{customerName}}

Thank you for booking with Travel365.

Booking Reference:
{{reference}}

Package:
{{package}}

Travel Date:
{{travelDate}}

Guests:
{{guests}}

Our consultant will contact you shortly.

Thank you.
```

---

# Email Template (Admin)

Subject

```
New Booking Received
```

Body

```
A new booking has been received.

Customer:
{{customer}}

Phone:
{{phone}}

Package:
{{package}}

Travel Date:
{{travelDate}}

Guests:
{{guests}}

Amount:
{{price}}
```

---

# WhatsApp Template (Admin)

Use Meta WhatsApp Cloud API.

The message should contain

```
🛫 NEW BOOKING

Booking Ref:
{{reference}}

Customer:
{{customer}}

Phone:
{{phone}}

Package:
{{package}}

Travel Date:
{{travelDate}}

Guests:
{{guests}}

Total:
{{price}}

Please log in to the admin dashboard.
```

This notification is ONLY for the agency owner.

No chatbot.

No AI conversation.

No automated replies.

---

# Cloud Function Structure

```
functions/

index.ts

booking/

    bookingTrigger.ts

notifications/

    notificationService.ts

    emailService.ts

    whatsappService.ts

templates/

    emailTemplates.ts

    whatsappTemplates.ts

utils/

    logger.ts

config.ts
```

---

# Trigger

```
onDocumentCreated(
"bookings/{bookingId}"
)
```

Workflow

```
Booking Created

↓

Read Booking

↓

Read Company Settings

↓

Send Notifications

↓

Log Result
```

---

# Notification Service

Responsible ONLY for deciding

Who receives notifications.

Example

```
notifyBookingCreated(
booking,
companySettings
)
```

It should NEVER know

- SMTP implementation
- WhatsApp API implementation

---

# Email Service

Responsible ONLY for sending email.

Functions

```
sendCustomerConfirmation()

sendAdminBookingAlert()
```

---

# WhatsApp Service

Responsible ONLY for Meta Cloud API.

Functions

```
sendBookingAlert()

sendFailureNotification()
```

---

# Logging

Save every notification.

Collection

```
notification_logs
```

Document

```
bookingId

recipient

channel

status

provider

timestamp

error
```

Example

```json
{
  "bookingId":"abc123",

  "channel":"whatsapp",

  "recipient":"26771234567",

  "status":"sent",

  "provider":"Meta"
}
```

---

# Error Handling

If WhatsApp fails

- Log the error
- Continue sending email
- Never fail the booking

If email fails

- Log the error
- Continue booking creation

Notifications must never prevent bookings.

---

# Security

Never expose

- Meta Access Token
- SMTP Password
- API Keys

Store all secrets using

Firebase Functions Secrets

or

Google Secret Manager

Never send notification credentials to Flutter.

---

# Design Principles

- Event-driven architecture.
- Single Responsibility Principle.
- Modular notification services.
- Firestore-triggered backend automation.
- Configurable agency contact details.
- Easily extensible to SMS, Push Notifications, or additional channels in the future.

```

This skill teaches Claude to generate a clean, production-ready notification system whenever you're working on your Travel365 Firebase backend, keeping the Flutter client thin and all notification logic centralized in Cloud Functions.
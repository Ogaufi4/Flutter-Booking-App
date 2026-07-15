import 'dart:async';
import 'package:booking_app/features/bookings/pages/booking_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();
  static final navigatorKey = GlobalKey<NavigatorState>();
  final local = FlutterLocalNotificationsPlugin();
  StreamSubscription<User?>? authSubscription;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    await local.initialize(const InitializationSettings(android: android),
        onDidReceiveNotificationResponse: (response) {
      if (response.payload?.isNotEmpty == true) openBooking(response.payload!);
    });
    await local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
            'travel365_bookings', 'Travel365 bookings',
            description: 'Booking updates and approval notifications',
            importance: Importance.high));
    FirebaseMessaging.onMessage.listen(_showForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_openFromMessage);
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      Future<void>.delayed(
          const Duration(milliseconds: 800), () => _openFromMessage(initial));
    }
    authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) registerCurrentDevice();
    });
    FirebaseMessaging.instance.onTokenRefresh
        .listen((_) => registerCurrentDevice());
  }

  Future<bool> registerCurrentDevice() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    final status = settings.authorizationStatus;
    final granted = status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return false;
    // FCM issues a token even when the user denies notification permission, so
    // the grant -- not the token -- decides whether the backend may target this
    // device. Re-writing `enabled` on every call also disables devices whose
    // permission was revoked after an earlier grant.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(token.hashCode.toUnsigned(32).toString())
        .set({
      'token': token,
      'platform': defaultTargetPlatform.name,
      'enabled': granted,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return granted;
  }

  Future<bool> currentDeviceEnabled() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return false;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(token.hashCode.toUnsigned(32).toString())
        .get();
    return snapshot.data()?['enabled'] == true;
  }

  Future<bool> setCurrentDeviceEnabled(bool enabled) async {
    if (enabled) return registerCurrentDevice();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return false;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(token.hashCode.toUnsigned(32).toString())
        .set({
      'token': token,
      'platform': defaultTargetPlatform.name,
      'enabled': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return false;
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await local.show(
        message.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'travel365_bookings', 'Travel365 bookings',
                channelDescription:
                    'Booking updates and approval notifications',
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/launcher_icon')),
        payload: message.data['bookingId']?.toString());
  }

  void _openFromMessage(RemoteMessage message) {
    final id = message.data['bookingId']?.toString();
    if (id != null && id.isNotEmpty) openBooking(id);
  }

  void openBooking(String bookingId) {
    navigatorKey.currentState?.pushNamed('/bookingDetails',
        arguments: BookingDetailsArgs(bookingId: bookingId));
  }
}

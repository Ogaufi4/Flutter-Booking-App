import 'package:booking_app/data/models/basic_model.dart';
import 'package:booking_app/features/bookings/data/travel_booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingRepository {
  BookingRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  String get currentUserId {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) return firebaseUser.uid;
    if (BasicModel.userToken == 'demo-token' || BasicModel.userID == '1') {
      return 'demo-user';
    }
    return BasicModel.userID;
  }

  Stream<List<TravelBooking>> watchMyBookings() {
    final userId = currentUserId;
    if (userId.isEmpty) return Stream.value(const <TravelBooking>[]);
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs
          .map(TravelBooking.fromFirestore)
          .toList(growable: false);
      bookings.sort((a, b) {
        final aDate = a.createdAt ?? a.departureDate;
        final bDate = b.createdAt ?? b.departureDate;
        return bDate.compareTo(aDate);
      });
      return bookings;
    });
  }

  Stream<List<TravelBooking>> watchAllBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(TravelBooking.fromFirestore)
            .toList(growable: false));
  }

  Stream<TravelBooking?> watchBooking(String bookingId) {
    return _firestore.collection('bookings').doc(bookingId).snapshots().map(
          (document) =>
              document.exists ? TravelBooking.fromFirestore(document) : null,
        );
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
    String ownerResponse = '',
    String declineReason = '',
  }) async {
    final payload = {
      'bookingId': bookingId,
      'status': status,
      'ownerResponse': ownerResponse.trim(),
      'declineReason': declineReason.trim(),
    };
    try {
      await _functions.httpsCallable('updateBookingStatus').call(payload);
    } on FirebaseFunctionsException catch (error) {
      if (!_shouldUseFirestoreFallback(error)) rethrow;
      await _updateBookingStatusDirect(
        bookingId: bookingId,
        status: status,
        ownerResponse: ownerResponse,
        declineReason: declineReason,
      );
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _functions.httpsCallable('cancelBooking').call({
        'bookingId': bookingId,
      });
    } on FirebaseFunctionsException catch (error) {
      if (!_shouldUseFirestoreFallback(error)) rethrow;
      await _cancelBookingDirect(bookingId);
    }
  }

  bool _shouldUseFirestoreFallback(FirebaseFunctionsException error) {
    return error.code == 'not-found' ||
        error.code == 'unavailable' ||
        error.code == 'internal';
  }

  Future<void> _updateBookingStatusDirect({
    required String bookingId,
    required String status,
    required String ownerResponse,
    required String declineReason,
  }) async {
    final ownerId = FirebaseAuth.instance.currentUser?.uid;
    if (ownerId == null) throw Exception('Please sign in as owner first.');
    if (status == 'declined' && declineReason.trim().isEmpty) {
      throw Exception('A decline reason is required.');
    }

    final update = <String, dynamic>{
      'status': status,
      'ownerResponse': ownerResponse.trim(),
      'statusUpdatedAt': FieldValue.serverTimestamp(),
      'statusUpdatedBy': ownerId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (status == 'approved') {
      update.addAll({
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': ownerId,
        'declineReason': '',
      });
    }
    if (status == 'declined') {
      update.addAll({
        'declinedAt': FieldValue.serverTimestamp(),
        'declinedBy': ownerId,
        'declineReason': declineReason.trim(),
      });
    }
    await _firestore.collection('bookings').doc(bookingId).update(update);
  }

  Future<void> _cancelBookingDirect(String bookingId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('Please sign in first.');
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancelledBy': userId,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
      'statusUpdatedBy': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> createBooking({
    required String serviceType,
    required String fullName,
    required String email,
    required String phone,
    required String departureCity,
    required String destination,
    required DateTime departureDate,
    required DateTime returnDate,
    required int adults,
    required int children,
    required String notes,
  }) async {
    final userId = currentUserId;
    if (userId.isEmpty) throw Exception('Please sign in before booking.');
    final document = await _firestore.collection('bookings').add({
      'userId': userId,
      'serviceType': serviceType,
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'departureCity': departureCity.trim(),
      'destination': destination.trim(),
      'departureDate': Timestamp.fromDate(departureDate),
      'returnDate': Timestamp.fromDate(returnDate),
      'adults': adults,
      'children': children,
      'status': 'new',
      'notes': notes.trim(),
      'ownerResponse': '',
      'declineReason': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return document.id;
  }
}

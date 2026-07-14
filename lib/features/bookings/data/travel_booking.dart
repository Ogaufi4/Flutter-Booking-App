import 'package:cloud_firestore/cloud_firestore.dart';

class TravelBooking {
  const TravelBooking({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.departureCity,
    required this.destination,
    required this.departureDate,
    required this.returnDate,
    required this.adults,
    required this.children,
    required this.status,
    required this.notes,
    this.createdAt,
    this.updatedAt,
    this.ownerResponse = '',
    this.declineReason = '',
    this.approvedAt,
    this.approvedBy = '',
    this.declinedAt,
    this.declinedBy = '',
    this.statusUpdatedAt,
    this.statusUpdatedBy = '',
    this.cancelledAt,
    this.cancelledBy = '',
  });

  final String id;
  final String userId;
  final String serviceType;
  final String fullName;
  final String email;
  final String phone;
  final String departureCity;
  final String destination;
  final DateTime departureDate;
  final DateTime returnDate;
  final int adults;
  final int children;
  final String status;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String ownerResponse;
  final String declineReason;
  final DateTime? approvedAt;
  final String approvedBy;
  final DateTime? declinedAt;
  final String declinedBy;
  final DateTime? statusUpdatedAt;
  final String statusUpdatedBy;
  final DateTime? cancelledAt;
  final String cancelledBy;

  String get normalizedStatus => status == 'submitted' ? 'new' : status;
  bool get canCustomerCancel =>
      normalizedStatus == 'new' || normalizedStatus == 'reviewing';

  factory TravelBooking.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};
    return TravelBooking(
      id: document.id,
      userId: data['userId']?.toString() ?? '',
      serviceType: data['serviceType']?.toString() ?? 'custom_trip',
      fullName: data['fullName']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      departureCity: data['departureCity']?.toString() ?? '',
      destination: data['destination']?.toString() ?? '',
      departureDate: _date(data['departureDate']),
      returnDate: _date(data['returnDate']),
      adults: (data['adults'] as num?)?.toInt() ?? 1,
      children: (data['children'] as num?)?.toInt() ?? 0,
      status: data['status']?.toString() ?? 'new',
      notes: data['notes']?.toString() ?? '',
      createdAt: _nullableDate(data['createdAt']),
      updatedAt: _nullableDate(data['updatedAt']),
      ownerResponse: data['ownerResponse']?.toString() ?? '',
      declineReason: data['declineReason']?.toString() ?? '',
      approvedAt: _nullableDate(data['approvedAt']),
      approvedBy: data['approvedBy']?.toString() ?? '',
      declinedAt: _nullableDate(data['declinedAt']),
      declinedBy: data['declinedBy']?.toString() ?? '',
      statusUpdatedAt: _nullableDate(data['statusUpdatedAt']),
      statusUpdatedBy: data['statusUpdatedBy']?.toString() ?? '',
      cancelledAt: _nullableDate(data['cancelledAt']),
      cancelledBy: data['cancelledBy']?.toString() ?? '',
    );
  }

  static DateTime _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _nullableDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

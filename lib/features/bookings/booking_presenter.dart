import 'package:booking_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

String bookingStatusLabel(String status) {
  switch (status == 'submitted' ? 'new' : status) {
    case 'new':
      return 'New';
    case 'reviewing':
      return 'Reviewing';
    case 'approved':
      return 'Approved';
    case 'declined':
      return 'Declined';
    case 'completed':
      return 'Completed';
    case 'cancelled':
      return 'Cancelled';
    default:
      return status;
  }
}

Color bookingStatusColor(String status) {
  switch (status == 'submitted' ? 'new' : status) {
    case 'approved':
      return AppColors.success;
    case 'completed':
      return AppColors.primarySoft;
    case 'declined':
    case 'cancelled':
      return AppColors.error;
    case 'reviewing':
      return AppColors.accent;
    default:
      return AppColors.accent;
  }
}

String bookingServiceLabel(String service) {
  const labels = <String, String>{
    'custom_trip': 'Complete trip',
    'flight': 'Flight',
    'accommodation': 'Hotel or lodge',
    'car_rental': 'Car rental',
    'holiday_package': 'Holiday package',
    'corporate_travel': 'Corporate travel',
    'group_travel': 'Group travel',
    'tour': 'Tour or activity',
    'insurance': 'Travel insurance',
    'visa_assistance': 'Visa assistance',
  };
  return labels[service] ?? 'Travel booking';
}

IconData bookingServiceIcon(String service) {
  switch (service) {
    case 'flight':
      return Icons.flight_takeoff_rounded;
    case 'accommodation':
      return Icons.hotel_outlined;
    case 'car_rental':
      return Icons.directions_car_outlined;
    case 'corporate_travel':
      return Icons.business_center_outlined;
    case 'insurance':
      return Icons.verified_user_outlined;
    case 'visa_assistance':
      return Icons.badge_outlined;
    default:
      return Icons.luggage_outlined;
  }
}

import 'package:url_launcher/url_launcher.dart';

/// Manual WhatsApp send flow: opens the WhatsApp app directly with a
/// prefilled message, falling back to wa.me in the browser when the app
/// is not installed. No automated sending happens here — the user always
/// reviews and taps send inside WhatsApp.
class WhatsAppLauncher {
  const WhatsAppLauncher._();

  /// Converts local Botswana numbers to international digits for WhatsApp.
  static String normalizeNumber(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.startsWith('0') && digits.length >= 8) {
      digits = '267${digits.substring(1)}';
    }
    if (digits.length == 8) digits = '267$digits';
    return digits;
  }

  /// Opens WhatsApp with [text] prefilled. When [phone] is provided the
  /// chat opens directly with that contact; otherwise WhatsApp shows its
  /// own contact picker (share flow).
  static Future<bool> send({String? phone, required String text}) async {
    final target =
        (phone == null || phone.trim().isEmpty) ? '' : normalizeNumber(phone);
    final encoded = Uri.encodeComponent(text);
    final direct = Uri.parse(
        'whatsapp://send?${target.isNotEmpty ? 'phone=$target&' : ''}text=$encoded');
    try {
      if (await launchUrl(direct,
          mode: LaunchMode.externalNonBrowserApplication)) {
        return true;
      }
    } catch (_) {}
    final fallback = Uri.parse('https://wa.me/$target?text=$encoded');
    try {
      return await launchUrl(fallback, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

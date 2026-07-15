import 'package:booking_app/core/notifications/notification_service.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/utils/shared_preferences/shared_preferences_helper.dart';
import 'package:booking_app/core/utils/widgets/toast.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_icon_button.dart';
import 'package:booking_app/core/widgets/luxury_text_field.dart';
import 'package:booking_app/data/database/user_helper.dart';
import 'package:booking_app/data/models/basic_model.dart';
import 'package:booking_app/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({Key? key}) : super(key: key);

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final _phoneController = TextEditingController(text: '+267');
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _verificationId;
  bool _sendingCode = false;
  bool _verifyingCode = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _sendingCode = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _normalizePhone(_phoneController.text),
        verificationCompleted: (credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) await _onSignedIn();
        },
        verificationFailed: (error) {
          customToast(
            title: error.message ?? 'Phone verification failed',
            color: AppColors.error,
          );
        },
        codeSent: (verificationId, _) {
          setState(() => _verificationId = verificationId);
          customToast(
              title: 'OTP sent to your phone', color: AppColors.primary);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      customToast(
        title: e.toString().replaceFirst('Exception: ', ''),
        color: AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _sendingCode = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null || _codeController.text.trim().isEmpty) {
      customToast(title: 'Enter the OTP code first', color: AppColors.error);
      return;
    }
    setState(() => _verifyingCode = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await _onSignedIn();
    } on FirebaseAuthException catch (e) {
      customToast(
          title: e.message ?? 'Invalid OTP code', color: AppColors.error);
    } catch (e) {
      customToast(
        title: e.toString().replaceFirst('Exception: ', ''),
        color: AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _verifyingCode = false);
    }
  }

  Future<void> _onSignedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = user.phoneNumber ?? 'Travel365 Traveller';
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': name,
      'email': user.email ?? '',
      'phone': user.phoneNumber ?? _normalizePhone(_phoneController.text),
      'role': 'customer',
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final localUser = UserModel(
      id: user.uid.hashCode,
      name: name,
      email: user.email ?? '',
      apiToken: user.uid,
      image: '',
    );

    final helper = UserHelper();
    await helper.deleteAll();
    helper.savePost(localUser);
    await addStringToSF('userID', user.uid);
    await addStringToSF('name', name);
    await addStringToSF('userToken', user.uid);
    await addStringToSF('userImage', '');

    BasicModel.userID = user.uid;
    BasicModel.name = name;
    BasicModel.userToken = user.uid;
    BasicModel.userImage = '';
    BasicModel.isLogin = true;

    await NotificationService.instance.registerCurrentDevice();

    if (!mounted) return;
    customToast(title: 'Welcome', color: AppColors.primary);
    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
  }

  String _normalizePhone(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9+]'), '').trim();
    if (digits.startsWith('+')) return digits;
    if (digits.startsWith('267')) return '+$digits';
    return '+267$digits';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    LuxuryIconButton(
                      icon: Icons.arrow_back_rounded,
                      semanticLabel: 'Back',
                      onPressed: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    SvgPicture.asset(
                      'assets/images/travel365_logo.svg',
                      width: 112,
                      semanticsLabel: 'Travel365 logo',
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                const Text(
                  'Verify with OTP',
                  style: AppTypography.displayMedium,
                ),
                const SizedBox(height: 10),
                const Text(
                  'We will send a code to your phone for secure sign-in and booking updates.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 26),
                LuxuryCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.accentSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sms_outlined,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _verificationId == null
                              ? 'Enter your WhatsApp-capable number to receive a one-time code.'
                              : 'Code sent. Enter the 6-digit OTP to continue.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                LuxuryTextField(
                  controller: _phoneController,
                  label: 'Phone number',
                  hintText: '+2677xxxxxxx',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android_rounded,
                  validator: (value) {
                    if (value == null || value.trim().length < 8) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                if (_verificationId != null) ...[
                  LuxuryTextField(
                    controller: _codeController,
                    label: 'OTP code',
                    hintText: '123456',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.lock_outline_rounded,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 22),
                  LuxuryButton(
                    label: 'Confirm OTP',
                    icon: Icons.verified_user_outlined,
                    isLoading: _verifyingCode,
                    onPressed: _verifyingCode ? null : _verifyCode,
                  ),
                  const SizedBox(height: 8),
                  LuxuryButton(
                    label: 'Send a new code',
                    variant: LuxuryButtonVariant.text,
                    icon: Icons.refresh_rounded,
                    isLoading: _sendingCode,
                    onPressed: _sendingCode ? null : _sendCode,
                  ),
                ] else ...[
                  LuxuryButton(
                    label: 'Send OTP',
                    icon: Icons.sms_outlined,
                    isLoading: _sendingCode,
                    onPressed: _sendingCode ? null : _sendCode,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

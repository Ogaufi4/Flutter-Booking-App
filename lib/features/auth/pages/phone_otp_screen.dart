import 'package:booking_app/core/notifications/notification_service.dart';
import 'package:booking_app/core/utils/local/cash_helper.dart';
import 'package:booking_app/core/utils/shared_preferences/shared_preferences_helper.dart';
import 'package:booking_app/core/utils/widgets/toast.dart';
import 'package:booking_app/data/database/user_helper.dart';
import 'package:booking_app/data/models/basic_model.dart';
import 'package:booking_app/data/models/user_model.dart';
import 'package:booking_app/resources/constants/constants.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
            color: OwnTheme.colorPalette['danger']!,
          );
        },
        codeSent: (verificationId, _) {
          setState(() => _verificationId = verificationId);
          customToast(
            title: 'OTP sent to your phone',
            color: OwnTheme.colorPalette['primary']!,
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      customToast(
        title: e.toString().replaceFirst('Exception: ', ''),
        color: OwnTheme.colorPalette['danger']!,
      );
    } finally {
      if (mounted) setState(() => _sendingCode = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null || _codeController.text.trim().isEmpty) {
      customToast(
        title: 'Enter the OTP code first',
        color: OwnTheme.colorPalette['danger']!,
      );
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
        title: e.message ?? 'Invalid OTP code',
        color: OwnTheme.colorPalette['danger']!,
      );
    } catch (e) {
      customToast(
        title: e.toString().replaceFirst('Exception: ', ''),
        color: OwnTheme.colorPalette['danger']!,
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
    customToast(
      title: 'Welcome',
      color: OwnTheme.colorPalette['primary']!,
    );
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
      backgroundColor: OwnTheme.colorPalette['bg'],
      appBar: AppBar(
        title: const Text('Phone login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(side, 20, side, bottom),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify with OTP',
                style: OwnTheme.titleBoldTextStyle(lang: lang).copyWith(
                  color: OwnTheme.colorPalette['secondary'],
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We will send a code to your phone for Travel365 alerts and booking confirmations.',
                style: OwnTheme.normalTextStyle(lang: lang).copyWith(
                  color: OwnTheme.colorPalette['gray'],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Phone number',
                style: OwnTheme.normalBoldTextStyle(lang: lang).copyWith(
                  color: OwnTheme.colorPalette['black'],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: OwnTheme.colorPalette['black']),
                validator: (value) {
                  if (value == null || value.trim().length < 8) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: '+2677xxxxxxx',
                  prefixIcon: Icon(
                    Icons.phone_android_rounded,
                    color: OwnTheme.colorPalette['secondary'],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_verificationId != null) ...[
                Text(
                  'OTP code',
                  style: OwnTheme.normalBoldTextStyle(lang: lang).copyWith(
                    color: OwnTheme.colorPalette['black'],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: TextStyle(color: OwnTheme.colorPalette['black']),
                  decoration: InputDecoration(
                    hintText: '123456',
                    counterText: '',
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: OwnTheme.colorPalette['secondary'],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyingCode ? null : _verifyCode,
                    child: _verifyingCode
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirm OTP'),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sendingCode ? null : _sendCode,
                    child: _sendingCode
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send OTP'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

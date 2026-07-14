import 'package:booking_app/core/localization/setup/app_localization.dart';
import 'package:booking_app/core/utils/local/cash_helper.dart';
import 'package:booking_app/core/utils/widgets/toast.dart';
import 'package:booking_app/features/login/bloc/login_cubit.dart';
import 'package:booking_app/resources/buttonkey/button.dart';
import 'package:booking_app/resources/constants/constants.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final emailController = TextEditingController(text: 'demo@travel365.com');
  final passwordController = TextEditingController(text: 'demo123');
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginStates>(
      listener: (context, state) {
        if (state is LoginErrorState) {
          customToast(
            title: state.error.replaceFirst('Exception: ', ''),
            color: OwnTheme.colorPalette['danger']!,
          );
        }
        if (state is LoginSuccessState) {
          CashHelper.saveData(key: 'token', value: state.model.apiToken);
          CashHelper.saveData(key: 'userId', value: state.model.id);
          customToast(
            title: 'Welcome',
            color: OwnTheme.colorPalette['primary']!,
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main',
            (Route<dynamic> route) => false,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(side, 12, side, bottom),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: OwnTheme.colorPalette['secondary'],
                      ),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: OwnTheme.colorPalette['secondary'],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.flight_takeoff_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'fontEnBold',
                              fontSize: 24,
                            ),
                            children: [
                              TextSpan(
                                text: 'Travel',
                                style: TextStyle(
                                  color: OwnTheme.colorPalette['secondary'],
                                ),
                              ),
                              TextSpan(
                                text: '365',
                                style: TextStyle(
                                  color: OwnTheme.colorPalette['primary'],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 42),
                    Text(
                      'Login_txt'.tr(context),
                      style: OwnTheme.titleBoldTextStyle(lang: lang).copyWith(
                        color: OwnTheme.colorPalette['secondary'],
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back. Sign in to continue planning your trip.',
                      style: OwnTheme.normalTextStyle(lang: lang).copyWith(
                        color: OwnTheme.colorPalette['gray'],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _FieldLabel(text: 'email_title_txt'.tr(context)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: OwnTheme.colorPalette['black']),
                      validator: (value) => value == null || value.isEmpty
                          ? 'email_table'.tr(context)
                          : null,
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: OwnTheme.colorPalette['secondary'],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel(text: 'password_txt'.tr(context)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: LoginCubit.get(context).isPassword,
                      style: TextStyle(color: OwnTheme.colorPalette['black']),
                      validator: (value) => value == null || value.isEmpty
                          ? 'password_table'.tr(context)
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: OwnTheme.colorPalette['secondary'],
                        ),
                        suffixIcon: IconButton(
                          onPressed: LoginCubit.get(context).ChangePassword,
                          icon: Icon(
                            LoginCubit.get(context).suffix,
                            color: OwnTheme.colorPalette['gray'],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Login_Title'.tr(context),
                        style:
                            OwnTheme.normalBoldTextStyle(lang: lang).copyWith(
                          color: OwnTheme.colorPalette['secondary'],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ButtonKey(
                      buttonText: 'Button_Login'.tr(context),
                      isLoading: state is LoginLoadingState,
                      function: () {
                        if (formKey.currentState!.validate()) {
                          FocusScope.of(context).unfocus();
                          LoginCubit.get(context).login(
                            email: emailController.text,
                            pass: passwordController.text,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/otp'),
                        child: Text(
                          'Use phone OTP instead',
                          style: OwnTheme.normalBoldTextStyle(lang: lang)
                              .copyWith(
                            color: OwnTheme.colorPalette['primary'],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: OwnTheme.colorPalette['surfaceAlt'],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: OwnTheme.colorPalette['border']!,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo account',
                            style: OwnTheme.normalBoldTextStyle(lang: lang)
                                .copyWith(
                              color: OwnTheme.colorPalette['secondary'],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'demo@travel365.com  •  demo123',
                            style:
                                OwnTheme.normalTextStyle(lang: lang).copyWith(
                              color: OwnTheme.colorPalette['gray'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: OwnTheme.normalBoldTextStyle(lang: lang).copyWith(
        color: OwnTheme.colorPalette['black'],
      ),
    );
  }
}

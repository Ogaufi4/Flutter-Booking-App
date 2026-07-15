import 'package:booking_app/core/localization/setup/app_localization.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/utils/local/cash_helper.dart';
import 'package:booking_app/core/utils/widgets/toast.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_icon_button.dart';
import 'package:booking_app/core/widgets/luxury_text_field.dart';
import 'package:booking_app/features/login/bloc/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: 'demo@travel365.com');
  final passwordController = TextEditingController(text: 'demo123');
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginStates>(
      listener: (context, state) {
        if (state is LoginErrorState) {
          customToast(
            title: state.error.replaceFirst('Exception: ', ''),
            color: AppColors.error,
          );
        }
        if (state is LoginSuccessState) {
          CashHelper.saveData(key: 'token', value: state.model.apiToken);
          CashHelper.saveData(key: 'userId', value: state.model.id);
          customToast(title: 'Welcome', color: AppColors.primary);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main',
            (Route<dynamic> route) => false,
          );
        }
      },
      builder: (context, state) {
        final cubit = LoginCubit.get(context);
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LuxuryIconButton(
                      icon: Icons.arrow_back_rounded,
                      semanticLabel: 'Back',
                      onPressed: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 30),
                    const _AuthLogo(),
                    const SizedBox(height: 38),
                    Text(
                      'Login_txt'.tr(context),
                      style: AppTypography.displayMedium,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Welcome back. Sign in to continue planning your trip.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 30),
                    LuxuryTextField(
                      controller: emailController,
                      label: 'email_title_txt'.tr(context),
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (value) => value == null || value.isEmpty
                          ? 'email_table'.tr(context)
                          : null,
                    ),
                    const SizedBox(height: 18),
                    LuxuryTextField(
                      controller: passwordController,
                      label: 'password_txt'.tr(context),
                      hintText: 'Enter your password',
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: cubit.isPassword,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        onPressed: cubit.ChangePassword,
                        icon: Icon(
                          cubit.suffix,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'password_table'.tr(context)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Login_Title'.tr(context),
                        style: AppTypography.button.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    LuxuryButton(
                      label: 'Button_Login'.tr(context),
                      icon: Icons.login_rounded,
                      isLoading: state is LoginLoadingState,
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          FocusScope.of(context).unfocus();
                          cubit.login(
                            email: emailController.text,
                            pass: passwordController.text,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    LuxuryButton(
                      label: 'Use phone OTP instead',
                      variant: LuxuryButtonVariant.text,
                      icon: Icons.phone_android_rounded,
                      onPressed: () => Navigator.pushNamed(context, '/otp'),
                    ),
                    const SizedBox(height: 18),
                    const _DemoAccountCard(),
                    const SizedBox(height: 22),
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            'New to Travel365? ',
                            style: AppTypography.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/register',
                            ),
                            child: Text(
                              'Create an account',
                              style: AppTypography.button.copyWith(
                                color: AppColors.primary,
                              ),
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

class _AuthLogo extends StatelessWidget {
  const _AuthLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/travel365_logo.svg',
          width: 118,
          semanticsLabel: 'Travel365 logo',
        ),
        const Spacer(),
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: AppColors.accentSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.flight_takeoff_rounded,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _DemoAccountCard extends StatelessWidget {
  const _DemoAccountCard();

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.key_rounded,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Demo account', style: AppTypography.label),
                const SizedBox(height: 4),
                Text(
                  'demo@travel365.com - demo123',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

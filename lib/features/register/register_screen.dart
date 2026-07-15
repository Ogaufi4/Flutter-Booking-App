import 'package:booking_app/core/localization/setup/app_localization.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/utils/local/cash_helper.dart';
import 'package:booking_app/core/utils/widgets/toast.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_icon_button.dart';
import 'package:booking_app/core/widgets/luxury_text_field.dart';
import 'package:booking_app/data/models/user_model.dart';
import 'package:booking_app/features/register/bloc/register_cubit.dart';
import 'package:booking_app/features/register/bloc/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterStates>(
      listener: (context, state) {
        if (state is RegisterErrorState) {
          customToast(
            title: state.error.replaceFirst('Exception: ', ''),
            color: AppColors.error,
          );
        }
        if (state is RegisterSuccessState) {
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
        final cubit = RegisterCubit.get(context);
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
                    Row(
                      children: [
                        LuxuryIconButton(
                          icon: Icons.arrow_back_rounded,
                          semanticLabel: 'Back',
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
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
                    Text(
                      'sign_up_txt'.tr(context),
                      style: AppTypography.displayMedium,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Create a Travel365 profile for bookings, receipts and trip updates.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    LuxuryCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          LuxuryTextField(
                            controller: firstNameController,
                            label: 'first_name_txt'.tr(context),
                            hintText: 'Box_First_Text'.tr(context),
                            keyboardType: TextInputType.name,
                            prefixIcon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'first_table_txt'.tr(context)
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          LuxuryTextField(
                            controller: lastNameController,
                            label: 'last_name_txt'.tr(context),
                            hintText: 'Box_Last_Text'.tr(context),
                            keyboardType: TextInputType.name,
                            prefixIcon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'last_table_txt'.tr(context)
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          LuxuryTextField(
                            controller: emailController,
                            label: 'email_title_txt'.tr(context),
                            hintText: 'Eg.example@gmail.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'email_table'.tr(context)
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          LuxuryTextField(
                            controller: passwordController,
                            label: 'password_txt'.tr(context),
                            hintText: 'Box_Password_Text'.tr(context),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    LuxuryButton(
                      label: 'Button_Register'.tr(context),
                      icon: Icons.person_add_alt_1_rounded,
                      isLoading: state is RegisterLoadingState,
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        FocusScope.of(context).unfocus();
                        final firstName = firstNameController.text.trim();
                        final lastName = lastNameController.text.trim();
                        final user = UserModel(
                          name: '$firstName $lastName',
                          email: emailController.text.trim(),
                          password: passwordController.text,
                          passwordConfirmation: passwordController.text,
                        );
                        cubit.register(obj: user);
                      },
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'first_text'.tr(context),
                            style: AppTypography.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/login'),
                            child: Text(
                              'last_text'.tr(context),
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

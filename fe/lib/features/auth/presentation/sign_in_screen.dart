import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/link_button.dart';
import '../../../core/widgets/primary_button.dart';
import 'auth_providers.dart';

const _phoneLength = 10;

/// Staff sign-in with phone and password; the route guard navigates on success.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  String? phoneError;
  String? passwordError;
  bool isPasswordVisible = false;

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void submit() {
    final phone = phoneController.text;
    final password = passwordController.text;
    setState(() {
      phoneError = phoneText(phone);
      passwordError = passwordText(password);
    });
    if (phoneError != null || passwordError != null) return;
    ref
        .read(signInControllerProvider.notifier)
        .submit(phone: phone, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final attempt = ref.watch(signInControllerProvider);
    final failure = attempt.error;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter,
            vertical: AppSpacing.xxl,
          ),
          children: [
            const Eyebrow('SAROORNAGAR BOXING'),
            const SizedBox(height: AppSpacing.sm),
            const Text('Sign in', style: AppTypography.title),
            const SizedBox(height: AppSpacing.xs),
            const Text('Staff and coaches only.', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              controller: phoneController,
              label: 'Phone number',
              prefixText: '+91 ',
              keyboardType: TextInputType.phone,
              maxLength: _phoneLength,
              textInputAction: TextInputAction.next,
              errorText: phoneError,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: passwordController,
              label: 'Password',
              obscureText: !isPasswordVisible,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => submit(),
              errorText: passwordError,
              suffix: IconButton(
                tooltip: isPasswordVisible ? 'Hide password' : 'Show password',
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (failure != null) ...[
              InlineBanner(
                message: _failureMessage(failure),
                tone: InlineBannerTone.error,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            PrimaryButton(
              label: 'Sign in',
              onPressed: submit,
              isBusy: attempt.isLoading,
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: LinkButton(
                label: 'Want to try a session? Book a trial',
                onPressed: () => context.push(Routes.trial).ignore(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _failureMessage(Object failure) => switch (failure) {
  AuthFailedException() => 'That phone number and password do not match.',
  OfflineException() => 'You are offline. Check the connection and try again.',
  AppException(:final message) => message,
  _ => UnknownException.defaultMessage,
};

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/brand_badge.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/link_button.dart';
import '../../../core/widgets/primary_button.dart';
import 'auth_providers.dart';

/// Staff sign-in with email and password; the route guard navigates on success.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? emailError;
  String? passwordError;
  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void submit() {
    final email = emailController.text;
    final password = passwordController.text;
    setState(() {
      emailError = emailText(email);
      passwordError = passwordText(password);
    });
    if (emailError != null || passwordError != null) return;
    ref
        .read(signInControllerProvider.notifier)
        .submit(email: email, password: password);
  }

  void openForgotPassword() {
    final email = emailController.text.trim();
    context
        .push(Routes.forgotPassword, extra: email.isEmpty ? null : email)
        .ignore();
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
            const BrandBadge(),
            const SizedBox(height: AppSpacing.xl),
            const Eyebrow('SAROORNAGAR BOXING'),
            const SizedBox(height: AppSpacing.sm),
            const Text('Sign in', style: AppTypography.title),
            const SizedBox(height: AppSpacing.xs),
            const Text('Staff and coaches only.', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              controller: emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              errorText: emailError,
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
                label: 'Forgot password?',
                onPressed: openForgotPassword,
              ),
            ),
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
  AuthFailedException() => 'That email and password do not match.',
  OfflineException() => 'You are offline. Check the connection and try again.',
  AppException(:final message) => message,
  _ => UnknownException.defaultMessage,
};

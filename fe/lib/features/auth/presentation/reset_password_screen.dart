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

const _codeLength = 6;
final _codePattern = RegExp(r'^\d{6}$');

/// Takes the emailed recovery code and a new password; the new session redirects.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  /// The normalized address the code was sent to.
  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  String? codeError;
  String? passwordError;
  String? confirmError;
  bool isPasswordVisible = false;

  @override
  void dispose() {
    codeController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (ref.read(passwordResetControllerProvider).isLoading) return;
    final code = codeController.text.trim();
    final password = passwordController.text;
    setState(() {
      codeError = _codePattern.hasMatch(code)
          ? null
          : 'Enter the 6-digit code from the email';
      passwordError = passwordText(password);
      confirmError = confirmController.text == password
          ? null
          : 'The passwords do not match';
    });
    if (codeError != null || passwordError != null || confirmError != null) {
      return;
    }
    // The root messenger outlives this screen, which the new session replaces.
    final messenger = ScaffoldMessenger.of(context);
    final failure = await ref
        .read(passwordResetControllerProvider.notifier)
        .complete(email: widget.email, code: code, newPassword: password);
    if (failure == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Password updated')));
    } else if (!mounted) {
      // Signed in by the code but the password change failed: no banner is left.
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  Future<void> resend() async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(passwordResetRequestControllerProvider.notifier);
    final isSent = await notifier.send(widget.email);
    if (!mounted) return;
    final message = isSent
        ? 'Code sent'
        : _failureMessage(
            ref.read(passwordResetRequestControllerProvider).error,
          );
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final attempt = ref.watch(passwordResetControllerProvider);
    final resendRequest = ref.watch(passwordResetRequestControllerProvider);
    final failure = attempt.isLoading ? null : attempt.error;
    final canPop = context.canPop();
    return Scaffold(
      appBar: canPop ? AppBar() : null,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            canPop ? AppSpacing.sm : AppSpacing.xxl,
            AppSpacing.gutter,
            AppSpacing.xxl,
          ),
          children: [
            const Eyebrow('SAROORNAGAR BOXING'),
            const SizedBox(height: AppSpacing.sm),
            const Text('Reset password', style: AppTypography.title),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Enter the code from the email and choose a new password.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              controller: codeController,
              label: 'Code',
              keyboardType: TextInputType.number,
              autocorrect: false,
              maxLength: _codeLength,
              textInputAction: TextInputAction.next,
              errorText: codeError,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: passwordController,
              label: 'New password',
              obscureText: !isPasswordVisible,
              autocorrect: false,
              textInputAction: TextInputAction.next,
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
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: confirmController,
              label: 'Confirm password',
              obscureText: !isPasswordVisible,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => submit(),
              errorText: confirmError,
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
              label: 'Set new password',
              onPressed: submit,
              isBusy: attempt.isLoading,
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: LinkButton(
                label: 'Send a new code',
                onPressed: resendRequest.isLoading ? null : resend,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: LinkButton(
                label: 'Back to sign in',
                onPressed: () => context.go(Routes.signIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _failureMessage(Object? failure) =>
    failure is AppException ? failure.message : UnknownException.defaultMessage;

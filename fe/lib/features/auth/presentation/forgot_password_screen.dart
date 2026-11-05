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

/// Asks for a recovery code by email, then moves on to the reset screen.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  /// What was typed on the sign-in screen, if anything.
  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final emailController = TextEditingController(text: widget.initialEmail);
  String? emailError;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final email = emailController.text;
    setState(() => emailError = emailText(email));
    if (emailError != null) return;
    final isSent = await ref
        .read(passwordResetRequestControllerProvider.notifier)
        .send(email);
    // The server answers the same for an unknown email, so every success moves on.
    if (isSent && mounted) {
      context.go(Routes.resetPassword, extra: normalizeEmail(email));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = ref.watch(passwordResetRequestControllerProvider);
    final failure = request.isLoading ? null : request.error;
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
              'We will email you a 6-digit code.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              controller: emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => send(),
              errorText: emailError,
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
              label: 'Send code',
              onPressed: send,
              isBusy: request.isLoading,
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

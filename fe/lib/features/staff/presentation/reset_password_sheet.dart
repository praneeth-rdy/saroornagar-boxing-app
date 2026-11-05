import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/domain/staff_profile.dart';
import 'staff_providers.dart';

const _passwordMaxLength = 72;

/// Opens [ResetPasswordSheet] for [member]; a success closes it with a snackbar.
Future<void> showResetPasswordSheet(
  BuildContext context,
  StaffProfile member,
) async {
  final isReset = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.ground,
    builder: (_) => ResetPasswordSheet(member: member),
  );
  if (isReset != true || !context.mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Password reset')));
}

/// A new password, typed twice, for one staff member.
class ResetPasswordSheet extends ConsumerStatefulWidget {
  const ResetPasswordSheet({super.key, required this.member});

  final StaffProfile member;

  @override
  ConsumerState<ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends ConsumerState<ResetPasswordSheet> {
  final password = TextEditingController();
  final confirmation = TextEditingController();
  var isPasswordVisible = false;

  /// Field errors show only after the first submit.
  var isSubmitted = false;

  @override
  void initState() {
    super.initState();
    password.addListener(revalidate);
    confirmation.addListener(revalidate);
  }

  @override
  void dispose() {
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  void revalidate() {
    if (isSubmitted) setState(() {});
  }

  String? get confirmationError =>
      confirmation.text == password.text ? null : 'The passwords do not match';

  Future<void> submit() async {
    setState(() => isSubmitted = true);
    if (passwordText(password.text) != null || confirmationError != null) {
      return;
    }
    final isReset = await ref
        .read(resetPasswordControllerProvider(widget.member.id).notifier)
        .reset(password.text);
    if (isReset && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final submission = ref.watch(
      resetPasswordControllerProvider(widget.member.id),
    );
    final failure = submission.isLoading ? null : submission.error;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.xl,
          AppSpacing.gutter,
          AppSpacing.gutter + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Reset password', style: AppTypography.heading),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'A new password for ${widget.member.fullName}.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: password,
              label: 'New password',
              obscureText: !isPasswordVisible,
              maxLength: _passwordMaxLength,
              textInputAction: TextInputAction.next,
              errorText: isSubmitted ? passwordText(password.text) : null,
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
              controller: confirmation,
              label: 'Confirm password',
              obscureText: !isPasswordVisible,
              maxLength: _passwordMaxLength,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => submit(),
              errorText: isSubmitted ? confirmationError : null,
            ),
            if (failure != null) ...[
              const SizedBox(height: AppSpacing.md),
              InlineBanner(
                message: failure is AppException
                    ? failure.message
                    : UnknownException.defaultMessage,
                tone: InlineBannerTone.error,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Reset',
              onPressed: submit,
              isBusy: submission.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

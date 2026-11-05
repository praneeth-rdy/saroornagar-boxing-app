import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'sign_out_button.dart';

/// Shown instead of the app when the server reports the staff member as blocked.
class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key})
    : title = 'Access blocked',
      message = 'Ask the club admin to restore your access.';

  /// A signed-in account with no staff profile.
  const BlockedScreen.notStaff({super.key})
    : title = 'Not a staff account',
      message = 'This account is not set up for staff.';

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.stateViewMaxWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.heading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    message,
                    style: AppTypography.body.copyWith(color: AppColors.muted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SignOutButton(isExpanded: false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

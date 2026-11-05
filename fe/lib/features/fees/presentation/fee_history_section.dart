import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/link_button.dart';
import '../../../core/widgets/list_row.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../today/presentation/today_providers.dart';
import '../domain/fee_payment.dart';
import 'fee_providers.dart';

/// A trainee's fee payments, with recording and the short undo window.
class FeeHistorySection extends ConsumerWidget {
  const FeeHistorySection({super.key, required this.traineeId});

  final String traineeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(feeHistoryProvider(traineeId));
    final removal = ref.watch(deletePaymentControllerProvider(traineeId));
    final removalFailure = removal.isLoading ? null : removal.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('Fees'),
        const SizedBox(height: AppSpacing.sm),
        PrimaryButton(
          label: 'Record payment',
          onPressed: () => context.push(Routes.recordPaymentOf(traineeId)),
        ),
        if (removalFailure != null) ...[
          const SizedBox(height: AppSpacing.md),
          InlineBanner(
            message: _messageOf(removalFailure),
            tone: InlineBannerTone.error,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        payments.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: LoadingView(),
          ),
          error: (error, _) => InlineBanner(
            message: _messageOf(error),
            tone: InlineBannerTone.error,
            onRetry: () => ref.invalidate(feeHistoryProvider(traineeId)),
          ),
          data: (loaded) => _PaymentsCard(
            traineeId: traineeId,
            payments: loaded,
            isRemoving: removal.isLoading,
          ),
        ),
      ],
    );
  }
}

class _PaymentsCard extends ConsumerWidget {
  const _PaymentsCard({
    required this.traineeId,
    required this.payments,
    required this.isRemoving,
  });

  final String traineeId;
  final List<FeePayment> payments;
  final bool isRemoving;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (payments.isEmpty) {
      return const AppCard(
        child: Text('No payments recorded yet', style: AppTypography.caption),
      );
    }
    final now = ref.watch(clockProvider)();
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: ListRow.divide([
          for (final payment in payments)
            ListRow(
              title: DateFormat('MMMM yyyy').format(payment.periodMonth),
              subtitle: _paymentDetails(payment),
              trailing: payment.canDeleteAt(now)
                  ? IconButton(
                      tooltip: 'Remove payment',
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.muted,
                      ),
                      onPressed: isRemoving
                          ? null
                          : () => _confirmRemove(context, ref, payment),
                    )
                  : null,
            ),
        ]),
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    FeePayment payment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove this payment?'),
        content: Text(
          '${payment.amount} for '
          '${DateFormat('MMMM yyyy').format(payment.periodMonth)} is removed '
          'from the record. Payments can be removed up to 7 days after '
          'they are recorded.',
        ),
        actions: [
          LinkButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          LinkButton(
            label: 'Remove',
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(deletePaymentControllerProvider(traineeId).notifier)
        .delete(payment.id);
  }
}

/// `800 · Cash · paid 3 Nov`, with the note on the next line.
String _paymentDetails(FeePayment payment) {
  final line =
      '${payment.amount} · ${paymentMethodLabel(payment.method)} · '
      'paid ${DateFormat('d MMM').format(payment.paidOn)}';
  final note = payment.note;
  return note == null ? line : '$line\n$note';
}

String _messageOf(Object error) =>
    error is AppException ? error.message : UnknownException.defaultMessage;

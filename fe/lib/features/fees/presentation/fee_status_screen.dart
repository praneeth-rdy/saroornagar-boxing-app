import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/avatar_initials.dart';
import '../../../core/widgets/link_button.dart';
import '../../../core/widgets/list_row.dart';
import '../../../core/widgets/state_views.dart';
import '../../today/presentation/today_providers.dart';
import '../../trainees/presentation/trainee_providers.dart';
import '../domain/fee_status.dart';
import 'fee_providers.dart';
import 'month_navigator.dart';

/// Who has paid for a month and who has not, unpaid first.
class FeeStatusScreen extends ConsumerStatefulWidget {
  const FeeStatusScreen({super.key});

  @override
  ConsumerState<FeeStatusScreen> createState() => _FeeStatusScreenState();
}

class _FeeStatusScreenState extends ConsumerState<FeeStatusScreen> {
  late final DateTime currentMonth;
  late DateTime month;

  @override
  void initState() {
    super.initState();
    currentMonth = monthOf(ref.read(clockProvider)());
    month = currentMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fee status')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.sm,
              AppSpacing.gutter,
              AppSpacing.md,
            ),
            child: MonthNavigator(
              month: month,
              latest: currentMonth,
              onChanged: (next) => setState(() => month = next),
            ),
          ),
          Expanded(
            child: AsyncValueView<List<FeeStatus>>(
              value: ref.watch(feeStatusProvider(month)),
              onRetry: () => ref.invalidate(feeStatusProvider(month)),
              isEmpty: (statuses) => statuses.isEmpty,
              empty: EmptyView(
                title: 'No active trainees',
                message: 'Fee status lists active trainees.',
                actionLabel: 'Go to Trainees',
                onAction: () => context.go(Routes.trainees),
              ),
              data: (statuses) =>
                  _FeeStatusList(statuses: statuses, month: month),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeStatusList extends StatelessWidget {
  const _FeeStatusList({required this.statuses, required this.month});

  final List<FeeStatus> statuses;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final paid = statuses.where((status) => status.isPaid).length;
    final unpaid = statuses.length - paid;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: [
        Text('$unpaid unpaid · $paid paid', style: AppTypography.caption),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: ListRow.divide([
              for (final status in statuses)
                _FeeStatusRow(status: status, month: month),
            ]),
          ),
        ),
      ],
    );
  }
}

class _FeeStatusRow extends ConsumerWidget {
  const _FeeStatusRow({required this.status, required this.month});

  final FeeStatus status;
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoPath = status.photoPath;
    final photoUrl = photoPath == null
        ? null
        : ref.watch(traineePhotoUrlProvider(photoPath)).value;
    void openRecord() =>
        context.push(Routes.recordPaymentOf(status.traineeId, month: month));
    // Partly paid rows keep the link; without a tier only "nothing paid" is known.
    final outstanding = status.outstanding;
    final isOwing = outstanding == null ? !status.isPaid : outstanding > 0;
    return ListRow(
      leading: AvatarInitials(name: status.fullName, photoUrl: photoUrl),
      title: status.fullName,
      subtitle: feeStatusSubtitle(status),
      trailing: isOwing
          ? LinkButton(label: 'Record', onPressed: openRecord)
          : null,
      onTap: openRecord,
    );
  }
}

/// `Paid 800 on 3 Nov`, `Partly paid 500 of 800`, `Unpaid · 800 due`, or the missing tier.
String feeStatusSubtitle(FeeStatus status) {
  final tier = status.tierAmount;
  final paid = status.paidAmount;
  if (!status.isPaid) {
    return tier == null
        ? 'No date of birth, tier unknown'
        : 'Unpaid · $tier due';
  }
  if (tier != null && paid < tier) return 'Partly paid $paid of $tier';
  final lastPaidOn = status.lastPaidOn;
  return lastPaidOn == null
      ? 'Paid $paid'
      : 'Paid $paid on ${DateFormat('d MMM').format(lastPaidOn)}';
}

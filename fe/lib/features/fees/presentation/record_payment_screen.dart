import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/payment_method.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/india_date.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/choice_row.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/link_button.dart';
import '../../../core/widgets/list_row.dart';
import '../../../core/widgets/primary_button.dart';
import '../../today/presentation/today_providers.dart';
import '../../trainees/domain/trainee.dart';
import '../../trainees/presentation/trainee_avatar.dart';
import '../../trainees/presentation/trainee_providers.dart';
import 'fee_providers.dart';

// Same note limit and method message as `record_fee_payment`.
const _noteMaxLength = 300;
const _noteLines = 4;
const _methodMessage = 'Choose cash or UPI';
const _amountMessage = 'Choose $juniorFee or $seniorFee';

// Arrears are recorded late, but not years late; the server sets no lower bound.
const _paidOnLookbackYears = 1;

const _iconSize = 20.0;

const _amounts = [
  ChoiceOption(value: juniorFee, label: '$juniorFee', caption: 'Junior'),
  ChoiceOption(value: seniorFee, label: '$seniorFee', caption: 'Senior'),
];

const _methods = [
  ChoiceOption(value: PaymentMethod.cash, label: 'Cash'),
  ChoiceOption(value: PaymentMethod.upi, label: 'UPI'),
];

final _dateFormat = DateFormat('d MMM yyyy');
final _monthFormat = DateFormat('MMM yyyy');

/// Records a fee payment for one trainee; [month] preselects the period.
class RecordPaymentScreen extends ConsumerWidget {
  const RecordPaymentScreen({super.key, required this.traineeId, this.month});

  final String traineeId;

  /// The first day of the period month, or null for the current month.
  final DateTime? month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record payment')),
      body: AsyncValueView<Trainee>(
        value: ref.watch(traineeProvider(traineeId)),
        onRetry: () => ref.invalidate(traineeProvider(traineeId)),
        data: (trainee) => _PaymentForm(trainee: trainee, month: month),
      ),
    );
  }
}

class _PaymentForm extends ConsumerStatefulWidget {
  const _PaymentForm({required this.trainee, required this.month});

  final Trainee trainee;
  final DateTime? month;

  @override
  ConsumerState<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<_PaymentForm> {
  late final DateTime today;
  late final DateTime currentMonth;

  /// Advance payments may name next month, never later.
  late final DateTime latestMonth;
  late final TextEditingController note;
  late DateTime paidOn;
  late DateTime periodMonth;
  int? amount;
  PaymentMethod? method;
  var isNoteOpen = false;

  /// Field errors show only after the first submit.
  var isSubmitted = false;

  @override
  void initState() {
    super.initState();
    today = dateOnly(ref.read(clockProvider)());
    currentMonth = monthOf(today);
    latestMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    amount = widget.trainee.feeTierOn(today);
    note = TextEditingController();
    paidOn = today;
    final month = widget.month;
    periodMonth = month == null || month.isAfter(latestMonth)
        ? currentMonth
        : monthOf(month);
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  Future<void> pickPaidOn() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: paidOn,
      firstDate: DateTime(
        today.year - _paidOnLookbackYears,
        today.month,
        today.day,
      ),
      lastDate: today,
    );
    if (picked != null && mounted) setState(() => paidOn = picked);
  }

  Future<void> submit() async {
    setState(() => isSubmitted = true);
    final chosenAmount = amount;
    final chosenMethod = method;
    if (chosenAmount == null || chosenMethod == null) return;
    final trimmedNote = note.text.trim();
    final payment = await ref
        .read(recordPaymentControllerProvider.notifier)
        .record(
          traineeId: widget.trainee.id,
          amount: chosenAmount,
          method: chosenMethod,
          paidOn: paidOn,
          periodMonth: periodMonth,
          note: trimmedNote.isEmpty ? null : trimmedNote,
        );
    if (payment == null || !mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Payment recorded')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final submission = ref.watch(recordPaymentControllerProvider);
    final failure = submission.isLoading ? null : submission.error;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.sm,
              AppSpacing.gutter,
              AppSpacing.lg,
            ),
            children: [
              _TraineeHeader(trainee: widget.trainee, today: today),
              const SizedBox(height: AppSpacing.xl),
              const Eyebrow('Amount'),
              const SizedBox(height: AppSpacing.sm),
              ChoiceRow<int>(
                options: _amounts,
                selected: amount,
                onSelected: (value) => setState(() => amount = value),
              ),
              if (isSubmitted && amount == null)
                const _FieldError(_amountMessage),
              const SizedBox(height: AppSpacing.lg),
              const Eyebrow('Method'),
              const SizedBox(height: AppSpacing.sm),
              ChoiceRow<PaymentMethod>(
                options: _methods,
                selected: method,
                onSelected: (value) => setState(() => method = value),
              ),
              if (isSubmitted && method == null)
                const _FieldError(_methodMessage),
              const SizedBox(height: AppSpacing.lg),
              _WhenCard(
                paidOn: paidOn,
                periodMonth: periodMonth,
                latestMonth: latestMonth,
                onPickPaidOn: pickPaidOn,
                onMonthChanged: (next) => setState(() => periodMonth = next),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (isNoteOpen)
                AppTextField(
                  controller: note,
                  label: 'Note',
                  keyboardType: TextInputType.multiline,
                  maxLength: _noteMaxLength,
                  maxLines: _noteLines,
                  showCounter: true,
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: LinkButton(
                    label: 'Add a note',
                    onPressed: () => setState(() => isNoteOpen = true),
                  ),
                ),
            ],
          ),
        ),
        _SubmitBar(
          failure: failure,
          isBusy: submission.isLoading,
          onPressed: submit,
        ),
      ],
    );
  }
}

class _TraineeHeader extends StatelessWidget {
  const _TraineeHeader({required this.trainee, required this.today});

  final Trainee trainee;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final tier = trainee.feeTierOn(today);
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListRow(
        leading: TraineeAvatar(trainee: trainee),
        title: trainee.fullName,
        subtitle: tier == null
            ? 'No date of birth, tier unknown'
            : '${feeTierLabel(tier)}, $tier per month',
      ),
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        message,
        style: AppTypography.caption.copyWith(color: AppColors.negative),
      ),
    );
  }
}

/// Paid-on date and period month as two rows of one card.
class _WhenCard extends StatelessWidget {
  const _WhenCard({
    required this.paidOn,
    required this.periodMonth,
    required this.latestMonth,
    required this.onPickPaidOn,
    required this.onMonthChanged,
  });

  final DateTime paidOn;
  final DateTime periodMonth;
  final DateTime latestMonth;
  final VoidCallback onPickPaidOn;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final chevronStyle = IconButton.styleFrom(
      foregroundColor: AppColors.ink,
      disabledForegroundColor: AppColors.line,
      fixedSize: const Size.square(AppSizes.minTapTarget),
    );
    final hasNext = periodMonth.isBefore(latestMonth);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: ListRow.divide([
          ListRow(
            title: 'Paid on',
            titleStyle: AppTypography.body,
            onTap: onPickPaidOn,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _dateFormat.format(paidOn),
                  style: AppTypography.bodyStrong,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: _iconSize,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
          ListRow(
            title: 'For month',
            titleStyle: AppTypography.body,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Previous month',
                  style: chevronStyle,
                  iconSize: _iconSize,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => onMonthChanged(
                    DateTime(periodMonth.year, periodMonth.month - 1),
                  ),
                ),
                Text(
                  _monthFormat.format(periodMonth),
                  style: AppTypography.bodyStrong,
                ),
                IconButton(
                  tooltip: 'Next month',
                  style: chevronStyle,
                  iconSize: _iconSize,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: hasNext
                      ? () => onMonthChanged(
                          DateTime(periodMonth.year, periodMonth.month + 1),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

/// The record button pinned under the form, with the server's message above it.
class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.failure,
    required this.isBusy,
    required this.onPressed,
  });

  final Object? failure;
  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final error = failure;
    return ColoredBox(
      color: AppColors.ground,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.sm,
            AppSpacing.gutter,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (error != null) ...[
                InlineBanner(
                  message: error is AppException
                      ? error.message
                      : UnknownException.defaultMessage,
                  tone: InlineBannerTone.error,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              PrimaryButton(
                label: 'Record payment',
                isBusy: isBusy,
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

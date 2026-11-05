import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/payment_method.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/india_date.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/choice_row.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/list_row.dart';
import '../../../core/widgets/primary_button.dart';
import '../../today/presentation/today_providers.dart';
import '../../trainees/domain/trainee.dart';
import '../../trainees/presentation/trainee_avatar.dart';
import '../../trainees/presentation/trainee_providers.dart';
import 'fee_providers.dart';
import 'month_navigator.dart';

// Same bounds and messages as `record_fee_payment`.
const _minAmount = 1;
const _maxAmount = 100000;
const _amountDigits = 6;
const _noteMaxLength = 300;
const _noteLines = 4;
const _amountMessage = 'Enter an amount between 1 and 100000';
const _methodMessage = 'Choose cash or UPI';

// Arrears are recorded late, but not years late; the server sets no lower bound.
const _paidOnLookbackYears = 1;

const _methods = [
  ChoiceOption(value: PaymentMethod.cash, label: 'Cash'),
  ChoiceOption(value: PaymentMethod.upi, label: 'UPI'),
];

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
  late final TextEditingController amount;
  late final TextEditingController note;
  late DateTime paidOn;
  late DateTime periodMonth;
  PaymentMethod? method;

  /// Field errors show only after the first submit.
  var isSubmitted = false;

  @override
  void initState() {
    super.initState();
    today = dateOnly(ref.read(clockProvider)());
    currentMonth = monthOf(today);
    latestMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    final tier = widget.trainee.feeTierOn(today);
    amount = TextEditingController(text: tier?.toString())
      ..addListener(revalidate);
    note = TextEditingController();
    paidOn = today;
    final month = widget.month;
    periodMonth = month == null || month.isAfter(latestMonth)
        ? currentMonth
        : monthOf(month);
  }

  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  void revalidate() {
    if (isSubmitted) setState(() {});
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
    final chosenMethod = method;
    final value = _amountValue(amount.text);
    if (value == null || chosenMethod == null) return;
    final trimmedNote = note.text.trim();
    final payment = await ref
        .read(recordPaymentControllerProvider.notifier)
        .record(
          traineeId: widget.trainee.id,
          amount: value,
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
    final hasAmountError = isSubmitted && _amountValue(amount.text) == null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: [
        _TraineeHeader(trainee: widget.trainee, today: today),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          controller: amount,
          label: 'Amount',
          keyboardType: TextInputType.number,
          maxLength: _amountDigits,
          errorText: hasAmountError ? _amountMessage : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('Method', style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        ChoiceRow<PaymentMethod>(
          options: _methods,
          selected: method,
          onSelected: (value) => setState(() => method = value),
        ),
        if (isSubmitted && method == null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _methodMessage,
            style: AppTypography.caption.copyWith(color: AppColors.negative),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        const Text('Paid on', style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListRow(
            title: DateFormat('d MMM yyyy').format(paidOn),
            trailing: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.muted,
            ),
            onTap: pickPaidOn,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('For month', style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        MonthNavigator(
          month: periodMonth,
          latest: latestMonth,
          onChanged: (next) => setState(() => periodMonth = next),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: note,
          label: 'Note (optional)',
          keyboardType: TextInputType.multiline,
          maxLength: _noteMaxLength,
          maxLines: _noteLines,
          showCounter: true,
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
          label: 'Record payment',
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

/// The typed amount when it is a whole number in the server's range, else null.
int? _amountValue(String text) {
  final value = int.tryParse(text.trim());
  if (value == null || value < _minAmount || value > _maxAmount) return null;
  return value;
}

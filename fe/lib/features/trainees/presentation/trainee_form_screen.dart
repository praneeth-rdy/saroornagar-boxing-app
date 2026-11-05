import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/india_date.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/list_row.dart';
import '../../../core/widgets/primary_button.dart';
import '../../today/presentation/today_providers.dart';
import '../domain/trainee.dart';
import '../domain/trainee_input.dart';
import 'trainee_providers.dart';

// Same bounds as the server: names 2 to 80, notes to 500, dates after 1900-01-01.
const _nameMinLength = 2;
const _nameMaxLength = 80;
const _notesMaxLength = 500;
const _phoneDigits = 10;
const _notesLines = 6;
final _earliestDate = DateTime(1900, 1, 2);

// A trainee may be added the evening before their first session.
const _joinSlackDays = 1;

// Most trainees are children, so the birth date picker opens a dozen years back.
const _typicalAgeYears = 12;

/// Adds a trainee, or edits one when [traineeId] is set.
class TraineeFormScreen extends ConsumerWidget {
  const TraineeFormScreen({super.key, this.traineeId});

  final String? traineeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = traineeId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add trainee')),
        body: const _TraineeForm(initial: null),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit trainee')),
      body: AsyncValueView<Trainee>(
        value: ref.watch(traineeProvider(id)),
        onRetry: () => ref.invalidate(traineeProvider(id)),
        data: (trainee) => _TraineeForm(initial: trainee),
      ),
    );
  }
}

class _TraineeForm extends ConsumerStatefulWidget {
  const _TraineeForm({required this.initial});

  final Trainee? initial;

  @override
  ConsumerState<_TraineeForm> createState() => _TraineeFormState();
}

class _TraineeFormState extends ConsumerState<_TraineeForm> {
  late final TextEditingController name;
  late final TextEditingController phone;
  late final TextEditingController notes;
  DateTime? dateOfBirth;
  DateTime? joinedOn;

  /// Field errors show only after the first submit.
  var isSubmitted = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    name = TextEditingController(text: initial?.fullName)
      ..addListener(revalidate);
    phone = TextEditingController(text: _localDigits(initial?.phone))
      ..addListener(revalidate);
    notes = TextEditingController(text: initial?.notes);
    dateOfBirth = initial?.dateOfBirth;
    joinedOn = initial?.joinedOn;
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    notes.dispose();
    super.dispose();
  }

  void revalidate() {
    if (isSubmitted) setState(() {});
  }

  Future<void> pickDateOfBirth(DateTime today) async {
    final suggested = DateTime(
      today.year - _typicalAgeYears,
      today.month,
      today.day,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? suggested,
      firstDate: _earliestDate,
      lastDate: today,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && mounted) setState(() => dateOfBirth = picked);
  }

  Future<void> pickJoinedOn(DateTime today) async {
    final last = DateTime(today.year, today.month, today.day + _joinSlackDays);
    final picked = await showDatePicker(
      context: context,
      initialDate: joinedOn ?? today,
      firstDate: _earliestDate,
      lastDate: last,
    );
    if (picked != null && mounted) setState(() => joinedOn = picked);
  }

  Future<void> submit() async {
    setState(() => isSubmitted = true);
    if (_nameError(name.text) != null || _phoneError(phone.text) != null) {
      return;
    }
    final initial = widget.initial;
    // Sent as typed: the server trims, normalizes and turns blanks into nulls.
    final input = TraineeInput(
      fullName: name.text,
      phone: phone.text,
      dateOfBirth: dateOfBirth,
      joinedOn: joinedOn,
      notes: notes.text,
    );
    final saved = await ref
        .read(traineeFormControllerProvider.notifier)
        .save(initial?.id, input);
    if (saved == null || !mounted) return;
    if (initial == null) {
      context.pushReplacement(Routes.traineeDetailOf(saved.id));
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(ref.watch(clockProvider)());
    final submission = ref.watch(traineeFormControllerProvider);
    final failure = submission.isLoading ? null : submission.error;
    final tier = feeTierFrom(dateOfBirth, today);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: [
        AppTextField(
          controller: name,
          label: 'Name',
          maxLength: _nameMaxLength,
          textInputAction: TextInputAction.next,
          errorText: isSubmitted ? _nameError(name.text) : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: phone,
          label: 'Phone (optional)',
          prefixText: '+91',
          keyboardType: TextInputType.phone,
          maxLength: _phoneDigits,
          textInputAction: TextInputAction.next,
          errorText: isSubmitted ? _phoneError(phone.text) : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        _DateField(
          label: 'Date of birth (optional)',
          date: dateOfBirth,
          clearLabel: 'Clear date of birth',
          helper: tier == null
              ? null
              : '${feeTierLabel(tier)}, $tier per month',
          onPick: () => pickDateOfBirth(today),
          onClear: () => setState(() => dateOfBirth = null),
        ),
        const SizedBox(height: AppSpacing.lg),
        _DateField(
          label: 'Joined on (optional)',
          date: joinedOn,
          clearLabel: 'Clear joining date',
          onPick: () => pickJoinedOn(today),
          onClear: () => setState(() => joinedOn = null),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: notes,
          label: 'Notes (optional)',
          keyboardType: TextInputType.multiline,
          maxLength: _notesMaxLength,
          maxLines: _notesLines,
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
          label: widget.initial == null ? 'Add trainee' : 'Save',
          isBusy: submission.isLoading,
          onPressed: submit,
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.clearLabel,
    required this.onPick,
    required this.onClear,
    this.helper,
  });

  final String label;
  final DateTime? date;
  final String clearLabel;
  final String? helper;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final chosen = date;
    final helperText = helper;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListRow(
            title: chosen == null
                ? 'Choose a date'
                : DateFormat('d MMM yyyy').format(chosen),
            trailing: chosen == null
                ? const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.muted,
                  )
                : IconButton(
                    tooltip: clearLabel,
                    icon: const Icon(Icons.close, color: AppColors.muted),
                    onPressed: onClear,
                  ),
            onTap: onPick,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(helperText, style: AppTypography.caption),
        ],
      ],
    );
  }
}

String? _nameError(String value) {
  final length = value.trim().runes.length;
  if (length < _nameMinLength || length > _nameMaxLength) {
    return 'Enter a name between 2 and 80 characters';
  }
  return null;
}

String? _phoneError(String value) {
  if (value.trim().isEmpty || normalizePhone(value) != null) return null;
  return 'Enter a 10-digit mobile number';
}

// The field shows +91 as a prefix, so a stored 91XXXXXXXXXX is edited as 10 digits.
String? _localDigits(String? phone) {
  if (phone == null) return null;
  return phone.length == 12 && phone.startsWith('91')
      ? phone.substring(2)
      : phone;
}

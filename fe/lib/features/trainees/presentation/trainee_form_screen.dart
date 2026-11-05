import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/india_date.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/link_button.dart';
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

// Postgres integer tops out at ten digits; a club never needs more than six.
const _rollNoMaxLength = 6;
final _earliestDate = DateTime(1900, 1, 2);

// A student may be added the evening before their first session.
const _joinSlackDays = 1;

// Most students are children, so the birth date picker opens a dozen years back.
const _typicalAgeYears = 12;

/// Adds a student, or edits one when [traineeId] is set.
class TraineeFormScreen extends ConsumerWidget {
  const TraineeFormScreen({super.key, this.traineeId});

  final String? traineeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = traineeId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add student')),
        body: const _TraineeForm(initial: null),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit student')),
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
  late final TextEditingController rollNo;
  late final TextEditingController name;
  late final TextEditingController phone;
  late final TextEditingController notes;
  DateTime? dateOfBirth;
  DateTime? joinedOn;

  /// Date of birth, joining date and notes stay behind a link until asked for.
  late bool isMoreOpen;

  /// Field errors show only after the first submit.
  var isSubmitted = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    rollNo = TextEditingController(text: initial?.rollNo.toString())
      ..addListener(revalidate);
    if (initial == null) {
      ref.listenManual(nextRollNoProvider, (_, next) {
        final suggested = next.value;
        // Never overwrite a number the coach already typed.
        if (suggested != null && rollNo.text.isEmpty) {
          rollNo.text = '$suggested';
        }
      }, fireImmediately: true);
    }
    name = TextEditingController(text: initial?.fullName)
      ..addListener(revalidate);
    phone = TextEditingController(text: _localDigits(initial?.phone))
      ..addListener(revalidate);
    notes = TextEditingController(text: initial?.notes);
    dateOfBirth = initial?.dateOfBirth;
    joinedOn = initial?.joinedOn;
    isMoreOpen =
        dateOfBirth != null ||
        joinedOn != null ||
        (initial?.notes?.isNotEmpty ?? false);
  }

  @override
  void dispose() {
    rollNo.dispose();
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
    final number = _parseRollNo(rollNo.text);
    if (number == null ||
        _nameError(name.text) != null ||
        _phoneError(phone.text) != null) {
      return;
    }
    final initial = widget.initial;
    // Sent as typed: the server trims, normalizes and turns blanks into nulls.
    final input = TraineeInput(
      rollNo: number,
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
    final suggestion = widget.initial == null
        ? ref.watch(nextRollNoProvider)
        : null;
    final failures = [?suggestion?.error, ?failure];
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
          controller: rollNo,
          label: 'Roll number',
          isRequired: true,
          enabled: !(suggestion?.isLoading ?? false),
          suffix: (suggestion?.isLoading ?? false)
              ? const _FieldSpinner()
              : null,
          keyboardType: TextInputType.number,
          maxLength: _rollNoMaxLength,
          textInputAction: TextInputAction.next,
          errorText: isSubmitted ? _rollNoError(rollNo.text) : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: name,
          label: 'Name',
          isRequired: true,
          maxLength: _nameMaxLength,
          textInputAction: TextInputAction.next,
          errorText: isSubmitted ? _nameError(name.text) : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: phone,
          label: 'Phone',
          prefixText: '+91',
          keyboardType: TextInputType.phone,
          maxLength: _phoneDigits,
          textInputAction: TextInputAction.next,
          errorText: isSubmitted ? _phoneError(phone.text) : null,
        ),
        if (isMoreOpen) ...[
          const SizedBox(height: AppSpacing.lg),
          DateField(
            label: 'Date of birth',
            date: dateOfBirth,
            clearLabel: 'Clear date of birth',
            helper: tier == null
                ? null
                : '${feeTierLabel(tier)}, $tier per month',
            onPick: () => pickDateOfBirth(today),
            onClear: () => setState(() => dateOfBirth = null),
          ),
          const SizedBox(height: AppSpacing.lg),
          DateField(
            label: 'Joined on',
            date: joinedOn,
            clearLabel: 'Clear joining date',
            onPick: () => pickJoinedOn(today),
            onClear: () => setState(() => joinedOn = null),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: notes,
            label: 'Notes',
            keyboardType: TextInputType.multiline,
            maxLength: _notesMaxLength,
            maxLines: _notesLines,
            showCounter: true,
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: LinkButton(
              label: 'Add more details',
              onPressed: () => setState(() => isMoreOpen = true),
            ),
          ),
        ],
        for (final failure in failures) ...[
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
          label: widget.initial == null ? 'Add student' : 'Save',
          isBusy: submission.isLoading,
          onPressed: submit,
        ),
      ],
    );
  }
}

/// A small spinner inside the roll number field while the suggestion loads.
class _FieldSpinner extends StatelessWidget {
  const _FieldSpinner();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: SizedBox.square(
        dimension: AppSizes.spinner,
        child: CircularProgressIndicator(strokeWidth: AppSizes.spinnerStroke),
      ),
    );
  }
}

int? _parseRollNo(String value) {
  final number = int.tryParse(value.trim());
  return number != null && number > 0 ? number : null;
}

// Same message as the server's check.
String? _rollNoError(String value) =>
    _parseRollNo(value) == null ? 'Enter a roll number above 0' : null;

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

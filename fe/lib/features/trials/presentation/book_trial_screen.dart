import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/session_slot.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/india_date.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/choice_row.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/link_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../../today/presentation/today_providers.dart';
import '../domain/trial_booking.dart';
import '../domain/trial_request.dart';
import 'trial_providers.dart';

// Same bounds as `book_trial`: names 2 to 80, ages 3 to 99, notes to 300, births after 1900.
const _nameMinLength = 2;
const _nameMaxLength = 80;
const _phoneDigits = 10;
const _minAge = 3;
const _maxAge = 99;
const _ageDigits = 2;
const _noteMaxLength = 300;
const _noteLines = 4;
final _earliestBirthDate = DateTime(1900, 1, 2);

// Most visitors are children, so the birth date picker opens a dozen years back.
const _typicalAgeYears = 12;

const _batchOptions = [
  ChoiceOption(
    value: SessionSlot.morning,
    label: 'Morning',
    caption: '6:00 to 8:30 am',
  ),
  ChoiceOption(
    value: SessionSlot.evening,
    label: 'Evening',
    caption: '5:30 to 8:00 pm',
  ),
];

/// The regular hours of a batch, or null for a slot visitors cannot book.
String? batchHours(SessionSlot slot) {
  for (final option in _batchOptions) {
    if (option.value == slot) return option.caption;
  }
  return null;
}

/// The public trial booking form; works with or without a staff session.
class BookTrialScreen extends ConsumerStatefulWidget {
  const BookTrialScreen({super.key});

  @override
  ConsumerState<BookTrialScreen> createState() => _BookTrialScreenState();
}

class _BookTrialScreenState extends ConsumerState<BookTrialScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final age = TextEditingController();
  final note = TextEditingController();
  DateTime? day;
  SessionSlot? slot;
  DateTime? dateOfBirth;
  var usesDateOfBirth = false;

  /// Field errors show only after the first submit.
  var isSubmitted = false;

  @override
  void initState() {
    super.initState();
    for (final field in [name, phone, age]) {
      field.addListener(revalidate);
    }
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    age.dispose();
    note.dispose();
    super.dispose();
  }

  void revalidate() {
    if (isSubmitted) setState(() {});
  }

  // Only one of age and date of birth is sent, so swapping clears the other.
  void swapAgeField() => setState(() {
    usesDateOfBirth = !usesDateOfBirth;
    age.clear();
    dateOfBirth = null;
  });

  Future<void> pickDateOfBirth(DateTime today) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          dateOfBirth ??
          DateTime(today.year - _typicalAgeYears, today.month, today.day),
      firstDate: _earliestBirthDate,
      lastDate: today,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && mounted) setState(() => dateOfBirth = picked);
  }

  bool get hasErrors =>
      _nameError(name.text) != null ||
      phoneText(phone.text) != null ||
      _dayError(day) != null ||
      _slotError(slot) != null ||
      ageOrBirthError != null;

  String? get ageOrBirthError => usesDateOfBirth
      ? (dateOfBirth == null ? _ageOrBirthMissing : null)
      : _ageError(age.text);

  Future<void> submit() async {
    setState(() => isSubmitted = true);
    final chosenDay = day;
    final chosenSlot = slot;
    if (hasErrors || chosenDay == null || chosenSlot == null) return;
    // Sent as typed: the server trims, normalizes and turns a blank note into null.
    final request = TrialRequest(
      fullName: name.text,
      phone: phone.text,
      sessionDate: chosenDay,
      slot: chosenSlot,
      age: usesDateOfBirth ? null : int.parse(age.text.trim()),
      dateOfBirth: usesDateOfBirth ? dateOfBirth : null,
      note: note.text,
    );
    final booking = await ref
        .read(bookTrialControllerProvider.notifier)
        .book(request);
    if (booking == null || !mounted) return;
    context.push(Routes.trialBooked, extra: booking).ignore();
    // The visitor's details stay for "Book another day"; the slot is spent.
    setState(() {
      isSubmitted = false;
      day = null;
      slot = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(ref.watch(clockProvider)());
    final submission = ref.watch(bookTrialControllerProvider);
    final failure = submission.isLoading ? null : submission.error;
    final mine = ref.watch(myTrialBookingsProvider).value ?? const [];
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
            const Text('Try a session', style: AppTypography.title),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Pick a day and a batch. The coach will expect you.',
              style: AppTypography.caption,
            ),
            if (mine.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _YourBookingsCard(bookings: mine),
            ],
            const SizedBox(height: AppSpacing.xl),
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
              label: 'Phone',
              prefixText: '+91 ',
              keyboardType: TextInputType.phone,
              maxLength: _phoneDigits,
              textInputAction: TextInputAction.next,
              errorText: isSubmitted ? phoneText(phone.text) : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            _ChoiceSection<DateTime>(
              title: 'DAY',
              options: [
                for (final date in trialDaysFrom(today))
                  ChoiceOption(
                    value: date,
                    label: DateFormat('EEE d').format(date),
                    caption: DateFormat('MMM').format(date),
                  ),
              ],
              selected: day,
              onSelected: (date) => setState(() => day = date),
              errorText: isSubmitted ? _dayError(day) : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            _ChoiceSection<SessionSlot>(
              title: 'BATCH',
              options: _batchOptions,
              selected: slot,
              onSelected: (batch) => setState(() => slot = batch),
              errorText: isSubmitted ? _slotError(slot) : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            const Eyebrow('YOUR AGE'),
            const SizedBox(height: AppSpacing.sm),
            if (usesDateOfBirth)
              DateField(
                label: 'Date of birth',
                date: dateOfBirth,
                errorText: isSubmitted ? ageOrBirthError : null,
                onPick: () => pickDateOfBirth(today),
              )
            else
              AppTextField(
                controller: age,
                hint: 'Age in years',
                keyboardType: TextInputType.number,
                maxLength: _ageDigits,
                textInputAction: TextInputAction.next,
                errorText: isSubmitted ? ageOrBirthError : null,
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: LinkButton(
                label: usesDateOfBirth
                    ? 'Use age instead'
                    : 'Use date of birth instead',
                onPressed: swapAgeField,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Eyebrow('ANYTHING WE SHOULD KNOW (OPTIONAL)'),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: note,
              hint: 'Anything the coach should know',
              keyboardType: TextInputType.multiline,
              maxLength: _noteMaxLength,
              maxLines: _noteLines,
              showCounter: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (failure != null) ...[
              InlineBanner(
                message: failure is AppException
                    ? failure.message
                    : UnknownException.defaultMessage,
                tone: InlineBannerTone.error,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            PrimaryButton(
              label: 'Book trial',
              isBusy: submission.isLoading,
              onPressed: submit,
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: LinkButton(
                label: 'Already train here? Sign in',
                onPressed: () => context.go(Routes.signIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An eyebrow, single-choice pills and the error under them once submitted.
class _ChoiceSection<T> extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.errorText,
  });

  final String title;
  final List<ChoiceOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelected;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final error = errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Eyebrow(title),
        const SizedBox(height: AppSpacing.sm),
        ChoiceRow<T>(
          options: options,
          selected: selected,
          onSelected: onSelected,
        ),
        if (error != null) _FieldError(error),
      ],
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

/// This device's upcoming bookings, so a returning visitor knows what is already booked.
class _YourBookingsCard extends StatelessWidget {
  const _YourBookingsCard({required this.bookings});

  final List<TrialBooking> bookings;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your bookings', style: AppTypography.bodyStrong),
          const SizedBox(height: AppSpacing.xs),
          for (final booking in bookings)
            Text(_bookingLine(booking), style: AppTypography.body),
        ],
      ),
    );
  }
}

String _bookingLine(TrialBooking booking) {
  final date = DateFormat('EEE d MMM').format(booking.sessionDate);
  final hours = batchHours(booking.slot);
  final batch = hours == null
      ? booking.slot.label
      : '${booking.slot.label} ($hours)';
  return '$date, $batch';
}

const _ageOrBirthMissing = 'Tell us your age or date of birth';

// Messages match `book_trial` so the client and server read the same.
String? _nameError(String value) {
  final length = value.trim().runes.length;
  if (length < _nameMinLength || length > _nameMaxLength) {
    return 'Enter your name';
  }
  return null;
}

String? _dayError(DateTime? day) => day == null ? 'Pick a day' : null;

String? _slotError(SessionSlot? slot) =>
    slot == null ? 'Pick the morning or the evening batch' : null;

String? _ageError(String value) {
  final text = value.trim();
  if (text.isEmpty) return _ageOrBirthMissing;
  final years = int.tryParse(text);
  if (years == null || years < _minAge || years > _maxAge) {
    return 'Enter an age between $_minAge and $_maxAge';
  }
  return null;
}

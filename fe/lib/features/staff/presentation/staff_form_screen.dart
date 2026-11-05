import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/staff_role.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/choice_row.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/domain/staff_profile.dart';
import '../domain/staff_input.dart';
import 'staff_admin_gate.dart';
import 'staff_providers.dart';

// Same bounds as update_staff and the admin-staff function.
const _nameMinLength = 2;
const _nameMaxLength = 80;
const _phoneDigits = 10;
const _passwordMaxLength = 72;

const _roleOptions = [
  ChoiceOption(value: StaffRole.coach, label: 'Coach'),
  ChoiceOption(value: StaffRole.admin, label: 'Admin'),
];

/// Adds a staff member, or edits one's name, role and phone when [userId] is set.
class StaffFormScreen extends ConsumerWidget {
  const StaffFormScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = userId;
    return Scaffold(
      appBar: AppBar(title: Text(id == null ? 'Add staff' : 'Edit staff')),
      body: StaffAdminGate(
        builder: (me) => id == null
            ? const _StaffForm(initial: null, isSelf: false)
            : AsyncValueView<StaffProfile>(
                value: ref.watch(staffMemberProvider(id)),
                onRetry: () => ref.invalidate(staffListProvider),
                data: (member) =>
                    _StaffForm(initial: member, isSelf: member.id == me.id),
              ),
      ),
    );
  }
}

class _StaffForm extends ConsumerStatefulWidget {
  const _StaffForm({required this.initial, required this.isSelf});

  final StaffProfile? initial;

  /// The admin is editing their own profile, so the role stays as it is.
  final bool isSelf;

  @override
  ConsumerState<_StaffForm> createState() => _StaffFormState();
}

class _StaffFormState extends ConsumerState<_StaffForm> {
  late final TextEditingController name;
  late final TextEditingController phone;
  final email = TextEditingController();
  final password = TextEditingController();
  late StaffRole role;
  var isPasswordVisible = false;

  /// Field errors show only after the first submit.
  var isSubmitted = false;

  bool get isNew => widget.initial == null;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.initial?.fullName)
      ..addListener(revalidate);
    phone = TextEditingController(text: _localDigits(widget.initial?.phone))
      ..addListener(revalidate);
    email.addListener(revalidate);
    password.addListener(revalidate);
    role = widget.initial?.role ?? StaffRole.coach;
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void revalidate() {
    if (isSubmitted) setState(() {});
  }

  bool get hasFieldErrors =>
      _nameError(name.text) != null ||
      _phoneError(phone.text) != null ||
      (isNew &&
          (emailText(email.text) != null ||
              passwordText(password.text) != null));

  Future<void> submit() async {
    setState(() => isSubmitted = true);
    if (hasFieldErrors) return;
    // Sent as typed: the server trims the name and normalizes the email and phone.
    final input = StaffInput(
      fullName: name.text,
      role: role,
      email: isNew ? email.text : null,
      // An emptied field clears the phone.
      phone: phone.text.trim().isEmpty ? null : phone.text,
      password: isNew ? password.text : null,
    );
    final saved = await ref
        .read(staffFormControllerProvider.notifier)
        .save(widget.initial?.id, input);
    if (saved != null && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final submission = ref.watch(staffFormControllerProvider);
    final failure = submission.isLoading ? null : submission.error;
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
          isRequired: true,
          maxLength: _nameMaxLength,
          textInputAction: TextInputAction.next,
          errorText: isSubmitted ? _nameError(name.text) : null,
        ),
        if (isNew) ...[
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: email,
            label: 'Email',
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            errorText: isSubmitted ? emailText(email.text) : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PasswordField(
            controller: password,
            isVisible: isPasswordVisible,
            errorText: isSubmitted ? passwordText(password.text) : null,
            onToggle: () =>
                setState(() => isPasswordVisible = !isPasswordVisible),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        const Text('Role', style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        ChoiceRow<StaffRole>(
          options: _roleOptions,
          selected: role,
          onSelected: widget.isSelf
              ? null
              : (selected) => setState(() => role = selected),
        ),
        if (widget.isSelf) ...[
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'You cannot change your own role',
            style: AppTypography.caption,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: phone,
          label: 'Phone',
          prefixText: '+91',
          keyboardType: TextInputType.phone,
          maxLength: _phoneDigits,
          textInputAction: TextInputAction.done,
          errorText: isSubmitted ? _phoneError(phone.text) : null,
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
          label: isNew ? 'Add staff' : 'Save',
          isBusy: submission.isLoading,
          onPressed: submit,
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.isVisible,
    required this.errorText,
    required this.onToggle,
  });

  final TextEditingController controller;
  final bool isVisible;
  final String? errorText;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: controller,
          label: 'Password',
          isRequired: true,
          obscureText: !isVisible,
          maxLength: _passwordMaxLength,
          textInputAction: TextInputAction.done,
          errorText: errorText,
          suffix: IconButton(
            tooltip: isVisible ? 'Hide password' : 'Show password',
            icon: Icon(
              isVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: onToggle,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'They will use this to sign in.',
          style: AppTypography.caption,
        ),
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

// Blank is allowed: the phone is optional.
String? _phoneError(String value) =>
    value.trim().isEmpty ? null : phoneText(value);

// The field shows +91 as a prefix, so a stored 91XXXXXXXXXX is edited as 10 digits.
String? _localDigits(String? phone) {
  if (phone == null) return null;
  return phone.length == 12 && phone.startsWith('91')
      ? phone.substring(2)
      : phone;
}

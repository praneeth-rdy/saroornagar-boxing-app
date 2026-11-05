import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/trainee_status.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/india_date.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/link_button.dart';
import '../../../core/widgets/list_row.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../fees/presentation/fee_history_section.dart';
import '../../today/presentation/today_providers.dart';
import '../domain/attendance_day.dart';
import '../domain/attendance_record.dart';
import '../domain/trainee.dart';
import 'attendance_day_row.dart';
import 'trainee_avatar.dart';
import 'trainee_photo_picker.dart';
import 'trainee_providers.dart';

const _badgeIconSize = 14.0;

/// One student: profile, status, notes and recent attendance.
class TraineeDetailScreen extends ConsumerWidget {
  const TraineeDetailScreen({super.key, required this.traineeId});

  final String traineeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student')),
      body: AsyncValueView<Trainee>(
        value: ref.watch(traineeProvider(traineeId)),
        onRetry: () => ref.invalidate(traineeProvider(traineeId)),
        data: (trainee) => _TraineeDetail(trainee: trainee),
      ),
    );
  }
}

class _TraineeDetail extends ConsumerWidget {
  const _TraineeDetail({required this.trainee});

  final Trainee trainee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusChange = ref.watch(traineeStatusControllerProvider(trainee.id));
    final photoChange = ref.watch(traineePhotoControllerProvider(trainee.id));
    final failures = [
      if (!statusChange.isLoading) statusChange.error,
      if (!photoChange.isLoading) photoChange.error,
    ].nonNulls;
    final notes = trainee.notes;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: [
        _HeaderCard(trainee: trainee, isUploading: photoChange.isLoading),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Edit',
                onPressed: () => context.push(Routes.traineeEditOf(trainee.id)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            LinkButton(
              label: trainee.isActive ? 'Set inactive' : 'Set active',
              onPressed: statusChange.isLoading
                  ? null
                  : () => _confirmStatus(context, ref),
            ),
          ],
        ),
        for (final failure in failures) ...[
          const SizedBox(height: AppSpacing.md),
          InlineBanner(
            message: failure is AppException
                ? failure.message
                : UnknownException.defaultMessage,
            tone: InlineBannerTone.error,
          ),
        ],
        if (notes != null) ...[
          const SizedBox(height: AppSpacing.xl),
          const Eyebrow('Notes'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(child: Text(notes, style: AppTypography.body)),
        ],
        const SizedBox(height: AppSpacing.xl),
        _RecentAttendance(traineeId: trainee.id),
        const SizedBox(height: AppSpacing.xl),
        FeeHistorySection(traineeId: trainee.id),
      ],
    );
  }

  Future<void> _confirmStatus(BuildContext context, WidgetRef ref) async {
    final next = trainee.isActive
        ? TraineeStatus.inactive
        : TraineeStatus.active;
    final action = trainee.isActive ? 'Set inactive' : 'Set active';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          trainee.isActive
              ? 'Set ${trainee.fullName} inactive?'
              : 'Set ${trainee.fullName} active?',
        ),
        content: Text(
          trainee.isActive
              ? 'They leave the attendance roster. You can set them active again later.'
              : 'They return to the attendance roster.',
        ),
        actions: [
          LinkButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          LinkButton(
            label: action,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(traineeStatusControllerProvider(trainee.id).notifier)
        .setStatus(next);
  }
}

class _HeaderCard extends ConsumerWidget {
  const _HeaderCard({required this.trainee, required this.isUploading});

  final Trainee trainee;
  final bool isUploading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = dateOnly(ref.watch(clockProvider)());
    final details = _detailsOf(trainee, today);
    final joinedOn = trainee.joinedOn;
    return AppCard(
      child: Row(
        children: [
          _PhotoButton(trainee: trainee, isUploading: isUploading),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainee.fullName, style: AppTypography.title),
                const SizedBox(height: AppSpacing.xs),
                Text(details, style: AppTypography.caption),
                if (joinedOn != null)
                  Text(
                    'Joined ${DateFormat('d MMM yyyy').format(joinedOn)}',
                    style: AppTypography.caption,
                  ),
                const SizedBox(height: AppSpacing.sm),
                _StatusChip(status: trainee.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `Roll no. 12 · +91 98765 43210 · Age 14 · Junior`, leaving out what is not known.
String _detailsOf(Trainee trainee, DateTime today) {
  final phone = trainee.phone;
  final age = trainee.ageOn(today);
  final tier = trainee.feeTierOn(today);
  return [
    'Roll no. ${trainee.rollNo}',
    if (phone != null) formatPhone(phone),
    if (age != null) 'Age $age',
    if (tier != null) feeTierLabel(tier),
  ].join(' · ');
}

class _PhotoButton extends StatelessWidget {
  const _PhotoButton({required this.trainee, required this.isUploading});

  final Trainee trainee;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Change photo',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isUploading
            ? null
            : () => showTraineePhotoPicker(context, trainee),
        child: SizedBox.square(
          dimension: AppSizes.avatarLarge,
          child: Stack(
            children: [
              TraineeAvatar(trainee: trainee, size: AppSizes.avatarLarge),
              if (isUploading)
                const Positioned.fill(
                  child: CircularProgressIndicator(
                    strokeWidth: AppSizes.spinnerStroke,
                  ),
                ),
              const Positioned(
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xs),
                    child: Icon(
                      Icons.photo_camera,
                      size: _badgeIconSize,
                      color: AppColors.onAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TraineeStatus status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == TraineeStatus.active;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isActive ? AppColors.accentSoft : AppColors.line,
        borderRadius: AppRadius.chipAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          isActive ? 'Active' : 'Inactive',
          style: AppTypography.label.copyWith(
            color: isActive ? AppColors.accent : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _RecentAttendance extends ConsumerWidget {
  const _RecentAttendance({required this.traineeId});

  final String traineeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recentAttendanceProvider(traineeId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Expanded(child: Eyebrow('Attendance')),
            Text(
              'Last $recentAttendanceDays days',
              style: AppTypography.caption,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        records.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: LoadingView(),
          ),
          error: (error, _) => InlineBanner(
            message: error is AppException
                ? error.message
                : UnknownException.defaultMessage,
            tone: InlineBannerTone.error,
            onRetry: () => ref.invalidate(recentAttendanceProvider(traineeId)),
          ),
          data: (loaded) => _RecordsCard(records: loaded),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: LinkButton(
            label: 'Full history',
            onPressed: () => context.push(Routes.traineeHistoryOf(traineeId)),
          ),
        ),
      ],
    );
  }
}

class _RecordsCard extends StatelessWidget {
  const _RecordsCard({required this.records});

  final List<AttendanceRecord> records;

  @override
  Widget build(BuildContext context) {
    final days = groupAttendanceByDate(records);
    if (days.isEmpty) {
      return const AppCard(
        child: Text('No classes attended', style: AppTypography.caption),
      );
    }
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: ListRow.divide([
          for (final day in days) AttendanceDayRow(day: day),
        ]),
      ),
    );
  }
}

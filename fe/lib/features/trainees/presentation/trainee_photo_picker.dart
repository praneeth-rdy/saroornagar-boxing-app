import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/list_row.dart';
import '../domain/trainee.dart';
import 'trainee_providers.dart';

/// Opens [TraineePhotoPicker] for [trainee].
Future<void> showTraineePhotoPicker(BuildContext context, Trainee trainee) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.ground,
      builder: (_) => TraineePhotoPicker(trainee: trainee),
    );

/// Take, choose or remove a trainee's photo; the upload runs after the sheet closes.
class TraineePhotoPicker extends ConsumerWidget {
  const TraineePhotoPicker({super.key, required this.trainee});

  final Trainee trainee;

  void run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(TraineePhotoController controller) action,
  ) {
    // The detail screen watches this controller, so it outlives the sheet.
    final controller = ref.read(
      traineePhotoControllerProvider(trainee.id).notifier,
    );
    Navigator.of(context).pop();
    action(controller).ignore();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.xl,
          AppSpacing.gutter,
          AppSpacing.gutter,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Photo', style: AppTypography.heading),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: ListRow.divide([
                  ListRow(
                    leading: const Icon(
                      Icons.photo_camera_outlined,
                      color: AppColors.ink,
                    ),
                    title: 'Take photo',
                    onTap: () => run(
                      context,
                      ref,
                      (controller) => controller.pick(ImageSource.camera),
                    ),
                  ),
                  ListRow(
                    leading: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.ink,
                    ),
                    title: 'Choose from gallery',
                    onTap: () => run(
                      context,
                      ref,
                      (controller) => controller.pick(ImageSource.gallery),
                    ),
                  ),
                  if (trainee.photoPath != null)
                    ListRow(
                      leading: const Icon(
                        Icons.delete_outline,
                        color: AppColors.negative,
                      ),
                      title: 'Remove',
                      onTap: () => run(
                        context,
                        ref,
                        (controller) => controller.remove(),
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

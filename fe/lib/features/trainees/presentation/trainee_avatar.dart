import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/avatar_initials.dart';
import '../domain/trainee.dart';
import 'trainee_providers.dart';

/// The trainee's photo through a signed URL, with initials until it loads or when absent.
class TraineeAvatar extends ConsumerWidget {
  const TraineeAvatar({
    super.key,
    required this.trainee,
    this.size = AppSizes.avatar,
  });

  final Trainee trainee;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoPath = trainee.photoPath;
    final url = photoPath == null
        ? null
        : ref.watch(traineePhotoUrlProvider(photoPath)).value;
    return AvatarInitials(name: trainee.fullName, photoUrl: url, size: size);
  }
}

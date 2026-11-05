import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_typography.dart';

/// A round avatar: the photo when there is one, else up to two initials.
class AvatarInitials extends StatelessWidget {
  const AvatarInitials({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = AppSizes.avatar,
  });

  final String name;
  final String? photoUrl;
  final double size;

  static String initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return '';
    final first = words.first.characters.first;
    final last = words.length > 1 ? words.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final initials = Center(
      child: Text(
        initialsOf(name),
        style: AppTypography.label.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
          fontSize: size * AppSizes.avatarInitialsRatio,
        ),
      ),
    );
    return Semantics(
      label: name,
      image: url != null,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.accentSoft,
            shape: BoxShape.circle,
          ),
          child: url == null
              ? initials
              : ClipOval(
                  child: Image.network(
                    url,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => initials,
                  ),
                ),
        ),
      ),
    );
  }
}

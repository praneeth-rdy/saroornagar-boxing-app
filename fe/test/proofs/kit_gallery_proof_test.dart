import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/theme/app_spacing.dart';
import 'package:saroornagar_boxing/core/widgets/app_card.dart';
import 'package:saroornagar_boxing/core/widgets/avatar_initials.dart';
import 'package:saroornagar_boxing/core/widgets/eyebrow.dart';
import 'package:saroornagar_boxing/core/widgets/list_row.dart';
import 'package:saroornagar_boxing/core/widgets/primary_button.dart';

import 'proof_harness.dart';

void main() {
  testWidgets('renderProof writes a PNG of a kit gallery', (tester) async {
    const gallery = Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow('Today'),
              SizedBox(height: AppSpacing.md),
              AppCard(
                child: ListRow(
                  leading: AvatarInitials(name: 'Asha Rao'),
                  title: 'Asha Rao',
                  subtitle: 'Morning',
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              PrimaryButton(label: 'Mark present', onPressed: null),
            ],
          ),
        ),
      ),
    );

    final file = await renderProof(tester, 'kit_gallery', gallery);

    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), greaterThan(0));
  });
}

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/theme/app_theme.dart';
import 'package:saroornagar_boxing/core/theme/app_typography.dart';

const _proofPixelRatio = 2.0;
const _outputDirectory = 'test/proofs/out';
const _interFonts = [
  'assets/fonts/Inter-Regular.ttf',
  'assets/fonts/Inter-Medium.ttf',
  'assets/fonts/Inter-SemiBold.ttf',
  'assets/fonts/Inter-Bold.ttf',
];

bool _fontsLoaded = false;

// Widget tests render text with a placeholder font unless the real one is registered.
Future<void> _loadInter() async {
  if (_fontsLoaded) return;
  final loader = FontLoader(AppTypography.fontFamily);
  for (final path in _interFonts) {
    loader.addFont(rootBundle.load(path));
  }
  await loader.load();
  _fontsLoaded = true;
}

/// Renders [child] at phone size in the app theme and writes `test/proofs/out/<name>.png`.
///
/// A review artefact, never a golden comparison: the test passes once the file is written.
Future<File> renderProof(
  WidgetTester tester,
  String name,
  Widget child, {
  Size size = const Size(390, 844),
  List<Override> overrides = const [],
}) async {
  await tester.runAsync(_loadInter);
  tester.view.physicalSize = size * _proofPixelRatio;
  tester.view.devicePixelRatio = _proofPixelRatio;
  addTearDown(tester.view.reset);

  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: AppTheme.light(),
          debugShowCheckedModeBanner: false,
          home: child,
        ),
      ),
    ),
  );
  await tester.pump();

  final file = File('$_outputDirectory/$name.png');
  await tester.runAsync(() async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: _proofPixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
  return file;
}

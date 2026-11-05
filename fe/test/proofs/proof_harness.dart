import 'dart:convert';
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

const _materialIconsPath =
    'bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';

bool _fontsLoaded = false;
bool _iconsLoaded = false;

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

// Icons render as empty boxes unless the SDK's Material Icons font is registered as well.
Future<void> _loadMaterialIcons() async {
  if (_iconsLoaded) return;
  _iconsLoaded = true;
  final root = await _flutterRoot();
  if (root == null) return;
  final file = File('$root/$_materialIconsPath');
  if (!file.existsSync()) return;
  final bytes = await file.readAsBytes();
  final loader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

Future<String?> _flutterRoot() async {
  final fromEnvironment = Platform.environment['FLUTTER_ROOT'];
  if (fromEnvironment != null && fromEnvironment.isNotEmpty) {
    return fromEnvironment;
  }
  try {
    final result = await Process.run('flutter', ['--version', '--machine']);
    if (result.exitCode != 0) return null;
    final machine = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    return machine['flutterRoot'] as String?;
  } on Exception {
    // Without the SDK path the proof still renders; icons just show as boxes.
    return null;
  }
}

/// Renders [child] at phone size in the app theme and writes `test/proofs/out/<name>.png`.
///
/// [interact] runs after the first frame and before the capture, to type into fields or
/// open a state. A review artefact, never a golden comparison: the test passes once the
/// file is written.
Future<File> renderProof(
  WidgetTester tester,
  String name,
  Widget child, {
  Size size = const Size(390, 844),
  List<Override> overrides = const [],
  Future<void> Function(WidgetTester tester)? interact,
}) async {
  await tester.runAsync(_loadInter);
  await tester.runAsync(_loadMaterialIcons);
  tester.view.physicalSize = size * _proofPixelRatio;
  tester.view.devicePixelRatio = _proofPixelRatio;
  addTearDown(tester.view.reset);

  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: ProviderScope(
        retry: (_, _) => null,
        overrides: overrides,
        child: MaterialApp(
          theme: AppTheme.light(),
          debugShowCheckedModeBanner: false,
          home: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (interact != null) await interact(tester);

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

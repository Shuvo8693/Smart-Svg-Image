import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_svg_image/smart_svg_image.dart';

void main() {
  group('SmartSvgImage', () {
    testWidgets('creates SmartSvgImage widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartSvgImage(
              svgAssetPath: 'test/assets/test.svg',
              height: 100,
              width: 100,
            ),
          ),
        ),
      );

      expect(find.byType(SmartSvgImage), findsOneWidget);
    });

    testWidgets('displays loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartSvgImage(
              svgAssetPath: 'test/assets/test.svg',
            ),
          ),
        ),
      );

      // Loading indicator should be present initially
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    test('SmartSvgImage constructor with required parameters', () {
      const widget = SmartSvgImage(
        svgAssetPath: 'assets/test.svg',
      );

      expect(widget.svgAssetPath, 'assets/test.svg');
      expect(widget.height, isNull);
      expect(widget.width, isNull);
    });

    test('SmartSvgImage constructor with optional parameters', () {
      const widget = SmartSvgImage(
        svgAssetPath: 'assets/test.svg',
        height: 200,
        width: 150,
      );

      expect(widget.svgAssetPath, 'assets/test.svg');
      expect(widget.height, 200);
      expect(widget.width, 150);
    });
  });
}

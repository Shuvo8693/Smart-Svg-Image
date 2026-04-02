import 'package:flutter/material.dart';
import 'package:smart_svg_image/smart_svg_image.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('SmartSvgImage Example')),
        body: Center(
          child: SmartSvgImage(
            svgAssetPath: 'assets/images/logo.svg',
            height: 200,
            width: 200,
          ),
        ),
      ),
    );
  }
}
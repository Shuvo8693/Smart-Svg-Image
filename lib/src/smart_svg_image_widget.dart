
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_svg/flutter_svg.dart';

/// A widget that loads an SVG asset and either:
/// - Renders the embedded base64 image directly (if found inside the SVG)
/// - Falls back to rendering the SVG itself (if no base64 image is embedded)
class SmartSvgImage extends StatefulWidget {
  final String svgAssetPath;
  final double? height;
  final double? width;

  const SmartSvgImage({
    super.key,
    required this.svgAssetPath,
    this.height,
    this.width,
  });

  @override
  State<SmartSvgImage> createState() => _SmartSvgImageState();
}

class _SmartSvgImageState extends State<SmartSvgImage> {
  Uint8List? imageBytes;   // Decoded bytes of the embedded image (if found)
  bool isLoading = true;   // True while SVG is being read and parsed
  bool isSvgLoaded = false; // True when no base64 found — fall back to SVG render
  String? errorMessage;    // Holds error description if loading fails

  @override
  void initState() {
    super.initState();
    _loadAndExtractImage();
  }

  Future<void> _loadAndExtractImage() async {
    try {
      // Load raw SVG string from assets
      String svgContent = await DefaultAssetBundle.of(context).loadString(widget.svgAssetPath);

      // Some SVGs have a negative Y translation in their transform matrix which
      // causes the image to render outside the visible area (clipped/invisible).
      // Fix: replace negative Y offset with 0 while preserving scale values.
      // Uses replaceAllMapped so we can reference captured groups (m.group(1), m.group(2)).
      svgContent = svgContent.replaceAllMapped(
        RegExp(
            r'transform="matrix\(([\d.]+)\s+0\s+0\s+([\d.]+)\s+0\s+-[\d.]+\)"'),
            (m) => 'transform="matrix(${m.group(1)} 0 0 ${m.group(2)} 0 0)"',
      );

      // Try to find an embedded base64 image inside the SVG (via xlink:href attribute)
      final RegExp regExp = RegExp(
        r'xlink:href="data:image/[^;]+;base64,([^"]+)"',
        multiLine: true,
        dotAll: true,
      );

      final Match? match = regExp.firstMatch(svgContent);

      if (match != null) {
        // Base64 image found — decode it to raw bytes for Image.memory
        String base64String = match.group(1)!;

        // SVG files sometimes have line breaks inside base64 data — strip them
        base64String = base64String.replaceAll(RegExp(r'\s'), '');

        final Uint8List bytes = base64Decode(base64String);

        setState(() {
          imageBytes = bytes;
          isLoading = false;
        });
      } else {
        // No embedded base64 image — render the SVG directly as fallback
        setState(() {
          isLoading = false;
          isSvgLoaded = true;
        });
      }
    } catch (e) {
      // Catch any asset loading or decoding errors
      setState(() {
        errorMessage = 'Error loading image: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show spinner while SVG is being loaded and parsed
    if (isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    // Show error message if loading failed — avoids silent fallthrough to "No image"
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    // Fallback: no base64 found, render SVG asset directly
    if (isSvgLoaded) {
      return SvgPicture.asset(
        widget.svgAssetPath,
        height: widget.height,
        width: widget.width,
        // Show empty box while SVG renders instead of a blank flash
        placeholderBuilder: (_) => const SizedBox(),
      );
    }

    // Primary case: render the extracted base64 image as a memory image
    if (imageBytes != null) {
      return Container(
        padding: EdgeInsets.all(2),
        child: Image.memory(
          imageBytes!,
          fit: BoxFit.contain,
          height: widget.height ?? 65,
          width: widget.width ?? 65,
          errorBuilder: (context, error, stackTrace) {
            // Shown if the decoded bytes are not a valid image format
            return const Center(child: Text('Error displaying image'));
          },
        ),
      );
    }

    // Should rarely be reached — means no error, no SVG flag, no bytes
    return const Center(child: Text('No image to display'));
  }
}
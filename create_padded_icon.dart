import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final originalImage = File('assets/logos/outer logo.png');
  final bytes = await originalImage.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  
  // Create a smaller icon with 20% padding on each side
  final size = 1024;
  final padding = (size * 0.2).toInt();
  final iconSize = size - (padding * 2);
  
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Draw white background
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    Paint()..color = Colors.white,
  );
  
  // Draw the image centered with padding
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    Rect.fromLTWH(padding.toDouble(), padding.toDouble(), iconSize.toDouble(), iconSize.toDouble()),
    Paint(),
  );
  
  final picture = recorder.endRecording();
  final img = await picture.toImage(size, size);
  final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
  
  final outputFile = File('assets/logos/outer_logo_padded.png');
  await outputFile.writeAsBytes(pngBytes!.buffer.asUint8List());
  
  print('Padded icon created: ${outputFile.path}');
}

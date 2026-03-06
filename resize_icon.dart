import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final originalFile = File('assets/logos/outer logo.png');
  final bytes = await originalFile.readAsBytes();
  final image = img.decodeImage(bytes);
  
  if (image == null) {
    print('Failed to decode image');
    return;
  }
  
  final newSize = (image.width * 0.65).round();
  final resized = img.copyResize(image, width: newSize, height: newSize);
  
  final padded = img.Image(width: 1024, height: 1024);
  img.fill(padded, color: img.ColorRgba8(255, 255, 255, 0));
  
  final x = (1024 - newSize) ~/ 2;
  final y = (1024 - newSize) ~/ 2;
  img.compositeImage(padded, resized, dstX: x, dstY: y);
  
  final outputFile = File('assets/logos/outer_logo_padded.png');
  await outputFile.writeAsBytes(img.encodePng(padded));
  
  print('Created padded icon: ${outputFile.path}');
}

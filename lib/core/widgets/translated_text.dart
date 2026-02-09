import 'package:flutter/material.dart';
import '../services/translation_service.dart';

class TranslatedText extends StatelessWidget {
  final dynamic text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: TranslationService.getTranslation(context, text),
      builder: (context, snapshot) {
        return Text(
          snapshot.data ?? TranslationService.getTranslationSync(context, text),
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

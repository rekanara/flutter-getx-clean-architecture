import 'package:flutter/material.dart';

import '../../utils/config.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.maxLines,
    this.fontType = FontType.bodyMedium,
    this.color,
    this.opacity,
    this.weight,
    this.textAlign,
    this.decoration,
  });

  final String text;
  final int? maxLines;
  final FontType fontType;
  final Color? color;
  final FontWeight? weight;
  final double? opacity;
  final TextAlign? textAlign;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle? textStyle;
    switch (fontType) {
      case FontType.displayLarge:
        textStyle = theme.textTheme.displayLarge;
        break;
      case FontType.displayMedium:
        textStyle = theme.textTheme.displayMedium;
        break;
      case FontType.displaySmall:
        textStyle = theme.textTheme.displaySmall;
        break;
      case FontType.headlineLarge:
        textStyle = theme.textTheme.headlineLarge;
        break;
      case FontType.headlineMedium:
        textStyle = theme.textTheme.headlineMedium;
        break;
      case FontType.headlineSmall:
        textStyle = theme.textTheme.headlineSmall;
        break;
      case FontType.titleLarge:
        textStyle = theme.textTheme.titleLarge;
        break;
      case FontType.titleMedium:
        textStyle = theme.textTheme.titleMedium;
        break;
      case FontType.titleSmall:
        textStyle = theme.textTheme.titleSmall;
        break;
      case FontType.bodyLarge:
        textStyle = theme.textTheme.bodyLarge;
        break;
      case FontType.bodyMedium:
        textStyle = theme.textTheme.bodyMedium;
        break;
      case FontType.bodySmall:
        textStyle = theme.textTheme.bodySmall;
        break;
      case FontType.labelLarge:
        textStyle = theme.textTheme.labelLarge;
        break;
      case FontType.labelMedium:
        textStyle = theme.textTheme.labelMedium;
        break;
      case FontType.labelSmall:
        textStyle = theme.textTheme.labelSmall;
        break;
    }
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.left,
      style: textStyle?.copyWith(
        fontFamily: FontFamilyType.primary,
        fontWeight: weight ?? textStyle.fontWeight,
        overflow: TextOverflow.ellipsis,
        decoration: decoration,
        color: color != null
            ? color!.withValues(alpha: opacity ?? 1.0)
            : textStyle.color?.withValues(alpha: opacity ?? 1.0),
      ),
      maxLines: maxLines,
    );
  }
}

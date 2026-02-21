import 'package:flutter/material.dart';
import 'package:zidanfath_codebase/utils/config.dart';

import 'custom_text.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    this.onPressed,
    this.color,
    this.textColor,
    this.fontType,
    this.height,
    this.width,
    this.buttonType = CustomButtonType.filled,
    this.padding,
    this.borderRadius,
    this.widget,
    this.borderRadiusValue,
    this.fontWeight,
    this.enable = true,
  });

  final String title;
  final Function()? onPressed;
  final Color? color;
  final Color? textColor;
  final FontType? fontType;
  final double? height;
  final double? width;
  final CustomButtonType? buttonType;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Widget? widget;
  final BorderRadius? borderRadiusValue;
  final FontWeight? fontWeight;
  final bool? enable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (buttonType == CustomButtonType.outline) {
      return OutlinedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          side: WidgetStateProperty.all<BorderSide>(
            BorderSide(
              color: enable == true
                  ? color ?? theme.colorScheme.primary
                  : Colors.grey,
            ),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius:
                  borderRadiusValue ??
                  BorderRadius.circular(borderRadius ?? 16),
            ),
          ),
          minimumSize: WidgetStateProperty.all<Size>(
            Size(width ?? 100, height ?? 40),
          ),
        ),
        onPressed: onPressed,
        key: key,
        child:
            widget ??
            CustomText(
              text: title,
              fontType: fontType ?? FontType.bodyMedium,
              weight: fontWeight,
              color: textColor ?? theme.colorScheme.primary,
            ),
      );
    }

    return ElevatedButton(
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(
          enable == true ? color ?? theme.colorScheme.primary : Colors.grey,
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius:
                borderRadiusValue ?? BorderRadius.circular(borderRadius ?? 16),
          ),
        ),
        minimumSize: WidgetStateProperty.all<Size>(
          Size(width ?? 100, height ?? 40),
        ),
      ),
      onPressed: enable == true ? onPressed : null,
      key: key,
      child:
          widget ??
          CustomText(
            text: title,
            fontType: fontType ?? FontType.bodyMedium,
            weight: fontWeight,
            color: textColor ?? theme.buttonTheme.colorScheme?.onPrimary,
          ),
    );
    // : ElevatedButton(
    //   style: ButtonStyle(
    //     backgroundColor: WidgetStateProperty.all<Color>(color!),
    //     shape: WidgetStateProperty.all<RoundedRectangleBorder>(
    //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //     ),
    //   ),
    //   onPressed: () {},
    //   child: CustomText(text: title, fontType: fontType, colorText: textColor),
    // );
  }
}

enum CustomButtonType { outline, filled }

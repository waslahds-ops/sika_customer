import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.textStyles,
    required this.backgroundColor,
    this.borderRadius,
    required this.borderColor,
    this.isValid = true,
  });
  final VoidCallback onPressed;
  final String text;
  final TextStyle textStyles;
  final Color backgroundColor;
  final Color borderColor;
  final BorderRadius? borderRadius;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor, width: 2),
        ),
        onPressed: isValid ? onPressed : null,
        child: Text(text, style: textStyles),
      ),
    );
  }
}

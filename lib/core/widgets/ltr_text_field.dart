import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A helper widget that wraps a TextField to always use LTR (left-to-right) direction
/// This is useful when the app's Directionality is RTL (Arabic mode) but you want
/// the text input field to remain LTR (like for entering numbers, English text, etc.)
class LTRTextInput extends StatelessWidget {
  final TextField textField;

  const LTRTextInput({super.key, required this.textField});

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.ltr, child: textField);
  }
}

/// A TextField that always renders in LTR (left-to-right) direction
/// regardless of the app's locale (useful for keeping input fields LTR
/// even when the app is in RTL mode like Arabic)
class LTRTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final Color? cursorColor;
  final double? cursorWidth;
  final Radius? cursorRadius;
  final bool showCursor;
  final TextStyle? style;

  const LTRTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.left,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.initialValue,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
    this.showCursor = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: decoration,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textAlign: textAlign,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        obscureText: obscureText,
        readOnly: readOnly,
        enabled: enabled,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        onSubmitted: onSubmitted,
        inputFormatters: inputFormatters,
        cursorColor: cursorColor,
        cursorWidth: cursorWidth ?? 2.0,
        cursorRadius: cursorRadius,
        showCursor: showCursor,
        style: style,
      ),
    );
  }
}

/// A TextFormField that always renders in LTR (left-to-right) direction
/// regardless of the app's locale (useful for keeping input fields LTR
/// even when the app is in RTL mode like Arabic)
class LTRTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final Color? cursorColor;
  final double? cursorWidth;
  final Radius? cursorRadius;
  final bool showCursor;
  final TextStyle? style;

  const LTRTextFormField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.left,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.initialValue,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.autovalidateMode,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
    this.showCursor = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: decoration,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textAlign: textAlign,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        obscureText: obscureText,
        readOnly: readOnly,
        enabled: enabled,
        initialValue: initialValue,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: onFieldSubmitted,
        onSaved: onSaved,
        validator: validator,
        inputFormatters: inputFormatters,
        autovalidateMode: autovalidateMode,
        cursorColor: cursorColor,
        cursorWidth: cursorWidth ?? 2.0,
        cursorRadius: cursorRadius,
        showCursor: showCursor,
        style: style,
      ),
    );
  }
}

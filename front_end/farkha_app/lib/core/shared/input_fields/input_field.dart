import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constant/theme/colors.dart';
import '../../functions/input_validation.dart';

void _showHelpPopup(BuildContext anchorContext, String title, String helpText) {
  final renderBox = anchorContext.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  final isDark = Theme.of(anchorContext).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.grey[800]!;
  final position = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;
  final screenSize = MediaQuery.sizeOf(anchorContext);
  final rect = RelativeRect.fromRect(
    Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
    Offset.zero & screenSize,
  );

  showMenu<void>(
    context: anchorContext,
    position: rect,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor,
    elevation: 8,
    items: [
      PopupMenuItem<void>(
        enabled: false,
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                helpText,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor.withValues(alpha: 0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

/// Converts Arabic and Persian digits to English as user types.
class _ArabicToEnglishDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = InputValidation.normalizeToEnglishDigits(newValue.text);
    if (normalized == newValue.text) return newValue;
    final offset = newValue.selection.baseOffset.clamp(0, normalized.length);
    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

class InputField extends StatelessWidget {
  final String label;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final String? hintText;
  final String? suffixText;
  final Widget? suffixIcon;
  final BoxConstraints? suffixIconConstraints;
  final TextInputType? keyboardType;
  final bool allowZero;
  final String? helpText;
  final bool enableValidation;

  const InputField({
    super.key,
    required this.label,
    this.onChanged,
    this.controller,
    this.hintText,
    this.suffixText,
    this.suffixIcon,
    this.suffixIconConstraints,
    this.keyboardType = TextInputType.number,
    this.allowZero = false,
    this.helpText,
    this.enableValidation = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: [_ArabicToEnglishDigitsFormatter()],
      validator: enableValidation
          ? (v) =>
              InputValidation.validateAndFormatNumber(v, allowZero: allowZero)
          : null,
      decoration: InputDecoration(
        label: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child:
              helpText != null
                  ? Builder(
                    builder:
                        (labelContext) => GestureDetector(
                          onTap:
                              () => _showHelpPopup(
                                labelContext,
                                label,
                                helpText!,
                              ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(label, style: TextStyle(fontSize: 13.sp)),
                              Padding(
                                padding: EdgeInsets.only(right: 4.w),
                                child: Icon(
                                  Icons.help_outline,
                                  size: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                  )
                  : Text(label, style: TextStyle(fontSize: 13.sp)),
        ),
        hintText: hintText,
        suffixText: suffixIcon == null ? suffixText : null,
        suffixIcon: suffixIcon,
        suffixIconConstraints: suffixIconConstraints,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
      ),
      onChanged: (value) {
        // Ensure selection is valid after text change
        if (controller != null) {
          final textLength = controller!.text.length;
          final selection = controller!.selection;

          // Fix selection if it's out of bounds
          if (selection.start < 0 ||
              selection.start > textLength ||
              selection.end < 0 ||
              selection.end > textLength ||
              selection.start > selection.end) {
            controller!.selection = TextSelection.fromPosition(
              TextPosition(offset: textLength),
            );
          }
        }
        onChanged?.call(value);
      },
    );
  }
}

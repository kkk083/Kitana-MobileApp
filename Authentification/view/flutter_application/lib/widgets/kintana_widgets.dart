import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class KintanaLogo extends StatelessWidget {
  const KintanaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: KintanaDimensions.logoSize,
      height: KintanaDimensions.logoSize,
      decoration: const BoxDecoration(
        color: KintanaColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.star,
        color: Colors.white,
        size: KintanaDimensions.logoIconSize,
      ),
    );
  }
}

class KintanaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Color? backgroundColor;
  final Color? borderColor;
  final Widget? suffixIcon;

  const KintanaTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.backgroundColor,
    this.borderColor,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? KintanaColors.inputEmailBackground,
        borderRadius: BorderRadius.circular(
          KintanaDimensions.borderRadiusMedium,
        ),
        border: Border.all(color: borderColor ?? KintanaColors.inputBorder),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: KintanaDimensions.inputPadding,
      ),
      child: Row(
        children: [
          Icon(prefixIcon, color: KintanaColors.inputText),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: const TextStyle(color: KintanaColors.inputText),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: KintanaTextStyles.inputHint,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KintanaButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const KintanaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? KintanaColors.primary,
          foregroundColor: textColor ?? KintanaColors.white,
          padding: const EdgeInsets.symmetric(
            vertical: KintanaDimensions.buttonPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              KintanaDimensions.borderRadiusMedium,
            ),
          ),
          elevation: 0,
        ),
        child: Text(text, style: KintanaTextStyles.button),
      ),
    );
  }
}

class KintanaErrorMessage extends StatelessWidget {
  final String message;

  const KintanaErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KintanaColors.errorBackground,
        borderRadius: BorderRadius.circular(
          KintanaDimensions.borderRadiusSmall,
        ),
        border: Border.all(color: KintanaColors.errorBorder, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: KintanaColors.errorText,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: KintanaTextStyles.error)),
        ],
      ),
    );
  }
}

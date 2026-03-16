import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

enum ButtonVariant { primary, secondary, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? leadingIcon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.leadingIcon,
    this.width,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.width,
  }) : variant = ButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.width,
  }) : variant = ButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.width,
  }) : variant = ButtonVariant.text;

  Widget _buildChild() {
    if (isLoading) return _loadingSpinner();
    if (leadingIcon != null) return _iconLabelRow();
    return Text(label);
  }

  Widget _loadingSpinner() => const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );

  Widget _iconLabelRow() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leadingIcon, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final child = _buildChild();
    final wrappedChild = width != null
        ? SizedBox(width: width, child: Center(child: child))
        : child;

    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: wrappedChild,
        );
      case ButtonVariant.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: wrappedChild,
        );
      case ButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: wrappedChild,
        );
    }
  }
}

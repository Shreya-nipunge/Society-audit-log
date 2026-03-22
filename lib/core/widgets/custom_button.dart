import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable primary button with gradient option
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool useGradient;
  final IconData? icon;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.useGradient = true,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: 64,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(AppColors.primary),
        ),
      );
    }

    if (useGradient) {
      return SizedBox(
        width: width ?? double.infinity,
        height: 64,
        child: Container(
          decoration: BoxDecoration(
            gradient: onPressed != null && !isLoading
                ? AppColors.primaryGradient
                : null,
            color: onPressed == null || isLoading ? Colors.grey[400] : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: onPressed != null && !isLoading
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Center(child: _buildChild(AppColors.textOnPrimary)),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(AppColors.textOnPrimary),
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 28,
        width: 28,
        child: CircularProgressIndicator(
          strokeWidth: 3.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.button.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(text, style: AppTextStyles.button.copyWith(color: color));
  }
}

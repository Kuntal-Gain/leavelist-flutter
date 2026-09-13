import 'package:flutter/material.dart';
import 'package:leavelist/core/constants/app_sizes.dart';
import 'package:leavelist/core/exports/app_exports.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textAlign = TextAlign.center,
    this.trailingIcon,
    this.isLoading = false,
    this.color,
    this.textColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final TextAlign textAlign;
  final IconData? trailingIcon;
  final bool isLoading;
  final Color? color;
  final Color? textColor;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = color ?? theme.colorScheme.primary;
    final fgColor = textColor ?? theme.colorScheme.onPrimary;
    final enabled = !isLoading && onPressed != null;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: enabled ? bgColor : bgColor.withValues(alpha: 0.2),
          
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: textAlign == TextAlign.center
                          ? MainAxisAlignment.center
                          : textAlign == TextAlign.left
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          text,
                          textAlign: textAlign,
                          style: TextStyle(color: fgColor, fontWeight: FontWeight.w500, fontSize: context.sp(AppSizes.s12)),
                        ),
                        
                        if (trailingIcon != null) ...[
                          // const SizedBox(width: 8),
                          Spacer(),
                          Icon(trailingIcon, size: 18, color: fgColor),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
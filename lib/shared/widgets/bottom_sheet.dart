import 'package:flutter/material.dart';
import 'package:leavelist/core/exports/app_exports.dart';

/// A reusable bottom sheet with customizable title, content, actions,
/// drag handle, and layout options.
///
/// Usage:
/// ```dart
/// AppBottomSheet.show(
///   context: context,
///   title: 'Filter options',
///   child: const MyFilterForm(),
///   actions: [
///     AppButton(text: 'Apply', onPressed: () => context.pop()),
///   ],
/// );
/// ```
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.actions,
    this.showDragHandle = true,
    this.showCloseButton = false,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.isScrollControlled = true,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showDragHandle;
  final bool showCloseButton;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final bool isScrollControlled;

  /// Shows the bottom sheet and returns the value passed to `Navigator.pop`.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    String? subtitle,
    List<Widget>? actions,
    bool showDragHandle = true,
    bool showCloseButton = false,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useSafeArea = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: useSafeArea,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        subtitle: subtitle,
        actions: actions,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        padding: padding,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: borderRadius ??
            BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: (padding ??
              EdgeInsets.fromLTRB(
                AppSizes.xlp,
                AppSizes.mp,
                AppSizes.xlp,
                AppSizes.xlp,
              )).add(EdgeInsets.only(bottom: bottomInset)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showDragHandle) ...[
                Center(
                  child: Container(
                    width: AppSizes.s46,
                    height: AppSizes.s4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppSizes.r4),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.mp),
              ],
              if (title != null || showCloseButton) ...[
                Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title!, style: AppTypography.titleLarge),
                            if (subtitle != null) ...[
                              SizedBox(height: AppSizes.s2),
                              Text(subtitle!, style: AppTypography.bodySmall),
                            ],
                          ],
                        ),
                      ),
                    if (showCloseButton)
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(AppSizes.s4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: AppSizes.s18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppSizes.mp),
              ],
              Flexible(child: child),
              if (actions != null && actions!.isNotEmpty) ...[
                SizedBox(height: AppSizes.mp),
                Row(
                  children: [
                    for (int i = 0; i < actions!.length; i++) ...[
                      if (i > 0) SizedBox(width: AppSizes.mp),
                      Expanded(child: actions![i]),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

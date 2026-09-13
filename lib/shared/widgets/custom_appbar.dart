import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leavelist/core/exports/app_exports.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.isCenter = false,
    this.backgroundColor,
    this.elevation = 0,
    this.onLeadingPressed,
    this.leadingWidth,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final Function()? onLeadingPressed;
  final List<Widget>? trailing;
  final bool isCenter;
  final Color? backgroundColor;
  final double elevation;
  final double? leadingWidth;

  @override
  Size get preferredSize => Size.fromHeight(
        subtitle != null ? kToolbarHeight + 16 : kToolbarHeight,
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: isCenter,
      leadingWidth: leadingWidth,
      leading: onLeadingPressed != null ? Center(
        child: GestureDetector(
          onTap: onLeadingPressed ?? () => context.pop(),
          child: Container(
            height: context.heightWithFraction(0.045),
            width: context.heightWithFraction(0.045),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSizes.r8),
            ),
            child: Icon(leading, color: AppColors.white),
          ),
        ),
      ) : null,
      automaticallyImplyLeading: leading != null,
      title: subtitle == null
          ? Text(title, style: AppTypography.labelLarge.copyWith(
            fontSize: context.sp(16),
            fontWeight: FontWeight.w400,
          ))
          : Column(
              crossAxisAlignment:
                  isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                ),
              ],
            ),
      actions: trailing,
    );
  }
}
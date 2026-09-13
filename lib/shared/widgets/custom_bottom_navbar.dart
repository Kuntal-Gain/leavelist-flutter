import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:leavelist/core/exports/app_exports.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({required this.icon, required this.activeIcon, required this.label});
}

class CustomBottomNavbar extends StatelessWidget {
  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(AppSizes.lp), vertical: context.h(AppSizes.sp)),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isActive = index == currentIndex;
            final item = items[index];

            return _NavItemView(
              item: item,
              isActive: isActive,
              onTap: () => onTap(index),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemView extends StatefulWidget {
  const _NavItemView({required this.item, required this.isActive, required this.onTap});

  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavItemView> createState() => _NavItemViewState();
}

class _NavItemViewState extends State<_NavItemView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    reverseDuration: const Duration(milliseconds: 260),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant _NavItemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward(from: 0);
      } else {
        _controller.reverse(from: 1);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // liquid "drop" curve: overshoots past 1 then settles, driving a
              // squash-and-stretch wobble instead of a plain linear scale.
              final drop = widget.isActive
                  ? Curves.elasticOut.transform(_controller.value)
                  : Curves.easeIn.transform(_controller.value);
              final wobble = math.sin(drop * math.pi).clamp(-1.0, 1.0);

              final scaleX = 1 + (wobble * 0.22) - (drop.clamp(0, 1) * 0.0);
              final scaleY = 1 - (wobble * 0.22);
              final fill = drop.clamp(0.0, 1.0);
              final dropOffset = (1 - drop) * -6;

              return Transform.translate(
                offset: Offset(0, dropOffset.clamp(-10, 10)),
                child: Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..scaleByDouble(scaleX, scaleY, 1, 1),
                  child: Container(
                    padding: EdgeInsets.all(context.w(AppSizes.s6)),
                    decoration: BoxDecoration(
                      color: Color.lerp(AppColors.transparent, AppColors.primary, fill),
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                      boxShadow: fill > 0
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35 * fill),
                                blurRadius: 10 * fill,
                                spreadRadius: 0.5 * fill,
                              ),
                            ]
                          : null,
                    ),
                    child: child,
                  ),
                ),
              );
            },
            child: Icon(
              widget.isActive ? widget.item.activeIcon : widget.item.icon,
              size: context.sp(AppSizes.s18),
              color: widget.isActive ? AppColors.white : AppColors.textTertiary,
            ),
          ),
          context.sizeV(AppSizes.s2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            style: AppTypography.labelLarge.copyWith(
              fontSize: context.sp(AppSizes.s10),
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
              color: widget.isActive ? AppColors.primary : AppColors.textTertiary,
            ),
            child: Text(widget.item.label),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:leavelist/core/exports/app_exports.dart';

/// Teardrop-shaped custom marker rendered as a real widget, then snapshotted
/// into a bitmap for use with GoogleMap markers.
class MapPinWidget extends StatelessWidget {
  const MapPinWidget({
    super.key,
    required this.icon,
    this.isSelected = false,
  });

  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textPrimary;

    return Center(
      child: CustomPaint(
        painter: _PinShadowPainter(color: color),
        child: SizedBox(
          width: 56,
          height: 68,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: AppColors.white, size: 16),
                ),
              ),
              Positioned(
                top: 38,
                child: CustomPaint(
                  size: const Size(16, 14),
                  painter: _PinTailPainter(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  const _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) => oldDelegate.color != color;
}

class _PinShadowPainter extends CustomPainter {
  final Color color;
  const _PinShadowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, 58), width: 18, height: 6),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PinShadowPainter oldDelegate) => false;
}

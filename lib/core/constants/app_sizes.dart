import 'package:flutter/material.dart';

/// Base design dimensions — set to whatever your Figma/design frame uses.
const double _kBaseWidth = 375.0;
const double _kBaseHeight = 812.0;

class AppSizes {
  AppSizes._();

  // base (unscaled) values — kept for places that need a raw constant
  // (e.g. inside painters, or non-context code)
  static const double s0   = 0.0;
  static const double s1   = 1.0;
  static const double s2   = 2.0;
  static const double s4   = 4.0;
  static const double s6   = 6.0;
  static const double s8   = 8.0;
  static const double s10  = 10.0;
  static const double s12  = 12.0;
  static const double s14  = 14.0;
  static const double s16  = 16.0;
  static const double s18  = 18.0;
  static const double s20  = 20.0;
  static const double s22  = 22.0;
  static const double s24  = 24.0;
  static const double s26  = 26.0;
  static const double s28  = 28.0;
  static const double s32  = 32.0;
  static const double s46  = 46.0;
  static const double s64  = 64.0;

  static const double sp   = 4.0;
  static const double mp   = 8.0;
  static const double lp   = 12.0;
  static const double xlp  = 16.0;
  static const double xxlp = 24.0;

  static const double r2   = 2.0;
  static const double r4   = 4.0;
  static const double r6   = 6.0;
  static const double r8   = 8.0;
  static const double r12  = 12.0;
  static const double r16  = 16.0;
}

/// Holds the current screen's scale factors. Compute once per build via
/// context.sizes, avoids recomputing MediaQuery.sizeOf() per call site.
class ScreenScale {
  final double widthFactor;
  final double heightFactor;
  final double textFactor;

  const ScreenScale({
    required this.widthFactor,
    required this.heightFactor,
    required this.textFactor,
  });

  double w(double value) => value * widthFactor;
  double h(double value) => value * heightFactor;
  // font scaling: clamp so text doesn't blow up on tablets/foldables
  double sp(double value) => (value * textFactor).clamp(value * 0.85, value * 1.3);
}

extension MediaQueryValues on BuildContext {
  double get width  => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;

  double heightWithFraction(double fraction) => MediaQuery.sizeOf(this).height * fraction;
  double widthWithFraction(double fraction)  => MediaQuery.sizeOf(this).width * fraction;

  /// Scale helper — cheap since MediaQuery.sizeOf is already O(1) + cached
  /// per frame by Flutter's InheritedModel diffing.
  ScreenScale get sizes {
    final size = MediaQuery.sizeOf(this);
    return ScreenScale(
      widthFactor: size.width / _kBaseWidth,
      heightFactor: size.height / _kBaseHeight,
      // average width/height factor tends to look better for font scaling
      // than width alone (avoids huge text on tall narrow phones)
      textFactor: ((size.width / _kBaseWidth) + (size.height / _kBaseHeight)) / 2,
    );
  }

  // ---- responsive shorthand, replaces raw AppSizes.sX at call sites ----
  double w(double value) => sizes.w(value);
  double h(double value) => sizes.h(value);
  double sp(double value) => sizes.sp(value);

  // sized boxes — now screen-aware
  Widget sizeV(double height)                => SizedBox(height: h(height));
  Widget sizeH(double width)                 => SizedBox(width: w(width));
  Widget sizeVH(double width, double height) => SizedBox(width: w(width), height: h(height));
  Widget sizeVWithFraction(double fraction)  => SizedBox(height: heightWithFraction(fraction));
  Widget sizeHWithFraction(double fraction)  => SizedBox(width: widthWithFraction(fraction));
}
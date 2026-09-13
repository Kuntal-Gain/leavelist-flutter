import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---- brand ----
  static const Color primary        = Color(0xFFFF7A1A); // core orange
  static const Color primaryDark    = Color(0xFFE0620A); // pressed/darker states
  static const Color primaryLight   = Color(0xFFFFE8D6); // tint bg, chips, highlights

  // ---- neutrals (white-forward minimalist scale) ----
  static const Color background     = Color(0xFFFFFFFF);
  static const Color surface        = Color(0xFFFAFAFA); // cards, sheets — slight lift off bg
  static const Color surfaceAlt     = Color(0xFFF2F2F2); // input fields, divid-ish fills

  static const Color textPrimary    = Color(0xFF1A1A1A);
  static const Color textSecondary  = Color(0xFF6B6B6B);
  static const Color textTertiary   = Color(0xFFA0A0A0); // hints, disabled labels

  static const Color border         = Color(0xFFE5E5E5);
  static const Color divider        = Color(0xFFEFEFEF);

  // ---- semantic ----
  static const Color success        = Color(0xFF2E9E5B);
  static const Color error          = Color(0xFFE04B3F);
  static const Color warning        = Color(0xFFF2B138);

  // ---- utility ----
  static const Color white          = Color(0xFFFFFFFF);
  static const Color black          = Color(0xFF000000);
  static const Color transparent    = Colors.transparent;
  static const Color shadow         = Color(0x1A000000); // 10% black, for elevation

  // ---- disabled/inactive states ----
  static const Color disabledBg     = Color(0xFFF0F0F0);
  static const Color disabledText   = Color(0xFFBDBDBD);
}
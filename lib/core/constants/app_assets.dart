import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class AppAssets {
  AppAssets._();

  static const String logo                      = 'assets/images/logo.svg';
  static const String banner                    = 'assets/images/banner.svg';
  static const String splash                    = 'assets/images/splash.svg';

  static const String emptyState                = 'assets/images/empty-state.svg';
  static const String errorState                = 'assets/images/error-state.svg';     
  static const String configureAddr             = 'assets/images/address.svg';
  static const String pageNotFound              = 'assets/images/404.svg';
}

extension SvgAssetExtension on String {
  Widget get svg => SvgPicture.asset(this);
}
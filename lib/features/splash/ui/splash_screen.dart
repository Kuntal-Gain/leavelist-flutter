import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leavelist/core/exports/app_exports.dart';
import 'package:leavelist/core/routes/app_routes.dart';
import 'package:leavelist/shared/buttons/app_btn.dart';
import 'package:leavelist/shared/wrapper/screen_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // local state variables
  bool isLoading = false;

Future<void> handleGetStarted() async {
  setState(() => isLoading = true);

  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return; // guard against navigating/setState after widget disposed
  context.push(AppRoutes.home);

  setState(() => isLoading = false); // optional — screen is navigating away anyway
}

  @override
  Widget build(BuildContext context) {
    return AppScreen(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xxlp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _logoWidget(context),
              const SizedBox(height: AppSizes.s24),
              Expanded(child: _splashWidget(context)),
               SizedBox(height: AppSizes.s32),
              _splashText(),
               SizedBox(height: AppSizes.s32),
              AppButton(
                text: 'Get Started',
                trailingIcon: AppIcons.next,
                isLoading: isLoading,
                onPressed: handleGetStarted,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
  }
}

Widget _logoWidget(BuildContext ctx) {
  return SizedBox(
    height: ctx.heightWithFraction(0.1),
    width: double.infinity,
    child: AppAssets.banner.svg,
  );
}

Widget _splashWidget(BuildContext ctx) {
  return AppAssets.splash.svg;
}

Widget _splashText() {
  return Column(
    children: [
      Text(
        'Welcome to ${AppConstants.appName}',
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.primary,
          fontSize: 22,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Make sure you have everything you need before heading out. Create your own lists, check off important items, and leave home with confidence knowing you haven\'t forgotten a thing.',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w200,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}
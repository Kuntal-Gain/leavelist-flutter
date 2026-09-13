import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leavelist/core/exports/app_exports.dart';
import 'package:leavelist/core/routes/app_routes.dart';
import 'package:leavelist/features/home/ui/home_screen.dart';
import 'package:leavelist/features/splash/ui/splash_screen.dart';
import 'package:leavelist/shared/buttons/app_btn.dart';
import 'package:leavelist/shared/widgets/custom_appbar.dart';
import 'package:leavelist/shared/wrapper/screen_wrapper.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: _RouteErrorScreen(message: 'Page not found: ${state.uri.path}'),
    ),
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) =>  HomeScreen(),
      ),
      // GoRoute(
      //   path: AppRoutes.addresses,
       
      //   builder: (context, state) => const ManageLocationsScreen(),
      //   routes: [
      //     GoRoute(
      //       path: 'add',
            
      //       parentNavigatorKey: rootNavigatorKey,
      //       pageBuilder: (context, state) => MaterialPage(
      //         key: state.pageKey,
      //         fullscreenDialog: true,
      //         child: const AddEditLocationScreen(),
      //       ),
      //     ),
      //     GoRoute(
      //       path: 'edit',
           
      //       parentNavigatorKey: rootNavigatorKey,
      //       pageBuilder: (context, state) {
      //         final location = state.extra as SavedLocation?;
      //         if (location == null) {
      //           return MaterialPage(
      //             key: state.pageKey,
      //             child: const _RouteErrorScreen(message: 'No location provided'),
      //           );
      //         }
      //         return MaterialPage(
      //           key: state.pageKey,
      //           fullscreenDialog: true,
      //           child: AddEditLocationScreen(location: location),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      // GoRoute(
      //   path: AppRoutes.addressItems,
      //   name: 'addressItems',
      //   builder: (context, state) {
      //     final locationId = state.uri.queryParameters['locationId'];
      //     final locationLabel = state.uri.queryParameters['label'] ?? '';
      //     if (locationId == null) {
      //       return const _RouteErrorScreen(message: 'No locationId provided');
      //     }
      //     return ChecklistScreen(
      //       locationId: locationId,
      //       locationLabel: locationLabel,
      //     );
      //   },
      // ),
    ],
  );
}

class _RouteErrorScreen extends StatelessWidget {
  final String message;
  const _RouteErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      topPadding: 16,
      child: Scaffold(
        appBar: CustomAppbar(
          title: 'Error',
          leading: AppIcons.navLeft,
          isCenter: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.w(AppSizes.s24)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppAssets.pageNotFound.svg,
                      context.sizeV(AppSizes.s24),
                      Text(
                        "The page you're looking for isn't available.\nPlease contact the developer.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.sp(AppSizes.s14),
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(AppSizes.s16),
                0,
                context.w(AppSizes.s16),
                context.h(AppSizes.s16),
              ),
              child: AppButton(text: "Go Back", onPressed: () => context.pop()),
            ),
          ],
        ),
      ),
    );
  }
}
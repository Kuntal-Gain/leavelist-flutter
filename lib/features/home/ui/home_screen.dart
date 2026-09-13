import 'package:flutter/material.dart';
import 'package:leavelist/core/exports/app_exports.dart';
import 'package:leavelist/features/home/ui/address_screen.dart';
import 'package:leavelist/features/home/ui/home_map_view.dart';
import 'package:leavelist/shared/widgets/custom_appbar.dart';
import 'package:leavelist/shared/widgets/custom_bottom_navbar.dart';
import 'package:leavelist/shared/wrapper/screen_wrapper.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _navItems = [
    NavItem(icon: AppIcons.homeOutline, activeIcon: AppIcons.home, label: "Home"),
    NavItem(icon: AppIcons.locationOutline, activeIcon: AppIcons.location, label: "Address"),
    NavItem(icon: AppIcons.settingsOutline, activeIcon: AppIcons.settings, label: "Settings"),
  ];

  void _onAddPressed() {
    // TODO: Implement add functionality
    print('Add button pressed');
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeMapView(),
      AddressScreen(onAddAddress: () => setState(() => _currentIndex = 0)),
      const Center(child: Text("Settings")),
    ];

    return AppScreen(
      header: CustomAppbar(title: "Home", isCenter: true),

      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      topPadding: 0,
      child: IndexedStack(index: _currentIndex, children: screens),
    );
  }
}

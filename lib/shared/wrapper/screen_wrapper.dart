import 'package:flutter/material.dart';

class AppScreen extends StatefulWidget {
  final Widget child;
  final PreferredSizeWidget? header;
  final double topPadding;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  const AppScreen({super.key, required this.child, this.header, this.topPadding = 20, this.bottomNavigationBar,this.floatingActionButton});

  @override
  State<AppScreen> createState() => AppScreenState();
}

class AppScreenState extends State<AppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.header,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(top: widget.topPadding),
          child: widget.child,
        ),
      ),
    );

  }
}

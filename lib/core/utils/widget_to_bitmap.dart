import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Renders an arbitrary widget off-screen and converts it into a
/// [BitmapDescriptor], so Google Maps markers can look like real Flutter
/// widgets instead of static marker images.
class WidgetToBitmap {
  WidgetToBitmap._();

  static Future<BitmapDescriptor> convert(
    BuildContext context,
    Widget widget, {
    Size logicalSize = const Size(120, 120),
  }) async {
    final repaintBoundaryKey = GlobalKey();
    final overlay = Overlay.of(context, rootOverlay: true);
    final mediaQueryData = MediaQuery.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: -logicalSize.width * 2,
        top: -logicalSize.height * 2,
        child: MediaQuery(
          data: mediaQueryData,
          child: Material(
            color: Colors.transparent,
            child: RepaintBoundary(
              key: repaintBoundaryKey,
              child: SizedBox(
                width: logicalSize.width,
                height: logicalSize.height,
                child: widget,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // let the offscreen widget lay out and paint before capturing it.
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;

    final boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: mediaQueryData.devicePixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    entry.remove();

    return BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      width: logicalSize.width,
      height: logicalSize.height,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:letdem/common/popups/popup_container.dart';

class AppPopup {
  static Future showDialogSheet(BuildContext context, Widget child) {
    return showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (context) => Center(child: PopupContainer(child: child)),
    );
  }

  static showBottomSheet(BuildContext context, Widget child) {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.1),
      context: context,
      builder: (context) => PopupContainer(
        bottomSheet: true,
        child: child,
      ),
    );
  }
}

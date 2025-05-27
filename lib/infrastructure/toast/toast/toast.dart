import 'package:flashy_flushbar/flashy_flushbar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';

class Toast {
  static void showError(String message) {
    FlashyFlushbar(
      messageStyle: Typo.mediumBody.copyWith(color: Colors.white),
      leadingWidget: const Icon(
        Icons.error_outline,
        color: Colors.white,
        size: 24,
      ),
      message: message,
      animationDuration: const Duration(milliseconds: 500),
      duration: const Duration(milliseconds: 4000),
      backgroundColor: AppColors.red500,
      trailingWidget: IconButton(
        icon: const Icon(
          Icons.close,
          color: Colors.white,
          size: 24,
        ),
        onPressed: () {
          FlashyFlushbar.cancel();
        },
      ),
      isDismissible: false,
    ).show();
  }

  static void showWarning(String message) {
    FlashyFlushbar(
      leadingWidget: const Icon(
        Icons.warning_amber_outlined,
        color: Colors.black,
        size: 24,
      ),
      duration: const Duration(milliseconds: 5000),
      message: message,
      backgroundColor: Colors.orangeAccent,
      trailingWidget: IconButton(
        icon: const Icon(
          Icons.close,
          color: Colors.black,
          size: 24,
        ),
        onPressed: () {
          FlashyFlushbar.cancel();
        },
      ),
      isDismissible: false,
    ).show();
  }

  static void show(String message) {
    FlashyFlushbar(
      messageStyle: Typo.mediumBody.copyWith(
        color: Colors.black,
      ),
      leadingWidget: const Icon(
        Iconsax.tick_circle,
        color: Colors.green,
        size: 24,
      ),
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.white,
      trailingWidget: IconButton(
        icon: const Icon(
          Icons.close,
          color: Colors.white,
          size: 24,
        ),
        onPressed: () {
          FlashyFlushbar.cancel();
        },
      ),
      isDismissible: false,
    ).show();
  }
}

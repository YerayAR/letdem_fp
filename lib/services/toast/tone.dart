import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToneHelper {
  static final player = AudioPlayer();

  static play() {
    player.play(AssetSource('audio/tone.mp3'));
  }
}

class AlertHelper {
  static void showWarning({
    required BuildContext context,
    required String title,
    required String subtext,
  }) {
    // Play the warning tone
    ToneHelper.play();

    toastification.show(
      context: context,
      alignment: Alignment.bottomCenter,
      type: ToastificationType.warning,
      style: ToastificationStyle.minimal,
      autoCloseDuration: const Duration(seconds: 5),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      description: Text(
        subtext,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
        ),
      ),
      animationDuration: const Duration(milliseconds: 500),
      icon: CircleAvatar(
        radius: 23,
        backgroundColor: const Color(0xFFFF5722).withOpacity(0.1),
        child: const Icon(Icons.warning_rounded, color: Color(0xFFFF5722)),
      ),
      showIcon: true,
      primaryColor: const Color(0xFFFF5722),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      borderRadius: BorderRadius.circular(20),
      closeOnClick: true,
    );
  }
}

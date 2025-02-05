import 'package:flutter/material.dart';

class SettingsContainer extends StatelessWidget {
  final Widget child;

  final bool isExpanded;
  const SettingsContainer(
      {super.key, required this.child, this.isExpanded = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: isExpanded ? 1 : 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 25,
          horizontal: 25,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      ),
    );
  }
}

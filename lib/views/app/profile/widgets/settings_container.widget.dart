import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letdem/constants/ui/colors.dart';

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
          vertical: 20,
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

class ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.8,
      child: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary500,
      ),
    );
  }
}

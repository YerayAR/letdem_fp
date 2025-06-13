import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letdem/core/extensions/locale.dart';

Future<Duration?> showMMSSPicker({
  required BuildContext context,
  Duration? initialDuration,
}) async {
  int minutes = initialDuration?.inMinutes.remainder(60) ?? 0;
  int seconds = initialDuration?.inSeconds.remainder(60) ?? 0;

  return await showCupertinoModalPopup<Duration>(
    context: context,
    builder: (BuildContext context) {
      return Material(
        child: Container(
          height: 300,
          padding: const EdgeInsets.only(top: 16),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              // Toolbar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(context.l10n.cancel),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      context.l10n.selectDuration,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(context.l10n.done),
                      onPressed: () {
                        Navigator.of(context).pop(
                          Duration(minutes: minutes, seconds: seconds),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController:
                            FixedExtentScrollController(initialItem: minutes),
                        itemExtent: 32,
                        onSelectedItemChanged: (int index) {
                          minutes = index;
                        },
                        children: List<Widget>.generate(60, (int index) {
                          return Center(
                            child: Text(index.toString().padLeft(2, '0')),
                          );
                        }),
                      ),
                    ),
                    const Text(
                      ":",
                      style: TextStyle(fontSize: 20),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController:
                            FixedExtentScrollController(initialItem: seconds),
                        itemExtent: 32,
                        onSelectedItemChanged: (int index) {
                          seconds = index;
                        },
                        children: List<Widget>.generate(60, (int index) {
                          return Center(
                            child: Text(index.toString().padLeft(2, '0')),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(context.l10n.minutes, textAlign: TextAlign.center),
                  ),
                  Expanded(
                    child: Text(context.l10n.sec, textAlign: TextAlign.center),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}

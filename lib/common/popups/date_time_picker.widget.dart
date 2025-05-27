import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

class PlatformTimePickerButton extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;
  final bool isSelected;

  const PlatformTimePickerButton({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
    this.isSelected = false,
  });

  @override
  State<PlatformTimePickerButton> createState() =>
      _PlatformTimePickerButtonState();
}

class _PlatformTimePickerButtonState extends State<PlatformTimePickerButton> {
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();

    selectedTime = widget.initialTime;
  }

  // Android Material style time picker
  Future<void> _showMaterialTimePicker(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.purple, // Header background
              onPrimary: Colors.white, // Header text
              onSurface: Colors.black, // Dial text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
        // Format the time based on user's locale or specific format
      });
      widget.onTimeSelected(pickedTime);
    }
  }

  // iOS Cupertino style time picker
  void _showCupertinoTimePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 280,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: const Text(
                        'Done',
                        style: TextStyle(color: CupertinoColors.activeBlue),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onTimeSelected(selectedTime);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    // set 24 hour format

                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      selectedTime.hour,
                      selectedTime.minute,
                    ),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        selectedTime = TimeOfDay(
                          hour: newDateTime.hour,
                          minute: newDateTime.minute,
                        );
                      });
                    },
                    use24hFormat: true, // Set to true for 24h format
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to format TimeOfDay as a string
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Format time in 24-hour format
    final String formattedTime =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.isSelected
                ? Colors.purple
                : Colors.grey.withOpacity(0.4),
            width: widget.isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(24),
          color: widget.isSelected
              ? Colors.purple.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: TextButton(
          onPressed: () {
            if (Platform.isIOS) {
              _showCupertinoTimePicker(context);
            } else {
              _showMaterialTimePicker(context);
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTimeOfDay(selectedTime),
                style: TextStyle(
                  color: widget.isSelected ? Colors.purple : Colors.black,
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Icon(
                IconlyLight.time_circle,
                size: 23,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlatformDatePickerButton extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final bool isSelected;

  const PlatformDatePickerButton({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    this.isSelected = false,
  });

  @override
  State<PlatformDatePickerButton> createState() =>
      _PlatformDatePickerButtonState();
}

class _PlatformDatePickerButtonState extends State<PlatformDatePickerButton> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  // Android Material style date picker
  Future<void> _showMaterialDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.purple, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // iOS Cupertino style date picker
  void _showCupertinoDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 280,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: const Text(
                        'Done',
                        style: TextStyle(color: CupertinoColors.activeBlue),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onDateSelected(selectedDate);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate.isBefore(DateTime.now())
                        ? DateTime.now()
                        : selectedDate,
                    minimumDate: DateTime(DateTime.now().year,
                        DateTime.now().month, DateTime.now().day),
                    maximumDate: DateTime(2100),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        selectedDate = newDateTime;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.isSelected
                ? Colors.purple
                : Colors.grey.withOpacity(0.4),
            width: widget.isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(24),
          color: widget.isSelected
              ? Colors.purple.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: TextButton(
          onPressed: () {
            if (Platform.isIOS) {
              _showCupertinoDatePicker(context);
            } else {
              _showMaterialDatePicker(context);
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // 11/2/2025
                DateFormat('MM/dd/yyyy').format(selectedDate),
                style: TextStyle(
                  color: widget.isSelected ? Colors.purple : Colors.black,
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Icon(
                IconlyLight.calendar,
                color: Colors.black54,
                size: 23,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

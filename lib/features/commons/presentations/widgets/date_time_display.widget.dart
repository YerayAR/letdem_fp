import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letdem/core/utils/dates.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/constants/colors.dart';


class DateTimeDisplay extends StatelessWidget {
  final DateTime date;

  const DateTimeDisplay({
    super.key,
    required this.date, // Mandatory parameter
  });

  @override
  Widget build(BuildContext context) {
    // Format date for display

    return Row(
      spacing: 5,
      children: [
        Text(
          formatDate(date, context),
          style: Typo.mediumBody.copyWith(
            fontSize: 14,
            color: AppColors.neutral400,
          ),
        ),
        CircleAvatar(
          radius: 3,
          backgroundColor: AppColors.neutral200,
        ),
        Text(
          DateFormat("HH:mm").format(
            (date.toLocal()),
          ),
          style: Typo.mediumBody.copyWith(
            fontSize: 14,
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }
}
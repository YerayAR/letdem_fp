import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/activities/dto/take_space.dto.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

class ParkingRatingWidget extends StatefulWidget {
  final VoidCallback onSubmit;

  final String spaceID;
  const ParkingRatingWidget(
      {super.key, required this.onSubmit, required this.spaceID});

  @override
  _ParkingRatingWidgetState createState() => _ParkingRatingWidgetState();
}

class _ParkingRatingWidgetState extends State<ParkingRatingWidget> {
  TakeSpaceType? _selectedOption;
  bool _submitted = false;
  late List<Map<String, dynamic>> _options;

  void _inizializeOptions() {
    _options = [
    {
      'id': 'take',
      'label': context.l10n.illTakeIt,
      'icon': Icons.thumb_up,
      'color': Colors.green.shade100,
      "enum": TakeSpaceType.TAKE_IT,
      'iconColor': Colors.green
    },
    {
      'id': 'inuse',
      'label': context.l10n.itsInUse,
      'icon': Icons.directions_car,
      "enum": TakeSpaceType.IN_USE,
      'color': AppColors.primary500.withOpacity(0.1),
      'iconColor': AppColors.primary500
    },
    {
      'id': 'notuseful',
      'label': context.l10n.notUseful,
      "enum": TakeSpaceType.NOT_USEFUL,
      'icon': Icons.thumb_down,
      'color': Colors.amber.shade100,
      'iconColor': Colors.amber.shade700
    },
    {
      'id': 'prohibited',
      'label': context.l10n.prohibited,
      "enum": TakeSpaceType.PROHIBITED,
      'icon': Icons.not_interested,
      'color': Colors.red.shade100,
      'iconColor': Colors.red
    },
  ];
  }

  void _handleSubmit() {
    context.read<ActivitiesBloc>().add(
          TakeSpaceEvent(
            type: _selectedOption as TakeSpaceType,
            spaceID: widget.spaceID,
          ),
        );
    return;

    if (_selectedOption != null) {
      setState(() {
        _submitted = true;
      });
      // Here you would typically send data to backend
      print('Selected option: $_selectedOption');
    }
  }

  void _resetForm() {
    setState(() {
      _selectedOption = null;
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _inizializeOptions();
    return _buildRatingForm();
  }

  Widget _buildRatingForm() {
    return BlocConsumer<ActivitiesBloc, ActivitiesState>(
      listener: (context, state) {
        if (state is ActivitiesPublished) {
          // Show success message
          AppPopup.showDialogSheet(
            context,
            SuccessDialog(
              title: context.l10n.feedbackSubmitted,
              subtext: context.l10n.thankYouForInput,
              onProceed: () {
                NavigatorHelper.pop();
                NavigatorHelper.pop();
                widget.onSubmit();
              },
            ),
          );
        }
        // TODO: implement listener
      },
      builder: (context, state) {
        return Container(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Dimens.space(3),
                // Location icon
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Text
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.l10n.arrivedAtDestination,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.rateThisParkingSpace,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Dimens.space(3),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rating options
                      ..._options.map((option) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedOption = option['enum'];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _selectedOption == option['enum']
                                  ? (option['color'] as Color).withOpacity(0.4)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _selectedOption == option['enum']
                                    ? option['iconColor']
                                    : Colors.grey.withOpacity(0.4),
                              ),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      (option['iconColor'] as Color)
                                          .withOpacity(0.1),
                                  child: Icon(option['icon'],
                                      color: option['iconColor']),
                                ),
                                const SizedBox(height: 5),
                                Text(option['label']),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                Dimens.space(4),

                // Submit Button
                PrimaryButton(
                  text: context.l10n.done,
                  isLoading: state is ActivitiesLoading,
                  onTap: _submitted ? null : _handleSubmit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

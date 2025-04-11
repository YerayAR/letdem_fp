import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/activities/screens/activities.view.dart';
import 'package:letdem/views/app/activities/widgets/contribution_item.widget.dart';

import '../../../../global/widgets/appbar.dart';

enum ViewAllType {
  all,
  space,
  event,
}

extension ViewAllTypeExtension on ViewAllType {
  String get name {
    switch (this) {
      case ViewAllType.all:
        return 'All';
      case ViewAllType.space:
        return 'Parking Space';
      case ViewAllType.event:
        return 'Events';
    }
  }

  ContributionType? get contributionType {
    switch (this) {
      case ViewAllType.all:
        return null;
      case ViewAllType.space:
        return ContributionType.space;
      case ViewAllType.event:
        return ContributionType.event;
    }
  }
}

class ViewAllView extends StatefulWidget {
  const ViewAllView({super.key});

  @override
  State<ViewAllView> createState() => _ViewAllViewState();
}

class _ViewAllViewState extends State<ViewAllView> {
  var viewAllType = ViewAllType.all;

  @override
  void initState() {
    context.read<ActivitiesBloc>().add(GetActivitiesEvent());
    super.initState();
  }

  void _onFilterChanged(ViewAllType type) {
    setState(() {
      viewAllType = type;
    });

    // Trigger filter in BLoC
    // context.read<ActivitiesBloc>().add(
    //     FilterActivitiesEvent(filterType: type.contributionType)
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: BlocConsumer<ActivitiesBloc, ActivitiesState>(
        listener: (context, state) {
          // Handle state changes if needed
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(Dimens.defaultMargin),
            child: Column(
              children: [
                StyledAppBar(
                  onTap: () => NavigatorHelper.pop(),
                  title: 'Contributions',
                  icon: Icons.close,
                ),
                FilterTabs<ViewAllType>(
                  values: ViewAllType.values,
                  getName: (type) => type.name,
                  initialValue: viewAllType,
                  onSelected: (type) {
                    setState(() {
                      viewAllType = type;
                    });
                    // Perform filtering logic here
                  },
                  selectedColor: AppColors.primary400,
                  unselectedTextColor: AppColors.neutral500,
                ),
                _buildActivityList(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            ViewAllType.values.map((type) => _buildTabItem(type)).toList(),
      ),
    );
  }

  Widget _buildTabItem(ViewAllType type) {
    final isSelected = viewAllType == type;

    return GestureDetector(
      onTap: () => _onFilterChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary400 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 11,
          horizontal: 25,
        ),
        child: Text(
          type.name,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.neutral500,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(ActivitiesState state) {
    if (state is ActivitiesLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is ActivitiesError) {
      return Expanded(
        child: Center(
          child: Text(
            'Failed to load activities: ${state.error}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (state is ActivitiesLoaded) {
      final activities = _getFilteredActivities(state.activities);

      if (activities.isEmpty) {
        return Expanded(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(
                  Iconsax.star,
                  size: 40,
                  color: AppColors.primary500,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Contributions Yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You have not made any contributions yet. Please check back later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
        ));
      }

      return Expanded(
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final activity = activities[index];
            final type = activity.type.toLowerCase() == "space"
                ? ContributionType.space
                : ContributionType.event;

            return ContributionItem(
              activity: activity,
              showDivider: false, // Using separator instead
              showBackground: true,
              type: type,
            );
          },
        ),
      );
    }

    return const Expanded(
      child: Center(
        child: Text('Select a filter to view activities'),
      ),
    );
  }

  List<dynamic> _getFilteredActivities(List<dynamic> activities) {
    if (viewAllType == ViewAllType.all) {
      return activities;
    }

    final contributionType = viewAllType.contributionType;
    return activities.where((activity) {
      final activityType = activity.type.toLowerCase() == "space"
          ? ContributionType.space
          : ContributionType.event;
      return activityType == contributionType;
    }).toList();
  }
}

/// A reusable filter tabs component that displays selectable tabs based on enum values
class FilterTabs<T extends Enum> extends StatefulWidget {
  /// The list of enum values to display as tabs
  final List<T> values;

  /// Function that returns the display name for each enum value
  final String Function(T value) getName;

  /// The initially selected value
  final T initialValue;

  /// Callback when a tab is selected
  final Function(T) onSelected;

  /// Background color of the container
  final Color backgroundColor;

  /// Selected tab color
  final Color selectedColor;

  /// Unselected text color
  final Color unselectedTextColor;

  /// Selected text color
  final Color selectedTextColor;

  /// Animation duration
  final Duration animationDuration;

  final bool isExapnded;

  const FilterTabs({
    super.key,
    required this.values,
    this.isExapnded = false,
    required this.getName,
    required this.initialValue,
    required this.onSelected,
    this.backgroundColor = Colors.white,
    this.selectedColor = Colors.blue,
    this.unselectedTextColor = Colors.grey,
    this.selectedTextColor = Colors.white,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<FilterTabs<T>> createState() => _FilterTabsState<T>();
}

class _FilterTabsState<T extends Enum> extends State<FilterTabs<T>> {
  late T _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  void _onTabSelected(T value) {
    setState(() {
      _selectedValue = value;
    });
    widget.onSelected(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(1000),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.values.map((value) => _buildTabItem(value)).toList(),
      ),
    );
  }

  Widget _buildTabItem(T value) {
    final isSelected = _selectedValue == value;

    if (widget.isExapnded) {
      return Expanded(
          child: GestureDetector(
        onTap: () => _onTabSelected(value),
        child: AnimatedContainer(
          duration: widget.animationDuration,
          decoration: BoxDecoration(
            color: isSelected ? widget.selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 11,
            horizontal: 25,
          ),
          child: Center(
            child: Text(
              widget.getName(value),
              style: TextStyle(
                color: isSelected
                    ? widget.selectedTextColor
                    : widget.unselectedTextColor,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ));
    }

    return GestureDetector(
      onTap: () => _onTabSelected(value),
      child: AnimatedContainer(
        duration: widget.animationDuration,
        decoration: BoxDecoration(
          color: isSelected ? widget.selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 11,
          horizontal: 25,
        ),
        child: Center(
          child: Text(
            widget.getName(value),
            style: TextStyle(
              color: isSelected
                  ? widget.selectedTextColor
                  : widget.unselectedTextColor,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

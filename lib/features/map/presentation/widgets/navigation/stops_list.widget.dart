import 'package:flutter/material.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/models/navigation/navigation_stop.model.dart';

class StopsListWidget extends StatelessWidget {
  final List<NavigationStop> stops;
  final int currentStopIndex;
  final VoidCallback? onDismiss;
  final VoidCallback? onAddStop;

  const StopsListWidget({
    super.key,
    required this.stops,
    required this.currentStopIndex,
    this.onDismiss,
    this.onAddStop,
  });

  @override
  Widget build(BuildContext context) {
    if (stops.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route, color: AppColors.primary500),
              const SizedBox(width: 8),
              Text(
                '${context.l10n.stops} (${stops.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...stops.map((stop) {
            final isActive = currentStopIndex == stop.orderIndex;
            final isCompleted = stop.status == StopStatus.completed;
            final isPending = stop.status == StopStatus.pending;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color:
                          isCompleted
                              ? AppColors.green500
                              : isActive
                              ? AppColors.primary500
                              : AppColors.neutral200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child:
                          isCompleted
                              ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                              : Text(
                                '${stop.orderIndex + 1}',
                                style: TextStyle(
                                  color:
                                      isActive
                                          ? Colors.white
                                          : AppColors.neutral500,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.streetName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                            color:
                                isCompleted
                                    ? AppColors.neutral400
                                    : Colors.black,
                            decoration:
                                isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        if (isActive)
                          Text(
                            context.l10n.onTheWay,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary500,
                            ),
                          ),
                        if (isCompleted)
                          Text(
                            context.l10n.completed,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.green500,
                            ),
                          ),
                        if (isPending)
                          Text(
                            context.l10n.pending,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral400,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.l10n.current,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          if (onAddStop != null)
            PrimaryButton(
              onTap: onAddStop!,
              text: context.l10n.addAnotherStop,
              icon: Icons.add_location_alt,
            ),
          Dimens.space(2),
        ],
      ),
    );
  }
}

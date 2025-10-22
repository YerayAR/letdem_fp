// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:letdem/core/extensions/locale.dart';

class NavigateBottom extends StatelessWidget {
  const NavigateBottom({
    super.key,
    required this.height,
    required this.mapPadding,
    required this.radius,
    required this.isLimit,
    required this.speed,
  });

  final double height;
  final double mapPadding;
  final double radius;
  final bool isLimit;
  final double speed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // top: MediaQuery.of(context).padding.top + 120,
      // right: _mapPadding,
      left: mapPadding,
      bottom: height + 15,
      child: CircleAvatar(
        radius: radius * 1.3,
        backgroundColor: isLimit ? const Color(0xFFFE4E1D) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (speed * 3.6).round().toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isLimit ? Colors.white : Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                context.l10n.kmPerHour,
                style: TextStyle(
                  color: isLimit ? Colors.white : Colors.orange.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      // child: Container(
      //   padding: const EdgeInsets.all(6),
      //   decoration: BoxDecoration(
      //     border: Border.all(color: Colors.grey.shade300),
      //     borderRadius: BorderRadius.circular(16),
      //     color: Colors.white,
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withValues(alpha: 0.1),
      //         blurRadius: 4,
      //         offset: const Offset(0, 2),
      //       ),
      //     ],
      //   ),
      //   child: Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Container(
      //         padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 13),
      //         decoration: BoxDecoration(
      //           color:
      //               _isOverSpeedLimit
      //                   ? Colors.redAccent.withOpacity(0.2)
      //                   : Colors.orange.shade50,
      //           borderRadius: BorderRadius.circular(8),
      //         ),
      //         child: Column(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             Text(
      //               (_currentSpeed * 3.6).round().toString(),
      //               style: TextStyle(
      //                 color:
      //                     _isOverSpeedLimit
      //                         ? Colors.redAccent.withValues(alpha: 0.8)
      //                         : Colors.orange.shade700,
      //                 fontWeight: FontWeight.bold,
      //                 fontSize: 24,
      //               ),
      //             ),
      //             Text(
      //               context.l10n.kmPerHour,
      //               style: TextStyle(
      //                 color:
      //                     _isOverSpeedLimit
      //                         ? Colors.redAccent.withValues(alpha: 0.8)
      //                         : Colors.orange.shade700,
      //                 fontSize: 10,
      //                 fontWeight: FontWeight.w500,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       const SizedBox(width: 8),
      //       Container(
      //         width: 50,
      //         height: 50,
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           shape: BoxShape.circle,
      //           border: Border.all(
      //             color: Colors.red,
      //             width: _isOverSpeedLimit ? 3 : 2,
      //           ),
      //         ),
      //         child: Center(
      //           child:
      //               _roadSpeedLimit != null &&
      //                       _roadSpeedLimit!.speedLimitInMetersPerSecond != null
      //                   ? Text(
      //                     "${(_roadSpeedLimit!.speedLimitInMetersPerSecond! * 3.6).round()}",
      //                     style: TextStyle(
      //                       color:
      //                           _isOverSpeedLimit ? Colors.red : Colors.black,
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 20,
      //                     ),
      //                   )
      //                   : Icon(
      //                     Icons.speed,
      //                     color: Colors.grey.shade400,
      //                     size: 18,
      //                   ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}

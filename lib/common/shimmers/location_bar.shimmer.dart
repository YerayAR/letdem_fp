import 'package:flutter/material.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:shimmer/shimmer.dart';

class LocationBarShimmer extends StatelessWidget {
  const LocationBarShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(1500),
          child: SizedBox(
            height: 60,
            width: 60,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[200]!.withOpacity(0.2),
              highlightColor: Colors.grey[50]!,
              child: Container(color: Colors.white),
            ),
          ),
        ),
        Dimens.space(1),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              height: 60,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[200]!.withOpacity(0.2),
                highlightColor: Colors.grey[50]!,
                child: Container(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:shimmer/shimmer.dart';

class HomePageShimmer extends StatelessWidget {
  const HomePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: AppColors.neutral50,
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(Dimens.defaultMargin),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Dimens.space(1),
                ClipRRect(
                  borderRadius: BorderRadius.circular(45),
                  child: SizedBox(
                    height: 60.0,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[200]!.withOpacity(0.2),
                      highlightColor: Colors.grey[50]!,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Dimens.space(6),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: SizedBox(
                          height: 60.0,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[200]!.withOpacity(0.2),
                            highlightColor: Colors.grey[50]!,
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Dimens.space(1),
                    Flexible(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: SizedBox(
                          height: 60.0,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[200]!.withOpacity(0.2),
                            highlightColor: Colors.grey[50]!,
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

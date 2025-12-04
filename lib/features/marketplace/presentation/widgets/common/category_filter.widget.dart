import 'package:flutter/material.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/data/models/store.model.dart';

class CategoryFilterChip extends StatelessWidget {
  final StoreCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary500 : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary500 : AppColors.neutral200,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              category.displayName,
              style: Typo.smallBody.copyWith(
                color: isSelected ? Colors.white : AppColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

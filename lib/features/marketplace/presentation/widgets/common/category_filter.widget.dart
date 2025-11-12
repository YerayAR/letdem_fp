import 'package:flutter/material.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/data/models/store.model.dart';

class CategoryFilterChip extends StatefulWidget {
  final StoreCategory category;
  final VoidCallback onTap;

  const CategoryFilterChip({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  State<CategoryFilterChip> createState() => _CategoryFilterChipState();
}

class _CategoryFilterChipState extends State<CategoryFilterChip> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
        });
        widget.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isSelected ? AppColors.primary500 : Colors.white,
          border: Border.all(
            color: _isSelected ? AppColors.primary500 : AppColors.neutral200,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(widget.category.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              widget.category.displayName,
              style: Typo.smallBody.copyWith(
                color: _isSelected ? Colors.white : AppColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

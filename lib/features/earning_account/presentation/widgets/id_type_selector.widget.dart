import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/features/earning_account/presentation/views/connect_account.view.dart';

class IDTypePage extends StatefulWidget {
  final Function(String pass) onNext;

  const IDTypePage({
    super.key,
    required this.onNext,
  });

  @override
  State<IDTypePage> createState() => _IDTypePageState();
}

class _IDTypePageState extends State<IDTypePage> {
  bool _isNationalIDSelected = true;

  void _onIDTypeSelected(bool isNationalID) {
    setState(() {
      _isNationalIDSelected = isNationalID;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select ID Type',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            'Select your ID type and upload the front & Back of your Identity Card',
            style: TextStyle(fontSize: 14, color: AppColors.neutral600),
          ),
          const SizedBox(height: 30),
          // Usage inside build()
          _buildIDTypeOption(
            title: 'National ID Card',
            subtitle: 'Your government issued national identity card',
            value: true,
          ),

          const SizedBox(height: 16),
          _buildIDTypeOption(
            title: 'Resident Permit',
            subtitle: 'Your government issued national resident permit',
            value: false,
          ),
          const Spacer(),
          buildNextButton(
              context,
              () => widget.onNext(
                    _isNationalIDSelected ? 'NATIONAL_ID' : 'RESIDENT_PERMIT',
                  )),
        ],
      ),
    );
  }

  Widget _buildIDTypeOption({
    required String title,
    required String subtitle,
    required bool value,
  }) {
    return InkWell(
      onTap: () => _onIDTypeSelected(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _isNationalIDSelected == value
                ? AppColors.primary500
                : AppColors.neutral100,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.card5,
              color: AppColors.neutral600,
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.neutral600),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: value,
              groupValue: _isNationalIDSelected,
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  _onIDTypeSelected(newValue);
                }
              },
              activeColor: AppColors.primary500,
            ),
          ],
        ),
      ),
    );
  }
}

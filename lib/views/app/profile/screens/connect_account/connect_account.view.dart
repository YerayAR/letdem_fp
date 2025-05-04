import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/services/res/navigator.dart';

import '../../../../../constants/ui/typo.dart';

class ProfileOnboardingApp extends StatefulWidget {
  const ProfileOnboardingApp({Key? key}) : super(key: key);

  @override
  State<ProfileOnboardingApp> createState() => _ProfileOnboardingAppState();
}

class _ProfileOnboardingAppState extends State<ProfileOnboardingApp> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header with progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildHeader(_currentPage),
            ),
            const SizedBox(height: 30),

            // Page content that changes
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable swiping
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  CountrySelectionPage(onNext: _goToNextPage),
                  PersonalInfoPage(onNext: _goToNextPage),
                  AddressInfoPage(onNext: _goToNextPage),
                  IDTypePage(onNext: _goToNextPage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CountrySelectionPage extends StatelessWidget {
  final VoidCallback onNext;

  const CountrySelectionPage({
    Key? key,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Country',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            'Select your country of residence to continue',
            style: TextStyle(fontSize: 14, color: AppColors.neutral600),
          ),
          const SizedBox(height: 30),
          Text(
            'Select Country',
            style: TextStyle(fontSize: 16, color: AppColors.neutral600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.neutral100,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ListTile(
              leading: Icon(Iconsax.location),
              title: Text(
                'Spain',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
                ),
              ),
              trailing: Icon(Icons.keyboard_arrow_down),
            ),
          ),
          const Spacer(),
          _buildNextButton(context, onNext),
        ],
      ),
    );
  }
}

class PersonalInfoPage extends StatelessWidget {
  final VoidCallback onNext;

  const PersonalInfoPage({
    Key? key,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your personal information',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            'Input your personal details as it is on your ID Card',
            style: TextStyle(fontSize: 14, color: AppColors.neutral600),
          ),
          const SizedBox(height: 30),
          const TextInputField(
            label: 'Enter first name',
            placeHolder: 'Eg. John',
          ),
          const SizedBox(height: 16),
          const TextInputField(
            label: 'Enter last name',
            placeHolder: 'Eg. Doe',
          ),
          const SizedBox(height: 16),
          const TextInputField(
            label: 'Enter phone number',
            placeHolder: 'Eg. +1234567890',
          ),
          const SizedBox(height: 16),
          const Spacer(),
          _buildNextButton(context, onNext),
        ],
      ),
    );
  }
}

class AddressInfoPage extends StatelessWidget {
  final VoidCallback onNext;

  const AddressInfoPage({
    Key? key,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your address information',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            'Input your full address and location of residence',
            style: TextStyle(fontSize: 14, color: AppColors.neutral600),
          ),
          const SizedBox(height: 30),
          const TextInputField(
            label: 'Enter your address',
            placeHolder: 'Eg. 123 Main St, City',
          ),
          const SizedBox(height: 16),
          const TextInputField(
            label: 'Enter postal code',
            placeHolder: 'Eg. 12345',
          ),
          const SizedBox(height: 16),
          const TextInputField(
            label: 'Enter city',
            placeHolder: 'Eg. Madrid',
          ),
          const Spacer(),
          const SizedBox(height: 16),
          _buildNextButton(context, onNext),
        ],
      ),
    );
  }
}

class IDTypePage extends StatelessWidget {
  final VoidCallback onNext;

  const IDTypePage({
    Key? key,
    required this.onNext,
  }) : super(key: key);

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
          _buildIDTypeOption(
            title: 'National ID Card',
            subtitle: 'Your government issued national identity card',
            isSelected: true,
          ),
          const SizedBox(height: 16),
          _buildIDTypeOption(
            title: 'Resident Permit',
            subtitle: 'Your government issued national resident permit',
            isSelected: false,
          ),
          const Spacer(),
          _buildNextButton(context, onNext),
        ],
      ),
    );
  }

  Widget _buildIDTypeOption({
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primary500 : AppColors.neutral100,
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
          Radio(
            value: true,
            groupValue: isSelected,
            onChanged: (_) {},
            activeColor: AppColors.primary500,
          ),
        ],
      ),
    );
  }
}

Widget _buildHeader(int pageIndex) {
  return Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          NavigatorHelper.pop();
        },
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Row(
          children: List.generate(
            4, // Fixing to number of actual pages
            (index) => Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: index <= pageIndex
                      ? Colors.amber
                      : Colors.amber.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildNextButton(BuildContext context, VoidCallback onNext) {
  return SizedBox(
    width: double.infinity,
    child: PrimaryButton(
      onTap: onNext,
      text: ('Next'),
    ),
  );
}

Widget _buildProfileIcon(Color color) {
  return Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}

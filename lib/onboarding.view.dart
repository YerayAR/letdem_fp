import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Interactive Tutorial Onboarding with App Screenshots and Feature Walkthroughs
class TutorialOnboardingView extends StatefulWidget {
  const TutorialOnboardingView({super.key});

  @override
  State<TutorialOnboardingView> createState() => _TutorialOnboardingViewState();
}

class FeaturesItem {
  final String text;
  final double? top;
  final String? description;
  final double? left;
  final double? bottom;
  final double? right;
  final String? phoneImage; // NEW: Each feature can have its own phone image

  FeaturesItem({
    required this.text,
    this.top,
    this.left,
    this.bottom,
    this.description,
    this.right,
    this.phoneImage, // NEW
  });
}

class _TutorialOnboardingViewState extends State<TutorialOnboardingView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // NEW: Track current feature within each page
  final Map<int, PageController> _featureControllers = {};
  final Map<int, int> _currentFeatureIndex = {};

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize feature controllers for each page with features
    for (int i = 0; i < _tutorialPages.length; i++) {
      if (_tutorialPages[i].features != null &&
          _tutorialPages[i].features!.isNotEmpty) {
        _featureControllers[i] = PageController();
        _currentFeatureIndex[i] = 0;
      }
    }

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    // Dispose all feature controllers
    for (var controller in _featureControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  final List<TutorialPage> _tutorialPages = [
    // Page 1: Welcome & Overview
    TutorialPage(
      title: 'Welcome to LetDem!',
      subtitle: 'Your smart parking companion',
      description:
          'Learn how to find parking, share your spot, and earn money in just a few simple steps.',
      tutorialType: TutorialType.welcome,
      icon: Iconsax.car5,
      iconColor: AppColors.primary500,
      features: [
        FeaturesItem(
          text: 'Find parking spots instantly',
          top: 160,
          left: -5,
          phoneImage: 'assets/res/cl.png', // Each feature gets its own image
        ),
        FeaturesItem(
          text: 'Share your spot when leaving',
          top: 220,
          right: -10,
          phoneImage: 'assets/res/cl.png', // Different image for each
        ),
        FeaturesItem(
          text: 'Earn money & LetDem points',
          top: 290,
          left: -10,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Navigate with real-time alerts',
          top: 360,
          right: 10,
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 2: Finding Parking Tutorial
    TutorialPage(
      title: 'Find Parking Spots',
      subtitle: 'Your step-by-step guide',
      description:
          'Discover nearby parking spaces instantly and navigate with real-time updates.',
      tutorialType: TutorialType.findParking,
      icon: Iconsax.search_normal_15,
      iconColor: AppColors.primary500,
      features: [
        FeaturesItem(
          text: 'Explore Nearby Parking',
          description: 'View all available spots around you on the live map.',
          top: 160,
          left: -5,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Tap a Spot',
          description:
              'Check details like distance, type, and price (if applicable).',
          top: 220,
          right: -10,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Reserve & Navigate',
          description:
              'Secure your spot, make payment if needed, and get guided directions.',
          top: 290,
          left: -10,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Arrive & Rate',
          description: 'Park your vehicle and leave a quick rating for others.',
          top: 360,
          right: 10,
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 3: Publishing Free Parking Tutorial
    TutorialPage(
      title: 'Share Free Parking',
      subtitle: 'Help others & earn points',
      description: 'Publish your spot when leaving and earn LetDem points',
      tutorialType: TutorialType.publishFree,
      icon: Iconsax.camera5,
      iconColor: AppColors.secondary500,
      features: [
        FeaturesItem(
          text: 'Tap Camera Button',
          description: 'When you\'re ready to leave your spot',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Take a Photo',
          description: 'Capture your parking spot clearly',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Select Type',
          description: 'Choose: Street, Zone, Garage, etc.',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Publish!',
          description: 'Share with the community & earn points',
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 4: Publishing Paid Parking Tutorial
    TutorialPage(
      title: 'Earn Money from Your Spot',
      subtitle: 'Publish paid parking',
      description: 'Set your price and earn money while you wait',
      tutorialType: TutorialType.publishPaid,
      icon: Iconsax.money,
      iconColor: AppColors.green600,
      features: [
        FeaturesItem(
          text: 'Register Your Vehicle',
          description: 'Add your car details in Activities tab',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Set Up Payments',
          description: 'Connect your account to receive money',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Publish with Price',
          description: 'Set time (1–60 min) & price (€3–20)',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Wait for Booking',
          description: 'Get paid when someone reserves',
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 5: Navigation & Alerts Tutorial
    TutorialPage(
      title: 'Smart Navigation',
      subtitle: 'Drive safely with alerts',
      description: 'Get real-time warnings about cameras, police, accidents',
      tutorialType: TutorialType.navigation,
      icon: Iconsax.routing_25,
      iconColor: Color(0xFF9C27B0),
      features: [
        FeaturesItem(
          text: '📍 GPS navigation to parking',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: '🚨 Speed camera alerts',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: '👮 Police presence warnings',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: '🚧 Accident & roadwork alerts',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: '⚡ Alternative route suggestions',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 6: Earnings & Points Tutorial
    TutorialPage(
      title: 'Earn Rewards',
      subtitle: 'Points & money',
      description: 'Every contribution gets rewarded',
      tutorialType: TutorialType.rewards,
      icon: Iconsax.cup5,
      iconColor: AppColors.secondary500,
      features: [
        FeaturesItem(
          text: 'Publish Free Parking',
          description: '+1 Point when someone uses it',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Publish Paid Parking',
          description: 'Earn €3–20 per booking',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Report Alerts',
          description: '+1 Point when verified by others',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Redeem Points',
          description: 'Coming soon: Exchange for benefits',
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 7: Tips & Best Practices
    TutorialPage(
      title: 'Pro Tips',
      subtitle: 'Get the most out of LetDem',
      description: 'Follow these tips for the best experience',
      tutorialType: TutorialType.tips,
      icon: Iconsax.lamp_15,
      iconColor: Color(0xFFFF9F43),
      features: [
        FeaturesItem(
          text: '📸 Take clear photos of parking spots',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: '⏱️ Publish as soon as you leave',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: '✅ Rate spots accurately to help others',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: '🎯 Check multiple spots before choosing',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: '💰 Set fair prices for paid parking',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _tutorialPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to main app or complete onboarding
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // NEW: Handle feature navigation within a page
  void _nextFeatureOrPage(int pageIndex) {
    final features = _tutorialPages[pageIndex].features;
    if (features == null || features.isEmpty) {
      _nextPage();
      return;
    }

    final currentFeature = _currentFeatureIndex[pageIndex] ?? 0;

    if (currentFeature < features.length - 1) {
      // Move to next feature
      setState(() {
        _currentFeatureIndex[pageIndex] = currentFeature + 1;
      });
      _featureControllers[pageIndex]?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // All features done, move to next page
      _nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at the top
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.neutral600,
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _tutorialPages.length,
                    effect: WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppColors.primary500,
                      dotColor: AppColors.neutral300,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                    child: Text(
                      'Skip',
                      style: Typo.mediumBody.copyWith(
                        color: AppColors.neutral600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main PageView for tutorial pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _fadeController.reset();
                  _fadeController.forward();
                },
                itemCount: _tutorialPages.length,
                itemBuilder: (context, index) {
                  return _buildTutorialPage(_tutorialPages[index], index);
                },
              ),
            ),

            // Bottom section with button
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialPage(TutorialPage page, int pageIndex) {
    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Page header
            _buildPageHeader(page),
            Dimens.space(4),

            // NEW: Build swipeable features section
            if (page.features != null && page.features!.isNotEmpty)
              _buildSwipeableFeatures(page, pageIndex)
            else
              const SizedBox(height: 300),
          ],
        ),
      ),
    );
  }

  // NEW: Build the swipeable features section
  Widget _buildSwipeableFeatures(TutorialPage page, int pageIndex) {
    final features = page.features!;
    final controller = _featureControllers[pageIndex];

    return SizedBox(
      height: 500,
      child: PageView.builder(
        controller: controller,
        onPageChanged: (index) {
          setState(() {
            _currentFeatureIndex[pageIndex] = index;
          });
        },
        itemCount: features.length,
        itemBuilder: (context, featureIndex) {
          final feature = features[featureIndex];
          return _buildSingleFeature(feature, featureIndex, features.length);
        },
      ),
    );
  }

  // NEW: Build a single feature with its phone image and tooltip
  Widget _buildSingleFeature(FeaturesItem feature, int index, int total) {
    return Column(
      children: [
        // Feature indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(total, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == index ? AppColors.primary500 : AppColors.neutral300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        Dimens.space(2),

        // Phone image with tooltip
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Phone image
              Center(
                child: Image(
                  image: AssetImage(feature.phoneImage ?? 'assets/res/cl.png'),
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),

              // Feature tooltip
              Positioned(
                top: feature.top,
                left: feature.left,
                bottom: feature.bottom,
                right: feature.right,
                child: ClipRRect(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.neutral100.withOpacity(0.5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            feature.text,
                            style: Typo.mediumBody.copyWith(
                              color: AppColors.neutral600,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (feature.description != null) ...[
                            Dimens.space(.5),
                            Text(
                              feature.description!,
                              style: Typo.smallBody.copyWith(
                                color: AppColors.neutral500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader(TutorialPage page) {
    return Column(
      children: [
        Text(
          page.title,
          style: Typo.largeBody.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: AppColors.neutral600,
          ),
          textAlign: TextAlign.center,
        ),
        Dimens.space(1),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: page.iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            page.subtitle,
            style: Typo.mediumBody.copyWith(
              color: page.iconColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        Dimens.space(2),
        Text(
          page.description,
          style: Typo.mediumBody.copyWith(
            color: AppColors.neutral600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    final currentPageData = _tutorialPages[_currentPage];
    final hasFeatures =
        currentPageData.features != null &&
        currentPageData.features!.isNotEmpty;

    String buttonText;
    if (hasFeatures) {
      final currentFeature = _currentFeatureIndex[_currentPage] ?? 0;
      final totalFeatures = currentPageData.features!.length;

      if (currentFeature < totalFeatures - 1) {
        buttonText = 'Next Feature (${currentFeature + 1}/${totalFeatures})';
      } else if (_currentPage < _tutorialPages.length - 1) {
        buttonText = 'Next: ${_tutorialPages[_currentPage + 1].title}';
      } else {
        buttonText = 'Get Started';
      }
    } else {
      buttonText =
          _currentPage < _tutorialPages.length - 1
              ? 'Next: ${_tutorialPages[_currentPage + 1].title}'
              : 'Get Started';
    }

    return Container(
      height: 140,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          PrimaryButton(
            onTap: () => _nextFeatureOrPage(_currentPage),
            text: buttonText,
          ),
        ],
      ),
    );
  }
}

// Tutorial Page Model
class TutorialPage {
  final String title;
  final String subtitle;
  final String description;
  final TutorialType tutorialType;
  final IconData icon;
  final Color iconColor;
  final List<FeaturesItem>? features;

  TutorialPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tutorialType,
    required this.icon,
    required this.iconColor,
    this.features,
  });
}

// Tutorial Types
enum TutorialType {
  welcome,
  findParking,
  publishFree,
  publishPaid,
  navigation,
  rewards,
  tips,
}

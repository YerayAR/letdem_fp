import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/auth/presentation/views/onboard/splash.view.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/storage/storage/storage.service.dart';
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

  checkOnboaringShown() {
    SecureStorageHelper().read("tutorial_step_shown").then((value) {
      if (value == null || value == 'false') {
        SecureStorageHelper().write("tutorial_step_shown", 'true');
      } else {
        NavigatorHelper.to(SplashView());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkOnboaringShown();
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
      subtitle: 'Smart parking made simple',
      description:
          'Join a community that shares parking spots in real-time. Find parking instantly, share your spot when leaving, and earn rewards while helping others.',
      tutorialType: TutorialType.welcome,
      icon: Iconsax.car5,
      iconColor: AppColors.primary500,
      features: [
        FeaturesItem(
          text: 'Real-time parking availability',
          top: 160,
          left: -5,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'GPS navigation with traffic alerts',
          top: 220,
          right: -10,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Earn money & LetDem points',
          top: 290,
          left: -10,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Community-driven safety alerts',
          top: 360,
          right: 10,
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 2: Finding Parking Tutorial
    TutorialPage(
      title: 'Find Parking Instantly',
      subtitle: 'Never circle the block again',
      description:
          'View real-time available parking spots on the map. Choose between free community spots or paid guaranteed parking.',
      tutorialType: TutorialType.findParking,
      icon: Iconsax.search_normal_15,
      iconColor: AppColors.primary500,
      features: [
        FeaturesItem(
          text: 'Browse Live Map',
          description:
              'See all available free and paid parking spots around you in real-time.',
          top: 160,
          left: -5,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Check Spot Details',
          description:
              'View parking type, distance, price, and photo. Reserve paid spots with one tap.',
          top: 220,
          right: -10,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Navigate with GPS',
          description:
              'Get turn-by-turn directions with real-time traffic, speed camera, and police alerts.',
          top: 290,
          left: -10,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Rate Your Experience',
          description:
              'Confirm if you took the spot or report its status to help the community.',
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
      description:
          'When you leave your parking spot, share it with the community. Earn +1 LetDem Point when someone uses it.',
      tutorialType: TutorialType.publishFree,
      icon: Iconsax.camera5,
      iconColor: AppColors.secondary500,
      features: [
        FeaturesItem(
          text: 'Take a Photo',
          description:
              'Capture a clear image of the empty parking spot you\'re leaving.',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Location Detected',
          description:
              'Your GPS location is automatically captured for accuracy.',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Select Type',
          description: 'Choose parking type: Street, Zone, Garage, or Private.',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Publish & Earn',
          description:
              'Share instantly! Earn +1 Point when someone confirms they used your spot.',
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 4: Publishing Paid Parking Tutorial
    TutorialPage(
      title: 'Earn Money from Parking',
      subtitle: 'Monetize your waiting time',
      description:
          'Publish paid parking when you\'re willing to wait. Set your price (€3-20) and time (1-60 min). Get paid when booked!',
      tutorialType: TutorialType.publishPaid,
      icon: Iconsax.money,
      iconColor: AppColors.green600,
      features: [
        FeaturesItem(
          text: 'Register Vehicle & Account',
          description:
              'Add your vehicle details and create a benefits account to receive payments.',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Take Photo & Set Location',
          description:
              'Capture your parking spot - location is detected automatically.',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Set Price & Wait Time',
          description:
              'Choose how long you can wait (1-60 min) and your price (€3-20).',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Get Booked & Paid',
          description:
              'When someone reserves, you\'ll get a notification. Confirm with their code and earn money!',
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 5: Paid Parking Reservation
    TutorialPage(
      title: 'Reserve Paid Parking',
      subtitle: 'Guaranteed spot when you need it',
      description:
          'Book a paid parking spot in advance. The owner waits for you. Pay securely and navigate directly.',
      tutorialType: TutorialType.publishPaid,
      icon: Iconsax.ticket5,
      iconColor: Color(0xFF00BCD4),
      features: [
        FeaturesItem(
          text: 'Find Paid Spots',
          description:
              'Browse paid parking options with price, wait time, and owner details.',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Reserve & Pay',
          description:
              'Book with your card or LetDem wallet. Payment is held until confirmed.',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Navigate in Real-Time',
          description:
              'Owner can track your arrival. Get turn-by-turn navigation to the spot.',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Confirm & Complete',
          description:
              'Owner enters your confirmation code. Payment releases and you earn +1 Point!',
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 6: Navigation & Smart Alerts
    TutorialPage(
      title: 'Smart Navigation',
      subtitle: 'Drive safely with real-time alerts',
      description:
          'Integrated GPS with live traffic updates, speed camera warnings, police alerts, and alternative route suggestions.',
      tutorialType: TutorialType.navigation,
      icon: Iconsax.routing_25,
      iconColor: Color(0xFF9C27B0),
      features: [
        FeaturesItem(
          text: '🗺️ Turn-by-turn GPS navigation',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: '📹 Speed camera & traffic camera alerts (Spain)',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: '👮 Police presence & roadblock warnings',
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
          text: '🛣️ Alternative routes & traffic visualization',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 7: Community Alerts
    TutorialPage(
      title: 'Report & Share Alerts',
      subtitle: 'Keep the community informed',
      description:
          'Report police, accidents, or road closures. When verified by others, earn +1 LetDem Point for contributing.',
      tutorialType: TutorialType.navigation,
      icon: Iconsax.danger5,
      iconColor: Color(0xFFFF5722),
      features: [
        FeaturesItem(
          text: 'One-Tap Reporting',
          description:
              'Quickly report Police, Accident, or Road Closed with automatic location.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Real-Time Alerts',
          description:
              'All users within 5km see your alert immediately on their map.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Community Verification',
          description:
              'Other drivers confirm if your alert is still there or report it\'s cleared.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Earn Points',
          description:
              'Get +1 LetDem Point when your alert is verified by another user.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 8: Scheduled Notifications
    TutorialPage(
      title: 'Never Miss a Spot',
      subtitle: 'Smart parking notifications',
      description:
          'Set alerts for specific locations and times. Get notified instantly when parking becomes available.',
      tutorialType: TutorialType.tips,
      icon: Iconsax.notification5,
      iconColor: Color(0xFFFF9F43),
      features: [
        FeaturesItem(
          text: 'Search Your Destination',
          description: 'Use the search bar to find where you need parking.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Set Alert Parameters',
          description: 'Choose your time range and search radius (500m - 2km).',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Receive Push Notifications',
          description:
              'Get instant alerts when parking is published in your defined area.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Manage from Activities',
          description:
              'Edit, pause, or delete your scheduled notifications anytime.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 9: Earnings & Points System
    TutorialPage(
      title: 'Earn Rewards',
      subtitle: 'Points & money for contributing',
      description:
          'Every action counts! Earn LetDem Points for free parking and alerts. Make real money with paid parking.',
      tutorialType: TutorialType.rewards,
      icon: Iconsax.cup5,
      iconColor: AppColors.secondary500,
      features: [
        FeaturesItem(
          text: 'Free Parking Shared',
          description: '+1 Point when someone confirms they used your spot.',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Paid Parking Booked',
          description: 'Earn €3-20 per reservation (10% commission to LetDem).',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Alerts Verified',
          description:
              '+1 Point when another user confirms your road alert is accurate.',
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Withdraw Earnings',
          description:
              'Transfer funds to your bank (min €10). Track all transactions in Earnings.',
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 10: Profile & Account Management
    TutorialPage(
      title: 'Your LetDem Profile',
      subtitle: 'Manage everything in one place',
      description:
          'Access your contributions, reservations, earnings, vehicles, payment methods, and preferences.',
      tutorialType: TutorialType.tips,
      icon: Iconsax.profile_circle5,
      iconColor: Color(0xFF3F51B5),
      features: [
        FeaturesItem(
          text: 'Track Contributions',
          description:
              'View all your points from parking spots and alerts shared.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Manage Payments',
          description:
              'Add cards, bank accounts, and view transaction history.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Register Vehicles',
          description:
              'Save your car details, including license plate and eco-label.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Customize Preferences',
          description:
              'Control notifications, alerts, language, and privacy settings.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
      ],
    ),

    // Page 11: Pro Tips & Best Practices
    TutorialPage(
      title: 'Pro Tips',
      subtitle: 'Get the most from LetDem',
      description:
          'Follow these best practices to maximize your earnings, find parking faster, and help the community.',
      tutorialType: TutorialType.tips,
      icon: Iconsax.lamp_15,
      iconColor: Color(0xFFFF9F43),
      features: [
        FeaturesItem(
          text: '📸 Take clear, well-lit photos',
          description:
              'Show the parking space clearly so others know exactly where to go.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: '⏱️ Publish immediately when leaving',
          description:
              'The sooner you share, the more useful it is to others nearby.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Rate spots honestly',
          description:
              'Confirm if you took it or report issues - accuracy helps everyone.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Set fair prices for paid parking',
          description:
              'Consider time saved and location value. Fair prices = more bookings.',
          top: 0.2,
          left: 0.1,
          bottom: 3,
          right: 3,
          phoneImage: 'assets/res/cl.png',
        ),
        FeaturesItem(
          text: 'Enable notifications',
          description:
              'Stay informed about bookings, expirations, and nearby spots.',
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
      SecureStorageHelper().write("tutorial_step_shown", 'true');
      NavigatorHelper.to(SplashView());
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
                      SecureStorageHelper().write(
                        "tutorial_step_shown",
                        'true',
                      );
                      NavigatorHelper.to(SplashView());
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

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:billmate/core/navigation/app_routes.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  void _onOnboardingComplete(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: TextStyle(fontSize: 19.0),
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: AppColors.background,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      globalBackgroundColor: AppColors.background,
      pages: [
        PageViewModel(
          title: "Welcome to BillMate",
          body:
              "Your all-in-one solution for professional billing, inventory management, and GST compliance.",
          image: _buildImage('assets/images/onboarding_welcome.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Manage Your Inventory",
          body:
              "Easily add products, track stock levels, and get low-stock alerts so you never run out.",
          image: _buildImage('assets/images/onboarding_inventory.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Create Professional Invoices",
          body:
              "Generate beautiful, GST-compliant PDF invoices in seconds and share them with your customers.",
          image: _buildImage('assets/images/onboarding_invoice.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Get Started",
          bodyWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Let's set up your business. You're just a few steps away from streamlining your work.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19.0),
              ),
            ],
          ),
          image: _buildImage('assets/images/onboarding_start.png'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onOnboardingComplete(context),
      onSkip: () => _onOnboardingComplete(context),
      showSkipButton: true,
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: AppColors.borderColor,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildImage(String assetName) {
    // Placeholder for now. You would add actual images to your assets folder.
    return Center(
      child: Icon(Icons.business_center, size: 200, color: AppColors.primary),
    );
  }
}

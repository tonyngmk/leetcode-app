import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      icon: Icons.code,
      title: 'Practice Anywhere',
      description: 'Solve LeetCode problems on the go with a premium mobile experience.',
    ),
    _OnboardingData(
      icon: Icons.trending_up,
      title: 'Track Progress',
      description: 'Monitor your streak, see progress rings, and review your activity heatmap.',
    ),
    _OnboardingData(
      icon: Icons.local_fire_department,
      title: 'Stay Consistent',
      description: 'Build a daily habit with challenges and smart reminders.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(page.icon, size: 80, color: AppColors.primary),
                        const Gap(AppSpacing.xl),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(AppSpacing.m),
                        Text(
                          page.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const Gap(AppSpacing.xl),
            // CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: FilledButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                    );
                  } else {
                    context.go('/');
                  }
                },
                child: Text(
                  _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                ),
              ),
            ),
            const Gap(AppSpacing.m),
            if (_currentPage < _pages.length - 1)
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Skip'),
              ),
            const Gap(AppSpacing.l),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

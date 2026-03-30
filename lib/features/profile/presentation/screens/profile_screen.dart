import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../injection.dart';
import '../../domain/repositories/profile_repository.dart';
import '../cubits/profile_cubit.dart';
import '../../../../shared/widgets/error_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(repository: sl<ProfileRepository>())..load(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return switch (state) {
            ProfileInitial() => _UsernamePrompt(),
            ProfileLoading() => const Center(child: CircularProgressIndicator()),
            ProfileError(:final message) => ErrorView(
                message: message,
                onRetry: () => context.read<ProfileCubit>().load(),
              ),
            ProfileLoaded(:final profile, :final acSubmissions, :final streak) =>
              _ProfileContent(
                profile: profile,
                acSubmissions: acSubmissions,
                streak: streak,
              ),
          };
        },
      ),
    );
  }
}

class _UsernamePrompt extends StatelessWidget {
  final _controller = TextEditingController();

  _UsernamePrompt();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 64, color: AppColors.textSecondary),
          const Gap(AppSpacing.m),
          Text(
            'Enter your LeetCode username',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(AppSpacing.m),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'username',
              prefixIcon: Icon(Icons.account_circle_outlined),
            ),
            onSubmitted: (username) {
              if (username.trim().isNotEmpty) {
                context.read<ProfileCubit>().setUsername(username.trim());
              }
            },
          ),
          const Gap(AppSpacing.m),
          FilledButton(
            onPressed: () {
              final username = _controller.text.trim();
              if (username.isNotEmpty) {
                context.read<ProfileCubit>().setUsername(username);
              }
            },
            child: const Text('Load Profile'),
          ),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final dynamic profile;
  final List acSubmissions;
  final int streak;

  const _ProfileContent({
    required this.profile,
    required this.acSubmissions,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final counts = profile.counts as Map<String, int>;
    final easy = counts['Easy'] ?? 0;
    final medium = counts['Medium'] ?? 0;
    final hard = counts['Hard'] ?? 0;
    final total = easy + medium + hard;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        children: [
          // Avatar + username
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.card,
            child: Text(
              profile.username.substring(0, 1).toUpperCase(),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          ),
          const Gap(AppSpacing.s),
          Text(
            profile.username,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(AppSpacing.l),

          // Stats grid
          Row(
            children: [
              _StatCard(label: 'Solved', value: '$total'),
              const Gap(AppSpacing.s),
              _StatCard(label: 'Streak', value: '$streak', icon: Icons.local_fire_department, iconColor: AppColors.medium),
            ],
          ),
          const Gap(AppSpacing.m),

          // Progress rings
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: easy.toDouble(),
                    color: AppColors.easy,
                    title: '$easy',
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    radius: 30,
                  ),
                  PieChartSectionData(
                    value: medium.toDouble(),
                    color: AppColors.medium,
                    title: '$medium',
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    radius: 30,
                  ),
                  PieChartSectionData(
                    value: hard.toDouble(),
                    color: AppColors.hard,
                    title: '$hard',
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    radius: 30,
                  ),
                ],
              ),
            ),
          ),
          const Gap(AppSpacing.s),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: AppColors.easy, label: 'Easy'),
              const Gap(AppSpacing.m),
              _Legend(color: AppColors.medium, label: 'Medium'),
              const Gap(AppSpacing.m),
              _Legend(color: AppColors.hard, label: 'Hard'),
            ],
          ),
          const Gap(AppSpacing.l),

          // Activity heatmap (simplified)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Gap(AppSpacing.s),
          _ActivityHeatmap(submissions: acSubmissions),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: 20),
              const Gap(AppSpacing.xs),
            ],
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const Gap(4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ActivityHeatmap extends StatelessWidget {
  final List submissions;

  const _ActivityHeatmap({required this.submissions});

  @override
  Widget build(BuildContext context) {
    // Count submissions per day for the last 90 days
    final now = DateTime.now();
    final counts = <String, int>{};
    for (final sub in submissions) {
      final date = DateTime.fromMillisecondsSinceEpoch(sub.timestamp * 1000).toLocal();
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: List.generate(90, (i) {
        final date = now.subtract(Duration(days: 89 - i));
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final count = counts[key] ?? 0;
        final color = count == 0
            ? AppColors.card
            : count == 1
                ? AppColors.easy.withValues(alpha: 0.3)
                : count <= 3
                    ? AppColors.easy.withValues(alpha: 0.6)
                    : AppColors.easy;
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

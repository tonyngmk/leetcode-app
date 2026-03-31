import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../cubits/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsBody();
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.m),
            children: [
              // Appearance Section
              _SectionHeader(title: 'Appearance'),
              const Gap(AppSpacing.s),
              _ThemeSelector(
                currentMode: state.themeMode,
                onChanged: (mode) {
                  context.read<SettingsCubit>().setThemeMode(mode);
                },
              ),
              const Gap(AppSpacing.l),

              // Notifications Section
              _SectionHeader(title: 'Notifications'),
              const Gap(AppSpacing.s),
              _SettingsCard(
                children: [
                  SwitchListTile(
                    title: const Text('Daily Challenge Reminder'),
                    subtitle: const Text('Get notified about the daily challenge'),
                    value: state.dailyReminder,
                    onChanged: (value) {
                      context.read<SettingsCubit>().setDailyReminder(value);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              const Gap(AppSpacing.l),

              // Account Section
              _SectionHeader(title: 'Account'),
              const Gap(AppSpacing.s),
              _SettingsCard(
                children: [
                  ListTile(
                    title: const Text('LeetCode Username'),
                    subtitle: Text(
                      state.username ?? 'Not set',
                      style: TextStyle(
                        color: state.username != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _showUsernameDialog(context, state.username),
                  ),
                ],
              ),
              const Gap(AppSpacing.l),

              // About Section
              _SectionHeader(title: 'About'),
              const Gap(AppSpacing.s),
              _SettingsCard(
                children: [
                  ListTile(
                    title: const Text('Version'),
                    subtitle: const Text('1.0.0'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Open Source Licenses'),
                    trailing: const Icon(Icons.chevron_right),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'AlgoFlow',
                        applicationVersion: '1.0.0',
                      );
                    },
                  ),
                ],
              ),
              const Gap(AppSpacing.l),

              // Danger Zone
              _SectionHeader(title: 'Data'),
              const Gap(AppSpacing.s),
              _SettingsCard(
                children: [
                  ListTile(
                    title: Text(
                      'Clear All Settings',
                      style: TextStyle(color: AppColors.hard),
                    ),
                    subtitle: const Text('Reset all preferences to defaults'),
                    trailing: Icon(Icons.delete_outline, color: AppColors.hard),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _showClearDialog(context),
                  ),
                ],
              ),
              const Gap(AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }

  void _showUsernameDialog(BuildContext context, String? currentUsername) {
    final controller = TextEditingController(text: currentUsername);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('LeetCode Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your username',
            prefixIcon: Icon(Icons.person_outline),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final username = controller.text.trim();
              if (username.isNotEmpty) {
                context.read<SettingsCubit>().setUsername(username);
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Settings?'),
        content: const Text(
          'This will reset all preferences to their defaults. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.hard,
            ),
            onPressed: () {
              context.read<SettingsCubit>().clearSettings();
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: Text(
            'Theme',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        _ThemeOption(
          title: 'Dark',
          subtitle: 'Easy on the eyes at night',
          icon: Icons.dark_mode,
          isSelected: currentMode == ThemeMode.dark,
          onTap: () => onChanged(ThemeMode.dark),
        ),
        const Gap(AppSpacing.s),
        _ThemeOption(
          title: 'Light',
          subtitle: 'Classic daytime look',
          icon: Icons.light_mode,
          isSelected: currentMode == ThemeMode.light,
          onTap: () => onChanged(ThemeMode.light),
        ),
        const Gap(AppSpacing.s),
        _ThemeOption(
          title: 'System',
          subtitle: 'Follow device settings',
          icon: Icons.settings_brightness,
          isSelected: currentMode == ThemeMode.system,
          onTap: () => onChanged(ThemeMode.system),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const Gap(AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

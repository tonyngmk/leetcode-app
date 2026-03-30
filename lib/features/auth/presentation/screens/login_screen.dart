import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../injection.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../profile/data/datasources/profile_remote_datasource.dart';
import '../cubits/auth_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(
        authInterceptor: sl<AuthInterceptor>(),
        profileRemote: sl<ProfileRemoteDataSource>(),
      ),
      child: const _LoginBody(),
    );
  }
}

class _LoginBody extends StatefulWidget {
  const _LoginBody();

  @override
  State<_LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<_LoginBody> {
  final _sessionController = TextEditingController();
  final _csrfController = TextEditingController();

  @override
  void dispose() {
    _sessionController.dispose();
    _csrfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Welcome, ${state.username}!')),
            );
            context.go('/');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connect your LeetCode account',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Gap(AppSpacing.s),
              Text(
                'To test and submit code, you need to provide your LeetCode session cookies.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Gap(AppSpacing.l),

              // Instructions
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How to get your cookies:',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Gap(AppSpacing.s),
                    _step('1. Open leetcode.com in your browser and sign in'),
                    _step('2. Open Developer Tools (F12)'),
                    _step('3. Go to Application > Cookies > leetcode.com'),
                    _step('4. Copy the values of LEETCODE_SESSION and csrftoken'),
                  ],
                ),
              ),
              const Gap(AppSpacing.l),

              // Session field
              Text('LEETCODE_SESSION', style: Theme.of(context).textTheme.labelLarge),
              const Gap(AppSpacing.xs),
              TextField(
                controller: _sessionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Paste your LEETCODE_SESSION cookie value...',
                ),
              ),
              const Gap(AppSpacing.m),

              // CSRF field
              Text('csrftoken', style: Theme.of(context).textTheme.labelLarge),
              const Gap(AppSpacing.xs),
              TextField(
                controller: _csrfController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Paste your csrftoken cookie value...',
                ),
              ),
              const Gap(AppSpacing.l),

              // Error message
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthError) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: Text(
                        state.message,
                        style: TextStyle(color: AppColors.hard),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Login button
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return FilledButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            final session = _sessionController.text.trim();
                            final csrf = _csrfController.text.trim();
                            if (session.isNotEmpty && csrf.isNotEmpty) {
                              context.read<AuthCubit>().login(
                                    session: session,
                                    csrftoken: csrf,
                                  );
                            }
                          },
                    child: state is AuthLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Validate & Login'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

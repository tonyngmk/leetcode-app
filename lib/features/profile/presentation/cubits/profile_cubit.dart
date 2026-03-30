import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_profile_model.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/utils/date_utils.dart';

// --- States ---

sealed class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final List<AcSubmission> acSubmissions;
  final int streak;

  ProfileLoaded({
    required this.profile,
    required this.acSubmissions,
    required this.streak,
  });
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// --- Cubit ---

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit({required ProfileRepository repository})
      : _repository = repository,
        super(ProfileInitial());

  Future<void> load([String? username]) async {
    final user = username ?? _repository.savedUsername;
    if (user == null) {
      emit(ProfileInitial());
      return;
    }

    emit(ProfileLoading());
    try {
      final results = await Future.wait([
        _repository.getUserProfile(user),
        _repository.getRecentAcSubmissions(user),
      ]);
      final profile = results[0] as UserProfile;
      final submissions = results[1] as List<AcSubmission>;

      final streak = AppDateUtils.calculateStreak(
        submissions.map((s) => s.timestamp).toList(),
      );

      emit(ProfileLoaded(
        profile: profile,
        acSubmissions: submissions,
        streak: streak,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> setUsername(String username) async {
    await _repository.saveUsername(username);
    await load(username);
  }
}

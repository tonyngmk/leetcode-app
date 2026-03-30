import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/network/auth_interceptor.dart';
import 'core/network/dio_client.dart';
import 'features/problems/data/datasources/problems_remote_datasource.dart';
import 'features/problems/data/datasources/problems_local_datasource.dart';
import 'features/problems/data/repositories/problems_repository_impl.dart';
import 'features/problems/domain/repositories/problems_repository.dart';
import 'features/solutions/data/datasources/solutions_local_datasource.dart';
import 'features/solutions/data/repositories/solutions_repository_impl.dart';
import 'features/solutions/domain/repositories/solutions_repository.dart';
import 'features/editor/data/datasources/judge_remote_datasource.dart';
import 'features/editor/data/repositories/judge_repository_impl.dart';
import 'features/editor/domain/repositories/judge_repository.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/datasources/profile_local_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Hive
  await Hive.initFlutter();
  final problemsBox = await Hive.openBox<Map>('problems');
  final solutionsBox = await Hive.openBox<Map>('solutions');
  final userDataBox = await Hive.openBox<dynamic>('user_data');

  // Network
  final authInterceptor = AuthInterceptor();
  final dioClient = DioClient(authInterceptor: authInterceptor);

  sl.registerSingleton<AuthInterceptor>(authInterceptor);
  sl.registerSingleton<DioClient>(dioClient);

  // Data sources
  sl.registerSingleton<ProblemsRemoteDataSource>(
    ProblemsRemoteDataSource(dioClient: dioClient),
  );
  sl.registerSingleton<ProblemsLocalDataSource>(
    ProblemsLocalDataSource(box: problemsBox),
  );
  sl.registerSingleton<SolutionsLocalDataSource>(
    SolutionsLocalDataSource(box: solutionsBox),
  );
  sl.registerSingleton<JudgeRemoteDataSource>(
    JudgeRemoteDataSource(dioClient: dioClient),
  );
  sl.registerSingleton<ProfileRemoteDataSource>(
    ProfileRemoteDataSource(dioClient: dioClient),
  );
  sl.registerSingleton<ProfileLocalDataSource>(
    ProfileLocalDataSource(box: userDataBox),
  );

  // Repositories
  sl.registerSingleton<ProblemsRepository>(
    ProblemsRepositoryImpl(
      remote: sl(),
      local: sl(),
    ),
  );
  sl.registerSingleton<SolutionsRepository>(
    SolutionsRepositoryImpl(local: sl()),
  );
  sl.registerSingleton<JudgeRepository>(
    JudgeRepositoryImpl(remote: sl()),
  );
  sl.registerSingleton<ProfileRepository>(
    ProfileRepositoryImpl(
      remote: sl(),
      local: sl(),
    ),
  );
}

import 'package:get_it/get_it.dart';
import 'package:calet/features/auth/domain/repositories/auth_repository.dart';
import 'package:calet/features/auth/service/google_auth.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Services
  getIt.registerLazySingleton<GoogleAuthService>(() => GoogleAuthService.instance);
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
}

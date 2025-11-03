import 'package:get_it/get_it.dart';
import 'package:calet/features/auth/domain/repositories/auth_repository.dart';
import 'package:calet/features/auth/infrastructure/google_auth_service.dart';
import 'package:calet/core/infrastructure/storage_service.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:calet/features/formulario/infrastructure/respuestas_repository_impl.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Infrastructure Services
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  
  // Services
  getIt.registerLazySingleton<GoogleAuthService>(() => GoogleAuthService.instance);
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );
  
  getIt.registerLazySingleton<RespuestasRepository>(
    () => RespuestasRepositoryImpl(),
  );
}

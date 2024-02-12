import 'package:code_warriors/src/controllers/settings_repository_impl.dart';
import 'package:get_it/get_it.dart';
import '../controllers/settings_repository.dart';
import 'package:hive/hive.dart';

Future<void> injectDependencies() async {
  // Reemplaza 'settingsBox' con el nombre que desees para la caja de Hive
  final box = await Hive.openBox<bool>('settingsBox');

  GetIt.I.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(box),
  );
}

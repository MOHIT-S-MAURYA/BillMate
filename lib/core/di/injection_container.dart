import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:billmate/core/di/injection_container.config.dart';
import 'package:billmate/core/database/database_helper.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

/// Register all dependencies for the application
/// This includes repositories, use cases, data sources, and BLoCs
@module
abstract class RegisterModule {
  @singleton
  DatabaseHelper get databaseHelper => DatabaseHelper();
}

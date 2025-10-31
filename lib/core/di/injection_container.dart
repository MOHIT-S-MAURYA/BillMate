import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:billmate/core/di/injection_container.config.dart';
import 'package:billmate/core/database/database_helper.dart';
import 'package:billmate/core/localization/country_service.dart';
import 'package:billmate/features/reports/data/datasources/reports_datasource.dart';
import 'package:billmate/features/reports/data/datasources/reports_local_datasource.dart';
import 'package:billmate/features/reports/domain/repositories/reports_repository.dart';
import 'package:billmate/features/reports/data/repositories/reports_repository_impl.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  getIt.init();

  // Manually register CountryService singleton
  getIt.registerSingleton<CountryService>(CountryService());
}

/// Register all dependencies for the application
/// This includes repositories, use cases, data sources, and BLoCs
@module
abstract class RegisterModule {
  @singleton
  DatabaseHelper get databaseHelper => DatabaseHelper();

  @injectable
  ReportsDataSource get reportsDataSource =>
      ReportsLocalDataSource(databaseHelper);

  @injectable
  ReportsRepository get reportsRepository =>
      ReportsRepositoryImpl(reportsDataSource);
}

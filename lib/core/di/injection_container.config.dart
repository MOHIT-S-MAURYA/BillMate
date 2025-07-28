// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:billmate/core/database/database_helper.dart' as _i14;
import 'package:billmate/core/di/injection_container.dart' as _i313;
import 'package:billmate/features/billing/data/datasources/billing_local_datasource.dart'
    as _i635;
import 'package:billmate/features/billing/data/repositories/billing_repository_impl.dart'
    as _i290;
import 'package:billmate/features/billing/domain/repositories/billing_repository.dart'
    as _i677;
import 'package:billmate/features/billing/domain/usecases/analytics_usecases.dart'
    as _i719;
import 'package:billmate/features/billing/domain/usecases/customer_usecases.dart'
    as _i1067;
import 'package:billmate/features/billing/domain/usecases/invoice_usecases.dart'
    as _i137;
import 'package:billmate/features/billing/domain/usecases/payment_history_usecases.dart'
    as _i924;
import 'package:billmate/features/billing/presentation/bloc/billing_bloc.dart'
    as _i59;
import 'package:billmate/features/billing/services/payment_alert_service.dart'
    as _i707;
import 'package:billmate/features/dashboard/presentation/bloc/dashboard_bloc.dart'
    as _i1059;
import 'package:billmate/features/inventory/data/datasources/inventory_local_datasource.dart'
    as _i132;
import 'package:billmate/features/inventory/data/repositories/inventory_repository_impl.dart'
    as _i1065;
import 'package:billmate/features/inventory/domain/repositories/inventory_repository.dart'
    as _i411;
import 'package:billmate/features/inventory/domain/usecases/inventory_management_usecases.dart'
    as _i520;
import 'package:billmate/features/inventory/domain/usecases/inventory_usecases.dart'
    as _i576;
import 'package:billmate/features/inventory/presentation/bloc/inventory_bloc.dart'
    as _i781;
import 'package:billmate/features/settings/data/datasources/settings_local_datasource.dart'
    as _i379;
import 'package:billmate/features/settings/data/repositories/settings_repository_impl.dart'
    as _i208;
import 'package:billmate/features/settings/domain/repositories/settings_repository.dart'
    as _i748;
import 'package:billmate/features/settings/domain/usecases/settings_usecases.dart'
    as _i130;
import 'package:billmate/features/settings/presentation/bloc/settings_bloc.dart'
    as _i148;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i14.DatabaseHelper>(() => registerModule.databaseHelper);
    gh.factory<_i635.BillingLocalDataSource>(
      () => _i635.BillingLocalDataSourceImpl(gh<_i14.DatabaseHelper>()),
    );
    gh.factory<_i379.SettingsLocalDataSource>(
      () => _i379.SettingsLocalDataSourceImpl(gh<_i14.DatabaseHelper>()),
    );
    gh.factory<_i132.InventoryLocalDataSource>(
      () => _i132.InventoryLocalDataSourceImpl(gh<_i14.DatabaseHelper>()),
    );
    gh.factory<_i411.InventoryRepository>(
      () =>
          _i1065.InventoryRepositoryImpl(gh<_i132.InventoryLocalDataSource>()),
    );
    gh.factory<_i677.BillingRepository>(
      () => _i290.BillingRepositoryImpl(gh<_i635.BillingLocalDataSource>()),
    );
    gh.factory<_i520.ReduceStockUseCase>(
      () => _i520.ReduceStockUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i520.IncreaseStockUseCase>(
      () => _i520.IncreaseStockUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i520.CheckStockAvailabilityUseCase>(
      () =>
          _i520.CheckStockAvailabilityUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i520.RecordInventoryTransactionUseCase>(
      () => _i520.RecordInventoryTransactionUseCase(
        gh<_i411.InventoryRepository>(),
      ),
    );
    gh.factory<_i520.ReduceStockForInvoiceUseCase>(
      () => _i520.ReduceStockForInvoiceUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i520.RestoreStockForCancelledInvoiceUseCase>(
      () => _i520.RestoreStockForCancelledInvoiceUseCase(
        gh<_i411.InventoryRepository>(),
      ),
    );
    gh.factory<_i576.GetAllItemsUseCase>(
      () => _i576.GetAllItemsUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i576.GetItemByIdUseCase>(
      () => _i576.GetItemByIdUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i576.SearchItemsUseCase>(
      () => _i576.SearchItemsUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i576.CreateItemUseCase>(
      () => _i576.CreateItemUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i576.UpdateItemUseCase>(
      () => _i576.UpdateItemUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i576.DeleteItemUseCase>(
      () => _i576.DeleteItemUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i576.UpdateStockUseCase>(
      () => _i576.UpdateStockUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i576.GetLowStockItemsUseCase>(
      () => _i576.GetLowStockItemsUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i576.GetAllCategoriesUseCase>(
      () => _i576.GetAllCategoriesUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i576.CreateCategoryUseCase>(
      () => _i576.CreateCategoryUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i576.UpdateCategoryUseCase>(
      () => _i576.UpdateCategoryUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i576.DeleteCategoryUseCase>(
      () => _i576.DeleteCategoryUseCase(gh<_i411.InventoryRepository>()),
    );
    gh.factory<_i1059.DashboardBloc>(
      () => _i1059.DashboardBloc(
        getAllItemsUseCase: gh<_i576.GetAllItemsUseCase>(),
        getLowStockItemsUseCase: gh<_i576.GetLowStockItemsUseCase>(),
        getAllCategoriesUseCase: gh<_i576.GetAllCategoriesUseCase>(),
      ),
    );
    gh.factory<_i748.SettingsRepository>(
      () => _i208.SettingsRepositoryImpl(gh<_i379.SettingsLocalDataSource>()),
    );
    gh.factory<_i707.PaymentAlertService>(
      () => _i707.PaymentAlertService(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i719.GetBillingDashboardStatsUseCase>(
      () =>
          _i719.GetBillingDashboardStatsUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i719.GetSalesReportUseCase>(
      () => _i719.GetSalesReportUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i719.GetPaymentReportUseCase>(
      () => _i719.GetPaymentReportUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i137.GetAllInvoicesUseCase>(
      () => _i137.GetAllInvoicesUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i137.GetInvoiceByIdUseCase>(
      () => _i137.GetInvoiceByIdUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i137.GetInvoiceByNumberUseCase>(
      () => _i137.GetInvoiceByNumberUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i137.GetInvoicesByCustomerUseCase>(
      () => _i137.GetInvoicesByCustomerUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i137.GetInvoicesByDateRangeUseCase>(
      () => _i137.GetInvoicesByDateRangeUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i137.SearchInvoicesUseCase>(
      () => _i137.SearchInvoicesUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i137.CreateInvoiceUseCase>(
      () => _i137.CreateInvoiceUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i137.UpdateInvoiceUseCase>(
      () => _i137.UpdateInvoiceUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i137.DeleteInvoiceUseCase>(
      () => _i137.DeleteInvoiceUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i137.UpdatePaymentStatusUseCase>(
      () => _i137.UpdatePaymentStatusUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i137.UpdatePartialPaymentUseCase>(
      () => _i137.UpdatePartialPaymentUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i137.ValidateInventoryQuantityUseCase>(
      () =>
          _i137.ValidateInventoryQuantityUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i137.GetAvailableStockUseCase>(
      () => _i137.GetAvailableStockUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i924.CreatePaymentHistoryUseCase>(
      () => _i924.CreatePaymentHistoryUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i924.GetPaymentHistoryByInvoiceUseCase>(
      () => _i924.GetPaymentHistoryByInvoiceUseCase(
        gh<_i677.BillingRepository>(),
      ),
    );
    gh.factory<_i924.GetAllPaymentHistoryUseCase>(
      () => _i924.GetAllPaymentHistoryUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i924.DeletePaymentHistoryUseCase>(
      () => _i924.DeletePaymentHistoryUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i1067.GetAllCustomersUseCase>(
      () => _i1067.GetAllCustomersUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i1067.GetCustomerByIdUseCase>(
      () => _i1067.GetCustomerByIdUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i1067.SearchCustomersUseCase>(
      () => _i1067.SearchCustomersUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i1067.CreateCustomerUseCase>(
      () => _i1067.CreateCustomerUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i1067.UpdateCustomerUseCase>(
      () => _i1067.UpdateCustomerUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i1067.DeleteCustomerUseCase>(
      () => _i1067.DeleteCustomerUseCase(gh<_i677.BillingRepository>()),
    );
    gh.factory<_i781.InventoryBloc>(
      () => _i781.InventoryBloc(
        getAllItemsUseCase: gh<_i576.GetAllItemsUseCase>(),
        searchItemsUseCase: gh<_i576.SearchItemsUseCase>(),
        createItemUseCase: gh<_i576.CreateItemUseCase>(),
        updateItemUseCase: gh<_i576.UpdateItemUseCase>(),
        deleteItemUseCase: gh<_i576.DeleteItemUseCase>(),
        updateStockUseCase: gh<_i576.UpdateStockUseCase>(),
        getLowStockItemsUseCase: gh<_i576.GetLowStockItemsUseCase>(),
        getAllCategoriesUseCase: gh<_i576.GetAllCategoriesUseCase>(),
        createCategoryUseCase: gh<_i576.CreateCategoryUseCase>(),
        updateCategoryUseCase: gh<_i576.UpdateCategoryUseCase>(),
        deleteCategoryUseCase: gh<_i576.DeleteCategoryUseCase>(),
      ),
    );
    gh.factory<_i130.GetAllSettingsUseCase>(
      () => _i130.GetAllSettingsUseCase(gh<_i748.SettingsRepository>()),
    );
    gh.factory<_i130.GetSettingByKeyUseCase>(
      () => _i130.GetSettingByKeyUseCase(gh<_i748.SettingsRepository>()),
    );
    gh.factory<_i130.UpdateSettingUseCase>(
      () => _i130.UpdateSettingUseCase(gh<_i748.SettingsRepository>()),
    );
    gh.factory<_i130.GetBusinessConfigUseCase>(
      () => _i130.GetBusinessConfigUseCase(gh<_i748.SettingsRepository>()),
    );
    gh.factory<_i130.GetNextInvoiceNumberUseCase>(
      () => _i130.GetNextInvoiceNumberUseCase(gh<_i748.SettingsRepository>()),
    );
    gh.factory<_i130.UpdateNextInvoiceNumberUseCase>(
      () =>
          _i130.UpdateNextInvoiceNumberUseCase(gh<_i748.SettingsRepository>()),
    );
    gh.factory<_i59.BillingBloc>(
      () => _i59.BillingBloc(
        getAllInvoicesUseCase: gh<_i137.GetAllInvoicesUseCase>(),
        getInvoiceByIdUseCase: gh<_i137.GetInvoiceByIdUseCase>(),
        getInvoiceByNumberUseCase: gh<_i137.GetInvoiceByNumberUseCase>(),
        getInvoicesByCustomerUseCase: gh<_i137.GetInvoicesByCustomerUseCase>(),
        getInvoicesByDateRangeUseCase:
            gh<_i137.GetInvoicesByDateRangeUseCase>(),
        searchInvoicesUseCase: gh<_i137.SearchInvoicesUseCase>(),
        createInvoiceUseCase: gh<_i137.CreateInvoiceUseCase>(),
        updateInvoiceUseCase: gh<_i137.UpdateInvoiceUseCase>(),
        deleteInvoiceUseCase: gh<_i137.DeleteInvoiceUseCase>(),
        updatePaymentStatusUseCase: gh<_i137.UpdatePaymentStatusUseCase>(),
        updatePartialPaymentUseCase: gh<_i137.UpdatePartialPaymentUseCase>(),
        validateInventoryQuantityUseCase:
            gh<_i137.ValidateInventoryQuantityUseCase>(),
        getAvailableStockUseCase: gh<_i137.GetAvailableStockUseCase>(),
        getAllCustomersUseCase: gh<_i1067.GetAllCustomersUseCase>(),
        getCustomerByIdUseCase: gh<_i1067.GetCustomerByIdUseCase>(),
        searchCustomersUseCase: gh<_i1067.SearchCustomersUseCase>(),
        createCustomerUseCase: gh<_i1067.CreateCustomerUseCase>(),
        updateCustomerUseCase: gh<_i1067.UpdateCustomerUseCase>(),
        deleteCustomerUseCase: gh<_i1067.DeleteCustomerUseCase>(),
        getBillingDashboardStatsUseCase:
            gh<_i719.GetBillingDashboardStatsUseCase>(),
        getSalesReportUseCase: gh<_i719.GetSalesReportUseCase>(),
        getPaymentReportUseCase: gh<_i719.GetPaymentReportUseCase>(),
        createPaymentHistoryUseCase: gh<_i924.CreatePaymentHistoryUseCase>(),
        getPaymentHistoryByInvoiceUseCase:
            gh<_i924.GetPaymentHistoryByInvoiceUseCase>(),
        getAllPaymentHistoryUseCase: gh<_i924.GetAllPaymentHistoryUseCase>(),
        deletePaymentHistoryUseCase: gh<_i924.DeletePaymentHistoryUseCase>(),
        reduceStockForInvoiceUseCase: gh<_i520.ReduceStockForInvoiceUseCase>(),
        restoreStockForCancelledInvoiceUseCase:
            gh<_i520.RestoreStockForCancelledInvoiceUseCase>(),
        checkStockAvailabilityUseCase:
            gh<_i520.CheckStockAvailabilityUseCase>(),
      ),
    );
    gh.factory<_i148.SettingsBloc>(
      () => _i148.SettingsBloc(
        getAllSettingsUseCase: gh<_i130.GetAllSettingsUseCase>(),
        getBusinessConfigUseCase: gh<_i130.GetBusinessConfigUseCase>(),
        updateSettingUseCase: gh<_i130.UpdateSettingUseCase>(),
        getNextInvoiceNumberUseCase: gh<_i130.GetNextInvoiceNumberUseCase>(),
        updateNextInvoiceNumberUseCase:
            gh<_i130.UpdateNextInvoiceNumberUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i313.RegisterModule {}

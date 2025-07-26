import 'package:billmate/features/settings/domain/entities/setting.dart';
import 'package:billmate/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAllSettingsUseCase {
  final SettingsRepository repository;

  GetAllSettingsUseCase(this.repository);

  Future<List<Setting>> call() async {
    return await repository.getAllSettings();
  }
}

@injectable
class GetSettingByKeyUseCase {
  final SettingsRepository repository;

  GetSettingByKeyUseCase(this.repository);

  Future<Setting?> call(String key) async {
    return await repository.getSettingByKey(key);
  }
}

@injectable
class UpdateSettingUseCase {
  final SettingsRepository repository;

  UpdateSettingUseCase(this.repository);

  Future<void> call(String key, String value) async {
    return await repository.updateSetting(key, value);
  }
}

@injectable
class GetBusinessConfigUseCase {
  final SettingsRepository repository;

  GetBusinessConfigUseCase(this.repository);

  Future<Map<String, String?>> call() async {
    final businessName = await repository.getBusinessName();
    final businessGstin = await repository.getBusinessGstin();
    final businessStateCode = await repository.getBusinessStateCode();
    final businessAddress = await repository.getBusinessAddress();
    final businessPhone = await repository.getBusinessPhone();
    final businessEmail = await repository.getBusinessEmail();

    return {
      'business_name': businessName,
      'business_gstin': businessGstin,
      'business_state_code':
          businessStateCode, // Map state_code to business_state_code for UI consistency
      'business_address': businessAddress,
      'business_phone': businessPhone,
      'business_email': businessEmail,
    };
  }
}

@injectable
class GetNextInvoiceNumberUseCase {
  final SettingsRepository repository;

  GetNextInvoiceNumberUseCase(this.repository);

  Future<int> call() async {
    return await repository.getNextInvoiceNumber();
  }
}

@injectable
class UpdateNextInvoiceNumberUseCase {
  final SettingsRepository repository;

  UpdateNextInvoiceNumberUseCase(this.repository);

  Future<void> call(int nextNumber) async {
    return await repository.updateNextInvoiceNumber(nextNumber);
  }
}

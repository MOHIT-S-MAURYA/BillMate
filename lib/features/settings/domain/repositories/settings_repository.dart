import 'package:billmate/features/settings/domain/entities/setting.dart';

abstract class SettingsRepository {
  Future<List<Setting>> getAllSettings();
  Future<Setting?> getSettingByKey(String key);
  Future<void> updateSetting(String key, String value);
  Future<void> createSetting(Setting setting);
  Future<void> deleteSetting(String key);

  // Business-specific convenience methods
  Future<String?> getBusinessName();
  Future<String?> getBusinessGstin();
  Future<String?> getBusinessStateCode();
  Future<String?> getBusinessAddress();
  Future<String?> getBusinessPhone();
  Future<String?> getBusinessEmail();
  Future<int> getNextInvoiceNumber();
  Future<void> updateNextInvoiceNumber(int nextNumber);
}

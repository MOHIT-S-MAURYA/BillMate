import 'package:billmate/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:billmate/features/settings/data/models/setting_model.dart';
import 'package:billmate/features/settings/domain/entities/setting.dart';
import 'package:billmate/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<List<Setting>> getAllSettings() async {
    final settingModels = await localDataSource.getAllSettings();
    return settingModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Setting?> getSettingByKey(String key) async {
    final settingModel = await localDataSource.getSettingByKey(key);
    return settingModel?.toEntity();
  }

  @override
  Future<void> updateSetting(String key, String value) async {
    await localDataSource.updateSetting(key, value);
  }

  @override
  Future<void> createSetting(Setting setting) async {
    final settingModel = SettingModel.fromEntity(setting);
    await localDataSource.createSetting(settingModel);
  }

  @override
  Future<void> deleteSetting(String key) async {
    await localDataSource.deleteSetting(key);
  }

  @override
  Future<String?> getBusinessName() async {
    final setting = await getSettingByKey('business_name');
    return setting?.value;
  }

  @override
  Future<String?> getBusinessGstin() async {
    final setting = await getSettingByKey('business_gstin');
    return setting?.value;
  }

  @override
  Future<String?> getBusinessStateCode() async {
    final setting = await getSettingByKey('state_code');
    return setting?.value;
  }

  @override
  Future<String?> getBusinessAddress() async {
    final setting = await getSettingByKey('business_address');
    return setting?.value;
  }

  @override
  Future<String?> getBusinessPhone() async {
    final setting = await getSettingByKey('business_phone');
    return setting?.value;
  }

  @override
  Future<String?> getBusinessEmail() async {
    final setting = await getSettingByKey('business_email');
    return setting?.value;
  }

  @override
  Future<int> getNextInvoiceNumber() async {
    final setting = await getSettingByKey('next_invoice_number');
    if (setting != null) {
      return int.tryParse(setting.value) ?? 1;
    }
    return 1;
  }

  @override
  Future<void> updateNextInvoiceNumber(int nextNumber) async {
    await updateSetting('next_invoice_number', nextNumber.toString());
  }
}

import 'package:billmate/core/database/database_helper.dart';
import 'package:billmate/features/settings/data/models/setting_model.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

abstract class SettingsLocalDataSource {
  Future<List<SettingModel>> getAllSettings();
  Future<SettingModel?> getSettingByKey(String key);
  Future<void> updateSetting(String key, String value);
  Future<void> createSetting(SettingModel setting);
  Future<void> deleteSetting(String key);
}

@Injectable(as: SettingsLocalDataSource)
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final DatabaseHelper databaseHelper;

  SettingsLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<List<SettingModel>> getAllSettings() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('settings');

    return List.generate(maps.length, (i) {
      return SettingModel.fromJson(maps[i]);
    });
  }

  @override
  Future<SettingModel?> getSettingByKey(String key) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return SettingModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<void> updateSetting(String key, String value) async {
    final db = await databaseHelper.database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      'settings',
      {'value': value, 'updated_at': now},
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  @override
  Future<void> createSetting(SettingModel setting) async {
    final db = await databaseHelper.database;
    await db.insert(
      'settings',
      setting.toJsonWithoutId(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteSetting(String key) async {
    final db = await databaseHelper.database;
    await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }
}

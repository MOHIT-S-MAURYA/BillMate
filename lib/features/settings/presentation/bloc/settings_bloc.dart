import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:billmate/features/settings/domain/entities/setting.dart';
import 'package:billmate/features/settings/domain/usecases/settings_usecases.dart';
import 'package:injectable/injectable.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadAllSettings extends SettingsEvent {}

class LoadBusinessConfig extends SettingsEvent {}

class UpdateSettingEvent extends SettingsEvent {
  final String key;
  final String value;

  const UpdateSettingEvent({required this.key, required this.value});

  @override
  List<Object> get props => [key, value];
}

class LoadNextInvoiceNumber extends SettingsEvent {}

class UpdateNextInvoiceNumber extends SettingsEvent {
  final int nextNumber;

  const UpdateNextInvoiceNumber({required this.nextNumber});

  @override
  List<Object> get props => [nextNumber];
}

class UpdateBusinessConfig extends SettingsEvent {
  final Map<String, String> config;

  const UpdateBusinessConfig(this.config);

  @override
  List<Object> get props => [config];
}

// States
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final List<Setting> settings;

  const SettingsLoaded({required this.settings});

  @override
  List<Object> get props => [settings];
}

class BusinessConfigLoaded extends SettingsState {
  final Map<String, String?> config;

  const BusinessConfigLoaded({required this.config});

  @override
  List<Object> get props => [config];
}

class NextInvoiceNumberLoaded extends SettingsState {
  final int nextNumber;

  const NextInvoiceNumberLoaded({required this.nextNumber});

  @override
  List<Object> get props => [nextNumber];
}

class SettingsUpdated extends SettingsState {
  final String message;

  const SettingsUpdated({required this.message});

  @override
  List<Object> get props => [message];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetAllSettingsUseCase getAllSettingsUseCase;
  final GetBusinessConfigUseCase getBusinessConfigUseCase;
  final UpdateSettingUseCase updateSettingUseCase;
  final GetNextInvoiceNumberUseCase getNextInvoiceNumberUseCase;
  final UpdateNextInvoiceNumberUseCase updateNextInvoiceNumberUseCase;

  SettingsBloc({
    required this.getAllSettingsUseCase,
    required this.getBusinessConfigUseCase,
    required this.updateSettingUseCase,
    required this.getNextInvoiceNumberUseCase,
    required this.updateNextInvoiceNumberUseCase,
  }) : super(SettingsInitial()) {
    on<LoadAllSettings>(_onLoadAllSettings);
    on<LoadBusinessConfig>(_onLoadBusinessConfig);
    on<UpdateSettingEvent>(_onUpdateSetting);
    on<LoadNextInvoiceNumber>(_onLoadNextInvoiceNumber);
    on<UpdateNextInvoiceNumber>(_onUpdateNextInvoiceNumber);
    on<UpdateBusinessConfig>(_onUpdateBusinessConfig);
  }

  Future<void> _onLoadAllSettings(
    LoadAllSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final settings = await getAllSettingsUseCase();
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> _onLoadBusinessConfig(
    LoadBusinessConfig event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final config = await getBusinessConfigUseCase();
      emit(BusinessConfigLoaded(config: config));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> _onUpdateSetting(
    UpdateSettingEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await updateSettingUseCase(event.key, event.value);
      emit(const SettingsUpdated(message: 'Setting updated successfully'));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> _onLoadNextInvoiceNumber(
    LoadNextInvoiceNumber event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final nextNumber = await getNextInvoiceNumberUseCase();
      emit(NextInvoiceNumberLoaded(nextNumber: nextNumber));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> _onUpdateNextInvoiceNumber(
    UpdateNextInvoiceNumber event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await updateNextInvoiceNumberUseCase(event.nextNumber);
      emit(
        const SettingsUpdated(message: 'Invoice number updated successfully'),
      );
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> _onUpdateBusinessConfig(
    UpdateBusinessConfig event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      // Update each setting in the config
      for (final entry in event.config.entries) {
        if (entry.value.isNotEmpty) {
          // Map UI key to database key for state code
          final databaseKey =
              entry.key == 'business_state_code' ? 'state_code' : entry.key;
          await updateSettingUseCase(databaseKey, entry.value);
        }
      }

      // Reload the business config to show updated values
      final updatedConfig = await getBusinessConfigUseCase();
      emit(BusinessConfigLoaded(config: updatedConfig));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }
}

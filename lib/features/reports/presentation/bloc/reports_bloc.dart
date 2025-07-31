import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:billmate/features/reports/domain/entities/report.dart';
import 'package:billmate/features/reports/domain/repositories/reports_repository.dart';
import 'package:billmate/features/reports/domain/usecases/reports_usecases.dart';

part 'reports_event.dart';
part 'reports_state.dart';

@injectable
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GenerateSalesReportUseCase _generateSalesReportUseCase;
  final GenerateInventoryReportUseCase _generateInventoryReportUseCase;
  final GeneratePaymentReportUseCase _generatePaymentReportUseCase;
  final GenerateBusinessReportUseCase _generateBusinessReportUseCase;
  final ExportReportUseCase _exportReportUseCase;

  ReportsBloc(
    this._generateSalesReportUseCase,
    this._generateInventoryReportUseCase,
    this._generatePaymentReportUseCase,
    this._generateBusinessReportUseCase,
    this._exportReportUseCase,
  ) : super(ReportsInitial()) {
    on<GenerateSalesReportEvent>(_onGenerateSalesReport);
    on<GenerateInventoryReportEvent>(_onGenerateInventoryReport);
    on<GeneratePaymentReportEvent>(_onGeneratePaymentReport);
    on<GenerateBusinessReportEvent>(_onGenerateBusinessReport);
    on<ExportReportEvent>(_onExportReport);
    on<ResetReportsEvent>(_onResetReports);
  }

  Future<void> _onGenerateSalesReport(
    GenerateSalesReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final report = await _generateSalesReportUseCase(event.dateRange);
      emit(ReportsLoaded(report: report));
    } catch (e) {
      emit(ReportsError(message: e.toString()));
    }
  }

  Future<void> _onGenerateInventoryReport(
    GenerateInventoryReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final report = await _generateInventoryReportUseCase(event.dateRange);
      emit(ReportsLoaded(report: report));
    } catch (e) {
      emit(ReportsError(message: e.toString()));
    }
  }

  Future<void> _onGeneratePaymentReport(
    GeneratePaymentReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final report = await _generatePaymentReportUseCase(event.dateRange);
      emit(ReportsLoaded(report: report));
    } catch (e) {
      emit(ReportsError(message: e.toString()));
    }
  }

  Future<void> _onGenerateBusinessReport(
    GenerateBusinessReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final report = await _generateBusinessReportUseCase(event.dateRange);
      emit(ReportsLoaded(report: report));
    } catch (e) {
      emit(ReportsError(message: e.toString()));
    }
  }

  Future<void> _onExportReport(
    ExportReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    if (state is! ReportsLoaded) return;

    final currentState = state as ReportsLoaded;
    emit(ReportsExporting());

    try {
      final exportPath = await _exportReportUseCase(
        currentState.report,
        event.format,
      );
      emit(
        ReportsExported(report: currentState.report, exportPath: exportPath),
      );
    } catch (e) {
      emit(ReportsError(message: e.toString()));
    }
  }

  void _onResetReports(ResetReportsEvent event, Emitter<ReportsState> emit) {
    emit(ReportsInitial());
  }
}

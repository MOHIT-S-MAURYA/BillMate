part of 'reports_bloc.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object> get props => [];
}

class GenerateSalesReportEvent extends ReportsEvent {
  final DateRange dateRange;

  const GenerateSalesReportEvent({required this.dateRange});

  @override
  List<Object> get props => [dateRange];
}

class GenerateInventoryReportEvent extends ReportsEvent {
  final DateRange dateRange;

  const GenerateInventoryReportEvent({required this.dateRange});

  @override
  List<Object> get props => [dateRange];
}

class GeneratePaymentReportEvent extends ReportsEvent {
  final DateRange dateRange;

  const GeneratePaymentReportEvent({required this.dateRange});

  @override
  List<Object> get props => [dateRange];
}

class GenerateBusinessReportEvent extends ReportsEvent {
  final DateRange dateRange;

  const GenerateBusinessReportEvent({required this.dateRange});

  @override
  List<Object> get props => [dateRange];
}

class ExportReportEvent extends ReportsEvent {
  final ExportFormat format;

  const ExportReportEvent({required this.format});

  @override
  List<Object> get props => [format];
}

class ResetReportsEvent extends ReportsEvent {
  const ResetReportsEvent();
}

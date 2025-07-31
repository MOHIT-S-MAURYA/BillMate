part of 'reports_bloc.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final Report report;

  const ReportsLoaded({required this.report});

  @override
  List<Object> get props => [report];
}

class ReportsExporting extends ReportsState {}

class ReportsExported extends ReportsState {
  final Report report;
  final String exportPath;

  const ReportsExported({required this.report, required this.exportPath});

  @override
  List<Object> get props => [report, exportPath];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError({required this.message});

  @override
  List<Object> get props => [message];
}

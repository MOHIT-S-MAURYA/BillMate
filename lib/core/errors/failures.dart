/// Core error classes for the application
abstract class Failure {
  const Failure();
}

/// Database related failures
class DatabaseFailure extends Failure {
  final String message;
  const DatabaseFailure(this.message);

  @override
  String toString() => 'DatabaseFailure: $message';
}

/// Network related failures
class NetworkFailure extends Failure {
  final String message;
  const NetworkFailure(this.message);

  @override
  String toString() => 'NetworkFailure: $message';
}

/// Validation related failures
class ValidationFailure extends Failure {
  final String message;
  const ValidationFailure(this.message);

  @override
  String toString() => 'ValidationFailure: $message';
}

/// File system related failures
class FileSystemFailure extends Failure {
  final String message;
  const FileSystemFailure(this.message);

  @override
  String toString() => 'FileSystemFailure: $message';
}

/// GST calculation related failures
class GstCalculationFailure extends Failure {
  final String message;
  const GstCalculationFailure(this.message);

  @override
  String toString() => 'GstCalculationFailure: $message';
}

/// PDF generation related failures
class PdfGenerationFailure extends Failure {
  final String message;
  const PdfGenerationFailure(this.message);

  @override
  String toString() => 'PdfGenerationFailure: $message';
}

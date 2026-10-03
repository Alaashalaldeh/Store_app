class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, dynamic> errors;

  const ApiException(this.message, {this.statusCode, this.errors = const {}});

  @override
  String toString() => message;
}

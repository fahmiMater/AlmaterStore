/// حالة العملية
enum ResponseStatus { success, failure }

/// كود خطأ اختياري لتوحيد الأنواع الشائعة
enum ErrorCode {
  notFound,
  alreadyExists,
  invalidInput,
  conflict,
  unknown,
}

/// ريسبونس عام قابل للتطبيق على أي نوع بيانات T
class AppResponse<T> {
  final ResponseStatus status;
  final String message;
  final T? data;
  final ErrorCode? error;

  const AppResponse._({
    required this.status,
    required this.message,
    this.data,
    this.error,
  });

  /// نجاح
  factory AppResponse.success(T data, {String message = 'Success'}) {
    return AppResponse._(
      status: ResponseStatus.success,
      message: message,
      data: data,
    );
  }

  /// فشل
  factory AppResponse.failure(String message, {ErrorCode? code}) {
    return AppResponse._(
      status: ResponseStatus.failure,
      message: message,
      error: code ?? ErrorCode.unknown,
    );
  }

  bool get isSuccess => status == ResponseStatus.success;

  /// تحويل النتيجة (مفيد لسلاسل المعالجات)
  AppResponse<R> map<R>(R Function(T value) convert) {
    if (!isSuccess || data == null) {
      return AppResponse.failure(message, code: error);
    }
    return AppResponse.success(convert(data as T), message: message);
  }

  @override
  String toString() =>
      'AppResponse(status: $status, message: $message, data: $data, error: $error)';
}

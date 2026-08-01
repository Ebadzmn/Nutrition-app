class ApiResponse<T> {
  final bool isSuccess;
  final int statusCode;
  final T? data;
  final String message;

  ApiResponse({
    required this.isSuccess,
    required this.statusCode,
    this.data,
    required this.message,
  });

  factory ApiResponse.success(T data, {int statusCode = 200, String message = 'Success'}) {
    return ApiResponse(
      isSuccess: true,
      statusCode: statusCode,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, {int statusCode = 500, T? data}) {
    return ApiResponse(
      isSuccess: false,
      statusCode: statusCode,
      data: data,
      message: message,
    );
  }
}

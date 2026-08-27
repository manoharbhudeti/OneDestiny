class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final List<String> errors;

  const ApiResponse({
    required this.success,
    this.data,
    this.message = '',
    this.errors = const [],
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    T? parsedData;
    if (json['data'] != null && fromJsonT != null) {
      try {
        parsedData = fromJsonT(json['data']);
      } catch (e) {
        // Fallback if conversion fails
        parsedData = null;
      }
    }

    final errorsList = json['errors'] is List
        ? (json['errors'] as List).map((e) => e.toString()).toList()
        : <String>[];

    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      data: parsedData,
      message: json['message'] as String? ?? '',
      errors: errorsList,
    );
  }

  factory ApiResponse.ok(T data, [String message = 'Success']) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.fail(String error, [String message = 'Failed']) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: [error],
    );
  }
}

class PagedResponse<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const PagedResponse({
    this.items = const [],
    this.totalCount = 0,
    this.page = 1,
    this.pageSize = 20,
    this.totalPages = 1,
    this.hasPreviousPage = false,
    this.hasNextPage = false,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonItem,
  ) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((e) => fromJsonItem(e)).toList();

    return PagedResponse<T>(
      items: items,
      totalCount: json['totalCount'] as int? ?? items.length,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? 1,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }
}

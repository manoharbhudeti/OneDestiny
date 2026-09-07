import 'package:flutter/foundation.dart';

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
    Map<String, dynamic> source = json;
    List<dynamic> rawItems = [];

    if (json['data'] is Map<String, dynamic>) {
      source = json['data'] as Map<String, dynamic>;
      if (source['items'] is List) {
        rawItems = source['items'] as List<dynamic>;
      } else if (source['data'] is List) {
        rawItems = source['data'] as List<dynamic>;
      }
    } else if (json['data'] is List) {
      rawItems = json['data'] as List<dynamic>;
    } else if (json['items'] is List) {
      rawItems = json['items'] as List<dynamic>;
    }

    final items = <T>[];
    for (final e in rawItems) {
      try {
        items.add(fromJsonItem(e));
      } catch (err) {
        debugPrint('[PagedResponse parse item error] $err');
      }
    }

    final totalCount = source['totalCount'] as int? ??
        json['totalCount'] as int? ??
        items.length;
    final page = source['page'] as int? ?? json['page'] as int? ?? 1;
    final pageSize = source['pageSize'] as int? ?? json['pageSize'] as int? ?? 20;
    final totalPages = source['totalPages'] as int? ?? json['totalPages'] as int? ?? 1;
    final hasPreviousPage = source['hasPreviousPage'] as bool? ??
        json['hasPreviousPage'] as bool? ??
        false;
    final hasNextPage = source['hasNextPage'] as bool? ??
        json['hasNextPage'] as bool? ??
        false;

    return PagedResponse<T>(
      items: items,
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
      totalPages: totalPages,
      hasPreviousPage: hasPreviousPage,
      hasNextPage: hasNextPage,
    );
  }
}

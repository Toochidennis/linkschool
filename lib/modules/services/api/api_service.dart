import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'dart:io';

// Enum to define the available HTTP methods
enum HttpMethod { GET, POST, PUT, DELETE, PATCH }

// Enum to define the supported payload types
enum PayloadType { JSON, FORM_DATA }

// Define standard API response structure
class ApiResponse<T> {
  final bool success;
  final String message;
  final int statusCode;
  final T? data;
  final Map<String, dynamic>? rawData;

  ApiResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    this.data,
    this.rawData,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, {T? parsedData}) {
    bool isSuccess = false;
    String message = "Unknown response";

    // Check for common API status indicators
    if (json.containsKey('status')) {
      isSuccess = json['status'] == 'success' || json['status'] == true;
      message = json['message'] ?? 'Operation completed';
    } else if (json.containsKey('success')) {
      isSuccess = json['success'] == true;
      message = json['message'] ?? 'Operation completed';
    }

    return ApiResponse<T>(
      success: isSuccess,
      message: message,
      statusCode: 200,
      data: parsedData,
      rawData: json,
    );
  }

  factory ApiResponse.error(String errorMessage, int statusCode) {
    return ApiResponse<T>(
      success: false,
      message: errorMessage,
      statusCode: statusCode,
      data: null,
      rawData: {'error': errorMessage},
    );
  }
}

// Base API Service
class ApiService {
  final String baseUrl;
  final String? apiKey;
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  ApiService({String? baseUrl, String? apiKey})
      : baseUrl = baseUrl ??
            dotenv.env['API_BASE_URL'] ??
            'https://linkskool.net/api/v3',
        apiKey = apiKey ?? dotenv.env['API_KEY'] {
    print('Initializing ApiService with baseUrl: $baseUrl');
  }

  void setAuthToken(String token) {
    _defaultHeaders['Authorization'] = 'Bearer $token';
    print('Auth token set in headers');
  }

  // Helper method to get current database dynamically
  String _getCurrentDatabase() {
    try {
      final userBox = Hive.box('userData');
      final db = userBox.get('_db');
      if (db == null || db.toString().isEmpty) {
        throw Exception('No database configuration found. Please login again.');
      }
      return db.toString();
    } catch (e) {
      throw Exception('Failed to get database configuration: $e');
    }
  }

  // Helper method to add database to query params if not already present
  Map<String, dynamic> _ensureDatabaseParam(Map<String, dynamic>? queryParams) {
    final params = Map<String, dynamic>.from(queryParams ?? {});

    // Only add _db if it's not already present
    if (!params.containsKey('_db')) {
      params['_db'] = _getCurrentDatabase();
    }

    return params;
  }

  Future<ApiResponse<T>> request<T>({
    required String endpoint,
    required HttpMethod method,
    Map<String, dynamic>? queryParams,
    dynamic body,
    PayloadType payloadType = PayloadType.JSON,
    T Function(Map<String, dynamic> json)? fromJson,
    bool addDatabaseParam = true, // New parameter to control database injection
  }) async {
    try {
      final headers = Map<String, String>.from(_defaultHeaders);
      if (apiKey != null) {
        headers['X-API-KEY'] = apiKey!;
      }
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';

      // Add database parameter if requested and not already present
      Map<String, dynamic>? finalQueryParams = queryParams;
      if (addDatabaseParam) {
        try {
          finalQueryParams = _ensureDatabaseParam(queryParams);
        } catch (e) {
          print('Warning: Could not add database parameter: $e');
          // Continue without database parameter for login and other auth endpoints
        }
      }

      final uri = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: finalQueryParams
            ?.map((key, value) => MapEntry(key, value.toString())),
      );

      print('Making ${method.toString()} request to: ${uri.toString()}');
      print('Headers: ${headers.keys.join(', ')}');

      http.Response response;
      switch (method) {
        case HttpMethod.GET:
          response = await http.get(uri, headers: headers);
          break;
        case HttpMethod.POST:
          if (payloadType == PayloadType.JSON) {
            // Add database to body if it's a Map and doesn't already contain _db
            dynamic finalBody = body;
            if (addDatabaseParam &&
                body is Map<String, dynamic> &&
                !body.containsKey('_db')) {
              try {
                finalBody = Map<String, dynamic>.from(body);
                finalBody['_db'] = _getCurrentDatabase();
              } catch (e) {
                print('Warning: Could not add database to body: $e');
                finalBody = body;
              }
            }

            response = await http.post(
              uri,
              headers: headers,
              body: finalBody != null ? json.encode(finalBody) : null,
            );
          } else {
            final request = http.MultipartRequest('POST', uri);
            final multipartHeaders = Map<String, String>.from(headers);
            multipartHeaders.remove('Content-Type');
            request.headers.addAll(multipartHeaders);

            if (body is Map<String, dynamic>) {
              // Add database parameter to form data if not present
              if (addDatabaseParam && !body.containsKey('_db')) {
                try {
                  body['_db'] = _getCurrentDatabase();
                } catch (e) {
                  print('Warning: Could not add database to form data: $e');
                }
              }

              body.forEach((key, value) {
                if (value is File) {
                  request.files.add(
                    http.MultipartFile(
                      key,
                      value.readAsBytes().asStream(),
                      value.lengthSync(),
                      filename: value.path.split('/').last,
                    ),
                  );
                } else {
                  request.fields[key] = value.toString();
                }
              });
            }
            final streamedResponse = await request.send();
            response = await http.Response.fromStream(streamedResponse);
          }
          break;
        case HttpMethod.PUT:
          // Add database to body if it's a Map and doesn't already contain _db
          dynamic finalBody = body;
          if (addDatabaseParam &&
              body is Map<String, dynamic> &&
              !body.containsKey('_db')) {
            try {
              finalBody = Map<String, dynamic>.from(body);
              finalBody['_db'] = _getCurrentDatabase();
            } catch (e) {
              print('Warning: Could not add database to body: $e');
              finalBody = body;
            }
          }

          response = await http.put(
            uri,
            headers: headers,
            body: finalBody != null ? json.encode(finalBody) : null,
          );
          break;
        case HttpMethod.DELETE:
          // Add database to body if it's a Map and doesn't already contain _db
          dynamic finalBody = body;
          if (addDatabaseParam &&
              body is Map<String, dynamic> &&
              !body.containsKey('_db')) {
            try {
              finalBody = Map<String, dynamic>.from(body);
              finalBody['_db'] = _getCurrentDatabase();
            } catch (e) {
              print('Warning: Could not add database to body: $e');
              finalBody = body;
            }
          }

          response = await http.delete(
            uri,
            headers: headers,
            body: finalBody != null ? json.encode(finalBody) : null,
          );
          break;
        case HttpMethod.PATCH:
          // Add database to body if it's a Map and doesn't already contain _db
          dynamic finalBody = body;
          if (addDatabaseParam &&
              body is Map<String, dynamic> &&
              !body.containsKey('_db')) {
            try {
              finalBody = Map<String, dynamic>.from(body);
              finalBody['_db'] = _getCurrentDatabase();
            } catch (e) {
              print('Warning: Could not add database to body: $e');
              finalBody = body;
            }
          }

          response = await http.patch(
            uri,
            headers: headers,
            body: finalBody != null ? json.encode(finalBody) : null,
          );
          break;
      }

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        print('Decoded JSON response: $jsonResponse');

        final apiResponse = ApiResponse<T>.fromJson(
          jsonResponse,
          parsedData: fromJson != null ? fromJson(jsonResponse) : null,
        );

        return ApiResponse<T>(
          success: apiResponse.success,
          message: apiResponse.message,
          statusCode: response.statusCode,
          data: apiResponse.data,
          rawData: jsonResponse, // Store the entire JSON response
        );
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          final message = response.reasonPhrase ?? 'Unknown error';
          return ApiResponse<T>.error(message, response.statusCode);
        }

        final message =
            errorData['message'] ?? errorData['error'] ?? 'Request failed';

        // Return error response with proper status code - this allows the service layer to handle 404s appropriately
        return ApiResponse<T>(
          success: false,
          message: message,
          statusCode: response.statusCode,
          data: null,
          rawData: errorData,
        );
      }
    } catch (e) {
      print('Network error: $e');
      return ApiResponse<T>.error('Network error: ${e.toString()}', 500);
    }
  }

  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic> json)? fromJson,
    bool addDatabaseParam = true,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.GET,
      queryParams: queryParams,
      fromJson: fromJson,
      addDatabaseParam: addDatabaseParam,
    );
  }

  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
    PayloadType payloadType = PayloadType.JSON,
    T Function(Map<String, dynamic> json)? fromJson,
    bool addDatabaseParam = true,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.POST,
      body: body,
      queryParams: queryParams,
      payloadType: payloadType,
      fromJson: fromJson,
      addDatabaseParam: addDatabaseParam,
    );
  }

  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
    PayloadType payloadType = PayloadType.JSON,
    T Function(Map<String, dynamic> json)? fromJson,
    bool addDatabaseParam = true,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.PUT,
      body: body,
      queryParams: queryParams,
      payloadType: payloadType,
      fromJson: fromJson,
      addDatabaseParam: addDatabaseParam,
    );
  }

  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic> json)? fromJson,
    bool addDatabaseParam = true,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.DELETE,
      body: body,
      queryParams: queryParams,
      fromJson: fromJson,
      addDatabaseParam: addDatabaseParam,
    );
  }
}

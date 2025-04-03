import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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

  // Constructor with optional baseUrl parameter
  ApiService({String? baseUrl, String? apiKey}) 
      : baseUrl = baseUrl ?? dotenv.env['API_BASE_URL'] ?? 'https://linkskool.net/api/v3',        
        apiKey = apiKey ?? dotenv.env['API_KEY'] {
    print('Initializing ApiService with baseUrl: $baseUrl');
  }

  // Add authorization header (for authenticated requests)
  void setAuthToken(String token) {
    _defaultHeaders['Authorization'] = 'Bearer $token';
    print('Auth token set in headers');
  }

  // Generic request method that handles all HTTP methods and payload types
  Future<ApiResponse<T>> request<T>({
    required String endpoint,
    required HttpMethod method,
    Map<String, dynamic>? queryParams,
    dynamic body,
    PayloadType payloadType = PayloadType.JSON,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {

            // Prepare headers
      final headers = Map<String, String>.from(_defaultHeaders);
      if (apiKey != null) {
        headers['X-API-KEY'] = apiKey!;
      }

      // Prepare URI
      final uri = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: queryParams,
      );

      print('Making ${method.toString()} request to: ${uri.toString()}');
      print('Headers: ${headers.keys.join(', ')}');
      // // Prepare the URI with query parameters
      // final uri = Uri.parse('$baseUrl/$endpoint').replace(
      //   queryParameters: queryParams,
      // );

      // // Prepare headers based on payload type
      // final headers = Map<String, String>.from(_defaultHeaders);
      // if (payloadType == PayloadType.FORM_DATA) {
      //   headers.remove('Content-Type'); // Let http package set the correct boundary
      // }

      // Initialize the request
      http.Response response;

      switch (method) {
        case HttpMethod.GET:
          response = await http.get(uri, headers: headers);
          break;

        case HttpMethod.POST:
          if (payloadType == PayloadType.JSON) {
            response = await http.post(
              uri,
              headers: headers,
              body: body != null ? json.encode(body) : null,
            );
          } else { // FORM_DATA
            final request = http.MultipartRequest('POST', uri);
            
            // Add headers
            request.headers.addAll(headers);
            
            // Add form fields
            if (body is Map<String, dynamic>) {
              body.forEach((key, value) {
                if (value is File) {
                  // Handle file uploads
                  request.files.add(
                    http.MultipartFile(
                      key,
                      value.readAsBytes().asStream(),
                      value.lengthSync(),
                      filename: value.path.split('/').last,
                    ),
                  );
                } else {
                  // Handle other form fields
                  request.fields[key] = value.toString();
                }
              });
            }
            
            final streamedResponse = await request.send();
            response = await http.Response.fromStream(streamedResponse);
          }
          break;

        case HttpMethod.PUT:
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;

        case HttpMethod.DELETE:
          response = await http.delete(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;

        case HttpMethod.PATCH:
          response = await http.patch(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
      }

      // Parse response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body);
        
        T? parsedData;
        if (fromJson != null && jsonResponse is Map<String, dynamic>) {
          parsedData = fromJson(jsonResponse);
        } else if (fromJson != null && jsonResponse is List) {
          // Handle list response by returning the raw data
          // The caller will need to handle the list parsing
          parsedData = null;
        }
        
        final apiResponse = ApiResponse<T>.fromJson(
          jsonResponse is Map<String, dynamic> 
              ? jsonResponse 
              : {'status': 'success', 'data': jsonResponse},
          parsedData: parsedData,
        );
        
        return ApiResponse<T>(
          success: apiResponse.success,
          message: apiResponse.message,
          statusCode: response.statusCode,
          data: parsedData,
          rawData: jsonResponse is Map<String, dynamic> ? jsonResponse : {'data': jsonResponse},
        );
      } else {
        // Handle error response
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          // If we can't parse the response, use the status message
          final message = response.reasonPhrase ?? 'Unknown error';
          return ApiResponse<T>.error(message, response.statusCode);
        }

        final message = errorData['message'] ?? errorData['error'] ?? 'Request failed';
        return ApiResponse<T>.error(message, response.statusCode);
      }
    } catch (e) {
      // Handle exceptions
      return ApiResponse<T>.error('Network error: ${e.toString()}', 500);
    }
  }

  // Convenience methods for different HTTP methods
  
  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic> json)? fromJson,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.GET,
      queryParams: queryParams,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
    PayloadType payloadType = PayloadType.JSON,
    T Function(Map<String, dynamic> json)? fromJson,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.POST,
      body: body,
      queryParams: queryParams,
      payloadType: payloadType,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic> json)? fromJson,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.PUT,
      body: body,
      queryParams: queryParams,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic> json)? fromJson,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.DELETE,
      body: body,
      queryParams: queryParams,
      fromJson: fromJson,
    );
  }
}
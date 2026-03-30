import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/cbt_user_model.dart';

class CbtUserService {
  final String baseUrl = 'https://linkskool.net/api/v3/public/cbt/users';
  final apiKey = EnvConfig.apiKey;

  Future<CbtUserModel?> fetchUserByEmail(String userEmail) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final url = '$baseUrl/$userEmail';
      // No body for GET

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      if (response.statusCode == 200) {

        final decoded = json.decode(response.body);

        if (decoded['success'] == true && decoded['data'] != null) {
          return CbtUserModel.fromJson(decoded['data']);
        } else {
          return null;
        }
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception("Failed to fetch user: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching user: $e");
    }
  }

  Future<CbtUserModel> createUser(CbtUserModel user) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final body = user.toJson();

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

        final decoded = json.decode(response.body);

        if (decoded['success'] == true && decoded['data'] != null) {
          return CbtUserModel.fromJson(decoded['data']);
        } else {
          throw Exception(
              "Failed to create user: ${decoded['message'] ?? 'Unknown error'}");
        }
      } else {
        throw Exception("Failed to create user: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error creating user: $e");
    }
  }

  Future<CbtUserModel> signupWithEmailPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String gender,
    required String birthDate,
    required String phone,
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final url = '$baseUrl/signup';
      final body = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'gender': gender,
        'birth_date': birthDate,
        'phone': phone,
      };


      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return CbtUserModel.fromJson(decoded['data']);
        }
        throw Exception(
            "Failed to sign up: ${decoded['message'] ?? 'Unknown error'}");
      }

      throw Exception("Failed to sign up: ${response.statusCode}");
    } catch (e) {
      throw Exception("Error signing up: $e");
    }
  }

  Future<CbtUserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final url = '$baseUrl/login';
      final body = {
        'email': email,
        'password': password,
      };


      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return CbtUserModel.fromJson(decoded['data']);
        }
        throw Exception(
            "Failed to login: ${decoded['message'] ?? 'Unknown error'}");
      }

      throw Exception("Failed to login: ${response.statusCode}");
    } catch (e) {
      throw Exception("Error logging in: $e");
    }
  }

  Future<CbtUserModel> updateUser(CbtUserModel user) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }
      final userId = user.id;
      if (userId == null) {
        throw Exception("User ID is required for update");
      }
      final updateUrl = '$baseUrl/$userId';
      final body = user.toJson();

      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(body),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return CbtUserModel.fromJson(decoded['data']);
        } else {
          throw Exception(
              "Failed to update user: ${decoded['message'] ?? 'Unknown error'}");
        }
      } else {
        throw Exception("Failed to update user: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error updating user: $e");
    }
  }

  Future<CbtUserModel> syncUserOnLogin({
    required String email,
    required String name,
    required String profilePicture,
    int? attemptCount,
    String? reference,
  }) async {
    try {

      final existingUser = await fetchUserByEmail(email);

      if (existingUser != null) {
        return existingUser;
      } else {
        final newUser = CbtUserModel(
          name: name,
          email: email,
          profilePicture: profilePicture,
          attempt: attemptCount ?? 0,
          subscribed: 0,
          reference: reference,
        );
        return await createUser(newUser);
      }
    } catch (e) {
      throw Exception("Error syncing user: $e");
    }
  }

  Future<CbtUserModel> updateUserAfterPayment({
    required String email,
    required String name,
    required String profilePicture,
    required String reference,
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final existingUser = await fetchUserByEmail(email);

      if (existingUser == null) {
        throw Exception("User not found. Cannot update payment reference.");
      }

      final updatedUser = existingUser.copyWith(
        name: name,
        profilePicture: profilePicture,
        subscribed: 1,
        reference: reference,
      );
      return await updateUser(updatedUser);
    } catch (e) {
      throw Exception("Error updating user after payment: $e");
    }
  }

  /// Handles payment success flow: wait, fetch user (with retries), update, verify.
  Future<CbtUserModel?> processPaymentSuccessAndVerifyUser({
    required String email,
    required String name,
    required String profilePicture,
    required String reference,
    int maxFetchAttempts = 3,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    CbtUserModel? user;
    int attempt = 0;
    while (attempt < maxFetchAttempts) {
      try {
        user = await fetchUserByEmail(email);
        if (user != null) {
          break;
        } else {
        }
      } catch (e) {
      }
      attempt++;
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (user == null) {
      return null;
    }

    final updatedUser = user.copyWith(
      name: name,
      profilePicture: profilePicture,
      subscribed: 1,
      reference: reference,
    );

    try {
      await updateUserAfterPayment(
        email: email,
        name: name,
        profilePicture: profilePicture,
        reference: reference,
      );
    } catch (e) {
      return null;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    CbtUserModel? verifiedUser;
    try {
      verifiedUser = await fetchUserByEmail(email);
      if (verifiedUser != null && verifiedUser.reference == reference) {
        return verifiedUser;
      } else {
        return verifiedUser;
      }
    } catch (e) {
      return null;
    }
  }


  // update user details 
 // Future<
}


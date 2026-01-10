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
      print("🛰️ [FETCH USER] GET $url");
      print("➡️ Headers: X-API-KEY: $apiKey");
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
        print("✅ Response received: ${response.body}");

        final decoded = json.decode(response.body);

        if (decoded['success'] == true && decoded['data'] != null) {
          return CbtUserModel.fromJson(decoded['data']);
        } else {
          return null;
        }
      } else if (response.statusCode == 404) {
        print("🔍 User not found (404)");
        return null;
      } else {
        print("❌ Failed to fetch user: ${response.statusCode}");
        print("Body: ${response.body}");
        throw Exception("Failed to fetch user: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching user: $e");
      throw Exception("Error fetching user: $e");
    }
  }

  Future<CbtUserModel> createOrUpdateUser(CbtUserModel user) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final body = user.toJson();
      print("🛰️ [CREATE/UPDATE USER] POST $baseUrl");
      print("➡️ Headers: X-API-KEY: $apiKey");
      print("➡️ Body: ${json.encode(body)}");

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
        print("✅ Response received: ${response.body}");

        final decoded = json.decode(response.body);

        if (decoded['success'] == true) {
          if (decoded['data'] != null) {
            return CbtUserModel.fromJson(decoded['data']);
          } else if (decoded['userId'] != null) {
            print("✅ User created with ID: ${decoded['userId']}");
            return user.copyWith(id: decoded['userId']);
          } else {
            throw Exception("No user data or userId in response");
          }
        } else {
          throw Exception(
              "Failed to create/update user: ${decoded['message'] ?? 'Unknown error'}");
        }
      } else {
        print("❌ Failed to create/update user: ${response.statusCode}");
        print("Body: ${response.body}");
        throw Exception("Failed to create/update user: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error creating/updating user: $e");
      throw Exception("Error creating/updating user: $e");
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
      print("🔄 Syncing user on login: $email");

      final existingUser = await fetchUserByEmail(email);

      if (existingUser != null) {
        print("👤 Existing user found, updating...");

        final updatedUser = existingUser.copyWith(
          name: name,
          profilePicture: profilePicture,
          attempt: attemptCount ?? existingUser.attempt,
          reference: reference,
        );

        return await createOrUpdateUser(updatedUser);
      } else {
        print("🆕 New user, creating with subscribed=1...");

        final newUser = CbtUserModel(
          name: name,
          email: email,
          profilePicture: profilePicture,
          attempt: attemptCount ?? 0,
          subscribed: 1,
          reference: reference,
        );

        return await createOrUpdateUser(newUser);
      }
    } catch (e) {
      print("❌ Error syncing user: $e");
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

      final body = updatedUser.toJson();
      final userId = updatedUser.id;
      final updateUrl = '$baseUrl/$userId';

      print("🛰️ [UPDATE USER] PUT $updateUrl");
      print("➡️ Headers: X-API-KEY: $apiKey");
      print("➡️ Body: ${json.encode(body)}");

      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(body),
      );

      print("⬅️ Response status: ${response.statusCode}");
      print("⬅️ Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ User updated successfully with payment reference");

        final decoded = json.decode(response.body);

        if (decoded['success'] == true) {
          if (decoded['data'] != null) {
            print("✅ Updated user data: ${decoded['data']}");
            return CbtUserModel.fromJson(decoded['data']);
          } else {
            return updatedUser;
          }
        } else {
          throw Exception(
              "Failed to update user: ${decoded['message'] ?? 'Unknown error'}");
        }
      } else {
        print("❌ Failed to update user: ${response.statusCode}");
        print("Body: ${response.body}");
        throw Exception("Failed to update user: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error updating user after payment: $e");
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
    print("🚦 Payment success detected. Starting post-payment flow...");
    await Future.delayed(const Duration(seconds: 1));
    print(
        "⏳ Waited 1 second. Fetching user with up to $maxFetchAttempts attempts...");

    CbtUserModel? user;
    int attempt = 0;
    while (attempt < maxFetchAttempts) {
      try {
        user = await fetchUserByEmail(email);
        if (user != null) {
          print("✅ User fetched on attempt ${attempt + 1}: ${user.toJson()}");
          break;
        } else {
          print("❌ User not found on attempt ${attempt + 1}");
        }
      } catch (e) {
        print("❌ Error fetching user on attempt ${attempt + 1}: $e");
      }
      attempt++;
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (user == null) {
      print(
          "❌ Failed to fetch user after $maxFetchAttempts attempts. Aborting.");
      return null;
    }

    print("🛠️ Creating updated user model with payment reference...");
    final updatedUser = user.copyWith(
      name: name,
      profilePicture: profilePicture,
      subscribed: 1,
      reference: reference,
    );

    print("📡 Making PUT request to update user...");
    try {
      await updateUserAfterPayment(
        email: email,
        name: name,
        profilePicture: profilePicture,
        reference: reference,
      );
    } catch (e) {
      print("❌ Error updating user after payment: $e");
      return null;
    }

    print("⏳ Waiting 500ms before verifying update...");
    await Future.delayed(const Duration(milliseconds: 500));

    print("🔍 Fetching user again to verify update...");
    CbtUserModel? verifiedUser;
    try {
      verifiedUser = await fetchUserByEmail(email);
      if (verifiedUser != null && verifiedUser.reference == reference) {
        print(
            "✅ Verified user has payment reference: ${verifiedUser.reference}");
        return verifiedUser;
      } else {
        print(
            "❌ Verified user missing reference or not updated. Data: ${verifiedUser?.toJson()}");
        return verifiedUser;
      }
    } catch (e) {
      print("❌ Error verifying user after update: $e");
      return null;
    }
  }
}

import 'dart:convert';
import 'dart:async';
import 'package:healthify/models/response/user_response.dart';
import 'package:healthify/core/constants/enums.dart';
import 'package:healthify/service/ApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends ApiService {
  @override
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Create dummy user data for login
    final Map<String, dynamic> userData = {
      'token': 'mock_token_12345',
      'user': {
        'sId': '1',
        'fullName': 'Sai Kamal',
        'email': email,
        'password': password,
        'gender': 'other',
        'weight': 70,
        'height': 175,
        'bmi': 22,
        'createdAt': DateTime.now().toIso8601String(),
      },
    };

    // Simulate saving auth details in SharedPreferences
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(AuthState.unknown.toString(), false);
    await pref.setString(AuthState.authToken.toString(), userData['token']);
    await pref.setBool(AuthState.authenticated.toString(), true);

    return userData;
  }

  @override
  Future<Map<String, dynamic>> registerUser(
      String fullName, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Create dummy user data for registration
    final Map<String, dynamic> userData = {
      'token': 'mock_token_67890',
      'user': {
        'sId': '2',
        'fullName': fullName,
        'email': email,
        'password': password,
        'gender': 'other',
        'weight': 65,
        'height': 165,
        'bmi': 24,
        'createdAt': DateTime.now().toIso8601String(),
      },
    };

    // Simulate saving auth details in SharedPreferences
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(AuthState.unknown.toString(), false);
    await pref.setString(AuthState.authToken.toString(), userData['token']);
    await pref.setBool(AuthState.authenticated.toString(), true);

    return userData;
  }

  @override
  Future<UserResponse> getUserData() async {
    await Future.delayed(const Duration(seconds: 1));

    // Create dummy JSON string that represents the user data
    final String dummyJson = jsonEncode({
      'user': {
        'sId': '1',
        'fullName': 'Sai Kamal',
        'email': 'email',
        'password': 'password',
        'gender': 'Male',
        'weight': 70,
        'height': 175,
        'bmi': 22,
        'createdAt': DateTime.now().toIso8601String(),
      }
    });

    return UserResponse.fromJson(dummyJson);
  }
}

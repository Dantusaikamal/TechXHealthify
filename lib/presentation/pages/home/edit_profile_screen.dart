// lib/presentation/pages/home/edit_profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthify/core/app_exports.dart';
import 'package:healthify/core/constants/api_constants.dart';
import 'package:healthify/core/constants/enums.dart';
import 'package:healthify/models/user_model.dart';
import 'package:healthify/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:healthify/themes/app_styles.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.user.fullName ?? "");
    _weightController =
        TextEditingController(text: widget.user.weight?.toString() ?? "");
    _heightController =
        TextEditingController(text: widget.user.height?.toString() ?? "");
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Update the local user model.
      widget.user.fullName = _fullNameController.text;
      widget.user.weight = int.tryParse(_weightController.text);
      widget.user.height = int.tryParse(_heightController.text);

      // Recalculate BMI.
      if (widget.user.weight != null &&
          widget.user.height != null &&
          widget.user.height! > 0) {
        widget.user.bmi = (widget.user.weight! /
                ((widget.user.height! / 100) * (widget.user.height! / 100)))
            .round();
      }

      // Retrieve the auth token using the same key as ApiService.
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token =
          prefs.getString(AuthState.authToken.toString()) ?? "";
      print("Retrieved token: $token");
      if (token.isEmpty) {
        Get.snackbar(
            "Error", "Authentication token not found. Please log in again.",
            backgroundColor: ColorConstant.lightRed,
            colorText: ColorConstant.whiteText);
        return;
      }

      // Build the update URL.
      final url = Uri.parse('${APIConstant.baseUrl}/user/update-profile');

      // Prepare the request body.
      final body = jsonEncode({
        'fullName': widget.user.fullName,
        'weight': widget.user.weight,
        'height': widget.user.height,
      });

      try {
        final response = await http.put(
          url,
          headers: {
            "Content-Type": "application/json",
            "authorization": token,
          },
          body: body,
        );

        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode == 200) {
          // On success, navigate back and show a snackbar.
          Get.back();
          Get.snackbar("Success", "Profile updated successfully",
              backgroundColor: ColorConstant.greenColor,
              colorText: ColorConstant.whiteText);
        } else {
          Get.snackbar("Error", "Failed to update profile",
              backgroundColor: ColorConstant.lightRed,
              colorText: ColorConstant.whiteText);
        }
      } catch (error) {
        print("Update error: $error");
        Get.snackbar("Error", "An error occurred",
            backgroundColor: ColorConstant.lightRed,
            colorText: ColorConstant.whiteText);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteBackground,
      appBar: AppBar(
        title: Text("Edit Profile", style: AppStyle.txtPoppinsBold18Dark),
        backgroundColor: ColorConstant.whiteBackground,
        iconTheme: IconThemeData(color: ColorConstant.bluedark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  labelStyle: AppStyle.txtPoppinsSemiBold16Dark,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your full name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: "Weight (kg)",
                  labelStyle: AppStyle.txtPoppinsSemiBold16Dark,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your weight";
                  }
                  if (int.tryParse(value) == null) {
                    return "Enter a valid number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: "Height (cm)",
                  labelStyle: AppStyle.txtPoppinsSemiBold16Dark,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your height";
                  }
                  if (int.tryParse(value) == null) {
                    return "Enter a valid number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text("Save", style: AppStyle.txtPoppinsBold18Dark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

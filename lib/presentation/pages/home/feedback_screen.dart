// lib/presentation/pages/home/feedback_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthify/core/app_exports.dart';
import 'package:healthify/core/constants/api_constants.dart';
import 'package:healthify/core/constants/enums.dart';
import 'package:healthify/themes/app_styles.dart';
import 'package:healthify/themes/app_decoration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 3.0;
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Retrieve the auth token (using same key as ApiService).
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token =
          prefs.getString(AuthState.authToken.toString()) ?? "";
      print("Feedback token: $token");
      if (token.isEmpty) {
        Get.snackbar(
            "Error", "Authentication token not found. Please log in again.",
            backgroundColor: ColorConstant.lightRed,
            colorText: ColorConstant.whiteText);
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Build the feedback endpoint URL.
      final url = Uri.parse('${APIConstant.baseUrl}/feedback');

      // Build the feedback data.
      final Map<String, dynamic> feedbackData = {
        'rating': _rating,
        'message': _feedbackController.text,
      };

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'authorization': token,
          },
          body: jsonEncode(feedbackData),
        );

        print("Feedback response status: ${response.statusCode}");
        print("Feedback response body: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar("Success", "Thank you for your feedback!",
              backgroundColor: ColorConstant.greenColor,
              colorText: ColorConstant.whiteText);
          _feedbackController.clear();
          setState(() {
            _rating = 3.0;
          });
        } else {
          Get.snackbar("Error", "Failed to submit feedback",
              backgroundColor: ColorConstant.lightRed,
              colorText: ColorConstant.whiteText);
        }
      } catch (error) {
        print("Feedback submission error: $error");
        Get.snackbar("Error", "An error occurred: $error",
            backgroundColor: ColorConstant.lightRed,
            colorText: ColorConstant.whiteText);
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteBackground,
      appBar: AppBar(
        title: Text("Feedback", style: AppStyle.txtPoppinsBold18Dark),
        backgroundColor: ColorConstant.whiteBackground,
        iconTheme: IconThemeData(color: ColorConstant.bluedark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecoration.boxShadowWithWhiteFillAndBorderRadius15,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("We value your feedback!",
                    textAlign: TextAlign.center,
                    style: AppStyle.txtPoppinsBold28Dark),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text("Rating:", style: AppStyle.txtPoppinsSemiBold16Dark),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Slider(
                        value: _rating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _rating.toString(),
                        activeColor: ColorConstant.bluedark,
                        inactiveColor: ColorConstant.lightGray,
                        onChanged: (value) {
                          setState(() {
                            _rating = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "Your feedback",
                    // Using a lighter color for the label text.
                    labelStyle: TextStyle(
                      color: ColorConstant.lightGray,
                      fontFamily: "Poppins",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    // Use a curved border.
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your feedback";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isSubmitting
                    ? Center(
                        child: CircularProgressIndicator(
                          color: ColorConstant.bluedark,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _submitFeedback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstant.bluedark,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white, // Ensure text is white.
                            fontFamily: "Poppins",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

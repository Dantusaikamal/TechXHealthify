// lib/presentation/pages/home/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:healthify/core/app_exports.dart';
import 'package:healthify/themes/app_decoration.dart';
import 'package:healthify/themes/app_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteBackground,
      appBar: AppBar(
        title: Text("Privacy Policy", style: AppStyle.txtPoppinsBold18Dark),
        backgroundColor: ColorConstant.whiteBackground,
        iconTheme: IconThemeData(color: ColorConstant.bluedark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecoration.boxShadowWithWhiteFillAndBorderRadius15,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Privacy Policy", style: AppStyle.txtPoppinsBold28Dark),
                const SizedBox(height: 16),
                Text(
                  "This privacy policy explains how Healthify collects, uses, and discloses your personal information. We are committed to protecting your privacy and ensuring that your personal data is handled safely and responsibly.",
                  style: AppStyle.txtPoppinsSemiBold16Dark,
                ),
                const SizedBox(height: 16),
                Text(
                  "Data is collected when you create an account, update your profile, or use our services. Your information, including your name, email, weight, and height, is stored securely and is only used to provide personalized services and improve our app.",
                  style: AppStyle.txtPoppinsSemiBold16Dark,
                ),
                const SizedBox(height: 16),
                Text(
                  "We do not share your information with third parties without your consent, except as required by law. By using Healthify, you agree to the terms outlined in this privacy policy.",
                  style: AppStyle.txtPoppinsSemiBold16Dark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

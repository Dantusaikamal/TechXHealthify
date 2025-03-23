// lib/presentation/pages/home/contact_us_screen.dart
import 'package:flutter/material.dart';
import 'package:healthify/core/app_exports.dart';
import 'package:healthify/themes/app_decoration.dart';
import 'package:healthify/themes/app_styles.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteBackground,
      appBar: AppBar(
        title: Text("Contact Us", style: AppStyle.txtPoppinsBold18Dark),
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
                Text("Contact Us", style: AppStyle.txtPoppinsBold18Dark),
                const SizedBox(height: 16),
                Text(
                  "If you have any questions or need support, please email us at:",
                  style: AppStyle.txtPoppinsSemiBold16Dark,
                ),
                const SizedBox(height: 8),
                Text(
                  "dantusaikamal@gmail.com",
                  style: AppStyle.txtPoppinsSemiBold18LightBlue,
                ),
                const SizedBox(height: 16),
                Text(
                  "Or call us at:",
                  style: AppStyle.txtPoppinsSemiBold16Dark,
                ),
                const SizedBox(height: 8),
                Text(
                  "+91 9177114722",
                  style: AppStyle.txtPoppinsSemiBold18LightBlue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

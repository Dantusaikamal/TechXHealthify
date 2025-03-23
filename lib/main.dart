import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:healthify/core/app_exports.dart';
import 'package:healthify/core/constants/enums.dart';
import 'package:healthify/helper/local_string.dart';
import 'package:healthify/presentation/pages/auth/sign_in_screen.dart';
import 'package:healthify/presentation/pages/home/home.dart';
import 'package:healthify/presentation/pages/onboarding/onboading.dart';
import 'package:healthify/repository/auth_repo/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './routes/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';

/// Requests all necessary runtime permissions.
Future<void> requestAllPermissions() async {
  // Request permissions for location, activity recognition, and sensors.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
    Permission.locationWhenInUse,
    Permission.activityRecognition,
    Permission.sensors,
  ].request();

  // Log status and if permanently denied, open app settings.
  statuses.forEach((permission, status) async {
    if (status.isPermanentlyDenied) {
      debugPrint(
          "${permission.toString()} is permanently denied. Opening settings...");
      await openAppSettings();
    } else if (status.isDenied) {
      debugPrint("${permission.toString()} is denied.");
    } else if (status.isGranted) {
      debugPrint("${permission.toString()} is granted.");
    }
  });
}

Future main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  // Set device orientations.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Request all necessary permissions before running the app.
  await requestAllPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isAuthenticated =
        prefs.getBool(AuthState.authenticated.toString()) ?? false;

    if (isAuthenticated) {
      return const Home();
    } else {
      final bool isNewUser =
          prefs.getBool(AuthState.unknown.toString()) ?? true;

      if (isNewUser) {
        return const OnBoardingScreen();
      } else {
        return SignInScreen();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuTheme(
      data: PopupMenuThemeData(
        textStyle: TextStyle(
          color: ColorConstant.bluedark,
        ),
        color: ColorConstant.whiteBackground,
      ),
      child: RepositoryProvider(
        create: (context) => AuthRepository(),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          locale: Get.deviceLocale,
          translations: LocalString(),
          title: 'Healthify-app',
          theme: ThemeData(
            primaryColor: Colors.white,
          ),
          initialRoute: "/",
          getPages: [
            GetPage(
              name: "/",
              page: () => FutureBuilder<Widget>(
                  future: _getInitialScreen(),
                  builder:
                      (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      // Show a splash screen or loading indicator while waiting.
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ),
            AppRoutes.homePage,
            AppRoutes.onBoardingPage,
            AppRoutes.signInPage,
            AppRoutes.signUpPage,
            AppRoutes.userDetailsPage,
            AppRoutes.stokeEmergencyPage,
            AppRoutes.healthCornerPage,
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:healthify/bloc/home/get_user_data/fetch_bloc.dart';
import 'package:healthify/bloc/home/get_user_data/fetch_bloc_event.dart';
import 'package:healthify/bloc/home/get_user_data/fetch_bloc_state.dart';
import 'package:healthify/core/app_exports.dart';
import 'package:healthify/models/user_model.dart';
import 'package:healthify/routes/app_routes.dart';
import 'package:healthify/themes/app_decoration.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import '../../../themes/app_styles.dart';

class StrokeEmergencyScreen extends StatefulWidget {
  final UserModel? userModel;
  const StrokeEmergencyScreen({super.key, this.userModel});

  @override
  State<StrokeEmergencyScreen> createState() => _StrokeEmergencyScreenState();
}

class _StrokeEmergencyScreenState extends State<StrokeEmergencyScreen> {
  List listOfWhatToDo = [
    {
      "title": "Stay Calm, and wait for Ambulance.",
      "description":
          "Do not panic. If you have called an ambulance, wait for help to arrive. Do not attempt to drive.",
    },
    {
      "title": "Do not lose consciousness",
      "description":
          "Try to stay awake. If you believe you are losing consciousness, take an aspirin. Try keeping your eyes open.",
    },
    {
      "title": "Importance of CPR",
      "description":
          "If you are not alone and there is someone to assist you, ask them to perform CPR if your vitals are dropping.",
    },
    {
      "title": "Check for Symptoms:",
      "description":
          "Face: If your face is drooping.\nArm: If your arms feel weak.\nSpeech: If you experience speech difficulties. Then it is time to call an ambulance.",
    },
  ];

  late FetchUserDataBloc fetchUserDataBloc;
  String userName = '';
  bool _alertSent = false; // Ensure we send the alert only once.

  TwilioFlutter twilioFlutter = TwilioFlutter(
    accountSid: dotenv.env['ACCOUNT_SID'].toString(),
    authToken: dotenv.env['AUTH_TOKEN'].toString(),
    twilioNumber: dotenv.env['TWILIO_NUMBER'].toString(),
  );

  /// Attempts to determine the device's current position.
  /// If location services are disabled, prompts the user to enable them.
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show a dialog instructing the user to enable location services.
      await _showEnableLocationDialog();
      // After returning from settings, check again:
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  /// Displays a dialog asking the user to enable location services.
  Future<void> _showEnableLocationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enable Location Services',
              style: AppStyle.txtPoppinsSemiBold22Dark),
          content: Text(
            'Location services are disabled. Please enable them in your device settings.',
            style: AppStyle.txtPoppinsSemiBold17Light,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Open Settings',
                  style: TextStyle(color: ColorConstant.lightRed)),
              onPressed: () async {
                await Geolocator.openLocationSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: ColorConstant.bluedark)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void sendSoS() async {
    try {
      Position position = await _determinePosition();

      String emergencyContactNumber1 = "+919177114722";
      String location =
          'Their current location: https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';

      String messageBody =
          "EMERGENCY!\n\n'$userName' might be experiencing a heart stroke.\n$location\n\nThis alert has been sent by Healthify app because an abnormal heart rate has been detected.";

      twilioFlutter.sendSMS(
        toNumber: emergencyContactNumber1,
        messageBody: messageBody,
      );
    } catch (err) {
      // Here you can show a snackbar or dialog to inform the user.
      debugPrint("Error sending SoS: $err");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(err.toString(), style: AppStyle.txtPoppinsSemiBold24Dark),
          backgroundColor: ColorConstant.lightRed,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserDataBloc = FetchUserDataBloc();
    fetchUserDataBloc.add(const GetUserData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteBackground,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "stroke".tr,
          style: TextStyle(color: ColorConstant.bluedark),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorConstant.bluedark),
          onPressed: () {
            Get.toNamed(AppRoutes.home);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_horiz, color: ColorConstant.bluedark),
          ),
        ],
        backgroundColor: ColorConstant.whiteBackground,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.only(left: 22, right: 22, bottom: 40),
          child: BlocProvider(
            create: (_) => fetchUserDataBloc,
            child: BlocListener<FetchUserDataBloc, FetchUserDataBlocState>(
              listener: (context, state) {
                if (state is FetchingDataSuccess) {
                  setState(() {
                    userName = state.user.fullName!;
                  });
                  // Once user data is fetched, if alert hasn't been sent, trigger the alert.
                  if (!_alertSent) {
                    sendSoS();
                    _alertSent = true;
                  }
                }
              },
              child: Column(
                children: [
                  _dailyActivityNotification(
                    false,
                    "An alert has been sent to your emergency contact.",
                  ),
                  CallAnAmbulance(
                    onTap: () {
                      // Allow manual re-sending if needed.
                      sendSoS();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0, bottom: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("whatToDo".tr,
                            style: AppStyle.txtPoppinsSemiBold18Dark),
                        Text(
                          "4 Steps",
                          style: TextStyle(
                            color: ColorConstant.bluedark.withOpacity(0.6),
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  WhatToDoWidget(
                    title: listOfWhatToDo[0]["title"],
                    index: "01",
                    description: listOfWhatToDo[0]["description"],
                  ),
                  WhatToDoWidget(
                    title: listOfWhatToDo[1]["title"],
                    index: "02",
                    description: listOfWhatToDo[1]["description"],
                  ),
                  WhatToDoWidget(
                    title: listOfWhatToDo[2]["title"],
                    index: "03",
                    description: listOfWhatToDo[2]["description"],
                  ),
                  WhatToDoWidget(
                    title: listOfWhatToDo[3]["title"],
                    index: "04",
                    description: listOfWhatToDo[3]["description"],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dailyActivityNotification(bool isAlertNotification, String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 22),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Icon(
            Icons.info_rounded,
            color: isAlertNotification
                ? ColorConstant.lightRed
                : ColorConstant.warningColor,
            size: 26,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Text(
              message,
              style: AppStyle.txtPoppinsSemiBold14LightGray,
            ),
          ),
        ],
      ),
    );
  }
}

class CallAnAmbulance extends StatelessWidget {
  final VoidCallback onTap;
  const CallAnAmbulance({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: ColorConstant.lightRed,
          ),
          borderRadius: BorderRadiusStyle.roundedBorder15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImageConstant.iconAlert,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 22),
            Text(
              "callAmb".tr,
              style: TextStyle(
                color: ColorConstant.lightRed,
                fontFamily: "Poppins",
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WhatToDoWidget extends StatelessWidget {
  final String title, description, index;
  const WhatToDoWidget({
    super.key,
    required this.title,
    required this.description,
    required this.index,
  });

  Widget _dotline() {
    return Container(
      margin: const EdgeInsets.only(left: 14, top: 5),
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: ColorConstant.bluedark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        index,
                        style: AppStyle.txtPoppinsSemiBold18Light,
                      ),
                      const SizedBox(width: 15),
                      Icon(
                        Icons.adjust_sharp,
                        color: ColorConstant.bluedark.withOpacity(0.8),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                  _dotline(),
                  _dotline(),
                  _dotline(),
                  _dotline(),
                  _dotline(),
                  _dotline(),
                  _dotline(),
                  _dotline(),
                  _dotline(),
                  _dotline(),
                  _dotline(),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppStyle.txtPoppinsSemiBold16Dark,
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        color: ColorConstant.bluedark.withOpacity(0.6),
                        fontFamily: "Poppins",
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

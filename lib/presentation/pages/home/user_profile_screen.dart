import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:healthify/bloc/home/get_user_data/fetch_bloc.dart';
import 'package:healthify/bloc/home/get_user_data/fetch_bloc_event.dart';
import 'package:healthify/bloc/home/get_user_data/fetch_bloc_state.dart';
import 'package:healthify/core/app_exports.dart';
import 'package:healthify/core/constants/enums.dart';
import 'package:healthify/core/helper_methods.dart';
import 'package:healthify/helper/lang_controller.dart';
import 'package:healthify/models/user_model.dart';
import 'package:healthify/presentation/pages/home/contact_us_screen.dart';
import 'package:healthify/presentation/pages/home/edit_profile_screen.dart';
import 'package:healthify/presentation/pages/home/privacy_policy_screen.dart';
import 'package:healthify/presentation/pages/profile/appointments_screen.dart';
import 'package:healthify/presentation/pages/profile/medical_records_screen.dart';
import 'package:healthify/presentation/pages/profile/plans_screen.dart';
import 'package:healthify/presentation/pages/profile/reports_screen.dart';
import 'package:healthify/routes/app_routes.dart';
import 'package:healthify/themes/app_decoration.dart';
import 'package:healthify/themes/app_styles.dart';
import 'package:translator/translator.dart';

const List<String> list = <String>['English', 'Hindi', 'Telugu', 'Marathi'];
const List<String> languages = <String>[
  'English',
  'Hindi',
  'Telugu',
  'Marathi'
];

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isNotification = true;
  late FetchUserDataBloc fetchUserDataBloc;
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    fetchUserDataBloc = FetchUserDataBloc()..add(const GetUserData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteBackground,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "Logout") {
                removeItemFromSharedPreferences(AuthState.authToken.toString());
                removeItemFromSharedPreferences(
                    AuthState.authenticated.toString());
                Get.offAndToNamed(AppRoutes.signInScreen);
              }
            },
            icon:
                Icon(Icons.more_horiz, color: ColorConstant.bluedark, size: 30),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: "Logout",
                child: Text("Logout"),
              )
            ],
          )
        ],
        title: Text("profile".tr,
            style: TextStyle(
              color: ColorConstant.bluedark,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w700,
            )),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          margin: const EdgeInsets.only(top: 22),
          child: BlocProvider(
            create: (_) => fetchUserDataBloc,
            child: BlocBuilder<FetchUserDataBloc, FetchUserDataBlocState>(
              builder: (context, state) {
                if (state is FetchingDataSuccess) {
                  return _profileContent(state.user);
                }
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.2,
                  child: Center(
                    child: CircularProgressIndicator(
                        color: ColorConstant.bluedark),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileContent(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile header: avatar, name, and Edit button.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    ImageConstant.imgMaleAvatar,
                    width: 60,
                    height: 60,
                  ),
                ),
                const SizedBox(width: 22),
                Text(
                  user.fullName!,
                  style: const TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Get.to(() => EditProfileScreen(user: user)),
              child: Container(
                width: MediaQuery.of(context).size.width / 4.5,
                height: 35,
                decoration: BoxDecoration(
                  color: ColorConstant.bluedark,
                  borderRadius: BorderRadiusStyle.roundedBorder15,
                ),
                child: Center(
                  child: Text("Edit",
                      style: TextStyle(
                        color: ColorConstant.whiteText,
                        fontFamily: "Poppins",
                        fontSize: 15,
                      )),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        // Rating cards row.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RatingCard(
                value: user.height.toString(),
                measure: "cm",
                title: "height".tr),
            RatingCard(
                value: user.weight.toString(),
                measure: "kg",
                title: "weight".tr),
            RatingCard(value: "22", measure: "yo", title: "age".tr),
          ],
        ),
        const SizedBox(height: 22),
        const AccountWidget(),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: AppDecoration.boxShadowWithWhiteFillAndBorderRadius15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Preferences", style: AppStyle.txtPoppinsBold18Dark),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(ImageConstant.iconOutlineNotification),
                      const SizedBox(width: 22),
                      Text("Pop-up Notification",
                          style: TextStyle(
                            color: ColorConstant.bluedark.withOpacity(0.7),
                            fontSize: 15.5,
                            fontFamily: "Poppins",
                          )),
                    ],
                  ),
                  Switch(
                    activeColor: ColorConstant.bluedark,
                    inactiveThumbColor: ColorConstant.bluedark.withOpacity(0.8),
                    inactiveTrackColor: ColorConstant.bluedark.withOpacity(0.5),
                    value: isNotification,
                    onChanged: (val) =>
                        setState(() => isNotification = !isNotification),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(ImageConstant.iconLanguage,
                          width: 32, height: 32),
                      const SizedBox(width: 6),
                      Text("languages".tr,
                          style: TextStyle(
                            color: ColorConstant.bluedark.withOpacity(0.7),
                            fontSize: 15.5,
                            fontFamily: "Poppins",
                          )),
                    ],
                  ),
                  const CustomDropdownButton(),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        OtherWidget(onTapContactUs: () {}),
      ],
    );
  }
}

/// A reusable rating card widget that displays a value with a measure and a title.
class RatingCard extends StatelessWidget {
  final String value;
  final String measure;
  final String title;
  const RatingCard({
    super.key,
    required this.value,
    required this.measure,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width / 3.7,
      decoration: AppDecoration.boxShadowWithWhiteFillAndBorderRadius15,
      child: Column(
        children: [
          Text("$value $measure",
              style: TextStyle(
                color: ColorConstant.bluedark,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                fontSize: 18,
              )),
          const SizedBox(height: 10),
          Text(title, style: AppStyle.txtPoppinsWithDefaultSizeLightGrayW500),
        ],
      ),
    );
  }
}

/// The rest of your widgets (CustomDropdownButton, OtherWidget, AccountWidget, ItemCardWidget) remain unchanged.

class CustomDropdownButton extends StatefulWidget {
  const CustomDropdownButton({super.key});

  @override
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  String dropdownValue = list.first;
  LangController langController = Get.put(LangController());

  updateLocale(Locale locale, BuildContext context) {
    Get.updateLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      style: TextStyle(color: ColorConstant.bluedark),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });

        if (value == "English") {
          updateLocale(const Locale("en", "US"), context);
          langController.setLanguagecode("en");
        } else if (value == "Hindi") {
          updateLocale(const Locale("hi", "IN"), context);
          langController.setLanguagecode("hi");
        } else if (value == "Telugu") {
          updateLocale(const Locale("te", "IN"), context);
          langController.setLanguagecode("te");
        } else if (value == "Marathi") {
          updateLocale(const Locale("mr", "IN"), context);
          langController.setLanguagecode("mr");
        }
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 15.5,
              color: ColorConstant.bluedark.withOpacity(0.7),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class OtherWidget extends StatelessWidget {
  final VoidCallback onTapContactUs;
  const OtherWidget({super.key, required this.onTapContactUs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: AppDecoration.boxShadowWithWhiteFillAndBorderRadius15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "other".tr,
            style: AppStyle.txtPoppinsBold18Dark,
          ),
          const SizedBox(height: 22),
          ItemCardWidget(
            leadingIcon: const Icon(Icons.email_outlined),
            title: "contactUs".tr,
            onTap: () {
              Get.to(() => const ContactUsScreen());
            },
          ),
          ItemCardWidget(
            leadingIcon: const Icon(Icons.policy_outlined),
            title: "privacy".tr,
            onTap: () {
              Get.to(() => const PrivacyPolicyScreen());
            },
          ),
        ],
      ),
    );
  }
}

class AccountWidget extends StatelessWidget {
  const AccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: AppDecoration.boxShadowWithWhiteFillAndBorderRadius15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "account".tr,
            style: AppStyle.txtPoppinsBold18Dark,
          ),
          const SizedBox(height: 22),
          ItemCardWidget(
            leadingIcon: const Icon(Icons.folder_shared_outlined),
            title: "Records",
            onTap: () {
              Get.to(() => const MedicalRecordsScreen());
            },
          ),
          ItemCardWidget(
            leadingIcon: const Icon(Icons.calendar_month_outlined),
            title: "Appointments",
            onTap: () {
              Get.to(() => const AppointmentsScreen());
            },
          ),
          ItemCardWidget(
            leadingIcon: const Icon(Icons.subscriptions_outlined),
            title: "My Plans",
            onTap: () {
              Get.to(() => const PlansScreen());
            },
          ),
          ItemCardWidget(
            leadingIcon: const Icon(Icons.analytics_outlined),
            title: "Progress Reports",
            onTap: () {
              Get.to(() => const ReportsScreen());
            },
          ),
        ],
      ),
    );
  }
}

class ItemCardWidget extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final VoidCallback onTap;
  const ItemCardWidget(
      {super.key,
      required this.leadingIcon,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                leadingIcon,
                const SizedBox(
                  width: 22,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: ColorConstant.bluedark.withOpacity(0.7),
                    fontSize: 15.5,
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 22,
              color: ColorConstant.bluedark.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

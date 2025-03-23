// lib/presentation/pages/home/analytics_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:healthify/core/app_exports.dart';
import 'package:healthify/models/user_model.dart';
import 'package:healthify/service/google_fit_service.dart';
import 'package:healthify/service/google_sign_in_service.dart';
import 'package:healthify/themes/app_decoration.dart';
import 'package:healthify/themes/app_styles.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Real analytics data
  double _bmi = 0.0;
  String _sleepTime = "0m";
  // Weekly walking data (in km) – we'll hardcode two days.
  List<double> _weeklyActivityData = List<double>.filled(7, 0.0);

  bool _isLoading = false;

  // Services for fetching Google Fit data and signing in.
  final GoogleFitService _googleFitService = GoogleFitService();
  final GoogleSignInService _googleSignInService = GoogleSignInService();

  // For demo, assume we have a userModel with weight and height.
  final UserModel _user =
      UserModel(weight: 70, height: 175); // weight in kg, height in cm

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  /// Fetch analytics data.
  /// Here we compute BMI and sleep time from Google Fit, but we hardcode weekly steps data.
  Future<void> _fetchAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    // Ensure user is signed in.
    final account = await _googleSignInService.signIn();
    if (account == null) {
      if (kDebugMode) print("Google Sign-In failed.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Compute BMI from user data.
    if (_user.weight != null && _user.height != null && _user.height! > 0) {
      _bmi = _user.weight! / ((_user.height! / 100) * (_user.height! / 100));
    }

    DateTime now = DateTime.now();
    // For sleep, use the past 24 hours starting from today's midnight.
    DateTime todayMidnight = DateTime(now.year, now.month, now.day);
    double totalSleepMinutes = await _googleFitService.getTotalValue(
      HealthDataType.SLEEP_ASLEEP,
      todayMidnight.subtract(const Duration(days: 1)),
      todayMidnight,
    );
    _sleepTime = "${totalSleepMinutes.round()}m";

    // Hardcode weekly steps data:
    // Assume today is Mar 16 and yesterday is Mar 15.
    // Convert steps to km: 5634 steps * 0.762 / 1000 ≈ 4.29 km, 3000 steps * 0.762 / 1000 ≈ 2.29 km.
    // We'll assume the other 5 days have no data.
    List<double> weeklyData = [0.0, 0.0, 0.0, 0.0, 0.0, 4.29, 2.29];

    setState(() {
      _weeklyActivityData = weeklyData;
      _isLoading = false;
    });
  }

  // Compute the last 7 days (in ascending order: oldest to newest) using local time.
  List<DateTime> get _last7Days {
    DateTime todayMidnight = DateTime.now();
    return List.generate(
      7,
      (index) =>
          DateTime(todayMidnight.year, todayMidnight.month, todayMidnight.day)
              .subtract(Duration(days: 6 - index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorConstant.whiteBackground,
        elevation: 0,
        title: Text(
          "Analytics",
          style: TextStyle(
            fontFamily: "Poppins",
            color: ColorConstant.bluedark,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _fetchAnalyticsData,
            icon: Icon(
              Icons.refresh_rounded,
              color: ColorConstant.bluedark,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: ColorConstant.bluedark,
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    BMIWidgetChart(
                      onTapViewMore: () {},
                      bmiValue: _bmi,
                    ),
                    const SizedBox(height: 22),
                    sleepingTimeWidget(_sleepTime),
                    ActivityProgressChart(
                      weeklyData: _weeklyActivityData,
                      last7Days: _last7Days,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget sleepingTimeWidget(String sleepingTime) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 25),
      decoration: AppDecoration.boxShadowWithWhiteFillAndBorderRadius15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "sleep".tr,
                style: AppStyle.txtPoppinsBold18Dark,
              ),
              const SizedBox(height: 15),
              Text(
                sleepingTime,
                style: TextStyle(
                  color: ColorConstant.lightBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 22),
            ],
          ),
          Image.asset(
            ImageConstant.imgSleeping,
            width: 150,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}

/// BarChart widget to display weekly activity progress using the hardcoded walking data.
class ActivityProgressChart extends StatefulWidget {
  final List<double> weeklyData;
  final List<DateTime> last7Days;
  const ActivityProgressChart(
      {super.key, required this.weeklyData, required this.last7Days});

  @override
  State<ActivityProgressChart> createState() => _ActivityProgressChartState();
}

class _ActivityProgressChartState extends State<ActivityProgressChart> {
  Color barBackgroundColor = ColorConstant.lightGray.withOpacity(0.25);
  Color touchedBarColor = ColorConstant.bluedark.withOpacity(0.5);
  int touchedIndex = -1;

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: touchedBarColor)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: barBackgroundColor,
          ),
          gradient: LinearGradient(
            colors: x % 2 == 0
                ? [ColorConstant.lightSkyBlue, ColorConstant.lightDarkBlue]
                : [ColorConstant.lightpink, ColorConstant.lightPurple],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        return makeGroupData(
          i,
          widget.weeklyData[i],
          isTouched: i == touchedIndex,
          showTooltips: [i],
        );
      });

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String formattedDay =
                DateFormat('EEE').format(widget.last7Days[group.x.toInt()]);
            return BarTooltipItem(
              '$formattedDay\n',
              TextStyle(
                color: ColorConstant.whiteText,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: rod.toY.toStringAsFixed(1),
                  style: TextStyle(
                    color: touchedBarColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value.toInt() < 0 ||
                  value.toInt() >= widget.last7Days.length) {
                return const SizedBox.shrink();
              }
              final day = widget.last7Days[value.toInt()];
              final formattedDay =
                  DateFormat('EEE').format(day); // e.g., Mon, Tue
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 16,
                child: Text(
                  formattedDay,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Activity Progress",
                style: TextStyle(
                  color: ColorConstant.bluedark,
                  fontFamily: "Poppins",
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        ColorConstant.lightSkyBlue,
                        ColorConstant.lightDarkBlue,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Weekly",
                        style: TextStyle(
                          color: ColorConstant.whiteText,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: ColorConstant.whiteBackground,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 40),
            width: MediaQuery.of(context).size.width,
            height: 250,
            child: BarChart(mainBarData()),
          ),
        ],
      ),
    );
  }
}

class BMIWidgetChart extends StatelessWidget {
  final VoidCallback onTapViewMore;
  final double bmiValue;
  const BMIWidgetChart(
      {super.key, required this.onTapViewMore, required this.bmiValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 22),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(ImageConstant.imgBannerDots),
          fit: BoxFit.cover,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConstant.lightSkyBlue,
            ColorConstant.lightDarkBlue,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BMI (Body Mass Index)",
                style: TextStyle(
                  color: ColorConstant.whiteText,
                  fontSize: 15,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Your BMI is ${bmiValue.toStringAsFixed(1)}",
                style: TextStyle(
                  color: ColorConstant.whiteText,
                  fontFamily: "Poppins",
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: onTapViewMore,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        ColorConstant.lightpink,
                        ColorConstant.lightPurple,
                      ],
                    ),
                  ),
                  child: Text(
                    "View More",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.whiteText,
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.only(right: 60),
            width: 10,
            height: 10,
            child: PieChart(
              PieChartData(
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                sections: [
                  PieChartSectionData(
                    value: 100,
                    color: ColorConstant.whiteBackground,
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: ColorConstant.whiteText,
                    ),
                  ),
                  PieChartSectionData(
                    value: bmiValue,
                    title: bmiValue.toStringAsFixed(1),
                    color: ColorConstant.lightPurple,
                    radius: 70,
                    titleStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: ColorConstant.whiteText,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

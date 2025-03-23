import 'package:health/health.dart';

class GoogleFitService {
  final HealthFactory _health = HealthFactory();

  // Define all health data types you might need.
  final List<HealthDataType> _types = [
    HealthDataType.HEART_RATE,
    // HealthDataType.ACTIVE_ENERGY_BURNED,
    // HealthDataType.DISTANCE_DELTA, // Use the correct constant.
    // HealthDataType.SLEEP_ASLEEP,
  ];

  /// Requests authorization to access the specified health data.
  Future<bool> requestAuthorization() async {
    try {
      bool authorized = await _health.requestAuthorization(_types);
      return authorized;
    } catch (error) {
      print("Error during authorization: $error");
      return false;
    }
  }

  /// Generic method to fetch data for a specific [type] between [startDate] and [endDate].
  Future<List<HealthDataPoint>> fetchData(
      HealthDataType type, DateTime startDate, DateTime endDate) async {
    List<HealthDataPoint> data = [];
    try {
      bool authorized = await requestAuthorization();
      if (authorized) {
        data = await _health.getHealthDataFromTypes(startDate, endDate, [type]);
        // Remove duplicates if any.
        data = HealthFactory.removeDuplicates(data);
      } else {
        print("Authorization not granted for $type");
      }
    } catch (error) {
      print("Error fetching data for $type: $error");
    }
    return data;
  }

  /// Returns the latest value for the given [type] within the specified time range.
  Future<double?> getLatestValue(
      HealthDataType type, DateTime startDate, DateTime endDate) async {
    List<HealthDataPoint> data = await fetchData(type, startDate, endDate);
    if (data.isNotEmpty) {
      // Sort by start time so that the last entry is the latest.
      data.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
      // Convert the value using double.parse, since toDouble() is not available.
      return double.tryParse(data.last.value.toString());
    }
    return null;
  }

  /// Sums up all the values for the given [type] within the specified time range.
  Future<double> getTotalValue(
      HealthDataType type, DateTime startDate, DateTime endDate) async {
    List<HealthDataPoint> data = await fetchData(type, startDate, endDate);
    double total = 0;
    for (var point in data) {
      total += double.tryParse(point.value.toString()) ?? 0;
    }
    return total;
  }
}

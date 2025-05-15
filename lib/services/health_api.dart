// lib/services/health_service.dart
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  final Health _health = Health();

  HealthService() {
    _health.configure();
  }

  Future<bool> authorize() async {
    await Permission.activityRecognition.request();
    await Permission.location.request();

    final List<HealthDataType> types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.BODY_TEMPERATURE,
    ];
    
    final List<HealthDataAccess> permissions = [
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE
    ];

    final granted = await _health.requestAuthorization(types, permissions: permissions);
    return granted ?? false;
  }

  Future<List<HealthDataPoint>> fetchData(HealthDataType type) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    final data = await _health.getHealthDataFromTypes(
      types: [type],
      startTime: start,
      endTime: now,
    );

    return _health.removeDuplicates(data);
  }
}

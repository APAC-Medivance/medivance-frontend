import "package:flutter/material.dart";
import "package:health/health.dart";
import 'package:permission_handler/permission_handler.dart';

class HealthServices extends StatefulWidget {
  const HealthServices({super.key});

  @override
  State<HealthServices> createState() => _HealthServicesState();
}

class _HealthServicesState extends State<HealthServices> {
  final Health health = Health();
  HealthConnectSdkStatus? _hcStatus;
  bool _authorized = false;
  List<HealthDataPoint> _data = [];
  bool _isLoading = false;

  Future<void> _checkHealthConnectStatus() async {
    final status = await health.getHealthConnectSdkStatus();
    setState(() => _hcStatus = status);
  }

  Future<void> _authorize() async {
    await Permission.activityRecognition.request();
    await Permission.location.request();

    final types = [HealthDataType.STEPS];
    final perms = [HealthDataAccess.READ_WRITE];

    final granted = await health.requestAuthorization(types, permissions: perms);
    setState(() => _authorized = granted ?? false);
  }

  Future<void> _fetchSteps() async {
    if (!_authorized) return;
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    final pts = await health.getHealthDataFromTypes(
      types: [HealthDataType.STEPS],
      startTime: midnight,
      endTime: now,
    );

    setState(() {
      _data = health.removeDuplicates(pts);
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
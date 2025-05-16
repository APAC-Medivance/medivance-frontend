import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:hajjhealth/services/health_api.dart';
import 'package:health/health.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class HealthMetricsScreen extends StatefulWidget {
  const HealthMetricsScreen({Key? key}) : super(key: key);

  @override
  State<HealthMetricsScreen> createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen> {
  String selectedPeriod = 'Hari Ini';
  final List<String> periods = ['Hari Ini', '7 Hari', '30 Hari'];

  final HealthService _healthService = HealthService();

  Map<String, dynamic>? _healthData;

  List<dynamic> _heartRate = [];
  List<dynamic> _bloodOxygen = [];
  List<dynamic> _temperature = [];

  double? _heartRateNow;
  double? _bloodOxygenNow;
  double? _temperatureNow;

  @override
  void initState() {
    super.initState();
    _initHealthData();
  }

  Future<void> _initHealthData() async {
    final authorized = await _healthService.authorize();
    if (authorized) {
      final hrData = await _healthService.fetchData(HealthDataType.HEART_RATE);
      final spo2Data = await _healthService.fetchData(HealthDataType.BLOOD_OXYGEN);
      final tempData = await _healthService.fetchData(HealthDataType.BODY_TEMPERATURE);

      // Convert data to JSON and save
      await _saveHealthDataToJson(hrData, spo2Data, tempData);

      print("Authorized status : $authorized");
      // print("Heart Rate data : $_heartRateData");
      // print("SpO2 Data : $_bloodOxygenData");
      // print("Temperature Data : $_tempData");
    } else {
      // Handle authorization failure
      print("Authorized status : $authorized");
    }
  }

  Future<void> _saveHealthDataToJson(
    List<HealthDataPoint> heartRateData,
    List<HealthDataPoint> bloodOxygenData,
    List<HealthDataPoint> tempData,
    ) async {
    try {
      // Convert HealthDataPoint lists into a serializable map
      Map<String, dynamic> healthData = {
        "heart_rate": heartRateData.map((e) => e.toJson()).toList(),
        "blood_oxygen": bloodOxygenData.map((e) => e.toJson()).toList(),
        "temperature": tempData.map((e) => e.toJson()).toList(),
      };

      final heartRate = healthData['heart_rate'];
      final bloodOxygen = healthData['blood_oxygen'];
      final temperature = healthData['temperature'];

      List<dynamic> heartRateNumeric = heartRate.map((data) => data['value']['numericValue']).toList();
      List<dynamic> bloodOxygenNumeric = bloodOxygen.map((data) => data['value']['numericValue']).toList();
      List<dynamic> temperatureNumeric = temperature.map((data) => data['value']['numericValue']).toList();

      setState(() {
        _heartRate = heartRateNumeric.isEmpty ? [1, 1] : heartRateNumeric;
        _bloodOxygen = bloodOxygenNumeric.isEmpty ? [1, 1] : bloodOxygenNumeric;
        _temperature = temperatureNumeric.isEmpty ? [1, 1] : temperatureNumeric;

        _heartRateNow = _heartRate.isEmpty ? 1 : (_heartRate[_heartRate.length - 1] as num).toDouble();
        _bloodOxygenNow = _bloodOxygen.isEmpty ? 1 : (_bloodOxygen[_bloodOxygen.length - 1] as num).toDouble();
        _temperatureNow = _temperature.isEmpty ? 1 : (_temperature[_temperature.length - 1] as num).toDouble();
      });
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
            Color(0xFFE8F9FF),
            Colors.white
          ])
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Text("Health Statistics", style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                )),

                const SizedBox(height: 20),

                // Statistic Card
                _buildCard(
                  'Statistic',
                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (_heartRateNow != null || _bloodOxygenNow != null || _temperatureNow != null)
                          ? Expanded(
                              flex: 7,
                              child: HealthRingsChart(
                                heartRateNow: _heartRateNow!,
                                bloodOxygenNow: _bloodOxygenNow!,
                                temperatureNow: _temperatureNow!,
                              ),
                            )
                          : const SizedBox(), // Atau bisa tambahin CircularProgressIndicator
                        // Legend
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildLegendItem(Colors.blue.shade300, 'SpO2'),
                              const SizedBox(height: 10),
                              _buildLegendItem(Colors.red.shade300, 'HR'),
                              const SizedBox(height: 10),
                              _buildLegendItem(Colors.orange.shade300, 'Temp')
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Heart Rate Card
                _buildCard(
                  'Heart rate',
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomPaint(
                            key: ValueKey(_heartRate),
                            painter: HeartRatePainter(_heartRate.map((e) => (e as num).toDouble()).toList()),
                            child: Container(),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "  $_heartRateNow bpm",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // SpO2 Card
                _buildCard(
                  'SpO2',
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomPaint(
                            key: ValueKey(_bloodOxygen),
                            painter: BloodOxygenPainter(_bloodOxygen.map((e) => (e as num).toDouble()).toList()),
                            child: Container(),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "  $_bloodOxygenNow %",
                              style: TextStyle(
                                color: Colors.lightBlue,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Suhu Card
                _buildCard(
                  'Temperature',
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomPaint(
                            key: ValueKey(_temperature),
                            painter: BloodOxygenPainter(_temperature.map((e) => (e as num).toDouble()).toList()),
                            child: Container(),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "  $_temperatureNow C",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                      ],
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

  Widget _buildCard(String title, Widget content) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 0,
            spreadRadius: 0.1,
            offset: const Offset(0, 1),
          )
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            if (title.isNotEmpty) const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// Custom painters

class HealthRingsChart extends StatelessWidget {
  final double heartRateNow;
  final double bloodOxygenNow;
  final double temperatureNow;

  const HealthRingsChart({Key? key, required this.heartRateNow, required this.bloodOxygenNow, required this.temperatureNow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RingsPainter(
        heartRateNow: heartRateNow,
        bloodOxygenNow: bloodOxygenNow,
        temperatureNow: temperatureNow
      ),
      child: Container(),
    );
  }
}

class RingsPainter extends CustomPainter {
  double heartRateNow;
  double bloodOxygenNow;
  double temperatureNow;

  RingsPainter({required this.heartRateNow, required this.bloodOxygenNow, required this.temperatureNow});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.5;
    
    // Calculate stroke widths for each ring
    final strokeWidth = radius * 0.12;
    final gap = radius * 0.05;
    
    // Define rings (from outside to inside)
    final rings = [
      _RingData(Colors.blue.shade300, bloodOxygenNow/100, Colors.blue.shade100),
      _RingData(Colors.red.shade300, heartRateNow/220, Colors.red.shade100),
      _RingData(Colors.orange.shade300, temperatureNow/100, Colors.orange.shade100)
    ];
    
    // Draw rings
    for (int i = 0; i < rings.length; i++) {
      final currentRadius = radius - (i * (strokeWidth + gap));
      
      // Background ring
      final bgPaint = Paint()
        ..color = rings[i].backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      canvas.drawCircle(center, currentRadius, bgPaint);
      
      // Progress ring
      final progressPaint = Paint()
        ..color = rings[i].color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: currentRadius),
        -math.pi / 2, // Start from top
        2 * math.pi * rings[i].progress, // Sweep angle based on progress
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _RingData {
  final Color color;
  final double progress;
  final Color backgroundColor;
  
  _RingData(this.color, this.progress, this.backgroundColor);
}

class HeartRatePainter extends CustomPainter {
  final List<double> heartRateNumeric;

  HeartRatePainter(this.heartRateNumeric);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    if (heartRateNumeric.isEmpty) return;

    double startX = 0;
    double maxHeartRate = heartRateNumeric.reduce((a, b) => a > b ? a : b);
    double minHeartRate = heartRateNumeric.reduce((a, b) => a < b ? a : b);

    double range = maxHeartRate - minHeartRate;
    if (range == 0) range = 1;
    maxHeartRate += range * 0.1;
    minHeartRate -= range * 0.1;

    double yScale = size.height / (maxHeartRate - minHeartRate);
    double xScale = size.width / (heartRateNumeric.length - 1);

    path.moveTo(startX, size.height - ((heartRateNumeric[0] - minHeartRate) * yScale));

    for (int i = 1; i < heartRateNumeric.length; i++) {
      double x = startX + (i * xScale);
      double y = size.height - ((heartRateNumeric[i] - minHeartRate) * yScale);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HeartRatePainter oldDelegate) {
    return !listEquals(oldDelegate.heartRateNumeric, heartRateNumeric);
  }
}

class BloodOxygenPainter extends CustomPainter {
  final List<double> bloodOxygenNumeric;

  BloodOxygenPainter(this.bloodOxygenNumeric);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.lightBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    if (bloodOxygenNumeric.isEmpty) return;

    double startX = 0;
    double maxHeartRate = bloodOxygenNumeric.reduce((a, b) => a > b ? a : b);
    double minHeartRate = bloodOxygenNumeric.reduce((a, b) => a < b ? a : b);

    double range = maxHeartRate - minHeartRate;
    if (range == 0) range = 1;
    maxHeartRate += range * 0.1;
    minHeartRate -= range * 0.1;

    double yScale = size.height / (maxHeartRate - minHeartRate);
    double xScale = size.width / (bloodOxygenNumeric.length - 1);

    path.moveTo(startX, size.height - ((bloodOxygenNumeric[0] - minHeartRate) * yScale));

    for (int i = 1; i < bloodOxygenNumeric.length; i++) {
      double x = startX + (i * xScale);
      double y = size.height - ((bloodOxygenNumeric[i] - minHeartRate) * yScale);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BloodOxygenPainter oldDelegate) {
    return !listEquals(oldDelegate.bloodOxygenNumeric, bloodOxygenNumeric);
  }
}

class TemperaturePainter extends CustomPainter {
  final List<double> temperatureNumeric;

  TemperaturePainter(this.temperatureNumeric);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    if (temperatureNumeric.isEmpty) return;

    double startX = 0;
    double maxHeartRate = temperatureNumeric.reduce((a, b) => a > b ? a : b);
    double minHeartRate = temperatureNumeric.reduce((a, b) => a < b ? a : b);

    double range = maxHeartRate - minHeartRate;
    if (range == 0) range = 1;
    maxHeartRate += range * 0.1;
    minHeartRate -= range * 0.1;

    double yScale = size.height / (maxHeartRate - minHeartRate);
    double xScale = size.width / (temperatureNumeric.length - 1);

    path.moveTo(startX, size.height - ((temperatureNumeric[0] - minHeartRate) * yScale));

    for (int i = 1; i < temperatureNumeric.length; i++) {
      double x = startX + (i * xScale);
      double y = size.height - ((temperatureNumeric[i] - minHeartRate) * yScale);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TemperaturePainter oldDelegate) {
    return !listEquals(oldDelegate.temperatureNumeric, temperatureNumeric);
  }
}

class BubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistency
    
    // Generate random bubbles
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 4.0 + random.nextDouble() * 10;
      
      final paint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
      
      // Add a highlight to the bubble
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x - radius * 0.3, y - radius * 0.3),
        radius * 0.3,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

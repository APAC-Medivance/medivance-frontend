import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HealthMetricsScreen extends StatefulWidget {
  const HealthMetricsScreen({Key? key}) : super(key: key);

  @override
  State<HealthMetricsScreen> createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen> {
  String selectedPeriod = 'Hari Ini';
  final List<String> periods = ['Hari Ini', '7 Hari', '30 Hari'];

  // Mock data for health metrics
  final Map<String, Map<String, dynamic>> healthMetrics = {
    'Heart Rate': {
      'value': '78',
      'unit': 'bpm',
      'icon': Icons.favorite,
      'color': Colors.red,
      'data': [68, 72, 76, 80, 75, 78, 82, 79],
      'normal': '60-100',
      'description': 'Detak jantung normal dalam keadaan istirahat',
    },
    'Temperature': {
      'value': '36.7',
      'unit': '°C',
      'icon': Icons.thermostat,
      'color': Colors.orange,
      'data': [36.5, 36.6, 36.7, 36.8, 36.7, 36.6, 36.7, 36.8],
      'normal': '36.1-37.2',
      'description': 'Suhu tubuh dalam kisaran normal',
    },
    'SpO2': {
      'value': '98',
      'unit': '%',
      'icon': Icons.air,
      'color': Colors.blue,
      'data': [97, 98, 99, 98, 97, 98, 99, 98],
      'normal': '95-100',
      'description': 'Kadar oksigen darah dalam kisaran normal',
    },
    'Blood Pressure': {
      'value': '120/80',
      'unit': 'mmHg',
      'icon': Icons.speed,
      'color': Colors.purple,
      'data': [
        {'systolic': 120, 'diastolic': 80},
        {'systolic': 118, 'diastolic': 78},
        {'systolic': 122, 'diastolic': 82},
        {'systolic': 119, 'diastolic': 79},
        {'systolic': 121, 'diastolic': 81},
        {'systolic': 120, 'diastolic': 80},
        {'systolic': 118, 'diastolic': 79},
        {'systolic': 122, 'diastolic': 81},
      ],
      'normal': '120/80',
      'description': 'Tekanan darah stabil dalam kisaran normal',
    }
  };

  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Health Statistics',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Statistic Card
              _buildCard(
                'Statistic',
                SizedBox(
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rings chart
                      const Expanded(
                        flex: 7,
                        child: HealthRingsChart(),
                      ),
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
                            _buildLegendItem(Colors.orange.shade300, 'Temp'),
                            const SizedBox(height: 10),
                            _buildLegendItem(Colors.green, 'BP'),
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
                          painter: HeartRatePainter(),
                        ),
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'bpm',
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
                  child: CustomPaint(
                    painter: BubblesPainter(),
                    size: const Size(double.infinity, 100),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Suhu Card
              _buildCard(
                'Suhu',
                const SizedBox(
                  height: 100,
                ),
              ),
            ],
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
  const HealthRingsChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RingsPainter(),
      child: Container(),
    );
  }
}

class RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.5;
    
    // Calculate stroke widths for each ring
    final strokeWidth = radius * 0.12;
    final gap = radius * 0.05;
    
    // Define rings (from outside to inside)
    final rings = [
      _RingData(Colors.blue.shade300, 0.95, Colors.blue.shade100),
      _RingData(Colors.red.shade300, 0.8, Colors.red.shade100),
      _RingData(Colors.orange.shade300, 0.75, Colors.orange.shade100),
      _RingData(Colors.green, 0.9, Colors.green.shade100),
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final path = Path();
    
    // ECG heart beat pattern
    double startX = 0;
    path.moveTo(startX, size.height / 2);
    
    // Create a repeating heart beat pattern
    for (int i = 0; i < 3; i++) {
      final segmentWidth = size.width / 3;
      final x = startX + (i * segmentWidth);
      
      // Normal line
      path.lineTo(x + segmentWidth * 0.2, size.height / 2);
      
      // Spike up
      path.lineTo(x + segmentWidth * 0.3, size.height * 0.2);
      
      // Spike down
      path.lineTo(x + segmentWidth * 0.4, size.height * 0.8);
      
      // Spike up again (main peak)
      path.lineTo(x + segmentWidth * 0.5, size.height * 0.3);
      
      // Back to baseline
      path.lineTo(x + segmentWidth * 0.7, size.height / 2);
      
      // Continue baseline
      path.lineTo(x + segmentWidth, size.height / 2);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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

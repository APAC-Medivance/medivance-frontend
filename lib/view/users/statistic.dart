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
      'description': 'Detak jantung normal dalam keadaan istirahat'
    },
    'Temperature': {
      'value': '36.7',
      'unit': '°C',
      'icon': Icons.thermostat,
      'color': Colors.orange,
      'data': [36.5, 36.6, 36.7, 36.8, 36.7, 36.6, 36.7, 36.8],
      'normal': '36.1-37.2',
      'description': 'Suhu tubuh dalam kisaran normal'
    },
    'SpO2': {
      'value': '98',
      'unit': '%',
      'icon': Icons.air,
      'color': Colors.blue,
      'data': [97, 98, 99, 98, 97, 98, 99, 98],
      'normal': '95-100',
      'description': 'Kadar oksigen darah dalam kisaran normal'
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
      'description': 'Tekanan darah stabil dalam kisaran normal'
    },
    'Sleep': {
      'value': '7.5',
      'unit': 'jam',
      'icon': Icons.bedtime,
      'color': Colors.indigo,
      'data': [
        {'deep': 2.5, 'light': 3.5, 'rem': 1.5},
        {'deep': 2.3, 'light': 3.7, 'rem': 1.2},
        {'deep': 2.7, 'light': 3.3, 'rem': 1.6},
        {'deep': 2.4, 'light': 3.6, 'rem': 1.4},
        {'deep': 2.6, 'light': 3.4, 'rem': 1.5},
        {'deep': 2.3, 'light': 3.7, 'rem': 1.5},
        {'deep': 2.5, 'light': 3.5, 'rem': 1.5},
      ],
      'normal': '7-9',
      'description': 'Durasi tidur dalam rentang sehat'
    },
    'Steps': {
      'value': '7,856',
      'unit': 'steps',
      'icon': Icons.directions_walk,
      'color': Colors.green,
      'data': [6543, 7890, 8256, 6789, 9234, 7856, 8543, 7123],
      'normal': '8,000-10,000',
      'description': 'Mendekati target langkah harian'
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildPeriodSelector(),
                const SizedBox(height: 20),
                _buildMetricsSummary(),
                const SizedBox(height: 25),
                _buildDetailedHealthMetrics(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 79, 181, 247), Color.fromARGB(255, 46, 156, 228)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Metrics',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Data dari Samsung Smartwatch',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Terhubung',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.update,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Terakhir: ${DateFormat('HH:mm').format(DateTime.now())}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Icon(
                Icons.watch,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: periods.map((period) {
          bool isSelected = selectedPeriod == period;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedPeriod = period;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                period,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricsSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Kesehatan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Circular graphics
                Expanded(
                  flex: 1,
                  child: _buildCircularSummary(),
                ),
                // Text summary
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skor Kesehatan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '87',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Sangat Baik',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Anda berada dalam kondisi kesehatan yang baik. Pertahankan aktivitas fisik dan pola tidur yang teratur.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularSummary() {
    // This widget displays a circular chart with multiple rings
    return CustomPaint(
      size: const Size(180, 180),
      painter: CircularHealthSummaryPainter(),
    );
  }

  Widget _buildDetailedHealthMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Kesehatan Detail',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        ...healthMetrics.entries.map((entry) {
          String key = entry.key;
          Map<String, dynamic> metric = entry.value;
          
          return _buildMetricCard(key, metric);
        }).toList(),
      ],
    );
  }

  Widget _buildMetricCard(String title, Map<String, dynamic> metric) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (metric['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      metric['icon'] as IconData,
                      color: metric['color'] as Color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Normal: ${metric['normal']}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (metric['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      metric['value'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: metric['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      metric['unit'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: (metric['color'] as Color).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: _buildChartForMetric(title, metric),
          ),
          const SizedBox(height: 10),
          Text(
            metric['description'],
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartForMetric(String title, Map<String, dynamic> metric) {
    if (title == 'Blood Pressure') {
      return _buildBloodPressureChart(metric);
    } else if (title == 'Sleep') {
      return _buildSleepChart(metric);
    } else {
      return _buildLineChart(metric);
    }
  }
Widget _buildLineChart(Map<String, dynamic> metric) {
  List<double> data = (metric['data'] as List)
      .map((e) => (e as num).toDouble())
      .toList();

  Color color = metric['color'] as Color;

  return LineChart(
    LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              final int hour = value.toInt() * 3;
              String text = '';
              if (hour % 6 == 0 && hour <= 24) {
                text = '$hour:00';
              }
              return Text(
                text,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: data.length.toDouble() - 1,
      minY: data.reduce(math.min) * 0.9,
      maxY: data.reduce(math.max) * 1.1,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(data.length, (index) {
            return FlSpot(index.toDouble(), data[index]);
          }),
          isCurved: true,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: color,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: color.withOpacity(0.2),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildBloodPressureChart(Map<String, dynamic> metric) {
    List<Map<String, dynamic>> data = (metric['data'] as List).cast<Map<String, dynamic>>();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int hour = value.toInt() * 3;
                String text = '';
                if (hour % 6 == 0 && hour <= 24) {
                  text = '$hour:00';
                }
                return Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 22,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: 7,
        minY: 60,
        maxY: 140,
        lineBarsData: [
          // Systolic
          LineChartBarData(
            spots: List.generate(data.length, (index) {
              return FlSpot(index.toDouble(), data[index]['systolic'].toDouble());
            }),
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.red,
                );
              },
            ),
          ),
          // Diastolic
          LineChartBarData(
            spots: List.generate(data.length, (index) {
              return FlSpot(index.toDouble(), data[index]['diastolic'].toDouble());
            }),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.blue,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepChart(Map<String, dynamic> metric) {
    List<Map<String, dynamic>> data = (metric['data'] as List).cast<Map<String, dynamic>>();
    final lastDayData = data.last;
    
    // Create a stacked bar chart for sleep stages
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String sleepStage;
              Color color;
              
              switch (rodIndex) {
                case 0:
                  sleepStage = 'Deep';
                  color = Colors.indigo;
                  break;
                case 1:
                  sleepStage = 'Light';
                  color = Colors.blue;
                  break;
                case 2:
                  sleepStage = 'REM';
                  color = Colors.lightBlue;
                  break;
                default:
                  sleepStage = '';
                  color = Colors.grey;
              }
              
              return BarTooltipItem(
                '$sleepStage: ${rod.toY.toStringAsFixed(1)} jam',
                TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            groupVertically: true,
            barRods: [
              BarChartRodData(
                toY: lastDayData['deep'].toDouble(),
                color: Colors.indigo,
                width: 40,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: lastDayData['light'].toDouble(),
                color: Colors.blue,
                width: 40,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: lastDayData['rem'].toDouble(),
                color: Colors.lightBlue,
                width: 40,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
        ],
        maxY: 8,
      ),
    );
  }
}

class CircularHealthSummaryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = math.min(centerX, centerY);

    final Offset center = Offset(centerX, centerY);

    // Background ring style
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0;

    // Draw background rings
    canvas.drawCircle(center, radius * 0.9, backgroundPaint); // Steps
    canvas.drawCircle(center, radius * 0.7, backgroundPaint); // Sleep
    canvas.drawCircle(center, radius * 0.5, backgroundPaint); // Heart rate

    // Draw data arcs
    _drawArc(canvas, center, radius * 0.9, 0.78, Colors.green, 14.0);  // Steps
    _drawArc(canvas, center, radius * 0.7, 0.85, Colors.indigo, 14.0); // Sleep
    _drawArc(canvas, center, radius * 0.5, 0.92, Colors.red, 14.0);    // Heart rate

    // Center circle
    final Paint centerCirclePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.3, centerCirclePaint);

    // Draw percentage text in center
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '85%',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.25,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
    
    );

    textPainter.layout();
    final Offset textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  void _drawArc(Canvas canvas, Offset center, double radius, double percent, Color color, double strokeWidth) {
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      rect,
      -math.pi / 2, // Start from top
      2 * math.pi * percent, // Sweep angle based on percent
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
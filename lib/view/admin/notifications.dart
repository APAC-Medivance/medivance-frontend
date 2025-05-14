import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({Key? key}) : super(key: key);

  @override
  State<AdminNotificationScreen> createState() => _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  bool isFiltering = false;
  String filterType = "All";
  
  // Simulated notifications with SpO2 data
  final List<Map<String, dynamic>> notifications = [
    {
      'patientName': 'Ahmad Khalid',
      'patientId': 'P-7821',
      'message': 'SpO2 level critical',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'isRead': false,
      'type': 'Critical',
      'spO2': 87,
      'avatar': 'A',
      'color': Colors.red,
    },
     {
      'patientName': 'Omar Farooq',
      'patientId': 'P-7833',
      'message': 'SpO2 level critical',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'isRead': false,
      'type': 'Critical',
      'spO2': 20,
      'avatar': 'B',
      'color': Colors.red,
    },
    {
      'patientName': 'Fatima Hassan',
      'patientId': 'P-5432',
      'message': 'SpO2 level dropping',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'isRead': false,
      'type': 'Warning',
      'spO2': 92,
      'avatar': 'F',
      'color': Colors.orange,
    },
    {
      'patientName': 'Omar Farooq',
      'patientId': 'P-3897',
      'message': 'SpO2 level critical',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': false,
      'type': 'Critical',
      'spO2': 85,
      'avatar': 'O',
      'color': Colors.red,
    },
    {
      'patientName': 'Aisha Rahman',
      'patientId': 'P-9043',
      'message': 'SpO2 returning to normal',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'isRead': true,
      'type': 'Normal',
      'spO2': 97,
      'avatar': 'A',
      'color': Colors.green,
    },
    {
      'patientName': 'Mohammed Ali',
      'patientId': 'P-2156',
      'message': 'SpO2 level critical',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': true,
      'type': 'Critical',
      'spO2': 88,
      'avatar': 'M',
      'color': Colors.red,
    },
    {
      'patientName': 'Zainab Malik',
      'patientId': 'P-6274',
      'message': 'SpO2 level warning',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'isRead': true,
      'type': 'Warning',
      'spO2': 91,
      'avatar': 'Z',
      'color': Colors.orange,
    },
  ];

  List<Map<String, dynamic>> get filteredNotifications {
    if (filterType == "All") {
      return notifications;
    } else {
      return notifications.where((notification) => notification['type'] == filterType).toList();
    }
  }

  Timer? _blinkTimer;
  bool _showHighlight = false;

  @override
  void initState() {
    super.initState();
    // Create a timer for blinking effect on critical notifications
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        _showHighlight = !_showHighlight;
      });
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Count critical notifications
    int criticalCount = notifications.where((n) => n['type'] == 'Critical' && n['isRead'] == false).length;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, criticalCount),
            _buildFilterChips(),
            Expanded(
              child: _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int criticalCount) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 119, 203, 255), Color.fromARGB(255, 97, 189, 255)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    'Notifications',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Mark all as read',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (criticalCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: _showHighlight 
                    ? Colors.red.withOpacity(0.9) 
                    : Colors.red.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$criticalCount patients with critical SpO2 levels',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildFilterChip("All", Icons.notifications),
            const SizedBox(width: 10),
            _buildFilterChip("Critical", Icons.dangerous, Colors.red),
            const SizedBox(width: 10),
            _buildFilterChip("Warning", Icons.warning, Colors.orange),
            const SizedBox(width: 10),
            _buildFilterChip("Normal", Icons.check_circle, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, [Color? iconColor]) {
    final isSelected = filterType == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          filterType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: iconColor ?? (isSelected ? Colors.blue : Colors.grey),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.blue : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return filteredNotifications.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off,
                  size: 70,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredNotifications.length,
            itemBuilder: (context, index) {
              final notification = filteredNotifications[index];
              return _buildNotificationCard(notification);
            },
          );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final bool isCritical = notification['type'] == 'Critical';
    final bool isWarning = notification['type'] == 'Warning';
    final bool isUnread = !notification['isRead'];
    final int spO2 = notification['spO2'] as int;

    // Determine card styling based on SpO2 level and read status
    Color cardBorderColor = Colors.transparent;
    Color cardColor = Colors.white;
    
    if (isCritical) {
      cardBorderColor = Colors.red;
      if (isUnread && _showHighlight) {
        cardColor = Colors.red.withOpacity(0.05);
      }
    } else if (isWarning) {
      cardBorderColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardBorderColor,
          width: isCritical ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (notification['color'] as Color).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      notification['avatar'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: notification['color'] as Color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification['patientName'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'ID: ${notification['patientId']} • ${_formatTimestamp(notification['timestamp'])}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTypeColor(notification['type']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              notification['type'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getTypeColor(notification['type']),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            notification['message'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // SpO2 display
            _buildSpO2Indicator(spO2),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  'Location in street no 54 ...',
                  Icons.location_on,
                  Colors.blue,
                  () {
                    // Action to view patient details
                  },
                ),
              
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpO2Indicator(int spO2) {
    Color progressColor;
    String statusText;
    IconData statusIcon;

    // Determine status based on SpO2 level
    if (spO2 < 90) {
      progressColor = Colors.red;
      statusText = "Critical - Immediate Action Required";
      statusIcon = Icons.dangerous;
    } else if (spO2 < 93) {
      progressColor = Colors.orange;
      statusText = "Warning - Monitor Closely";
      statusIcon = Icons.warning;
    } else {
      progressColor = Colors.green;
      statusText = "Normal";
      statusIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: progressColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: progressColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                statusIcon,
                color: progressColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "SpO2 Level",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                constraints: const BoxConstraints(minWidth: 60),
                child: Text(
                  "$spO2%",
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: spO2 / 100,
              backgroundColor: Colors.grey.withOpacity(0.2),
              color: progressColor,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  statusText,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: progressColor,
                  ),
                ),
              ),
                              if (spO2 < 90)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "URGENT",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(
        icon,
        color: color,
        size: 16,
      ),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Critical':
        return Colors.red;
      case 'Warning':
        return Colors.orange;
      case 'Normal':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
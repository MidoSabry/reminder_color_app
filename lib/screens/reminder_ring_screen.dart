import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';

class ReminderRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const ReminderRingScreen({super.key, required this.alarmSettings});

  @override
  State<ReminderRingScreen> createState() => _ReminderRingScreenState();
}

class _ReminderRingScreenState extends State<ReminderRingScreen>  with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation للأيقونة
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // منع الرجوع بالـ back button
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.shade900,
                Colors.purple.shade700,
                Colors.pink.shade500,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animation Icon
                  const Spacer(),
                  
                  // Animated Icon
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(50),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.notifications_active,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                    
                  const SizedBox(height: 40),
                    
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      widget.alarmSettings.notificationSettings.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                    
                  const SizedBox(height: 16),
                    
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      widget.alarmSettings.notificationSettings.body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                    
                  const SizedBox(height: 60),
                    
                  // Time
                  Text(
                    TimeOfDay.fromDateTime(widget.alarmSettings.dateTime).format(context),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                    
                  const Spacer(),
                    
                  // Buttons
                 Row(
                    children: [
                      // Snooze Button
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.snooze,
                          label: 'غفوة\n5 دقائق',
                          color: Colors.white.withOpacity(0.25),
                          textColor: Colors.white,
                          onPressed: () => _handleSnooze(context),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Dismiss Button
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.check_circle,
                          label: 'إيقاف',
                          color: Colors.white,
                          textColor: Colors.deepPurple,
                          onPressed: () => _handleDismiss(context),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              
              ),
            ),
          ),
        ),
      ),
    );
  }






 Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 40, color: textColor),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSnooze(BuildContext context) {
    // تأجيل 5 دقائق
    final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
    
    Alarm.set(
      alarmSettings: widget.alarmSettings.copyWith(
        dateTime: snoozeTime,
      ),
    );
    
    Alarm.stop(widget.alarmSettings.id);
    
    // عرض رسالة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم التأجيل 5 دقائق'),
        duration: Duration(seconds: 2),
      ),
    );
    
    Navigator.of(context).pop();
  }

  void _handleDismiss(BuildContext context) {
    Alarm.stop(widget.alarmSettings.id);
    Navigator.of(context).pop();
  }
}

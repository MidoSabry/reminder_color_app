import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmScreen extends StatefulWidget {
  final String title;
  final String note;
  final String sticker;
  final int backgroundColor;
  final int textColor;

  const AlarmScreen({
    super.key,
    required this.title,
    required this.note,
    required this.sticker,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playAlarmSound();

    // Animation for pulsing effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _playAlarmSound() async {
    try {
      // Play default system alarm sound in loop
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
    } catch (e) {
      print('Error playing alarm sound: $e');
      // If custom sound fails, use notification sound
    }
  }

  void _stopAlarm() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    Navigator.of(context).pop();
  }

  void _snooze() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    // TODO: Schedule snooze for 5 minutes later
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Snoozed for 5 minutes')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(widget.backgroundColor),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated sticker
              ScaleTransition(
                scale: _pulseAnimation,
                child: Text(
                  widget.sticker,
                  style: const TextStyle(fontSize: 120),
                ),
              ),
              const SizedBox(height: 40),

              // Time display
              Text(
                TimeOfDay.now().format(context),
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Color(widget.textColor),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(widget.textColor),
                ),
              ),
              const SizedBox(height: 16),

              // Note
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.note,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Stop button (large and prominent)
              GestureDetector(
                onTap: _stopAlarm,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stop, size: 80, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'STOP',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Snooze button
              OutlinedButton.icon(
                onPressed: _snooze,
                icon: const Icon(Icons.snooze, size: 32),
                label: const Text(
                  'Snooze 5 min',
                  style: TextStyle(fontSize: 20),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(widget.textColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  side: BorderSide(
                    color: Color(widget.textColor),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
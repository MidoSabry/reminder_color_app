import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder_color_app/screens/home_screen.dart';
import 'package:reminder_color_app/screens/reminder_ring_screen.dart';
import 'package:reminder_color_app/services/reminder_service.dart';

import 'cubit/reminder_cubit.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';





final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize alarm service
  await FullScreenReminderService.instance.initialize();
   // Initialize notifications
  await NotificationService.instance.initialize();
  await NotificationService.instance.requestPermissions();
  await WidgetService.instance.initialize(); // ← أضف ده

   // Check if app launched from notification
  final launchDetails =
      await NotificationService.instance.getNotificationAppLaunchDetails();
  if (launchDetails?.didNotificationLaunchApp ?? false) {
    final payload = launchDetails!.notificationResponse?.payload;
    if (payload != null) {
      AlarmTapEventBus.instance.add(payload);
    }
  }


  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    
    // Listen to alarm ring events مرة واحدة بس
    Alarm.ringStream.stream.listen((alarmSettings) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => ReminderRingScreen(
            alarmSettings: alarmSettings,
          ),
        ),
      );
    });


     // Listen to notification taps
     // Listen to notification taps
  AlarmTapEventBus.instance.stream.listen((payload) async {
    final parts = payload.split('|');
    if (parts.isNotEmpty) {
      final reminderId = parts[0].replaceAll('alarm:', '');

      // ← جلب الـ reminder من قاعدة البيانات
      final reminder = await FullScreenReminderService.instance.getReminderById(reminderId);
      if (reminder != null) {
        final alarmSettings = AlarmSettings(
          id: reminder.id.hashCode,
          dateTime: reminder.dateTime,
          assetAudioPath: 'assets/sounds/alarm.mp3',
          loopAudio: true,
          vibrate: true,
          androidFullScreenIntent: true,
          warningNotificationOnKill: true,
          volumeSettings: VolumeSettings.fade(
            volume: 0.8,
            fadeDuration: const Duration(seconds: 3),
            volumeEnforced: true,
          ),
          notificationSettings: NotificationSettings(
            title: '${reminder.sticker} ${reminder.title}',
            body: reminder.note,
            stopButton: 'Stop',
          ),
        );

         navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ReminderRingScreen(alarmSettings: alarmSettings),
            fullscreenDialog: true,
          ),
        );
      }
    }});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReminderCubit()..loadReminders(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Colorful Reminders',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'providers/prayer_state.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system bars for immersive dark obsidian aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  final prayerState = PrayerState();
  await prayerState.initialize();

  runApp(PrayerApp(prayerState: prayerState));
}

class PrayerApp extends StatelessWidget {
  final PrayerState prayerState;

  const PrayerApp({
    super.key,
    required this.prayerState,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Times',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(state: prayerState),
    );
  }
}

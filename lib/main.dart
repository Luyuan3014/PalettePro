import 'package:flutter/material.dart';
import 'state/editor_notifier.dart';
import 'screens/editor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PaletteProApp());
}

/// The root application of PalettePro (臻图坊).
class PaletteProApp extends StatefulWidget {
  const PaletteProApp({super.key});

  @override
  State<PaletteProApp> createState() => _PaletteProAppState();
}

class _PaletteProAppState extends State<PaletteProApp> {
  late final EditorNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = EditorNotifier();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PalettePro (臻图坊)',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white70,
          surface: Color(0xFF1E1E1E),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Colors.white,
          inactiveTrackColor: Colors.white12,
          thumbColor: Colors.white,
          overlayColor: Colors.white10,
        ),
      ),
      home: EditorScreen(notifier: _notifier),
    );
  }
}

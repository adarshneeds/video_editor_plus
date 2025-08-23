import 'package:flutter/material.dart';
import 'package:video_editor_example/pick_video_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Editor Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        brightness: Brightness.dark,
        tabBarTheme: const TabBarThemeData(
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        dividerColor: Colors.white,
      ),
      home: const PickVideoScreen(),
    );
  }
}

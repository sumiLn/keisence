import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/title_page.dart';

void main() {
  runApp(const KeisenseApp());
}

class KeisenseApp extends StatelessWidget {
  const KeisenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ケイセンス',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.notoSansJpTextTheme(ThemeData.dark().textTheme),
      ),
      home: const TitlePage(),
    );
  }
}

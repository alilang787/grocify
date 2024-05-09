import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:grocify/widgets/gorceries_main.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 3, 21, 37),
            brightness: Brightness.dark,
            surface: const Color.fromARGB(255, 51, 63, 73),
          ),
   
        
        ),
        home: GrocriesMain(),
      ),
    );
  }
}

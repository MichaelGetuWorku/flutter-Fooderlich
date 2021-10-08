import 'package:flutter/material.dart';
import 'package:fooderlich/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'fooderlich_theme.dart';
import 'screens/home.dart';
import 'models/models.dart';

void main() {
  runApp(const Fooderlich());
}

class Fooderlich extends StatelessWidget {
  const Fooderlich({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = FooderlichTheme.light();
    return MaterialApp(
      theme: theme,
      title: 'Fooderlich',
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => TabManager(),
          ),
          ChangeNotifierProvider(
            create: (context) => GroceryManager(),
          ),
        ],
        child: const SplashScreen(),
      ),
    );
  }
}
// git push foodler
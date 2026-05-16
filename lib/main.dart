import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/app_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const AppProviders(
      child: KeepNotesApp(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'injection_container.dart';

void main() {
  configureDependencies();
  runApp(const ProviderScope(child: AtimeLogApp()));
}

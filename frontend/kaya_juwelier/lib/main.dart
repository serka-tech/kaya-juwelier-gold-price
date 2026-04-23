import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya_juwelier/app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KayaJuwelierApp(),
    ),
  );
}

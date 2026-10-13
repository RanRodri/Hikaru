import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait everywhere. The cymatic screen allows landscape while it is open.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  runApp(const ProviderScope(child: HikaruApp()));
}

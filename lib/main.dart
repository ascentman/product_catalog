import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'core/di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();
  Hive.init(dir.path);

  await initDependencies();

  runApp(const App());
}

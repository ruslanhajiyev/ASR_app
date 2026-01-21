import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/ui_config.dart';
import 'services/encryption_service.dart';
import 'services/logging_service.dart';
import 'utils/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await LoggingService().initialize();
    await EncryptionService().initialize();
  } catch (e) {
    debugPrint('Failed to initialize services: $e');
  }

  final uiConfig = await UIConfig.load();

  runApp(
    ProviderScope(
      child: MyApp(uiConfig: uiConfig),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final UIConfig uiConfig;

  const MyApp({super.key, required this.uiConfig});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ASR Data Record',
      theme: ThemeConfig.getTheme(uiConfig),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

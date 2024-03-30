import 'package:apel_detection_app/cores/routers/app_router.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser:
          AppRouter.returnRouter(false).routeInformationParser,
      routerDelegate: AppRouter.returnRouter(false).routerDelegate,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local data storage
  await Hive.initFlutter();
  
  // Open Hive boxes for guest data and preferences
  await Hive.openBox('guest_attempts_box');
  await Hive.openBox('guest_dashboard_box');
  await Hive.openBox('auth_preferences_box');
  await Hive.openBox('curriculum_cache_box');
  await Hive.openBox('auth_dashboard_box');
  await Hive.openBox('auth_attempts_box');

  await di.init();
  runApp(const LingoApp());
}

class LingoApp extends StatelessWidget {
  const LingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Lingo-Abyssinia',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


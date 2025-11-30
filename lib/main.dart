import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'router.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/supabase_config.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Create router once in initState
    // We'll set refreshListenable later when we have access to authProvider
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
            debugShowCheckedModeBanner: false,
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()..loadUser()),
            ChangeNotifierProvider(create: (_) => LocaleProvider(snapshot.data!)),
            ChangeNotifierProxyProvider<AuthProvider, DataProvider>(
              create: (_) => DataProvider()..loadInitialData(),
              update: (_, auth, data) {
                if (data != null) {
                  data.setUserId(auth.currentUser?.id);
                }
                return data!;
              },
            ),
          ],
          child: Consumer2<AuthProvider, LocaleProvider>(
            builder: (context, authProvider, localeProvider, _) {
              // Create router only once
              if (!_isRouterInitialized) {
                _router = createRouter(authProvider);
                _isRouterInitialized = true;
              }
              
              return MaterialApp.router(
                title: 'Couple Ordering App',
                theme: AppTheme.lightTheme,
                routerConfig: _router,
                debugShowCheckedModeBanner: false,
                locale: localeProvider.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'), // English
                  Locale('zh'), // Chinese
                ],
              );
            },
          ),
        );
      },
    );
  }
  
  bool _isRouterInitialized = false;
}

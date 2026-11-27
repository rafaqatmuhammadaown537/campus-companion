import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

  final authProvider = AuthProvider();
  final dataProvider = DataProvider(authProvider);

  runApp(CampusCompanionApp(
    authProvider: authProvider,
    dataProvider: dataProvider,
  ));
}

class CampusCompanionApp extends StatelessWidget {
  const CampusCompanionApp({
    super.key,
    required this.authProvider,
    required this.dataProvider,
  });

  final AuthProvider authProvider;
  final DataProvider dataProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: dataProvider),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // Restore the JWT session once at startup.
          if (auth.bootstrapping) {
            auth.restore();
          }
          return MaterialApp(
            title: 'Campus Companion',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorSchemeSeed: const Color(0xFF3F51B5),
              useMaterial3: true,
            ),
            home: auth.bootstrapping
                ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()))
                : auth.user == null
                    ? const LoginScreen()
                    : const HomeScreen(),
          );
        },
      ),
    );
  }
}

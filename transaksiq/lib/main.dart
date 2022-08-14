import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:transaksiq/common/styles.dart';
import 'package:transaksiq/ui/add_automatic_transaction_page.dart';
import 'package:transaksiq/ui/automatic_transaction_page.dart';
import 'package:transaksiq/ui/chart_page.dart';
import 'package:transaksiq/ui/edit_transaction_page.dart';
import 'package:transaksiq/ui/login_page.dart';
import 'package:transaksiq/ui/main_page.dart';
import 'package:transaksiq/ui/otp_page.dart';
import 'package:transaksiq/ui/personal_form_page.dart';
import 'package:transaksiq/ui/profile_page.dart';
import 'package:transaksiq/ui/splash_page.dart';
import 'package:transaksiq/ui/add_transaction_page.dart';
import 'package:transaksiq/utils/model/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TransaksiQ',
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id'),
      ],
      initialRoute: SplashPage.routeName,
      routes: {
        SplashPage.routeName: (context) => const SplashPage(),
        LoginPage.routeName: (context) => const LoginPage(),
        MainPage.routeName: (context) => const MainPage(),
        OTPPage.routeName: (context) => OTPPage(
              number: ModalRoute.of(context)?.settings.arguments as String,
            ),
        PersonalFormPage.routeName: (context) => const PersonalFormPage(),
        AddTransactionPage.routeName: (context) => const AddTransactionPage(),
        EditTransactionPage.routeName: (context) => EditTransactionPage(
              data: ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>,
            ),
        ProfilePage.routeName: (context) => ProfilePage(
              user: ModalRoute.of(context)?.settings.arguments as User,
            ),
        ChartPage.routeName: (context) => ChartPage(
              data: ModalRoute.of(context)?.settings.arguments
                  as List<Map<String, dynamic>>,
            ),
        AutomaticTransactionPage.routeName: (context) =>
            const AutomaticTransactionPage(),
        AddAutomaticTransactionPage.routeName: (context) =>
            const AddAutomaticTransactionPage(),
      },
    );
  }
}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transaksiq/ui/login_page.dart';
import 'package:transaksiq/ui/main_page.dart';

class SplashPage extends StatefulWidget {
  static const routeName = '/splash_page';

  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _loadUser() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(
          context, _loadUser() ? MainPage.routeName : LoginPage.routeName);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Image.asset(
          'images/ss_logo.png',
          width: MediaQuery.of(context).size.width * 0.4,
        ),
      ),
    );
  }
}

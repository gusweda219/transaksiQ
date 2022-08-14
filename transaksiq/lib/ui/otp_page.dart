import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:transaksiq/common/styles.dart';
import 'package:transaksiq/ui/personal_form_page.dart';
import 'package:transaksiq/utils/firestore_database.dart';

import 'main_page.dart';

class OTPPage extends StatefulWidget {
  static const routeName = '/otp_page';
  final String number;

  const OTPPage({Key? key, required this.number}) : super(key: key);

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  String _verificationId = '';
  String _smsOtp = '';
  bool hasErrorLen = false;
  bool hasErrorInvalid = false;
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;

  void _verifyNumber(String number) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    await _auth.verifyPhoneNumber(
      phoneNumber: number,
      timeout: Duration(seconds: 30),
      verificationCompleted: (AuthCredential authCredential) async {
        print('verificationcomplete');
        await _auth.signInWithCredential(authCredential).then((value) async {
          if (value.user != null) {
            print('user logged in');
          }
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print('verificationfailed');
        print(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        print('codesent');
        print(verificationId);
        print(resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        print("Timeout");
        print(verificationId);
      },
    );
  }

  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
    _verifyNumber(widget.number);
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/img_login.png',
                width: 140,
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                'Verifikasi Nomor Telepon',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Masukkan OTP yang telah dikirim ke nomor ${widget.number}',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 300,
                child: PinCodeTextField(
                  appContext: context,
                  keyboardType: TextInputType.number,
                  length: 6,
                  showCursor: false,
                  errorAnimationController: errorController,
                  controller: textEditingController,
                  onCompleted: (v) {
                    print("Completed");
                  },
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      _smsOtp = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  hasErrorLen
                      ? "Silakan isi semua sel dengan benar"
                      : hasErrorInvalid
                          ? "OTP tidak valid"
                          : "",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_smsOtp.length != 6) {
                      errorController!.add(ErrorAnimationType
                          .shake); // Triggering error shake animation
                      setState(() => hasErrorLen = true);
                    } else {
                      setState(() {
                        hasErrorLen = false;
                      });
                      try {
                        await FirebaseAuth.instance
                            .signInWithCredential(PhoneAuthProvider.credential(
                                verificationId: _verificationId,
                                smsCode: _smsOtp))
                            .then((value) async {
                          if (value.user != null) {
                            final snapshot = await FirestoreDatabase.getUser(
                                value.user!.uid);
                            setState(() => hasErrorInvalid = false);
                            if (snapshot.exists) {
                              Navigator.pushReplacementNamed(
                                  context, MainPage.routeName);
                            } else {
                              Navigator.pushReplacementNamed(
                                  context, PersonalFormPage.routeName);
                            }
                          }
                        });
                      } catch (e) {
                        errorController!.add(ErrorAnimationType
                            .shake); // Triggering error shake animation
                        setState(() => hasErrorInvalid = true);
                      }
                    }
                  },
                  child: Text(
                    'Verifikasi Nomor Telepon',
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

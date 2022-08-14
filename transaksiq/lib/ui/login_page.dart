import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transaksiq/common/styles.dart';
import 'package:transaksiq/ui/otp_page.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login_page';

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobilePhoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/img_login.png',
                width: 140,
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Verifikasi Nomor Telepon',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Kami akan mengirimkan OTP kepada anda di nomor telepon ini',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _mobilePhoneController,
                  keyboardType: TextInputType.number,
                  textAlignVertical: TextAlignVertical.center,
                  style: GoogleFonts.montserrat(fontSize: 16),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                          top: 8, bottom: 10, right: 6, left: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'images/flag_id.png',
                            width: 30,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '+62',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    prefixIconConstraints:
                        BoxConstraints(minWidth: 0, minHeight: 0),
                    // suffixIcon: Icon(
                    //   Icons.verified,
                    //   size: 32,
                    // ),
                  ),
                  validator: (value) {
                    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                    RegExp regExp = RegExp(patttern);
                    if (value!.isEmpty) {
                      return 'Tolong masukan nomor telepon';
                    } else if (!regExp.hasMatch(value)) {
                      return 'Tolong masukan nomor telepon yang valid';
                    }
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    final isValid = _formKey.currentState!.validate();

                    if (isValid) {
                      _formKey.currentState!.save();
                      Navigator.pushNamed(context, OTPPage.routeName,
                          arguments: '+62${_mobilePhoneController.text}');
                    }
                  },
                  child: Text(
                    'Kirim OTP',
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

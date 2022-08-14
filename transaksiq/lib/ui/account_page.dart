import 'package:transaksiq/common/styles.dart';
import 'package:transaksiq/ui/automatic_transaction_page.dart';
import 'package:transaksiq/ui/login_page.dart';
import 'package:transaksiq/ui/profile_page.dart';
import 'package:transaksiq/utils/firestore_database.dart';
import 'package:transaksiq/utils/model/user.dart' as user_model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountPage extends StatefulWidget {
  static const routeName = '/account_page';

  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late User user;

  void _loadUser() {
    var currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      user = currentUser;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Akun',
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirestoreDatabase.getUser(user.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 70,
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Center(
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(100),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: const Offset(0, 1),
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 32,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data!.data()!['name'],
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                snapshot.data!.data()!['phoneNumber'],
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6D6D6D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pushNamed(
                              context, ProfilePage.routeName,
                              arguments: user_model.User(
                                name: snapshot.data!.data()!['name'],
                                phoneNumber:
                                    snapshot.data!.data()!['phoneNumber'],
                              )).then((_) {
                            setState(() {});
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            margin: const EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAB52F),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              'Edit',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 20, bottom: 20),
                        child: Text(
                          'Lainnya',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            listSetting(
                              text: 'Pencatatan Otomatis',
                              icon: Icons.alarm_add_rounded,
                              onTap: () {
                                Navigator.pushNamed(context,
                                    AutomaticTransactionPage.routeName);
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            listSetting(
                              text: 'Bantuan',
                              icon: Icons.help_outline_rounded,
                              onTap: () {},
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            listSetting(
                              text: 'Tentang App',
                              icon: Icons.info_outline_rounded,
                              onTap: () {},
                            ),
                            listSetting(
                              text: 'Keluar',
                              icon: Icons.exit_to_app_rounded,
                              color: Colors.red,
                              onTap: () {
                                CoolAlert.show(
                                    context: context,
                                    type: CoolAlertType.confirm,
                                    confirmBtnText: 'Keluar',
                                    cancelBtnText: 'Batal',
                                    title: 'Apakah anda ingin keluar?',
                                    onConfirmBtnTap: () async {
                                      await FirebaseAuth.instance.signOut();
                                      Navigator.pushReplacementNamed(
                                          context, LoginPage.routeName);
                                    });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }

  ListTile listSetting({
    required String text,
    required IconData icon,
    required Function() onTap,
    Color color = Colors.black,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 30,
        color: color,
      ),
      title: Text(
        text,
        style: GoogleFonts.montserrat(
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
      ),
      dense: true,
      enabled: true,
      selected: false,
      onTap: onTap,
    );
  }
}

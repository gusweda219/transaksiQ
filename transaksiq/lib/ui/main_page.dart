import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transaksiq/common/styles.dart';
import 'package:transaksiq/ui/account_page.dart';
import 'package:transaksiq/ui/add_transaction_page.dart';
import 'package:transaksiq/ui/transaction_page.dart';

class MainPage extends StatefulWidget {
  static const routeName = '/main_page';

  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _bottomNavIndex = 0;

  final PageStorageBucket bucket = PageStorageBucket();
  Widget _currentScreen = const TransactionPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: bucket,
        child: _currentScreen,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, AddTransactionPage.routeName);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        child: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 10,
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MaterialButton(
                  minWidth: 40,
                  onPressed: () {
                    setState(() {
                      _currentScreen = TransactionPage();
                      _bottomNavIndex = 0;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: _bottomNavIndex == 0
                            ? primaryColor
                            : Colors.grey[400],
                      ),
                      Text(
                        'Transaksi',
                        style: GoogleFonts.montserrat(
                          color: _bottomNavIndex == 0
                              ? primaryColor
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  minWidth: 40,
                  onPressed: () {
                    setState(() {
                      _currentScreen = AccountPage();
                      _bottomNavIndex = 1;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.manage_accounts_rounded,
                        color: _bottomNavIndex == 1
                            ? primaryColor
                            : Colors.grey[400],
                      ),
                      Text(
                        'Akun',
                        style: GoogleFonts.montserrat(
                          color: _bottomNavIndex == 1
                              ? primaryColor
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      extendBody: true,
    );
  }
}

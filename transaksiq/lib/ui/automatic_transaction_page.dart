import 'package:flutter/material.dart';
import 'package:transaksiq/common/styles.dart';
import 'package:transaksiq/ui/add_automatic_transaction_page.dart';

class AutomaticTransactionPage extends StatefulWidget {
  static const routeName = '/automatic_transaction_page';
  const AutomaticTransactionPage({Key? key}) : super(key: key);

  @override
  _AutomaticTransactionPageState createState() =>
      _AutomaticTransactionPageState();
}

class _AutomaticTransactionPageState extends State<AutomaticTransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Pencatatan Otomatis'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.pushNamed(context, AddAutomaticTransactionPage.routeName);
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

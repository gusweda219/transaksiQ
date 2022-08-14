import 'package:transaksiq/common/styles.dart';
import 'package:transaksiq/utils/firestore_database.dart';
import 'package:transaksiq/utils/model/transaction.dart' as transaction_model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

class AddTransactionPage extends StatefulWidget {
  static const routeName = '/add_transaction_page';
  static const income = 'income';
  static const expense = 'expense';

  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late User user;

  final formKey = GlobalKey<FormState>();

  final TextEditingController _calcController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String type = AddTransactionPage.income;
  late DateTime _dateTime;

  bool _isCalcKeyboardVisible = true;
  bool _isInputVisible = false;
  bool _isTotalEmpty = false;

  String _expression = '';
  String _history = '';
  String _display = '';
  bool _isOperatorActive = false;

  List<String> numberFormat() {
    final regex = RegExp(r"(?<=\+|-|\*|/|=)|(?=\+|-|\*|/|=)");
    final str = _expression;
    final splitList = str.split(regex);

    var formatter = NumberFormat("#,##0", "pt_BR");

    var temp = splitList.map((element) {
      if (element != '+' &&
          element != '-' &&
          element != '*' &&
          element != '/') {
        var arr = element.split(',');

        if (arr.length < 2) {
          return formatter.format(int.parse(element)).toString();
        } else {
          return formatter.format(int.parse(arr[0])).toString() + ',' + arr[1];
        }
      } else {
        return " $element ";
      }
    }).toList();

    return temp;
  }

  void numClick(String text) {
    if (_expression.isEmpty && (text == '0' || text == '00' || text == '000')) {
      return;
    }

    if (_isOperatorActive && (text == '0' || text == '00' || text == '000')) {
      _expression += '0';
    } else {
      _expression += text;
    }

    setState(() => _display = numberFormat().join());
    _isOperatorActive = false;
    _isInputVisible = true;

    evaluate('');
  }

  void opeClick(String text) {
    if (!_isOperatorActive) {
      if (_expression.isEmpty) {
        _expression = '0';
        _expression += text;
        setState(() {
          _display += "0 $text ";
          _isInputVisible = true;
        });
        _isOperatorActive = true;
      } else {
        _expression += text;
        setState(() => _display += " $text ");
        _isOperatorActive = true;
      }
    } else {
      _expression = _expression.substring(0, _expression.length - 1);
      _display = _display.substring(0, _display.length - 2);
      _expression += text;
      setState(() => _display += "$text ");
    }
  }

  void clear(String text) {
    _expression = '';
    _isOperatorActive = false;
    _calcController.text = '';
    _calcController.selection = TextSelection.fromPosition(
        TextPosition(offset: _calcController.text.length));
    setState(() {
      _display = '';
      _isInputVisible = false;
    });
  }

  void delete(String text) {
    if (_expression.isEmpty) {
      return;
    } else {
      _expression = _expression.substring(0, _expression.length - 1);
      if (_expression.isEmpty) {
        setState(() {
          _isInputVisible = false;
        });
        _calcController.text = '';
        _calcController.selection = TextSelection.fromPosition(
            TextPosition(offset: _calcController.text.length));
      } else {
        setState(() {
          if (int.tryParse(_expression[_expression.length - 1]) != null) {
            _isOperatorActive = false;
          } else {
            _isOperatorActive = true;
          }
          _display = numberFormat().join();
        });
        evaluate('');
      }
    }
  }

  void evaluate(String text) {
    String finalUserInput = _expression;
    finalUserInput = _expression.replaceAll(',', '.');

    if (_isOperatorActive) {
      finalUserInput = finalUserInput.substring(0, finalUserInput.length - 1);
    }

    Parser p = Parser();
    Expression exp = p.parse(finalUserInput);
    ContextModel cm = ContextModel();

    var eval = exp.evaluate(EvaluationType.REAL, cm);

    if (eval == 0 ||
        eval == double.infinity ||
        (eval as double).isNaN ||
        eval < 0) {
      _calcController.text = '';
      _calcController.selection = TextSelection.fromPosition(
          TextPosition(offset: _calcController.text.length));
      _history = '';
    } else {
      var formatter = NumberFormat("#,##0", "pt_BR");
      if (eval % 1 == 0) {
        _calcController.text = formatter.format(eval).toString();
        _calcController.selection = TextSelection.fromPosition(
            TextPosition(offset: _calcController.text.length));
        _history = eval.toStringAsFixed(0);
      } else {
        var arr = eval.toStringAsFixed(2).split('.');
        _calcController.text =
            formatter.format(int.parse(arr[0])).toString() + ',' + arr[1];
        _calcController.selection = TextSelection.fromPosition(
            TextPosition(offset: _calcController.text.length));
        _history = eval.toStringAsFixed(2);
      }
    }

    // print(_history);
  }

  void done(String text) {
    FocusScope.of(context).unfocus();
    setState(() {
      _isInputVisible = false;
      _isCalcKeyboardVisible = false;
    });
  }

  void _loadUser() {
    var currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      user = currentUser;
    }
  }

  @override
  void initState() {
    _loadUser();
    _dateTime = DateTime.now();
    _dateController.text = DateFormat.yMMMMd('id').format(_dateTime);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Tambah Transaksi'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(15),
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          type = AddTransactionPage.income;
                        });
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: type == AddTransactionPage.income
                              ? incomeColor
                              : Colors.grey[300],
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10)),
                        ),
                        child: Center(
                          child: Text(
                            'Pemasukan',
                            style: GoogleFonts.montserrat(
                              color: type == AddTransactionPage.income
                                  ? Colors.white
                                  : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          type = AddTransactionPage.expense;
                        });
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: type == AddTransactionPage.expense
                              ? expenseColor
                              : Colors.grey[300],
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        child: Center(
                          child: Text(
                            'Pengeluaran',
                            style: GoogleFonts.montserrat(
                              color: type == AddTransactionPage.expense
                                  ? Colors.white
                                  : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                type == AddTransactionPage.income
                    ? 'Total Pemasukan'
                    : 'Total Pengeluaran',
                style: GoogleFonts.montserrat(
                  textStyle: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF172331),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isCalcKeyboardVisible && _isTotalEmpty
                          ? Colors.red
                          : _isCalcKeyboardVisible
                              ? Colors.blue
                              : Colors.grey,
                      width: _isCalcKeyboardVisible ? 2 : 1,
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Rp.'),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _calcController,
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            readOnly: true,
                            showCursor: true,
                            autofocus: true,
                            onTap: () {
                              if (_calcController.text.isNotEmpty) {
                                _expression = _history.replaceAll('.', ',');
                                print(_expression);
                                setState(() {
                                  _display = _expression;
                                  _isInputVisible = true;
                                  _isCalcKeyboardVisible = true;
                                });
                              } else {
                                setState(() {
                                  _expression = '';
                                  _display = '';
                                  _isCalcKeyboardVisible = true;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                        visible: _isInputVisible,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                            Text(
                              _display,
                            ),
                          ],
                        )),
                  ],
                ),
              ),
              Visibility(
                visible: _isTotalEmpty,
                child: Text(
                  type == AddTransactionPage.income
                      ? 'Total pemasukan harus lebih besar dari 0'
                      : 'Total pengeluaran harus lebih besar dari 0',
                  style: GoogleFonts.montserrat(
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                'Tanggal',
                style: GoogleFonts.montserrat(
                  textStyle: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF172331),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              TextField(
                controller: _dateController,
                onTap: () async {
                  setState(() {
                    _isCalcKeyboardVisible = false;
                    _isInputVisible = false;
                  });

                  var date = await showDatePicker(
                    context: context,
                    locale: const Locale('id'),
                    initialDate: _dateTime,
                    firstDate: DateTime(2021),
                    lastDate: DateTime(2045),
                  );

                  if (date != null) {
                    _dateTime = date;
                    _dateController.text =
                        DateFormat.yMMMMd('id').format(_dateTime);
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.calendar_today_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                readOnly: true,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Catatan',
                style: GoogleFonts.montserrat(
                  textStyle: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF172331),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _isCalcKeyboardVisible = false;
                    _isInputVisible = false;
                  });
                },
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (_calcController.text.isEmpty ||
                      _calcController.text == '0') {
                    setState(() {
                      _isCalcKeyboardVisible = true;
                      _isTotalEmpty = true;
                    });
                  } else {
                    setState(() {
                      _isCalcKeyboardVisible = false;
                      _isTotalEmpty = false;
                    });
                    try {
                      await FirestoreDatabase.addTransaction(
                        user.uid,
                        transaction_model.Transaction(
                            type: type == AddTransactionPage.income
                                ? 'Pemasukan'
                                : 'Pengeluaran',
                            total: double.parse(_history),
                            note: _noteController.text,
                            timestamp: Timestamp.fromMicrosecondsSinceEpoch(
                                _dateTime.microsecondsSinceEpoch)),
                      );
                      print('success');
                      Navigator.pop(context);
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                child: Text(
                  'Simpan',
                  style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
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
              SizedBox(
                height: _isCalcKeyboardVisible ? 300 : 0,
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            bottom: _isCalcKeyboardVisible ? 0 : -300,
            right: 0,
            left: 0,
            child: Container(
              height: 300,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                )
              ]),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        calculatorKey('C', clear),
                        calculatorKey('/', opeClick),
                        calculatorKey('*', opeClick),
                        calculatorKey('DEL', delete),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        calculatorKey('7', numClick),
                        calculatorKey('8', numClick),
                        calculatorKey('9', numClick),
                        calculatorKey('-', opeClick),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        calculatorKey('4', numClick),
                        calculatorKey('5', numClick),
                        calculatorKey('6', numClick),
                        calculatorKey('+', opeClick),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        calculatorKey('1', numClick),
                        calculatorKey('2', numClick),
                        calculatorKey('3', numClick),
                        calculatorKey(',', opeClick),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        calculatorKey('0', numClick),
                        calculatorKey('00', numClick),
                        calculatorKey('000', numClick),
                        calculatorKey('DONE', done),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _calcController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

Widget calculatorKey(String key, Function onTap) {
  return Expanded(
    child: Material(
      child: InkWell(
        enableFeedback: false,
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: key == 'DONE' ? primaryColor : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
              child: Text(
            key,
            style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: key == 'DONE' ? Colors.white : Colors.black),
          )),
        ),
        onTap: () {
          onTap(key);
        },
      ),
    ),
  );
}

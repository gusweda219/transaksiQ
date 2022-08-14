import 'dart:io';
import 'package:transaksiq/common/styles.dart';
import 'package:transaksiq/ui/chart_page.dart';
import 'package:transaksiq/ui/edit_transaction_page.dart';
import 'package:transaksiq/utils/firestore_database.dart';
import 'package:transaksiq/utils/model/transaction.dart' as ts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late User user;

  late List<QueryDocumentSnapshot<Map<String, dynamic>>> dataTransactions;

  void _loadUser() {
    var currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      user = currentUser;
    }
  }

  String _formatNumber(double number) {
    var formatter = NumberFormat("#,##0", "pt_BR");

    if (number % 1 == 0) {
      return formatter.format(number);
    } else {
      var arr = number.toStringAsFixed(2).split('.');
      return formatter.format(int.parse(arr[0])).toString() + ',' + arr[1];
    }
  }

  bool _isProfitOrLoss(double income, double expense) {
    if (income >= expense) {
      return true;
    } else {
      return false;
    }
  }

  List<Map<String, dynamic>> _groupTransactionByDate(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> data) {
    var value = data
        .fold(<String, List<dynamic>>{}, (Map<String, List<dynamic>> a, b) {
          a
              .putIfAbsent(
                  DateFormat.yMMMMd('id').format(DateTime.parse(
                      (b['timeStamp'] as Timestamp).toDate().toString())),
                  () => [])
              .add(b);
          return a;
        })
        .values
        .where((l) => (l).isNotEmpty)
        .map((l) => {
              'timeStamp': l.first['timeStamp'],
              'data': l
                  .map((e) => {
                        'id': e.id,
                        'type': e['type'],
                        'total': e['total'],
                        'note': e['note'],
                        'timeStamp': e['timeStamp'],
                      })
                  .toList()
            })
        .toList();
    return value;
  }

  Future<void> _createExcel() async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    sheet.enableSheetCalculations();

    sheet.getRangeByName('A1').columnWidth = 4.82;
    sheet.getRangeByName('B1:E1').columnWidth = 13.82;

    sheet.getRangeByName('B4:D5').merge();

    sheet.getRangeByName('B4').setText('Laporan Transaksi');
    sheet.getRangeByName('B4').cellStyle.fontSize = 20;

    var endDate = DateFormat.yMMMMd('id').format(DateTime.parse(
        dataTransactions.first.data()['timeStamp'].toDate().toString()));

    var startDate = DateFormat.yMMMMd('id').format(DateTime.parse(
        dataTransactions.last.data()['timeStamp'].toDate().toString()));

    sheet.getRangeByName('C9:D9').merge();
    sheet.getRangeByName('C9').setText('$startDate - $endDate');
    sheet.getRangeByName('C9').cellStyle.fontSize = 9;

    sheet.getRangeByName('B9').setText('Tanggal Laporan');
    sheet.getRangeByName('B9').cellStyle.fontSize = 9;

    sheet.getRangeByName('B10').setText('Pemasukan');
    sheet.getRangeByName('B10').cellStyle.fontSize = 9;

    sheet.getRangeByName('B11').setText('Pengeluaran');
    sheet.getRangeByName('B11').cellStyle.fontSize = 9;

    sheet.getRangeByName('B12').setText('9365550136');
    sheet.getRangeByName('B12').cellStyle.fontSize = 9;

    sheet.getRangeByIndex(15, 2).setText('Tanggal');
    sheet.getRangeByIndex(15, 3).setText('Catatan');
    sheet.getRangeByIndex(15, 4).setText('Pemasukan');
    sheet.getRangeByIndex(15, 5).setText('Pengeluaran');

    for (var i = 0; i < dataTransactions.length; i++) {
      sheet.getRangeByIndex(i + 16, 2).setText(DateFormat.yMMMMd('id').format(
          DateTime.parse((dataTransactions[i].data()['timeStamp'] as Timestamp)
              .toDate()
              .toString())));
      sheet
          .getRangeByIndex(i + 16, 3)
          .setText(dataTransactions[i].data()['note']);
      if (dataTransactions[i].data()['type'] == 'Pemasukan') {
        sheet
            .getRangeByIndex(i + 16, 4)
            .setNumber(dataTransactions[i].data()['total']);
        sheet.getRangeByIndex(i + 16, 4).cellStyle.hAlign =
            xlsio.HAlignType.left;
      } else {
        sheet
            .getRangeByIndex(i + 16, 5)
            .setNumber(dataTransactions[i].data()['total']);
        sheet.getRangeByIndex(i + 16, 5).cellStyle.hAlign =
            xlsio.HAlignType.left;
      }
    }

    // sheet.getRangeByIndex(15, 3, 15, 4).merge();
    // sheet.getRangeByIndex(16, 3, 16, 4).merge();
    // sheet.getRangeByIndex(17, 3, 17, 4).merge();
    // sheet.getRangeByIndex(18, 3, 18, 4).merge();
    // sheet.getRangeByIndex(19, 3, 19, 4).merge();
    // sheet.getRangeByIndex(20, 3, 20, 4).merge();

    // sheet.getRangeByIndex(15, 7).setText('Total');
    // sheet.getRangeByIndex(16, 7).setFormula('=E16*F16+(E16*F16)');
    // sheet.getRangeByIndex(17, 7).setFormula('=E17*F17+(E17*F17)');
    // sheet.getRangeByIndex(18, 7).setFormula('=E18*F18+(E18*F18)');
    // sheet.getRangeByIndex(19, 7).setFormula('=E19*F19+(E19*F19)');
    // sheet.getRangeByIndex(20, 7).setFormula('=E20*F20+(E20*F20)');
    // sheet.getRangeByIndex(15, 6, 20, 7).numberFormat = r'$#,##0.00';

    // sheet.getRangeByName('E15:G15').cellStyle.hAlign = xlsio.HAlignType.right;
    // sheet.getRangeByName('B15:G15').cellStyle.fontSize = 10;
    // sheet.getRangeByName('B15:G15').cellStyle.bold = true;
    // sheet.getRangeByName('B16:G20').cellStyle.fontSize = 9;

    // sheet.getRangeByName('E22:G22').merge();
    // sheet.getRangeByName('E22:G22').cellStyle.hAlign = xlsio.HAlignType.right;
    // sheet.getRangeByName('E23:G24').merge();

    // final xlsio.Range range7 = sheet.getRangeByName('E22');
    // final xlsio.Range range8 = sheet.getRangeByName('E23');
    // range7.setText('TOTAL');
    // range7.cellStyle.fontSize = 8;
    // range8.setFormula('=SUM(G16:G20)');
    // range8.numberFormat = r'$#,##0.00';
    // range8.cellStyle.fontSize = 24;
    // range8.cellStyle.hAlign = xlsio.HAlignType.right;
    // range8.cellStyle.bold = true;

    // sheet.getRangeByIndex(26, 1).text =
    //     '800 Interchange Blvd, Suite 2501, Austin, TX 78721 | support@adventure-works.com';
    // sheet.getRangeByIndex(26, 1).cellStyle.fontSize = 8;

    // final xlsio.Range range9 = sheet.getRangeByName('A26:H27');
    // range9.cellStyle.backColor = '#ACB9CA';
    // range9.merge();
    // range9.cellStyle.hAlign = xlsio.HAlignType.center;
    // range9.cellStyle.vAlign = xlsio.VAlignType.center;
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName =
        '$path/Laporan Laba Rugi_${DateFormat.yMMMMd('id').format(DateTime.now())}.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }

  Future<void> _createPDF() async {
    PdfDocument document = PdfDocument();

    final PdfPage page = document.pages.add();
    final PdfGrid grid = getGrid();

    page.graphics.drawString(
        'Laporan Transaksi', PdfStandardFont(PdfFontFamily.helvetica, 16));

    var endDate = DateFormat.yMMMMd('id').format(DateTime.parse(
        dataTransactions.first.data()['timeStamp'].toDate().toString()));

    var startDate = DateFormat.yMMMMd('id').format(DateTime.parse(
        dataTransactions.last.data()['timeStamp'].toDate().toString()));

    page.graphics.drawString(
        'Tanggal laporan', PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(0, 30, 0, 0));

    page.graphics.drawString(
        ': $startDate - $endDate', PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(100, 30, 0, 0));

    page.graphics.drawString(
        'Pemasukan', PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(0, 45, 0, 0));

    page.graphics.drawString(': Rp. ${_formatNumber(getTotalIncome(grid))}',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(100, 45, 0, 0));

    page.graphics.drawString(
        'Pengeluaran', PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(0, 60, 0, 0));

    page.graphics.drawString(': Rp. ${_formatNumber(getTotalExpense(grid))}',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(100, 60, 0, 0));

    page.graphics.drawString(
        getTotalIncome(grid) - getTotalExpense(grid) >= 0
            ? 'Keuntungan'
            : 'Pengeluaran',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(0, 75, 0, 0));

    page.graphics.drawString(
        ': Rp. ${_formatNumber((getTotalIncome(grid) - getTotalExpense(grid).abs()))}',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(100, 75, 0, 0));

    // final PdfLayoutResult result = drawHeader(page, pageSize, grid);
    grid.draw(page: page, bounds: Rect.fromLTWH(0, 105, 0, 0));

    List<int> bytes = document.save();
    document.dispose();

    final path = (await getApplicationDocumentsDirectory()).path;
    final String fileName =
        '$path/Laporan Laba Rugi_${DateFormat.yMMMMd('id').format(DateTime.now())}';
    final file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }

  //Create PDF grid and return
  PdfGrid getGrid() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 4);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'Tanggal';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Catatan';
    headerRow.cells[2].value = 'Pemasukan';
    headerRow.cells[3].value = 'Pengeluaran';
    //Add rows
    addTransaction(grid);
    //Apply the table built-in style
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    //Set gird columns width
    grid.columns[1].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

  //Create and row for the grid.
  void addTransaction(PdfGrid grid) {
    for (var element in dataTransactions) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = DateFormat.yMMMMd('id').format(DateTime.parse(
          (element.data()['timeStamp'] as Timestamp).toDate().toString()));
      row.cells[1].value =
          element.data()['note'].trim().isEmpty ? '-' : element.data()['note'];
      if (element.data()['type'] == 'Pemasukan') {
        row.cells[2].value = 'Rp.${_formatNumber(element.data()['total'])}';
        row.cells[3].value = 'Rp.-';
      } else {
        row.cells[2].value = 'Rp.-';
        row.cells[3].value = 'Rp.${_formatNumber(element.data()['total'])}';
      }
    }
  }

  double getTotalIncome(PdfGrid grid) {
    double total = 0;
    for (int i = 0; i < grid.rows.count; i++) {
      String value =
          (grid.rows[i].cells[2].value as String).replaceAll('Rp.', '');
      if (value != '-') {
        total += double.parse(value.replaceAll('.', ''));
      }
    }
    return total;
  }

  double getTotalExpense(PdfGrid grid) {
    double total = 0;
    for (int i = 0; i < grid.rows.count; i++) {
      String value =
          (grid.rows[i].cells[3].value as String).replaceAll('Rp.', '');
      if (value != '-') {
        total += double.parse(value.replaceAll('.', ''));
      }
    }
    return total;
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
        title: Text(
          'Transaksi',
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreDatabase.getDataTransactions(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('data kosong'),
            );
          } else {
            dataTransactions = snapshot.data!.docs;

            double income = 0;
            double expense = 0;

            for (var item in snapshot.data!.docs) {
              if (item['type'] == 'Pemasukan') {
                income += item['total'];
              } else {
                expense += item['total'];
              }
            }

            final value = _groupTransactionByDate(snapshot.data!.docs);

            print(value);

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
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
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              padding: const EdgeInsets.only(top: 10),
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                  )
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Pemasukan',
                                            style: styleLabelTransaction,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Pengeluaran',
                                            style: styleLabelTransaction,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Rp. ${_formatNumber(income)}',
                                            style:
                                                styleValueTransaction.copyWith(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Rp. ${_formatNumber(expense)}',
                                            style:
                                                styleValueTransaction.copyWith(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: _isProfitOrLoss(income, expense)
                                          ? incomeColor
                                          : expenseColor,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _isProfitOrLoss(income, expense)
                                                ? 'Keuntungan'
                                                : 'Kerugian',
                                            style:
                                                styleLabelTransaction.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            _isProfitOrLoss(income, expense)
                                                ? 'Rp. ${_formatNumber(income - expense)}'
                                                : 'Rp. ${_formatNumber(expense - income)}',
                                            style:
                                                styleValueTransaction.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, ChartPage.routeName,
                                  arguments: value);
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.bar_chart_rounded),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Lihat Diagram',
                                  style: GoogleFonts.montserrat(),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showMaterialModalBottomSheet(
                                  context: context,
                                  builder: (context) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          const SizedBox(
                                            height: 12,
                                          ),
                                          Text(
                                            'Pilih format laporan',
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          ),
                                          ListTile(
                                              title: Text('PDF'),
                                              leading: Image.asset(
                                                'images/pdf.png',
                                                width: 24,
                                              ),
                                              onTap: () => _createPDF()),
                                          ListTile(
                                            title: Text('Excel'),
                                            leading: Image.asset(
                                              'images/xls.png',
                                              width: 24,
                                            ),
                                            onTap: () => _createExcel(),
                                          ),
                                        ],
                                      ));
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.download_rounded),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Unduh Laporan',
                                  style: GoogleFonts.montserrat(),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: value.length,
                        itemBuilder: (contex, index) {
                          double incomeDate = 0;
                          double expenseDate = 0;

                          for (Map<String, dynamic> item in value[index]
                              ['data']) {
                            if (item['type'] == 'Pemasukan') {
                              incomeDate += item['total'];
                            } else {
                              expenseDate += item['total'];
                            }
                          }

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  color: Colors.grey[300],
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormat.yMMMMd('id').format(
                                          DateTime.parse((value[index]
                                                  ['timeStamp'] as Timestamp)
                                              .toDate()
                                              .toString()))),
                                      Text(
                                        _isProfitOrLoss(incomeDate, expenseDate)
                                            ? 'Keuntungan Rp. ${_formatNumber(incomeDate - expenseDate)}'
                                            : 'Kerugian Rp. ${_formatNumber(expenseDate - incomeDate)}',
                                        style: TextStyle(
                                          color: _isProfitOrLoss(
                                                  incomeDate, expenseDate)
                                              ? Colors.green[700]
                                              : Colors.red,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Row(
                                    children: const [
                                      Expanded(flex: 4, child: Text('Catatan')),
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                            'Pemasukan',
                                            textAlign: TextAlign.end,
                                          )),
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                            'Pengeluaran',
                                            textAlign: TextAlign.end,
                                          )),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  color: Colors.black,
                                  indent: 15,
                                  endIndent: 15,
                                  thickness: 1,
                                ),
                                ListView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  children:
                                      value[index]['data'].map<Widget>((e) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            EditTransactionPage.routeName,
                                            arguments: {
                                              'typeForm': e['type'] ==
                                                      'Pemasukan'
                                                  ? EditTransactionPage.income
                                                  : EditTransactionPage.expense,
                                              'userId': user.uid,
                                              'transaction': ts.Transaction(
                                                id: e['id'],
                                                type: e['type'],
                                                total: e['total'],
                                                note: e['note'],
                                                timestamp: e['timeStamp'],
                                              )
                                            });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 4,
                                                child: Text(
                                                    (e['note'] as String)
                                                            .trim()
                                                            .isNotEmpty
                                                        ? e['note'].toString()
                                                        : '-')),
                                            Expanded(
                                                flex: 3,
                                                child: Text(
                                                  e['type'] == 'Pemasukan'
                                                      ? _formatNumber(
                                                          e['total'])
                                                      : '-',
                                                  style: GoogleFonts.montserrat(
                                                    color: Colors.green[700],
                                                  ),
                                                  textAlign: TextAlign.end,
                                                )),
                                            Expanded(
                                                flex: 3,
                                                child: Text(
                                                  e['type'] == 'Pengeluaran'
                                                      ? _formatNumber(
                                                          e['total'])
                                                      : '-',
                                                  style: GoogleFonts.montserrat(
                                                    color: Colors.red,
                                                  ),
                                                  textAlign: TextAlign.end,
                                                )),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              ],
                            ),
                          );
                        }),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

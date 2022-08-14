import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:transaksiq/common/styles.dart';
import 'package:intl/intl.dart';

class ChartPage extends StatefulWidget {
  static const routeName = '/chart_page';
  final List<Map<String, dynamic>> data;
  const ChartPage({Key? key, required this.data}) : super(key: key);

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;

  List<_ChartData> toData(List<Map<String, dynamic>> list) {
    List<_ChartData> listData = [];

    for (var i in list.reversed) {
      var income = 0.0;
      var expense = 0.0;
      for (var j in i['data']) {
        if (j['type'] == 'Pemasukan') {
          income += j['total'];
        } else {
          expense += j['total'];
        }
      }
      listData.add(_ChartData(
          DateFormat.yMd('id').format(DateTime.parse(
              (i['timeStamp'] as Timestamp).toDate().toString())),
          income,
          expense));
    }

    return listData;
  }

  @override
  void initState() {
    data = toData(widget.data);
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text('Diagram Transaksi'),
          centerTitle: true,
        ),
        body: SfCartesianChart(
            legend: Legend(isVisible: true),
            zoomPanBehavior: ZoomPanBehavior(
              zoomMode: ZoomMode.x,
              enablePanning: true,
              enableDoubleTapZooming: true,
              enableMouseWheelZooming: true,
            ),
            primaryXAxis: CategoryAxis(
              visibleMaximum: 3,
              interval: 1,
            ),
            tooltipBehavior: _tooltip,
            series: <CartesianSeries>[
              ColumnSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (_ChartData data, _) => data.x,
                  yValueMapper: (_ChartData data, _) => data.y1,
                  name: 'Pemasukan',
                  color: incomeColor),
              ColumnSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (_ChartData data, _) => data.x,
                  yValueMapper: (_ChartData data, _) => data.y2,
                  name: 'Pengeluaran',
                  color: expenseColor),
            ]));
  }
}

class _ChartData {
  _ChartData(this.x, this.y1, this.y2);

  final String x;
  final double y1;
  final double y2;
}

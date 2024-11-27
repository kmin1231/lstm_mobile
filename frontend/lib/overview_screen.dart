import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'constants.dart';

class RecentData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<FlSpot> actualData = [];
  List<FlSpot> predictionData = [];
  List<FlSpot> differenceData = [];

  final double marginRate = 0.03;

  Future<void> fetchData(String ticker) async {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(Duration(days: 60));
    // DateTime startDate = DateTime(2024, 1, 1);

    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    QuerySnapshot querySnapshot = await _firestore
        .collection('predictions')
        .where('date', isGreaterThanOrEqualTo: formattedStartDate)
        .where('date', isLessThanOrEqualTo: formattedEndDate)
        .where('ticker', isEqualTo: ticker)
        .orderBy('date')
        .get();

    // checks whether the query works well
    // querySnapshot.docs.forEach((doc) {
    //   print(doc.data());
    // });

    actualData.clear();
    predictionData.clear();
    differenceData.clear();

    for (var doc in querySnapshot.docs) {
      DateTime date = DateTime.parse(doc.id.split('_')[0]);
      double actual = doc['actual'].toDouble() ?? 0.0;
      double prediction = doc['prediction'].toDouble() ?? 0.0;
      double difference = doc['difference'].toDouble() ?? 0.0;

      actualData.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), actual));
      predictionData
          .add(FlSpot(date.millisecondsSinceEpoch.toDouble(), prediction));
      differenceData
          .add(FlSpot(date.millisecondsSinceEpoch.toDouble(), difference));
    }
  }

  double calcAvgActual() {
  double sum = 0.0;
    for (var spot in actualData) {
      sum += spot.y;
    }
    return actualData.isNotEmpty ? sum / actualData.length : 0.0;
  }

  double calcAvgDifference() {
    double sum = 0.0;
    for (var spot in differenceData) {
      sum += spot.y;
    }
    return differenceData.isNotEmpty ? sum / differenceData.length : 0.0;
  }

  double calcAvgPrediction() {
    double sum = 0.0;
    for (var spot in predictionData) {
      sum += spot.y;
    }
    return predictionData.isNotEmpty ? sum / predictionData.length : 0.0;
  }

  double calcAccuracy() {
    double avgActual = calcAvgActual();
    double margin = avgActual * marginRate;

    int countWithinMargin = 0;
    for (var spot in differenceData) {
      if (spot.y.abs() <= margin) {
        countWithinMargin++;
      }
    }

    double accuracy = (countWithinMargin / differenceData.length) * 100;
    return accuracy;
  }

  double calcMargin() {
    return calcAvgActual() * marginRate;
  }

  String formattedMargin() {
    int marginValue = calcMargin().round();
    return NumberFormat("#,###").format(marginValue);
  }

  double getLastActualValue() {
    return actualData.isNotEmpty ? actualData.last.y : 0.0;
  }

  String getLastActualDate() {
    return actualData.isNotEmpty
        ? DateFormat('yyyy-MM-dd').format(
            DateTime.fromMillisecondsSinceEpoch(actualData.last.x.toInt()))
        : '';
  }
}

class GraphWidget extends StatefulWidget {
  final String ticker;

  const GraphWidget({Key? key, required this.ticker}) : super(key: key);

  @override
  _GraphWidgetState createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  late RecentData recentData;

  final formatter = NumberFormat("#,###");

  @override
  void initState() {
    super.initState();
    recentData = RecentData();
    recentData.fetchData(widget.ticker).then((_) {
      setState(() {
        recentData.actualData = recentData.actualData.reversed.toList();
        recentData.predictionData = recentData.predictionData.reversed.toList();
      });
    });
  }

  double _calcMaxY() {
    double maxActual = recentData.actualData.map((spot) => spot.y).reduce(math.max);
    double maxPrediction = recentData.predictionData.map((spot) => spot.y).reduce(math.max);
    double overallMax = math.max(maxActual, maxPrediction);
    return overallMax * 1.05;
  }

  double _calcMinY() {
    double minActual = recentData.actualData.map((spot) => spot.y).reduce(math.min);
    double minPrediction = recentData.predictionData.map((spot) => spot.y).reduce(math.min);
    double overallMin = math.min(minActual, minPrediction);
    return overallMin * 0.96;
  }

  @override
  Widget build(BuildContext context) {
    const Color actualColor = Color(0xFFff0c8f3);
    const Color predictionColor = Color(0xFFbdd9ee);

    return recentData.actualData.isEmpty
        ? Center(child: CircularProgressIndicator(
          color: progressColor,
        ))
        : Padding(
            padding: const EdgeInsets.all(7.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 10, height: 10, color: actualColor),
                      SizedBox(width: 8),
                      Text('Actual', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 30),
                      Container(width: 10, height: 10, color: predictionColor),
                      SizedBox(width: 8),
                      Text('Prediction', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),

                Expanded(
                  child: LineChart(
                    LineChartData(
                      backgroundColor: Color(0xFF32343A),
                      gridData: FlGridData(show: true),
                      maxY: _calcMaxY(),
                      minY: _calcMinY(),
                      titlesData: FlTitlesData(

                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 20,
                          ),
                        ),

                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 10
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 0
                          ),
                        ),

                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: null,
                            getTitlesWidget: (value, meta) {
                              DateTime date =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      value.toInt());
                              return Text(
                                DateFormat('M/d').format(date),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,

                        border: Border.all(
                          color: const Color(0xff37434d),
                          width: 2,
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: recentData.actualData,
                          isCurved: true,
                          color: actualColor,
                          belowBarData: BarAreaData(show: false),
                        ),
                        LineChartBarData(
                          spots: recentData.predictionData,
                          isCurved: true,
                          color: predictionColor,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final flSpot = barSpot;
                              final isActual = barSpot.barIndex == 0;
                              return LineTooltipItem(
                                '${formatter.format(flSpot.y)}',
                                TextStyle(
                                  color: isActual ? actualColor : predictionColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                      ),
                    ),
                  ),
                ),


              ],
            ),
          );
  }
}

class TableWidget extends StatelessWidget {
  final String ticker;

  TableWidget({Key? key, required this.ticker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RecentData recentData = RecentData();
    final formatter = NumberFormat("#,###");

    return FutureBuilder<void>(
      future: recentData.fetchData(ticker),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(
            color: progressColor,
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return SingleChildScrollView(
            // scrollDirection: Axis.vertical,
            child: DataTable(
              headingTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              columnSpacing: 40,
              columns: const [
                DataColumn(label: Center(child: Text('Date'))),
                DataColumn(label: Center(child: Text('Actual'))),
                DataColumn(label: Center(child: Text('Pred.'))),
                DataColumn(label: Center(child: Text('Diff.'))),
              ],

              rows: List<DataRow>.generate(
                recentData.actualData.length,
                (index) {
                  DateTime date = DateTime.fromMillisecondsSinceEpoch(
                      recentData.actualData[index].x.toInt());
                  return DataRow(cells: [
                    DataCell(Text(DateFormat('yyyy-MM-dd').format(date),
                        style: TextStyle(color: Colors.white, fontSize: 12))),
                    DataCell(
                      Text(
                        formatter.format(recentData.actualData[index].y),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    DataCell(
                      Text(
                        formatter.format(recentData.predictionData[index].y),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    DataCell(
                      Text(
                        formatter.format(recentData.differenceData[index].y),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ]);
                },
              ),
            ),
          );
        }
      },
    );
  }
}

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime? selectedDate;
  List<DocumentSnapshot> fetchedData = [];

  Future<void> requestData(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      print('Requesting data for date: $formattedDate');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('predictions')
          .where('date', isEqualTo: formattedDate)
          .get();

      setState(() {
        fetchedData = querySnapshot.docs.toSet().toList();
      });

      print('Fetched data count: ${fetchedData.length}');
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
      requestData(selectedDate!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: basicColor,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 5),
            if (selectedDate != null)
              Text(
                'Select Date',
                // 'Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                style:
                TextStyle(fontSize: 18, color: calendarTextColor),
              ),
            SizedBox(height: 20),
            Container(
              height: 260,
              width: 320,
              decoration: BoxDecoration(
                color: calendarBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CalendarDatePicker(
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2101),
                onDateChanged: (date) {
                  _selectDate(date);
                },
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            SizedBox(height: 20),
            Expanded(
              child: fetchedData.isEmpty
                  ? Center(
                  child: Text('No Data Available',
                      style: TextStyle(color: calendarTextColor)))
                  : ListView.builder(
                itemCount: 1,
                // itemCount: fetchedData.length,
                itemBuilder: (context, index) {
                  final data = fetchedData[index];

                  return ListTile(
                      title: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('${data['date']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: resultTextColor,
                                    fontSize: 21)),
                            SizedBox(height: 8),
                            Container(
                              width: 180,
                              child: Divider(),
                            ),
                            Column(
                              children: [
                                SizedBox(height: 5),
                                Text(
                                    'Actual: ${NumberFormat('#,##0').format(data['actual'])}',
                                    style: TextStyle(
                                        color: resultTextColor,
                                        fontSize: 19)),
                                SizedBox(height: 10),
                                Text(
                                    'Prediction: ${NumberFormat('#,##0').format(data['prediction'])}',
                                    style: TextStyle(
                                        color: resultTextColor,
                                        fontSize: 19)),
                                SizedBox(height: 10),
                                Text(
                                    'Difference: ${NumberFormat('#,##0').format(data['difference'])}',
                                    style: TextStyle(
                                        color: resultTextColor,
                                        fontSize: 19)),
                              ],
                            ),
                          ]));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class StatsWidget extends StatelessWidget {
  final double accuracy;
  final double errorMargin;
  final String startDate;
  final String endDate;
  final double actualAverage;
  final double differenceAverage;
  final double predictionAverage;
  final double lastActualValue;
  final String lastActualDate;

  StatsWidget({
    required this.accuracy,
    required this.errorMargin,
    required this.startDate,
    required this.endDate,
    required this.actualAverage,
    required this.differenceAverage,
    required this.predictionAverage,
    required this.lastActualValue,
    required this.lastActualDate,
  });

  String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  String formatAvg(double value) {
    int roundedValue = (value - 2).round();
    return NumberFormat('#,###').format(roundedValue);
  }

  String formatInt(double value) {
    return NumberFormat('#,###').format(value.round());
  }

  @override
  Widget build(BuildContext context) {
    const double statSpacing = 18.0;

    return Center(
      child: Container(
        width: 325,
        height: 450,
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 28.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistical Info',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: infoTextColor
              ),
            ),
            SizedBox(height: 4),

            Text(
              '($startDate ~ $endDate)',
              style: statNumStyle.copyWith(color: dateColor, fontStyle: FontStyle.italic,)
            ),
            SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Accuracy', style: statItemStyle),
                Text(
                  '${accuracy.toStringAsFixed(2)}%',
                  style: statNumStyle,
                ),
              ],
            ),
            SizedBox(height: statSpacing),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Error Margin', style: statItemStyle),
                Text(
                  '${formatInt(errorMargin)}',
                  style: statNumStyle,
                ),
              ],
            ),
            SizedBox(height: statSpacing),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Last Actual', style: statItemStyle),
                Text(
                  '${formatInt(lastActualValue)}',
                  style: statNumStyle,
                ),
              ],
            ),
            SizedBox(height: statSpacing),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Avg. Actual', style: statItemStyle),
                Text(
                  '${formatInt(actualAverage)}',
                  style: statNumStyle,
                ),
              ],
            ),
            SizedBox(height: statSpacing),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Avg. Prediction', style: statItemStyle),
                Text(
                  '${formatAvg(predictionAverage)}',
                  style: statNumStyle,
                ),
              ],
            ),
            SizedBox(height: statSpacing),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Avg. Difference', style: statItemStyle),
                Text(
                  '${formatAvg(differenceAverage)}',
                  style: statNumStyle,
                ),
              ],
            ),
            SizedBox(height: statSpacing),

          ],
        ),
      ),
    );
  }
}
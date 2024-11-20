import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class RecentData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<FlSpot> actualData = [];
  List<FlSpot> predictionData = [];
  List<FlSpot> differenceData = [];

  Future<void> fetchData(String ticker) async {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(Duration(days: 60));
    // DateTime startDate = DateTime(2024, 1, 1);

    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    QuerySnapshot querySnapshot = await _firestore
        .collection('ticker_test')
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
    // recentData.fetchData();
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
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(7.0),
            child: Column(
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 8.0),
                //   child: Text(
                //     'Actual vs. Predicted',
                //     style: TextStyle(
                //       fontWeight: FontWeight.bold,
                //       color: Colors.white,
                //       fontSize: 15),
                //   ),
                // ),

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
                            // interval: null,
                            // getTitlesWidget: (value, meta) {
                            //   return Text(
                            //     formatter.format(value.toInt()),
                            //     style: TextStyle(
                            //         color: Colors.white, fontSize: 10),
                            //   );
                            // },
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

                          // axisNameWidget: const Text(
                          //   'Date',
                          //   style: TextStyle(
                          //       fontWeight: FontWeight.bold, color: Colors.white),
                          // ),

                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,

                        border: Border.all(
                          color: const Color(0xff37434d),
                          width: 2,
                        ),
                        // border: Border(
                        //   right:
                        //       BorderSide(color: Colors.transparent, width: 20),
                        // ),
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
          return Center(child: CircularProgressIndicator());
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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

    // check whether the query works well
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
                Text(
                  'Actual vs. Predicted',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24),
                ),
                // SizedBox(height: 5),
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(right: 4.0, top: 10.0), // right margin
                        child: LineChart(
                          LineChartData(
                            backgroundColor: Color(0xFF32343A),
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(reservedSize: 0),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(reservedSize: 0),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    DateTime date =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt());
                                    return Text(
                                      DateFormat('MM/dd').format(date),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    );
                                  },
                                ),
                                axisNameWidget: const Text(
                                  'Date',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                right: BorderSide(
                                    color: Colors.transparent, width: 20),
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
                          ),
                        ),
                      ),
                      Positioned(
                        top: 22, right: 20,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                      width: 10,
                                      height: 10,
                                      color: actualColor),
                                  SizedBox(width: 6),
                                  Text('Actual',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Container(
                                      width: 10,
                                      height: 10,
                                      color: predictionColor),
                                  SizedBox(width: 6),
                                  Text(
                                    'Prediction',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
              columns: const [
                DataColumn(
                    label: Text('Date', style: TextStyle(color: Colors.white))),
                DataColumn(
                    label:
                        Text('Actual', style: TextStyle(color: Colors.white))),
                DataColumn(
                    label: Text('Pred.',
                        style: TextStyle(color: Colors.white))),
                DataColumn(
                    label: Text('Diff.',
                        style: TextStyle(color: Colors.white))),
              ],
              rows: List<DataRow>.generate(
                recentData.actualData.length,
                (index) {
                  DateTime date = DateTime.fromMillisecondsSinceEpoch(
                      recentData.actualData[index].x.toInt());
                  return DataRow(cells: [
                    DataCell(Text(DateFormat('yyyy-MM-dd').format(date),
                        style: TextStyle(color: Colors.white))),
                    DataCell(
                      Text(
                        formatter.format(recentData.actualData[index].y),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      Text(
                        formatter.format(recentData.predictionData[index].y),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      Text(
                        formatter.format(recentData.differenceData[index].y),
                        style: TextStyle(color: Colors.white),
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

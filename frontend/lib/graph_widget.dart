import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class GraphWidget extends StatefulWidget {
  const GraphWidget({Key? key}) : super(key: key);

  @override
  _GraphWidgetState createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<FlSpot> actualData = [];
  List<FlSpot> predictionData = [];
  List<FlSpot> differenceData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(Duration(days: 30));
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    QuerySnapshot querySnapshot = await _firestore
        .collection('005930_prediction')
        .where('date', isGreaterThanOrEqualTo: formattedStartDate)
        .where('date', isLessThanOrEqualTo: formattedEndDate)
        .get();

    for (var doc in querySnapshot.docs) {
      DateTime date = DateTime.parse(doc.id);
      double actual = doc['actual'].toDouble();
      double prediction = doc['prediction'].toDouble();

      actualData.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), actual));
      predictionData.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), prediction));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return actualData.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return Text(DateFormat('MM/dd').format(date));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black, width: 1),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: actualData,
                  isCurved: true,
                  color: Colors.blue,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: predictionData,
                  isCurved: true,
                  color: Colors.red,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            )),
          );
  }
}
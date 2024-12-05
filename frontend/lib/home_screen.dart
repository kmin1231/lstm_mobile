import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import 'overview_screen.dart';
import 'news_crawler.dart';
import 'info_screen.dart';
import 'constants.dart';

class HomeScreen extends StatefulWidget {
  final String stockTicker;

  HomeScreen({required this.stockTicker});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: basicColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
            // Navigator.pop(context);
          },
        ),
        title: Text(
          appName,
          style: appNameStyle,
        ),

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 6.0),  // position
            child: PopupMenuButton<String>(
              color: menuButtonColor,
              icon: Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                switch (value) {
                  case 'appinfo':
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AppInfoDialog();
                      },
                    );
                    // Navigator.pushNamed(context, '/geninfo');
                    break;
                  case 'devinfo':
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const DevInfoDialog();
                      },
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'appinfo',
                  child: Row(
                    children: [
                      Icon(Icons.info),
                      SizedBox(width: 7),
                      Text('App Info', style: infoMenuStyle),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'devinfo',
                  child: Row(
                    children: [
                      Icon(Icons.info),
                      SizedBox(width: 7),
                      Text('Dev Info', style: infoMenuStyle),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 0),
                Items(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Items extends StatefulWidget {
  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 288,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: stockNames.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    stockName: stockNames[index],
                    stockTicker: stockTickers[index],
                  ),
                ),
              );
            },
            child: Container(
              height: 50,
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: elementColor,
                borderRadius: BorderRadius.circular(10),
              ),

              child: Row(
                children: <Widget>[
                  Container(
                    width: 105,
                    height: 70,
                    alignment: Alignment.center,
                    child: Container(
                      width: 80,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(80),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        stockTickers[index],
                        style: GoogleFonts.getFont(
                          fontTicker,
                          color: tickerColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 0), // between ticker & stockName
                  Expanded(
                    child: Container(
                      height: 70,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        stockNames[index],
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansKR',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final String stockName;
  final String stockTicker;

  const DetailScreen({
    super.key,
    required this.stockName,
    required this.stockTicker,
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late RecentData recentData;

  double accuracy = 0.0;
  double errorMargin = 0.0;
  double actualAverage = 0.0;
  double differenceAverage = 0.0;
  double predictionAverage = 0.0;
  double lastActualValue = 0.0;
  String lastActualDate = '';
  String startDate = '';
  String endDate = '';

  String price = ' ';

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    recentData = RecentData();
    _loadData();
  }

  Future<void> _loadData() async {
    await recentData.fetchData(widget.stockTicker);
    setState(() {
      accuracy = recentData.calcAccuracy();
      errorMargin = recentData.calcMargin();
      actualAverage = recentData.calcAvgActual();
      differenceAverage = recentData.calcAvgDifference();
      predictionAverage = recentData.calcAvgPrediction();
      lastActualValue = recentData.getLastActualValue();
      lastActualDate = recentData.getLastActualDate();
      startDate = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: 60)));
      endDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    });
  }

  // resource management to ensure application stability
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    await recentData.fetchData(widget.stockTicker);
    setState(() {});
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: basicColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.stockName,
          style: TextStyle(
            fontFamily: 'IBMPlexSansKR',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                NewsWidget(stockName: widget.stockName),
                Column(
                  children: [
                    Expanded(flex: 14, child: GraphWidget(ticker: widget.stockTicker)),
                    Spacer(flex: 1),
                    Expanded(flex: 16, child: TableWidget(ticker: widget.stockTicker)),
                    Spacer(flex: 1),
                  ],
                ),
                CalendarWidget(),
                Center(
                  child: SizedBox(
                    width: 325,
                    height: 650,
                    child: StatsWidget(
                      accuracy: accuracy,
                      errorMargin: errorMargin,
                      startDate: startDate,
                      endDate: endDate,
                      actualAverage: actualAverage,
                      differenceAverage: differenceAverage,
                      predictionAverage: predictionAverage,
                      lastActualValue: lastActualValue,
                      lastActualDate: lastActualDate,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Page indicator and navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _currentPage > 0
                    ? () {
                        setState(() {
                          _currentPage--;
                          _pageController.animateToPage(
                            _currentPage,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        });
                      }
                    : null,
                icon: Icon(Icons.arrow_back),
                color: _currentPage > 0 ? buttonColor : basicColor,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    width: 12.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? buttonColor : Colors.grey,
                    ),
                  );
                }),
              ),
              IconButton(
                onPressed: _currentPage < 3
                    ? () {
                        setState(() {
                          _currentPage++;
                          _pageController.animateToPage(
                            _currentPage,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        });
                      }
                    : null,
                icon: Icon(Icons.arrow_forward),
                color: _currentPage < 3 ? buttonColor : basicColor,
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'overview_screen.dart';
// import 'package:intl/intl.dart';

import 'news_crawler.dart';
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
      backgroundColor: backgroundColor,
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

  // static const String fontItem = 'IBM Plex Sans KR';
  // static const String fontTicker = 'Lato';

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

  // DetailScreen({required this.stockTicker, required this.stockName});
  const DetailScreen({
    Key? key,
    required this.stockName,
    required this.stockTicker,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late RecentData recentData;

  double accuracy = 0.0;
  double margin = 0.0;

  String price = ' ';

  PageController _pageController = PageController();
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
      margin = recentData.calcMargin();
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
    const Color buttonColor = Color(0xFF9BC9E9);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigator.pushReplacementNamed(context, '/home');
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
        // padding: const EdgeInsets.all(16.0),
        // child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
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
                      // Spacer(flex: 1),
                      Expanded(flex: 14, child: GraphWidget(ticker: widget.stockTicker)),
                      // SizedBox(height: 7),
                      Spacer(flex: 1),
                      Expanded(flex: 16, child: TableWidget(ticker: widget.stockTicker)),
                      Spacer(flex: 1),
                    ],
                  ),
                  CalendarWidget(),

                  Center(
                    child: SizedBox(
                      width: 300,
                      height: 180,
                      child: StatsWidget(
                        accuracy: recentData.calcAccuracy(),
                        margin: recentData.formattedMargin(),
                      ),
                    ),
                  ),
                ],
              ),
          ),

          // page indicator
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
                color: _currentPage > 0 ? buttonColor : backgroundColor,
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
                color: _currentPage < 3 ? buttonColor : backgroundColor,
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

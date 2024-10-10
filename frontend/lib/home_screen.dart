import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFF06172B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Header(),
            Items(),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  // final double screenWidth;
  // Header({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360, height: 48,
      color: Colors.transparent,
      // width: screenWidth, // width: 320,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/images/colored_logo.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            SizedBox(width: 18), // margin between logo & text
            Text(
              'LSTM Mobile',
              textAlign: TextAlign.center,
              style: GoogleFonts.marhey(
                color: Color.fromRGBO(218, 218, 218, 1),
                fontSize: 27,
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class Items extends StatefulWidget {
  // final double screenHeight;
  // Items({required this.screenHeight});

  @override
  _ItemsState createState() => _ItemsState();
}


class _ItemsState extends State<Items> {
  final List<String> stockTicker = [
    '005930', // 삼성전자
    '000660', // SK하이닉스
    '373220', // LG에너지솔루션
    '207940', // 삼성바이오로직스
    '005380', // 현대차
    '005935', // 삼성전자우
    '068270', // 셀트리온
    '000270', // 기아
    '105560', // KB금융
    '005490', // POSCO홀딩스
  ];

  final List<String> stockNames = [
    '삼성전자',
    'SK하이닉스',
    'LG에너지솔루션',
    '삼성바이오로직스',
    '현대차',
    '삼성전자우',
    '셀트리온',
    '기아',
    'KB금융',
    'POSCO홀딩스',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: double.infinity,
      // height: widget.screenHeight,
      // margin: EdgeInsets.all(10),
      // padding: EdgeInsets.all(10),
      width: 320, height: 650,
      decoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0),
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 5.8,
          mainAxisSpacing: 10,
          crossAxisSpacing: 0,
        ),
        itemCount: stockNames.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(stockName: stockNames[index]),
                ),
              );
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 100, height: 54,
                    alignment: Alignment.center,
                    child: Container(
                      width: 80,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(238, 242, 248, 1), // EEF2F8
                        borderRadius: BorderRadius.circular(80),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        stockTicker[index],
                        style: GoogleFonts.inter(
                          color: Color.fromRGBO(0, 94, 238, 1), // 005CEE
                          fontSize: 17,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 54,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        stockNames[index],
                        textAlign: TextAlign.left,
                        style: GoogleFonts.inter(
                          color: Colors.black,
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


// should be changed into 'stateful'
class DetailScreen extends StatelessWidget {
  final String stockName;

  DetailScreen({ required this.stockName });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(stockName),
          backgroundColor: Color.fromRGBO(238, 242, 255, 1),
      ),
      backgroundColor: Color(0xFF06172B),
      body: Center(
        child: Text(
          'Here is detailed page for $stockName.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
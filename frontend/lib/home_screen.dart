import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181A1F),
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
          'PrediTock',
          style: TextStyle(color: Colors.white),
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
      width: 285,
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
                  builder: (context) => DetailScreen(stockName: stockNames[index]),
                ),
              );
            },
            child: Container(
              height: 50,
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xFF32343a),
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
                        // color: Color.fromRGBO(238, 242, 248, 1), // EEF2F8
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(80),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        stockTicker[index],
                        style: GoogleFonts.inter(
                          // color: Color.fromRGBO(0, 94, 238, 1), // 005CEE
                          color: Color(0xFF9bc9e9),
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
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
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          // color: Color(0xFF9bc9e9),
                          fontSize: 19,
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

class DetailScreen extends StatelessWidget {
  final String stockName;

  DetailScreen({ required this.stockName });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF181A1F),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Text(
              stockName,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
      backgroundColor: Color(0xFF181A1F),
      body: Center(
        child: Text(
          'Detailed page for $stockName',
          style: TextStyle(
            fontSize: 22,
            color: Color(0xffffffff),
          ),
        ),
      ),
    );
  }
}
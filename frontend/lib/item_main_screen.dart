import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class DetailScreen extends StatefulWidget {
  final String stockName;
  final String stockTicker;

  DetailScreen({
    required this.stockName,
    required this.stockTicker
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String price = "Loading..."; // 가격은 초기값을 로딩으로 설정

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchStockPrice(); // 가격 가져오기 함수 호출
  // }

  void _fetchStockPrice() async {
    final response = await http.get(Uri.parse('http://your-django-api.com/lstm/stock-price/${widget.stockTicker}/'));
    if (response.statusCode == 200) {
      setState(() {
        price = jsonDecode(response.body)['price'].toString();
      });
    } else {
      // 에러 처리
      setState(() {
        price = 'Error fetching price';
      });
    }
  }

  // void _fetchStockPrice() async {
  //   // 이 부분에서 Django 서버를 사용하여 가격을 받아옵니다.
  //   // 예: Django에서 REST API 호출
  //   // 실제 코드는 Django API와 통신하여 주가를 가져오는 로직이 추가되어야 합니다.
  //   await Future.delayed(Duration(seconds: 2)); // 모의 지연 시간
  //   setState(() {
  //     price = "50000"; // 실제 가격 데이터를 API에서 받아와 업데이트
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _fetchStockPrice(); // 화면이 처음 생성될 때 주식 가격을 가져옵니다.
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181A1F),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Text(
              "종목명: ${widget.stockName}",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            SizedBox(height: 10),
            Text(
              "종목코드: ${widget.stockTicker}",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "현재 가격: $price 원",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}

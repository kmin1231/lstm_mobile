import 'package:dio/dio.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';


class StockPriceFetcher {
  final Dio _dio = Dio();

  Future<String> getPrice(String stockCode) async {
    try {
      final response = await _dio.get('http://127.0.0.1:8000/lstm/stock/$stockCode',
          options: Options(
            responseType: ResponseType.json,
          ));
      print('Response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data['price'].toString();
      } else {
        throw Exception('Failed to load stock price');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load stock price: $e');
    }
  }
}
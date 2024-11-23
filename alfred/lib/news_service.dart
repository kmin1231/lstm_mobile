// news_service.dart

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'dart:convert';

class NewsService {
  Future<List<Map<String, String>>> getNews(String keyword) async {
    final encodedKeyword = Uri.encodeComponent(keyword);
    final url = 'https://news.google.com/rss/search?q=$encodedKeyword&hl=ko&gl=KR&ceid=KR:ko';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(utf8.decode(response.bodyBytes));
      final items = document.findAllElements('item');
      
      return items.map((item) {
        final title = item.findElements('title').first.innerText;
        final link = item.findElements('link').first.innerText;
        return {'title': title, 'url': link};
      }).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}
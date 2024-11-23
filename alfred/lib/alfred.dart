// alfred.dart

import 'package:alfred/alfred.dart';
import 'dart:convert';
import 'dart:isolate';

import 'news_service.dart';


void startServer() async {
  final app = Alfred();

  final newsService = NewsService();

  // fetches news articles related to keyword
  app.get('/news/:keyword', (req, res) async {
    final keyword = utf8.decode(req.params['keyword']!.codeUnits);
    final articles = await newsService.getNews(keyword);
    return {'keyword': keyword, 'articles': articles};
  });

  await app.listen(8080);
  print('Alfred Server running on http://localhost:8080');
}


// isolates entry point for Alfred server
void startServerIsolated(SendPort sendPort) {
  startServer();
  sendPort.send("Alfred Server Started!");
}


void main() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(startServerIsolated, receivePort.sendPort);
}
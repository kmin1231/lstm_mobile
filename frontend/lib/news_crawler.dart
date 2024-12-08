import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// cross platform
import 'dart:io' show Platform;  // cf. [Python] from A import B
import 'package:flutter/foundation.dart' show kIsWeb;


// defines stateful widget that displays related (latest) news
class NewsWidget extends StatefulWidget {
  final String stockName;

  NewsWidget({required this.stockName});

  @override
  _NewsWidgetState createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget> {
  List<Map<String, String>> _news = [];   // saves title & url
  bool _isLoading = true;                 // indicates the status

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    // 'stockName' (in Korean) needs to be encoded
    final encodedStockName = Uri.encodeComponent(widget.stockName);

    // determines 'baseUrl' based on the platform: Android vs. web 
    final baseUrl = kIsWeb ? 'http://localhost:8090' : (Platform.isAndroid ? 'http://10.0.2.2:8090' : 'http://localhost:8090');
    final url = Uri.parse('$baseUrl/news/$encodedStockName');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // checks whether the list of news is loaded
        if (data['articles'] is List && data['articles'].isNotEmpty) {
          final firstArticleTitle = data['articles'][0]['title'];
          print('first article: $firstArticleTitle');
        } else {
        print('No articles found');
        }

        setState(() {
          _news = (data['articles'] as List).map((item) => {
            'title': item['title']?.toString() ?? '',
            'url': item['url']?.toString() ?? '',
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color(0xFF32343A);
    const Color progressColor = Color(0xFFCFE2F3);
    final screenWidth = MediaQuery.of(context).size.width;  // responsive

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '최신 뉴스',
            style: TextStyle(
              fontFamily: 'IBMPlexSansKR',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        _isLoading ? Expanded(
          child: Center(
            child: CircularProgressIndicator(
                color: progressColor,
            ),
          ),
        )
        : Expanded(
            child: ListView.builder(
              itemCount: _news.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Card(
                    margin: EdgeInsets.all(5.0),
                    color: cardColor,
                    child: Container(
                      width: screenWidth * 0.88,
                      padding: EdgeInsets.all(4.0),
                      child: ListTile(
                        title: Text(
                          _news[index]['title'] ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'IBMPlexSansKR',
                          ),
                        ),
                        onTap: () async {
                          try {
                            final url = Uri.parse(_news[index]['url'] ?? '');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              print('Could not launch $url');
                            }
                          } catch (e) {
                            print('Error launching URL: $e');
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
         SizedBox(height: 17),
      ],
    );
  }
}
import 'package:news_reader_app/models/news_article.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService{
  static const String _apiKey = '774e9295d047478cbe38c4e658421709';


  Future<List<NewsArticle>> fetchNews({String category = 'general'}) async{
    final String _url =  'https://newsapi.org/v2/everything?q=$category india&sortBy=publishedAt&apiKey=$_apiKey';
    try{
      print("Fetching news for category: $category");
      final response = await http.get(Uri.parse(_url));
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if(response.statusCode == 200){
        final data = json.decode(response.body);
        final articles = data['articles'];
        return articles.map<NewsArticle>((article) => NewsArticle.fromJson(article)).toList();
      }
      else{
        throw Exception('Failed to load news');
      }
    }
    catch(e){
      throw Exception('Error fetching news: $e');
    }
  }
}
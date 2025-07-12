
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../models/news_article.dart';
import '../providers/theme_provider.dart';
import '../services/news_service.dart';
import 'WebViewScreen.dart';

class NewsHome extends StatefulWidget {
  const NewsHome({super.key});

  @override
  _NewsHomeState createState() => _NewsHomeState();
}

class _NewsHomeState extends State<NewsHome> {
  final NewsService _newsService = NewsService();
  late Future<List<NewsArticle>> _futureNews;
  String selectedCategory = 'general';

  final List<String> categories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  @override
  void initState() {
    super.initState();
    _futureNews = _newsService.fetchNews(category: selectedCategory);
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      _futureNews = _newsService.fetchNews(category: selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('📰 News Reader'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Row(
                  children: [
                    Text(
                      'Dark Mode',
                      style: DefaultTextStyle.of(context).style,
                    ),
                    Switch(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (val) => themeProvider.toggleTheme(val),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),

      body: Column(
        children: [
          // Category Chips
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _onCategorySelected(category),
                    selectedColor: Colors.grey,
                    backgroundColor: Colors.grey.shade200,
                    elevation: 3,
                    shadowColor: Colors.black,
                    pressElevation: 0,
                    disabledColor: Colors.grey.shade300,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    selectedShadowColor: Colors.black,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                      fontFamily: 'Montserrat',
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),

          // News List
          Expanded(
            child: FutureBuilder<List<NewsArticle>>(
              future: _futureNews,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No news found.'));
                }

                final newsList = snapshot.data!;
                
                return ListView.builder(
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    final article = newsList[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8),
                        leading: CachedNetworkImage(
                          imageUrl: article.urlToImage,
                          placeholder: (_, __) => CircularProgressIndicator(),
                          errorWidget: (_, __, ___) =>
                              Icon(Icons.broken_image),
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          article.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WebViewScreen(url: article.url),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
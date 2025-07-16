
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/news_article.dart';
import '../providers/theme_provider.dart';
import '../providers/top_headlines_carousel.dart';
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
        title: const Text('News Reader'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
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
          ),
        ],
      ),
      body: FutureBuilder<List<NewsArticle>>(
        future: _futureNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No news available.'));
          }

          final newsList = snapshot.data!;

          return ListView(
            children: [
              // Category Chips
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: ChoiceChip(
                        label: Text(
                          category[0].toUpperCase() + category.substring(1),
                        ),
                        selected: isSelected,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.grey),
                        elevation: 4,
                        shadowColor: Colors.grey.withOpacity(0.5),
                        pressElevation: 8,
                        onSelected: (_) => _onCategorySelected(category),
                        selectedColor: Colors.grey,
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Top Headlines Carousel
              TopHeadlinesCarousel(articles: newsList),

              const SizedBox(height: 15),

              // Remaining News Articles
              ...newsList.skip(5).map((article) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WebViewScreen(url: article.url),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.urlToImage.isNotEmpty)
                          Image.network(
                            article.urlToImage,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                article.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
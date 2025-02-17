import './news_model.dart';

class NewsResponse {
  final List<NewsModel> allNews;

  NewsResponse({required this.allNews});

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    var newsList = json['allNews']['rows'] as List;
    List<NewsModel> newsItems =
        newsList.map((news) => NewsModel.fromJson(news)).toList();

    return NewsResponse(allNews: newsItems);
  }
}

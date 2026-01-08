import 'package:flutter/material.dart';
// import 'package:linkschool/modules/explore/home/news/allnews_screen.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/home/news/all_news_screen.dart';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class NewsDetails extends StatefulWidget {
  final NewsModel news;
  final dynamic time;

  const NewsDetails({
    super.key,
    required this.news,
    required this.time,
  });

  @override
  State<NewsDetails> createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {
  late NewsModel currentNews;
  List<NewsModel> allNewsList = [];
  int currentIndex = 0;
  String selectedCategory = 'All';
  List<String> categories = ['All'];

  @override
  void initState() {
    super.initState();
    currentNews = widget.news;
    Future.microtask(() {
      final provider = Provider.of<NewsProvider>(context, listen: false);
      if (provider.newsmodel.isEmpty) {
        provider.fetchNews();
      }
      setState(() {
        allNewsList = provider.newsmodel;
        currentIndex = allNewsList.indexWhere((news) => news.id == currentNews.id);
        // Load available categories from provider
        categories = ['All', ...provider.availableCategories];
      });
    });
  }

  void navigateToNews(NewsModel news) {
    setState(() {
      currentNews = news;
      currentIndex = allNewsList.indexWhere((n) => n.id == news.id);
    });
  }

  List<NewsModel> getFilteredNews() {
    if (selectedCategory == 'All') {
      return allNewsList;
    }
    final provider = Provider.of<NewsProvider>(context, listen: false);
    return provider.getNewsByCategory(selectedCategory);
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'WAEC':
        return Colors.orange;
      case 'JAMB':
        return Colors.blue;
      case 'Admission':
        return Colors.purple;
      case 'Scholarships':
        return Colors.green;
      case 'General':
      default:
        return Colors.grey;
    }
  }

  _navigatorAllNews() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AllnewsScreen()));
  }

  void _shareNews(String title, String content, String time, String imageUrl) {
    // Format the complete news content for sharing
    String shareText = '''
📰 $title

📅 Published: $time

📝 Content:
$content

${imageUrl.isNotEmpty ? '🖼️ Image: $imageUrl' : ''}

#LinkSchool #News
''';
    
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    String? category = newsProvider.getCategoryForNews(currentNews.id);
    Color categoryColor = getCategoryColor(category ?? 'General');
    
    List<NewsModel> recommendedNews = newsProvider.recommendedNews
        .where((news) => news.id != currentNews.id)
       
        .toList();
    
    List<NewsModel> relatedNews = newsProvider.relatedNews
        .where((news) => news.id != currentNews.id)
     
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image with Overlay Content
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.text2Light,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                onPressed: () => _shareNews(
                  widget.news.title,
                  widget.news.content,
                  widget.time.toString(),
                  widget.news.imageUrl,
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Image
                  Image.network(
                    widget.news.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.grey.shade500,
                        ),
                      );
                    },
                  ),
                  
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  
                  // Content Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.news.title,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Urbanist',
                              height: 1.3,
                            ),
                          ),
                          // Category badge and time
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: categoryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category ?? "General",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Urbanist',
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.time.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          
                          
                          // Title
                          
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Category Filter Section
          // SliverToBoxAdapter(
          //   child: Container(
          //     color: Colors.white,
          //     padding: const EdgeInsets.symmetric(vertical: 16.0),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: 20.0),
          //           child: Text(
          //             'Filter by Category',
          //             style: AppTextStyles.normal600(
          //               fontSize: 16.0,
          //               color: AppColors.text2Light,
          //             ),
          //           ),
          //         ),
          //         const SizedBox(height: 12),
          //         SizedBox(
          //           height: 40,
          //           child: ListView.builder(
          //             scrollDirection: Axis.horizontal,
          //             padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //             itemCount: categories.length,
          //             itemBuilder: (context, index) {
          //               final cat = categories[index];
          //               final isSelected = selectedCategory == cat;
          //               return Padding(
          //                 padding: const EdgeInsets.only(right: 8.0),
          //                 child: FilterChip(
          //                   label: Text(cat),
          //                   selected: isSelected,
          //                   onSelected: (selected) {
          //                     setState(() {
          //                       selectedCategory = cat;
          //                     });
          //                   },
          //                   backgroundColor: Colors.grey.shade100,
          //                   selectedColor: getCategoryColor(cat).withOpacity(0.2),
          //                   labelStyle: TextStyle(
          //                     color: isSelected ? getCategoryColor(cat) : Colors.black87,
          //                     fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          //                     fontFamily: 'Urbanist',
          //                     fontSize: 13,
          //                   ),
          //                   side: BorderSide(
          //                     color: isSelected ? getCategoryColor(cat) : Colors.grey.shade300,
          //                     width: isSelected ? 2 : 1,
          //                   ),
          //                 ),
          //               );
          //             },
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          
          // Content Section
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content text
                    Text(
                      currentNews.content,
                      style: AppTextStyles.normal400(
                        fontSize: 16.0,
                        color: Colors.black,
                      ).copyWith(height: 1.7),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Recommended News Section
                    if (recommendedNews.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.text2Light.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.star_rounded,
                              color: AppColors.text2Light,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recommended for You',
                            style: AppTextStyles.normal600(
                              fontSize: 18.0,
                              color: AppColors.text2Light,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...recommendedNews.map((news) => _buildNewsCard(news, context)),
                      const SizedBox(height: 32),
                    ],
                    
                    // Related News Section
                    if (relatedNews.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.text2Light.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.article_rounded,
                              color: AppColors.text2Light,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Related News',
                            style: AppTextStyles.normal600(
                              fontSize: 18.0,
                              color: AppColors.text2Light,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...relatedNews.map((news) => relatedCard(news, context)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget relatedCard(NewsModel news, BuildContext context) {
  final newsProvider = Provider.of<NewsProvider>(context, listen: false);
  final category = newsProvider.getCategoryForNews(news.id) ?? 'General';
  final categoryColor = getCategoryColor(category);
  DateTime dop = DateTime.parse(news.date_posted);
  DateTime nowDateTime = DateTime.now();
  Duration difference = nowDateTime.difference(dop);
  String timeAgo = formatDuration(difference);

  return GestureDetector(
    onTap: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewsDetails(
            news: news,
            time: timeAgo,
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------------- IMAGE ----------------
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              news.imageUrl,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 160,
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          /// ---------------- TITLE ----------------
          Text(
            news.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.normal600(
              fontSize: 15.0,
              color: AppColors.text2Light,
            ),
          ),

          const SizedBox(height: 10),

          /// ---------------- CATEGORY + TIME ----------------
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.access_time,
                size: 12,
                color: AppColors.text4Light,
              ),

              const SizedBox(width: 4),

              Text(
                timeAgo,
                style: AppTextStyles.normal400(
                  fontSize: 11.0,
                  color: AppColors.text4Light,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


  Widget _buildNewsCard(NewsModel news, BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final category = newsProvider.getCategoryForNews(news.id) ?? 'General';
    final categoryColor = getCategoryColor(category);
    DateTime dop = DateTime.parse(news.date_posted);
    DateTime nowDateTime = DateTime.now();
    Duration difference = nowDateTime.difference(dop);
    String timeAgo = formatDuration(difference);
    
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetails(
              news: news,
              time: timeAgo,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                news.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image,
                      size: 30,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.normal600(
                      fontSize: 14.0,
                      color: AppColors.text2Light,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.text4Light,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeAgo,
                        style: AppTextStyles.normal400(
                          fontSize: 11.0,
                          color: AppColors.text4Light,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    if (duration.isNegative) return 'just now';

    final seconds = duration.inSeconds;
    if (seconds < 60) return '$seconds seconds ago';

    final minutes = duration.inMinutes;
    if (minutes < 60) return '$minutes minutes ago';

    final hours = duration.inHours;
    if (hours < 24) return '$hours hours ago';

    final days = duration.inDays;
    if (days < 7) return '$days days ago';

    return '${days ~/ 7} weeks ago';
  }
}

import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/e_library/E_lib_vids.dart';
import 'package:linkschool/modules/explore/videos/see_all_screen.dart';
import 'package:linkschool/modules/explore/videos/watch_history_screen.dart';
import 'package:linkschool/modules/model/explore/home/video_model.dart';
import 'package:linkschool/modules/services/explore/watch_history_service.dart';
import 'package:provider/provider.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../common/text_styles.dart';
import '../../providers/explore/subject_provider.dart';
// import '../e_library/cbt.details.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../e_library/e_lib_subject_detail.dart';

class ElibraryVidoes extends StatefulWidget {
  final bool showAppBar;
  const ElibraryVidoes({super.key, this.showAppBar = true});

  @override
  State<ElibraryVidoes> createState() => _ElibraryVidoesState();
}

class _ElibraryVidoesState extends State<ElibraryVidoes> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Video> _watchHistory = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    Provider.of<SubjectProvider>(context, listen: false).fetchSubjects();
    _loadWatchHistory();
  }

  Future<void> _loadWatchHistory() async {
    setState(() => _isLoadingHistory = true);
    final history = await WatchHistoryService.getWatchHistory(limit: 10);
    if (mounted) {
      setState(() {
        _watchHistory = history;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _onVideoTap(Video video) async {
    // Add to watch history before navigating
    await WatchHistoryService.addToWatchHistory(video);
    
    // Navigate to video player
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => E_lib_vids(video: video),
        ),
      );
      
      // Reload watch history when returning
      _loadWatchHistory();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Video> _filterVideos(List<Video> videos) {
    if (_searchQuery.isEmpty) {
      return videos;
    }
    return videos.where((video) {
      return video.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  _navigateToSeeall() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SeeallScreen(),
        ));
  }

  _navigateToWatchHistory() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WatchHistoryScreen(),
        )).then((_) {
      // Reload watch history when returning
      _loadWatchHistory();
    });
  }

  Color _getSubjectColor(String subjectName) {
    switch (subjectName.toLowerCase()) {
      case 'english language':
        return AppColors.videoColor1;

      case 'mathematics':
        return AppColors.videoColor2;
      case 'physics':
        return AppColors.videoColor3;
      case 'chemistry':
        return AppColors.videoColor4;
      case 'biology':
        return AppColors.videoColor5;

      default:
        return AppColors.videoColor3;
    }
  }

  List<String> subjectIcons = [
    'english',
    'maths',
    'physics',
    'chemistry',
    'biology',
  ];
  List<String> subjectName = [
    'English',
    'maths',
    'physics',
    'chemistry',
    'biology',
  ];

  @override
  @override
  Widget build(BuildContext context) {
    return Consumer<SubjectProvider>(
      builder: (context, subjectProvider, child) {
        if (subjectProvider.isLoading) {
          return Scaffold(
           
            body: Skeletonizer(
              child: Container(
                decoration: Constants.customBoxDecoration(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Constants.headingWithSeeAll600(
                              title: 'Watch history',
                              titleSize: 18.0,
                              onPressed: _navigateToSeeall,
                              titleColor: AppColors.primaryLight,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 150.0,
                              child: ListView.builder(
                                itemCount: 7,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Skeletonizer(
                                    child: Container(
                                      width: 100,
                                      color: Colors.amber,
                                      height: 100,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Text(
                              'Categor',
                              style: AppTextStyles.normal600(
                                  fontSize: 20, color: AppColors.primaryLight),
                            ),
                          ),
                          const SliverToBoxAdapter(
                              child: SizedBox(height: 10.0)),
                          SliverToBoxAdapter(
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              double screenWidth =
                                  MediaQuery.of(context).size.width;

                              double aspectRatio = (screenWidth / 4);

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3.2,
                                  vertical: 1.90,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.videoCardColor,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.videoCardBorderColor,
                                    ),
                                    top: BorderSide(
                                      color: AppColors.videoCardBorderColor,
                                    ),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                    childAspectRatio: aspectRatio,
                                  ),
                                  itemCount: 8,
                                  itemBuilder: (context, index) {
                                    return _buildCategoriesCard(
                                      subjectName: 'Loading...',
                                      subjectIcon: 'english',
                                      backgroundColor: AppColors.videoColor1,
                                    );
                                  },
                                ),
                              );
                            }),
                          ),
                          const SliverToBoxAdapter(
                              child: SizedBox(height: 19.0)),
                          SliverToBoxAdapter(
                            child: Constants.heading600(
                              title: 'Recommended for you',
                              titleSize: 20.0,
                              titleColor: AppColors.primaryLight,
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return _recommendedForYouCard(Video(
                                  title: 'Loading...',
                                  url: '',
                                  thumbnail: '',
                                ));
                              },
                              childCount: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          final categories = subjectProvider.subjects
              .map((subject) => _buildCategoriesCard(
                    subjectName:
                        subjectName[subjectProvider.subjects.indexOf(subject)],
                    subjectIcon:
                        subjectIcons[subjectProvider.subjects.indexOf(subject)],
                    backgroundColor: _getSubjectColor(subject.name),
                  ))
              .toList();

          final allVideos = subjectProvider.subjects
              .expand((subject) => subject.categories)
              .expand((category) => category.videos)
              .toList();

          final filteredVideos = _filterVideos(allVideos);

          final recommendationVideos = filteredVideos.length > 4
              ? filteredVideos.getRange(0, filteredVideos.length > 6 ? 6 : filteredVideos.length).toList()
              : filteredVideos;

          return Scaffold(
            
            body: Stack(
              children: [
                Container(
                  decoration: Constants.customBoxDecoration(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search videos...',
                            hintStyle: AppTextStyles.normal400(
                              fontSize: 14,
                              color: AppColors.text5Light,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.text2Light,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.textField(context),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.textFieldBorder(context),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.textFieldBorder(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.text2Light,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Only show watch history section if there's data
                        if (_watchHistory.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Constants.headingWithSeeAll600(
                              title: 'Watch history',
                              titleSize: 18.0,
                              titleColor: AppColors.primaryLight,
                              onPressed: _navigateToWatchHistory,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _isLoadingHistory
                                ? const SizedBox(
                                    height: 150.0,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : SizedBox(
                                    height: 150.0,
                                    child: ListView.builder(
                                      itemCount: _watchHistory.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () => _onVideoTap(_watchHistory[index]),
                                          child: _buildWatchHistoryCard(
                                            _watchHistory[index],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ],
                        if (_searchQuery.isEmpty) ...[
                          SliverToBoxAdapter(
                              child: Constants.heading600(
                            title: 'Categories',
                            titleSize: 18.0,
                            titleColor: AppColors.primaryLight,
                          )),
                          const SliverToBoxAdapter(
                              child: SizedBox(height: 10.0)),
                          SliverToBoxAdapter(
                          child: LayoutBuilder(builder: (context, constraints) {
                            double screenHeight =
                                MediaQuery.of(context).size.height;
                            double screenWidth =
                                MediaQuery.of(context).size.width;
                            double height = screenHeight * 0.34;
                            double aspectRatio =
                                (screenWidth / 4) / (height / 2);

                            return Container(
                              height: height,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3.2,
                                vertical: 1.90,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.videoCardColor,
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.videoCardBorderColor,
                                  ),
                                  top: BorderSide(
                                    color: AppColors.videoCardBorderColor,
                                  ),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                    childAspectRatio: aspectRatio,
                                  ),
                                  itemCount: categories.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ELibSubjectDetail(
                                                      subject: subjectProvider
                                                          .subjects[index])),
                                        );
                                      },
                                      child: categories[index],
                                    );
                                  },
                                ),
                              ),
                            );
                          }),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 19.0)),
                        ],
                        SliverToBoxAdapter(
                          child: Constants.heading600(
                            title: 'Recommended for you',
                            titleSize: 18.0,
                            titleColor: AppColors.primaryLight,
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index < recommendationVideos.length) {
                                return GestureDetector(
                                  onTap: () => _onVideoTap(recommendationVideos[index]),
                                  child: _recommendedForYouCard(
                                      recommendationVideos[index]),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            childCount: recommendationVideos.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
                // White overlay layer for search results
                if (_searchQuery.isNotEmpty)
                  Positioned(
                    top: 90, // Below the search bar
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: filteredVideos.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: AppColors.text5Light,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No videos found',
                                    style: AppTextStyles.normal600(
                                      fontSize: 18,
                                      color: AppColors.text5Light,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try adjusting your search',
                                    style: AppTextStyles.normal400(
                                      fontSize: 14,
                                      color: AppColors.text5Light,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Search Results (${filteredVideos.length})',
                                    style: AppTextStyles.normal600(
                                      fontSize: 18,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: filteredVideos.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () => _onVideoTap(filteredVideos[index]),
                                        child: _recommendedForYouCard(
                                            filteredVideos[index]),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildWatchHistoryCard(Video video) {
    return Container(
      height: 146,
      width: 150,
      margin: const EdgeInsets.only(left: 16.0),
      child: Column(children: [
        Image.network(
          video.thumbnail,
          fit: BoxFit.cover,
          height: 92,
          width: 150,
        ),
        const SizedBox(height: 4.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.normal500(
              fontSize: 16.0,
              color: AppColors.backgroundDark,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildCategoriesCard({
    required String subjectName,
    required String subjectIcon,
    required Color backgroundColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            Container(
              height: 60,
              width: 60,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: Image.asset(
                'assets/icons/$subjectIcon.png',
                color: Colors.white,
                width: 24.0,
                height: 24.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                subjectName,
                style: AppTextStyles.normal500(
                    fontSize: 14.0, color: Colors.black),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _recommendedForYouCard(Video video) {
    return Container(
      height: 130,
      padding:
          const EdgeInsets.only(left: 16.0, top: 16.0, right: 8.0, bottom: 18),
      decoration: const BoxDecoration(
        color: AppColors.videoCardColor,
        border: Border(
          bottom: BorderSide(color: AppColors.newsBorderColor),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(
                  video.thumbnail,
                  fit: BoxFit.cover,
                  height: 80,
                  width: 108,
                    errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      width: 108,
                      color: AppColors.videoColor9.withAlpha(50),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white.withOpacity(0.7),
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.normal500(
                    fontSize: 16.0,
                    color: AppColors.videoColor9,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '1hr 34mins',
                  style: AppTextStyles.normal500(
                    fontSize: 14.0,
                    color: AppColors.videoColor9,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/views.png',
                      width: 16,
                      height: 16.0,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "345",
                      style: AppTextStyles.normal500(
                        fontSize: 12.0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    const Icon(Icons.file_download_outlined, size: 16.0),
                    const SizedBox(width: 4),
                    Text(
                      '12k',
                      style: AppTextStyles.normal500(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

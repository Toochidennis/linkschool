// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/explore/e_library/E_lib_vids.dart';
// import 'package:linkschool/modules/model/explore/home/subject_model2.dart';
// import 'package:linkschool/modules/model/explore/home/video_model.dart';
// import 'package:skeletonizer/skeletonizer.dart';
// // import 'package:linkschool/modules/explore/e_library/cbt.details.dart';
// // import 'package:linkschool/modules/providers/explore/subject_provider.dart';

// class ELibSubjectDetail extends StatefulWidget {
//   const ELibSubjectDetail({super.key, this.subject});
//   final SubjectModel2? subject;

//   @override
//   State<ELibSubjectDetail> createState() => _ELibSubjectDetailState();
// }

// class _ELibSubjectDetailState extends State<ELibSubjectDetail>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final ScrollController _scrollController = ScrollController();
//   bool _showFloatingTabBar = false;
//   bool _isLoading = true;
//   bool _hasError = false;
//   String _errorMessage = '';
//   bool _isTextExpanded = true;

//   final String paratext =
//       "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _scrollController.addListener(_onScroll);
//     _loadData();
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadData() async {
//     if (mounted) {
//       setState(() {
//         _isLoading = true;
//         _hasError = false;
//         _errorMessage = '';
//       });
//     }

//     try {
//       await Future.delayed(Duration(seconds: 1)); // Remove in production

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _hasError = true;
//           _errorMessage = 'Failed to load subject details. Please try again.';
//         });
//       }
//     }
//   }

//   void _onScroll() {
//     if (_scrollController.offset >= 200 && !_showFloatingTabBar) {
//       setState(() => _showFloatingTabBar = true);
//     } else if (_scrollController.offset < 200 && _showFloatingTabBar) {
//       setState(() => _showFloatingTabBar = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: _loadData,
//         child: Skeletonizer(
//           enabled: _isLoading,
//           child: Container(
//             decoration: Constants.customBoxDecoration(context),
//             child: Stack(
//               children: [
//                 if (!_isLoading) _buildBackgroundImage(),
//                 _buildBackButton(),
//                 if (_hasError) _buildErrorView() else _buildMainContent(),
//                 if (_showFloatingTabBar && !_isLoading && !_hasError)
//                   _buildFloatingTabBar(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorView() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 48, color: Colors.red),
//             SizedBox(height: 16),
//             Text(
//               _errorMessage,
//               textAlign: TextAlign.center,
//               style: AppTextStyles.normal500(
//                 fontSize: 16,
//                 color: AppColors.assessmentColor2,
//               ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadData,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.bgBorder,
//               ),
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBackgroundImage() {
//     return Positioned(
//       left: 0,
//       right: 0,
//       child: Image(
//         image: AssetImage(
//             'assets/images/e-subject_detail/maths_colourful_words.png'),
//         fit: BoxFit.cover,
//         height: 338,
//         width: 360,
//       ),
//     );
//   }

//   Widget _buildBackButton() {
//     return Positioned(
//       top: 40,
//       left: 0,
//       child: IconButton(
//         onPressed: () => Navigator.pop(context),
//         icon: Image.asset(
//           'assets/icons/arrow_back.png',
//           color: AppColors.assessmentColor1,
//           width: 34.0,
//           height: 34.0,
//         ),
//       ),
//     );
//   }

//   Widget _buildMainContent() {
//     return Positioned(
//       top: 310,
//       left: 0,
//       right: 0,
//       bottom: 0,
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.assessmentColor1,
//           border: Border.all(color: AppColors.assessmentColor3),
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(30),
//             topRight: Radius.circular(30),
//           ),
//         ),
//         child: NestedScrollView(
//           controller: _scrollController,
//           headerSliverBuilder: (context, innerBoxIsScrolled) {
//             return [
//               SliverToBoxAdapter(child: _buildHeader()),
//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: _SliverAppBarDelegate(
//                   TabBar(
//                     controller: _tabController,
//                     isScrollable: true,
//                     tabAlignment: TabAlignment.start,
//                     labelColor: AppColors.bgBorder,
//                     unselectedLabelColor: AppColors.assessmentColor2,
//                     indicatorColor: AppColors.bgBorder,
//                     tabs: [
//                       Tab(
//                           text:
//                               'Lessons(${widget.subject?.categories.isEmpty ?? true ? 0 : widget.subject?.categories[0].videos.length})'),
//                       Tab(text: 'Reviews'),
//                     ],
//                   ),
//                 ),
//               ),
//             ];
//           },
//           body: TabBarView(
//             controller: _tabController,
//             children: [
//               _buildLessonsTab(),
//               _buildReviewsTab(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.subject?.name ?? 'Subject Name',
//             style: AppTextStyles.normal700(
//                 fontSize: 22, color: AppColors.aboutTitle),
//           ),
//           SizedBox(height: 8),
//           _buildSubjectInfo(),
//           SizedBox(height: 16),
//           Text.rich(
//             TextSpan(
//               text: paratext,
//               style: AppTextStyles.normal400(
//                 fontSize: 16,
//                 color: AppColors.assessmentColor2,
//               ),
//             ),
//             maxLines: _isTextExpanded ? null : 4,
//             overflow: TextOverflow.ellipsis,
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _isTextExpanded = !_isTextExpanded;
//               });
//             },
//             child: Text(
//               _isTextExpanded ? 'Read More' : 'Read Less',
//               style: AppTextStyles.normal400(
//                   fontSize: 16, color: AppColors.bgBorder),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubjectInfo() {
//     if (_isLoading) {
//       return Padding(
//         padding: EdgeInsets.symmetric(vertical: 8),
//         child: Row(
//           children: [
//             Container(
//               width: 80,
//               height: 12,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(6),
//               ),
//             ),
//             SizedBox(width: 8),
//             Container(
//               width: 80,
//               height: 12,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(6),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Row(
//       children: [
//         Icon(Icons.access_time, size: 12),
//         SizedBox(width: 4),
//         Text(
//           '3h 30min',
//           style: AppTextStyles.normal400(
//               fontSize: 14, color: AppColors.admissionTitle),
//         ),
//         SizedBox(width: 8),
//         Icon(Icons.access_time, size: 12),
//         SizedBox(width: 4),
//         Text(
//           '3h 30min',
//           style: AppTextStyles.normal400(
//               fontSize: 14, color: AppColors.admissionTitle),
//         ),
//         SizedBox(width: 8),
//         Text(
//           '. ${widget.subject?.categories.fold<int>(0, (sum, category) => sum + (category.videos.length)) ?? 0} Lessons',
//           style: AppTextStyles.normal400(
//               fontSize: 16, color: AppColors.admissionTitle),
//         ),
//       ],
//     );
//   }

//   Widget _buildFloatingTabBar() {
//     return Positioned(
//       top: 310,
//       left: 0,
//       right: 0,
//       child: Container(
//         color: AppColors.assessmentColor1,
//         child: TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           tabAlignment: TabAlignment.start,
//           labelColor: AppColors.bgBorder,
//           unselectedLabelColor: AppColors.assessmentColor2,
//           indicatorColor: AppColors.bgBorder,
//           tabs: [
//             Tab(
//                 text:
//                     'Lessons(${widget.subject?.categories.isEmpty ?? true ? 0 : widget.subject?.categories[0].videos.length})'),
//             Tab(text: 'Reviews'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLessonsTab() {
//     if (_isLoading) {
//       return Skeletonizer(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.video_library_outlined,
//                   size: 48, color: AppColors.assessmentColor2),
//               SizedBox(height: 16),
//               Text(
//                 '',
//                 style: AppTextStyles.normal500(
//                   fontSize: 16,
//                   color: AppColors.assessmentColor2,
//                 ),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _loadData,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.bgBorder,
//                 ),
//                 child: Text(''),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (widget.subject?.categories.isEmpty ?? true) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.video_library_outlined,
//                 size: 48, color: AppColors.assessmentColor2),
//             SizedBox(height: 16),
//             Text(
//               '',
//               style: AppTextStyles.normal500(
//                 fontSize: 16,
//                 color: AppColors.assessmentColor2,
//               ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadData,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.bgBorder,
//               ),
//               child: Text(''),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView(
//       padding: EdgeInsets.all(16),
//       children: [
//         _buildLessonSection(
//             'Elementary', widget.subject?.categories[0].videos ?? []),
//         _buildLessonSection(
//             'Junior Secondary', widget.subject?.categories[1].videos ?? []),
//       ],
//     );
//   }

//   Widget _buildLessonSection(String title, List<Video> videos) {
//     if (videos.isEmpty) {
//       return SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Text(
//             title,
//             style: AppTextStyles.normal600(
//                 fontSize: 16, color: AppColors.assessmentColor2),
//           ),
//         ),
//         ...videos.map((video) => GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => E_lib_vids(video: video),
//                   ),
//                 );
//               },
//               child: SubjectDetails(video: video),
//             )),
//         SizedBox(height: 20),
//       ],
//     );
//   }

//   Widget _buildReviewsTab() {
//     if (_isLoading) {
//       return Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(AppColors.bgBorder),
//         ),
//       );
//     }

//     return ListView(
//       padding: EdgeInsets.all(16),
//       children: [
//         Text(
//           paratext,
//           style: AppTextStyles.normal400(
//             fontSize: 14,
//             color: AppColors.assessmentColor2,
//           ),
//         ),
//         // Add more review content here
//       ],
//     );
//   }
// }

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   _SliverAppBarDelegate(this._tabBar);

//   final TabBar _tabBar;

//   @override
//   double get minExtent => _tabBar.preferredSize.height;
//   @override
//   double get maxExtent => _tabBar.preferredSize.height;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: AppColors.assessmentColor1,
//       child: _tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }

// class SubjectDetails extends StatelessWidget {
//   const SubjectDetails({super.key, required this.video});
//   final Video video;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 4, right: 12, left: 4),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 50,
//                 width: 50,
//                 decoration: BoxDecoration(
//                   color: AppColors.bgColor3,
//                   borderRadius: BorderRadius.circular(50),
//                   image: DecorationImage(
//                     image: NetworkImage(video.thumbnail),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 20),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       video.title,
//                       maxLines: 2,
//                       style: AppTextStyles.normal600(
//                           fontSize: 16.0, color: AppColors.admissionTitle),
//                     ),
//                     Text(
//                       '02:57:00',
//                       style: AppTextStyles.normal500(
//                           fontSize: 14.0, color: AppColors.admissionTitle),
//                     ),
//                     SizedBox(height: 8),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

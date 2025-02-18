import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';

class ELibSubjectDetail extends StatefulWidget {
  const ELibSubjectDetail({Key? key, this.subject}) : super(key: key);
  final Subject? subject;

  @override
  State<ELibSubjectDetail> createState() => _ELibSubjectDetailState();
}

class _ELibSubjectDetailState extends State<ELibSubjectDetail> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingTabBar = false;

  final String paratext =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset >= 200 && !_showFloatingTabBar) {
      setState(() => _showFloatingTabBar = true);
    } else if (_scrollController.offset < 200 && _showFloatingTabBar) {
      setState(() => _showFloatingTabBar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Stack(
          children: [
            _buildBackgroundImage(),
            _buildBackButton(),
            _buildMainContent(),
            if (_showFloatingTabBar) _buildFloatingTabBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned(
      left: 0,
      right: 0,
      child: Image(
        image: AssetImage('assets/images/e-subject_detail/maths_colourful_words.png'),
        fit: BoxFit.cover,
        height: 338,
        width: 360,
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 40,
      left: 0,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Image.asset(
          'assets/icons/arrow_back.png',
          color: AppColors.assessmentColor1,
          width: 34.0,
          height: 34.0,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Positioned(
      top: 310,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.assessmentColor1,
          border: Border.all(color: AppColors.assessmentColor3),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColors.bgBorder,
                    unselectedLabelColor: AppColors.assessmentColor2,
                    indicatorColor: AppColors.bgBorder,
                    tabs: [
                      Tab(text: 'Lessons(${widget.subject?.categories[0].videos.length ?? 0})'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildLessonsTab(),
              _buildReviewsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subject?.name ?? '',
            style: AppTextStyles.normal700(fontSize: 20, color: AppColors.aboutTitle),
          ),
          SizedBox(height: 8),
          _buildSubjectInfo(),
          SizedBox(height: 16),
          Text(
            paratext,
            style: AppTextStyles.normal400(
              fontSize: 16,
              color: AppColors.assessmentColor2,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Read More',
              style: AppTextStyles.normal400(fontSize: 14, color: AppColors.bgBorder),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectInfo() {
    return Row(
      children: [
        Icon(Icons.access_time, size: 12),
        SizedBox(width: 4),
        Text(
          '3h 30min',
          style: AppTextStyles.normal400(fontSize: 12, color: AppColors.admissionTitle),
        ),
        SizedBox(width: 8),
        Icon(Icons.access_time, size: 12),
        SizedBox(width: 4),
        Text(
          '3h 30min',
          style: AppTextStyles.normal400(fontSize: 12, color: AppColors.admissionTitle),
        ),
        SizedBox(width: 8),
        Text(
          '. 28 Lessons',
          style: AppTextStyles.normal400(fontSize: 12, color: AppColors.admissionTitle),
        ),
      ],
    );
  }

  Widget _buildFloatingTabBar() {
    return Positioned(
      top: 310,
      left: 0,
      right: 0,
      child: Container(
        color: AppColors.assessmentColor1,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.bgBorder,
          unselectedLabelColor: AppColors.assessmentColor2,
          indicatorColor: AppColors.bgBorder,
          tabs: [
            Tab(text: 'Lessons(${widget.subject?.categories[01].videos.length ?? 0})'),
            Tab(text: 'Reviews'),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildLessonSection('Elementary', widget.subject?.categories[0].videos ?? []),
        _buildLessonSection('Junior Secondary', widget.subject?.categories[1].videos ?? []),
      ],
    );
  }

  Widget _buildLessonSection(String title, List<Video> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: AppTextStyles.normal500(fontSize: 14, color: AppColors.assessmentColor2),
          ),
        ),
        ...videos.map((video) => SubjectDetails(video: video)).toList(),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(paratext),
        // Add more review content here
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.assessmentColor1,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class SubjectDetails extends StatelessWidget {
  const SubjectDetails({Key? key, required this.video}) : super(key: key);
  final Video video;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 12, left: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgColor3,
                  borderRadius: BorderRadius.circular(50),
                  image: DecorationImage(
                    image: NetworkImage(video.thumbnail),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: AppTextStyles.normal600(fontSize: 14.0, color: AppColors.admissionTitle),
                    ),
                    Text(
                      '02:57:00', // Replace with actual duration when available
                      style: AppTextStyles.normal600(fontSize: 12.0, color: AppColors.admissionTitle),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_fill_rounded,
                color: AppColors.bgBorder,
                size: 30,
              ),
            ],
          ),
          Divider(
            color: AppColors.attBorderColor1,
            height: 10,
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/e_library/E_lib_vids.dart';
import 'package:linkschool/modules/explore/e_library/cbt.details.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/providers/explore/subject_provider.dart';
import 'package:provider/provider.dart';

class SeeallScreen extends StatefulWidget {
  const SeeallScreen({super.key});

  @override
  State<SeeallScreen> createState() => _SeeallScreenState();
}

class _SeeallScreenState extends State<SeeallScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<SubjectProvider>(context, listen: false).fetchSubject();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubjectProvider>(
      builder: (context, subjectProvider, child) {
        final allVideos = subjectProvider.subjects
            .expand((subject) => subject.categories)
            .expand((category) => category.videos)
            .toList();

        return Scaffold(
          appBar: Constants.customAppBar(context: context),
          body: Container(
            decoration: Constants.customBoxDecoration(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Constants.heading600(
                  title: 'Watch history',
                  titleSize: 18,
                  titleColor: AppColors.primaryLight,
                ),
                Expanded(
                  // Add this Expanded widget
                  child: ListView.builder(
                    physics:
                        const BouncingScrollPhysics(), // Optional: for better scrolling
                    itemCount:
                        10, // Show all videos instead of just 5
                    itemBuilder: (context, index) =>
                         GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>E_lib_vids(
                                                video: allVideos[index]))),
                          child: _watchHistory(allVideos[index])),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _watchHistory(Video video) {
  return Container(
    height: 121,
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
                  Text(
                    "345",
                    style: AppTextStyles.normal500(
                      fontSize: 12.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  const Icon(Icons.file_download_outlined, size: 16.0),
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

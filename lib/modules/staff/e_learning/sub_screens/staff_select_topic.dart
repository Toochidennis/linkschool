import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/topic_model.dart';
import 'package:linkschool/modules/providers/admin/e_learning/topic_provider.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_create_topic_screen.dart';
import 'package:provider/provider.dart';
// import 'package:linkschool/modules/admin_portal/result/behaviour_settings_screen.dart';

class StaffSelectTopicScreen extends StatefulWidget {
  final String callingScreen;
  final VoidCallback? onTopicCreated;
  final List<Map<String, dynamic>>? classes;
  final String? levelId;
  final int? syllabusId;
  final courseId;
  final courseName;

  const StaffSelectTopicScreen(
      {super.key,
      required this.callingScreen,
      this.onTopicCreated,
      this.levelId,
      this.syllabusId,
      this.classes,
      this.courseId,
      this.courseName});

  @override
  State<StaffSelectTopicScreen> createState() => _SelectTopicScreenState();
}

class _SelectTopicScreenState extends State<StaffSelectTopicScreen> {
  late final String callingScreen;
  late final VoidCallback? onTopicCreated;
  Topic? selectedTopic; // Changed to Topic? to store the full Topic object
  late double opacity;

  @override
  void initState() {
    super.initState();
    callingScreen = widget.callingScreen;
    onTopicCreated = widget.onTopicCreated;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.syllabusId != null && widget.syllabusId! > 0) {
        print('Fetching topics with syllabusId: ${widget.syllabusId}');
        Provider.of<TopicProvider>(context, listen: false)
            .fetchTopic(syllabusId: widget.syllabusId!);
      } else {
        print('Invalid syllabusId: ${widget.syllabusId}, skipping fetch');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topicProvider = Provider.of<TopicProvider>(context);
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Select topic',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CustomSaveElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'topicName': selectedTopic?.name ?? 'No Topic',
                  'topicId': selectedTopic?.id,
                });
              },
              text: 'Save',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: topicProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : topicProvider.topics.isEmpty
                        ? const Center(child: Text('No topics found'))
                        : ListView.builder(
                            itemCount: topicProvider.topics.length,
                            itemBuilder: (context, index) {
                              final topicItem = topicProvider.topics[index];
                              return TopicItem(
                                topic: topicItem,
                                isSelected: topicItem == selectedTopic,
                                onSelect: _selectTopic,
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StaffCreateTopicScreen(
                classes: widget.classes,
                levelId: widget.levelId,
                syllabusId: widget.syllabusId!,
                courseId: widget.courseId,
                courseName: widget.courseName,
              ),
            ),
          );
          if (widget.syllabusId != null) {
            Provider.of<TopicProvider>(context, listen: false)
                .fetchTopic(syllabusId: widget.syllabusId!);
          }
        },
        backgroundColor: AppColors.primaryLight,
        child: const Icon(Icons.add, color: AppColors.text6Light),
      ),
    );
  }

  void _selectTopic(Topic topic) {
    setState(() {
      selectedTopic = topic;
    });
  }
}

class TopicItem extends StatelessWidget {
  final Topic topic; // Changed to Topic object
  final bool isSelected;
  final Function(Topic) onSelect; // Updated to accept Topic

  const TopicItem({
    super.key,
    required this.topic,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(topic),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/e_learning/topic_icon1.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(topic.name), // Use topic.name
              ),
              if (isSelected)
                SvgPicture.asset(
                  'assets/icons/result/check.svg',
                  width: 24,
                  height: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:linkschool/modules/admin/e_learning/create_topic_screen.dart';
// import 'package:linkschool/modules/admin/result/behaviour_settings_screen.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/topic_provider.dart';
// import 'package:provider/provider.dart';
// // import 'package:linkschool/modules/admin_portal/result/behaviour_settings_screen.dart';

// class SelectTopicScreen extends StatefulWidget {
//   final String callingScreen;
//   final VoidCallback? onTopicCreated;
//   final String? levelId ;
//   final int? syllabusId;

//   const SelectTopicScreen({
//     super.key,
//     required this.callingScreen,
//     this.onTopicCreated,
//      this.levelId,
//      this.syllabusId,
//   });

//   @override
//   State<SelectTopicScreen> createState() => _SelectTopicScreenState();
// }

// class _SelectTopicScreenState extends State<SelectTopicScreen> {
//   late final String callingScreen;
//   late final VoidCallback? onTopicCreated;

//   String? selectedTopic;
//   late double opacity;
//   @override
//   void initState() {
//     super.initState();

//     callingScreen = widget.callingScreen;
//     onTopicCreated = widget.onTopicCreated;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//      if (widget.syllabusId != null && widget.syllabusId! > 0) {
//       print('Fetching topics with syllabusId: ${widget.syllabusId}');
//       Provider.of<TopicProvider>(context, listen: false).fetchTopic(syllabusId: widget.syllabusId!);
//     } else {
//       print('Invalid syllabusId: ${widget.syllabusId}, skipping fetch');
//     }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final topicProvider = Provider.of<TopicProvider>(context);
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.primaryLight,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           'Select topic',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.primaryLight,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: CustomSaveElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, selectedTopic ?? 'No Topic');
//               },
//               text: 'Save',
//             ),
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Add new Topic',
//                   border: OutlineInputBorder(),
//                 ),

//               ),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: topicProvider.isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : topicProvider.topics.isEmpty
//                         ? const Center(child: Text('No topics found'))
//                         : ListView.builder(
//                             itemCount: topicProvider.topics.length,
//                             itemBuilder: (context, index) {
//                               final topicItem = topicProvider.topics[index];
//                               return TopicItem(
//                                 topic: topicItem.name,
//                                 isSelected: topicItem.name == selectedTopic,
//                                 onSelect: _selectTopic,
//                               );
//                             },
//                           ),
//               ),
//             ],
//           ),
//         ),
//       ),

//       floatingActionButton: FloatingActionButton(
//   onPressed: () async {
//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => CreateTopicScreen(
//           levelId: widget.levelId,
//           syllabusId: widget.syllabusId!, // Pass the syllabusId

//         ),
//       ),
//     );
//      if (widget.syllabusId != null) {
//       Provider.of<TopicProvider>(context, listen: false)
//         .fetchTopic(syllabusId: widget.syllabusId!);
//     }
//   },
//   child: Icon(Icons.add,color: AppColors.text6Light,),
//   backgroundColor: AppColors.primaryLight,
// ),
//   );
// }

//   // void _addTopic(String topic) {
//   //   setState(() {
//   //     topics.add(topic);
//   //     selectedTopic = topic;
//   //     if (onTopicCreated != null) {
//   //       onTopicCreated!();
//   //     }
//   //   });
//   // }

//   void _selectTopic(String topic) {
//     setState(() {
//       selectedTopic = topic;
//     });
//   }
// }

// class TopicsList extends StatelessWidget {
//   final List<String> topics;
//   final String? selectedTopic;
//   final Function(String) onSelect;

//   const TopicsList({
//     super.key,
//     required this.topics,
//     required this.selectedTopic,
//     required this.onSelect,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: topics.length,
//       itemBuilder: (context, index) {
//         return TopicItem(
//           topic: topics[index],
//           isSelected: topics[index] == selectedTopic,
//           onSelect: onSelect,
//         );
//       },
//     );
//   }
// }

// class TopicItem extends StatelessWidget {
//   final String topic;
//   final bool isSelected;
//   final Function(String) onSelect;

//   const TopicItem({
//     super.key,
//     required this.topic,
//     required this.isSelected,
//     required this.onSelect,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => onSelect(topic),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Container(
//           padding: const EdgeInsets.only(bottom: 10),
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: Colors.grey[300]!,
//                 width: 1,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               SvgPicture.asset(
//                 'assets/icons/e_learning/topic_icon1.svg',
//                 width: 24,
//                 height: 24,
//               ),
//               const SizedBox(width: 18),
//               Expanded(
//                 child: Text(topic),
//               ),
//               if (isSelected)
//                 SvgPicture.asset(
//                   'assets/icons/result/check.svg',
//                   width: 24,
//                   height: 24,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

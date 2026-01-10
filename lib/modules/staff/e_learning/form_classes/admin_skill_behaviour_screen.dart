import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/admin/skills_behavior_table_provider.dart';
import 'package:provider/provider.dart';

class AdminSkillsBehaviourScreen extends StatefulWidget {
  final String classId;
  final String levelId;
  final String term;
  final String year;
  final String db;

  const AdminSkillsBehaviourScreen({
    super.key,
    required this.classId,
    required this.levelId,
    this.term = '1',
    this.year = '2023',
    this.db = 'aalmgzmy_linkskoo_practice',
  });

  @override
  State<AdminSkillsBehaviourScreen> createState() =>
      _AdminSkillsBehaviourScreenState();
}

class _AdminSkillsBehaviourScreenState
    extends State<AdminSkillsBehaviourScreen> {
  late double opacity;

  @override
  void initState() {
    super.initState();
    final skillsProvider =
        Provider.of<SkillsBehaviorTableProvider>(context, listen: false);
    skillsProvider.fetchSkillsAndBehaviours(
      classId: widget.classId,
      levelId: widget.levelId,
      term: widget.term,
      year: widget.year,
      db: widget.db,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Skill and Behaviour',
          style: AppTextStyles.normal600(
            fontSize: 18.0,
            color: AppColors.eLearningBtnColor1,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.eLearningBtnColor1,
            width: 34.0,
            height: 34.0,
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
          TextButton.icon(
            onPressed: () {
              // Implement download functionality
            },
            icon:
                const Icon(Icons.download, color: AppColors.eLearningBtnColor1),
            label: const Text(
              'Save',
              style: TextStyle(color: AppColors.eLearningBtnColor1),
            ),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: Consumer<SkillsBehaviorTableProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.errorMessage.isNotEmpty) {
                return Center(
                  child: Text(
                    'Error: ${provider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              if (provider.students.isEmpty || provider.skills.isEmpty) {
                return const Center(
                  child: Text('No data available'),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSubjectsTable(provider.skills, provider.students),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectsTable(List<SkillsBehaviorTable> skills,
      List<StudentSkillBehaviorTable> students) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildSubjectColumn(students),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: skills
                      .map((skill) => _buildScrollableColumn(
                          skill.name, 100, students, skill.id))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectColumn(List<StudentSkillBehaviorTable> students) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            child: const Text(
              'Student Name',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...students.map((student) {
            return Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black, // Changed to black
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScrollableColumn(String title, double width,
      List<StudentSkillBehaviorTable> students, int skillId) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.eLearningBtnColor1,
              border: Border(
                left: const BorderSide(color: Colors.white),
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white, // Keep header text white for contrast
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...students.map((student) {
            return Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                student.skills[skillId] ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black, // Changed to black
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

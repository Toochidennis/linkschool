import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/cbt/cbt_study_screen.dart';

class StudySubjectSelectionModal extends StatefulWidget {
  const StudySubjectSelectionModal({Key? key}) : super(key: key);

  @override
  State<StudySubjectSelectionModal> createState() =>
      _StudySubjectSelectionModalState();
}

class _StudySubjectSelectionModalState
    extends State<StudySubjectSelectionModal> {
  String? _selectedSubject;
  List<String> _selectedTopics = [];
  bool _showTopics = false;
  bool _isTransitioning = false;

  // Static subjects for study mode
  final List<Map<String, dynamic>> _subjects = [
    {
      'id': 'chemistry',
      'name': 'Chemistry',
      'icon': Icons.science,
      'color': Color(0xFF6366F1),
    },
    {
      'id': 'physics',
      'name': 'Physics',
      'icon': Icons.bolt,
      'color': Color(0xFF10B981),
    },
    {
      'id': 'biology',
      'name': 'Biology',
      'icon': Icons.biotech,
      'color': Color(0xFFEC4899),
    },
    {
      'id': 'mathematics',
      'name': 'Mathematics',
      'icon': Icons.calculate,
      'color': Color(0xFFF59E0B),
    },
    {
      'id': 'english',
      'name': 'English',
      'icon': Icons.menu_book,
      'color': Color(0xFF8B5CF6),
    },
    {
      'id': 'geography',
      'name': 'Geography',
      'icon': Icons.public,
      'color': Color(0xFF06B6D4),
    },
  ];

  // Topics for each subject
  final Map<String, List<String>> _topicsBySubject = {
    'chemistry': [
      'Organic Chemistry',
      'Inorganic Chemistry',
      'Physical Chemistry',
      'Chemical Bonding',
      'Acids and Bases',
      'Redox Reactions',
    ],
    'physics': [
      'Mechanics',
      'Electricity',
      'Magnetism',
      'Optics',
      'Thermodynamics',
      'Waves',
    ],
    'biology': [
      'Cell Biology',
      'Genetics',
      'Ecology',
      'Human Anatomy',
      'Evolution',
      'Plant Biology',
    ],
    'mathematics': [
      'Algebra',
      'Calculus',
      'Geometry',
      'Trigonometry',
      'Statistics',
      'Probability',
    ],
    'english': [
      'Grammar',
      'Literature',
      'Comprehension',
      'Essay Writing',
      'Poetry',
      'Drama',
    ],
    'geography': [
      'Physical Geography',
      'Human Geography',
      'Map Reading',
      'Climate',
      'Resources',
      'Population',
    ],
  };

  void _onSubjectSelected(String subjectId) {
    setState(() {
      _selectedSubject = subjectId;
      _isTransitioning = true;
    });

    // Fade out and then show topics
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showTopics = true;
          _isTransitioning = false;
        });
      }
    });
  }

  void _onTopicSelected(String topic) {
    setState(() {
      if (_selectedTopics.contains(topic)) {
        _selectedTopics.remove(topic);
      } else {
        _selectedTopics.add(topic);
      }
    });
  }

  void _onContinue() {
    if (_selectedTopics.isNotEmpty) {
      Navigator.pop(context);
      // Navigate to study screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CBTStudyScreen(
            subject: _subjects.firstWhere(
                (s) => s['id'] == _selectedSubject)['name'],
            topics: _selectedTopics,
          ),
        ),
      );
    }
  }

  void _goBack() {
    if (_showTopics) {
      setState(() {
        _isTransitioning = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showTopics = false;
            _selectedSubject = null;
            _selectedTopics = [];
            _isTransitioning = false;
          });
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showTopics) {
          _goBack();
          return false;
        }
        return true;
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _goBack,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _showTopics ? 'Select Topic' : 'Select Subject',
                    style: AppTextStyles.normal600(
                      fontSize: 20,
                      color: AppColors.text4Light,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showTopics
                    ? _buildTopicsList()
                    : _buildSubjectsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return GestureDetector(
          onTap: () => _onSubjectSelected(subject['id']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (subject['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              // border: Border.all(
              //   color: subject['color'] as Color,
              //   width: 1.5,
              // ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: subject['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    subject['icon'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    subject['name'],
                    style: AppTextStyles.normal600(
                      fontSize: 18,
                      color: AppColors.text4Light,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: subject['color'] as Color,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopicsList() {
    final topics = _topicsBySubject[_selectedSubject] ?? [];
    final subject = _subjects.firstWhere((s) => s['id'] == _selectedSubject);
    final subjectColor = subject['color'] as Color;

    return Container(
      color: subjectColor.withOpacity(0.05),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                final isSelected = _selectedTopics.contains(topic);

                return GestureDetector(
                  onTap: () => _onTopicSelected(topic),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? subjectColor.withOpacity(0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      // border: Border.all(
                      //   color: isSelected ? subjectColor : Colors.grey.shade300,
                      //   width: isSelected ? 2 : 1,
                      // ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected ? subjectColor : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            topic,
                            style: AppTextStyles.normal600(
                              fontSize: 16,
                              color: isSelected ? subjectColor : AppColors.text4Light,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _selectedTopics.isNotEmpty ? _onContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: subjectColor,
                disabledBackgroundColor: Colors.grey.shade300,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continue',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
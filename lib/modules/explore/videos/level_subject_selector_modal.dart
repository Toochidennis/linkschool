import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/videos/videos_dashboard.dart';
import 'package:linkschool/modules/model/explore/home/subject_model2.dart';
import 'package:linkschool/modules/model/explore/home/level_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/explore/subject_provider.dart';

class LevelSubjectSelectorModal extends StatefulWidget {
  const LevelSubjectSelectorModal({super.key});

  @override
  State<LevelSubjectSelectorModal> createState() =>
      _LevelSubjectSelectorModalState();
}

class _LevelSubjectSelectorModalState extends State<LevelSubjectSelectorModal> {
  LevelModel? _selectedLevel;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure provider method is called after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<SubjectProvider>(context, listen: false).fetchLevels();
      }
    });
  }

  Future<void> _onLevelSelected(LevelModel level) async {
    setState(() {
      _selectedLevel = level;
    });

    // Save selected level to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_level_id', level.id);
    await prefs.setString('selected_level_name', level.name);

    // Immediately close modal and navigate
    if (mounted) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideosDashboard(
            levelId: level.id,
            levelName: level.name,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Choose Grade',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),

          // Grade levels list
          Flexible(
            child: _buildLevelsList(),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildLevelsList() {
    return Consumer<SubjectProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingLevels) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.levels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No levels available',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: provider.levels.length,
          itemBuilder: (context, index) {
            final level = provider.levels[index];
            final isSelected = _selectedLevel?.id == level.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isSelected ? Color(0xFFFF6B35) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _onLevelSelected(level),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected ? Colors.white : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            level.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

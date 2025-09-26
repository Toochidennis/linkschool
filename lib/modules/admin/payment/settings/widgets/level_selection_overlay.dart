import 'package:flutter/material.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:provider/provider.dart';

class LevelSelectionOverlay extends StatelessWidget {
  final Function(String levelName) onLevelSelected;

  const LevelSelectionOverlay({super.key, required this.onLevelSelected});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final levels = authProvider.getLevels();
    final classes = authProvider.getClasses();

    // Filter levels that have corresponding classes
    final availableLevels = levels.where((level) {
      return classes.any((classItem) => 
        classItem['level_id'] == level['id'] && 
        classItem['class_name'] != null && 
        classItem['class_name'].toString().isNotEmpty
      );
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Level',
                  style: AppTextStyles.normal600(
                    fontSize: 20,
                    color: const Color.fromRGBO(47, 85, 221, 1),
                  ),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: availableLevels.isEmpty
                      ? Center(
                          child: Text(
                            'No levels available',
                            style: AppTextStyles.normal500(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: availableLevels.length,
                          itemBuilder: (context, index) {
                            final level = availableLevels[index];
                            final levelName = level['level_name'] ?? 'Unknown Level';
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onLevelSelected(levelName);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  levelName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

import 'package:linkschool/modules/providers/admin/grade_provider.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';

import '../../model/admin/grade _model.dart';

class GradingSettingsScreen extends StatefulWidget {
  const GradingSettingsScreen({super.key});

  @override
  _GradingSettingsScreenState createState() => _GradingSettingsScreenState();
}

class _GradingSettingsScreenState extends State<GradingSettingsScreen> {
  String? focusedField;
  bool isHoveringEdit = false;
  bool isHoveringDelete = false;
  bool isHoveringAdd = false;
  bool isHoveringSave = false;

  final TextEditingController gradeController = TextEditingController();
  final TextEditingController rangeController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  final Map<String, bool> editingStates = {};
  final Map<String, TextEditingController> editingControllers = {};
  final Map<String, FocusNode> focusNodes = {};
  final _addFormKey = GlobalKey<FormState>();
  final Map<String, GlobalKey<FormState>> formKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
      gradeProvider.fetchGrades().then((_) {
        // Initialize controllers after grades are fetched
        initializeControllers(gradeProvider.grades);
      });
    });
  }

  void initializeControllers(List<Grade> grades) {
    for (var grade in grades) {
      String itemId = grade.id;
      if (itemId.isNotEmpty) {
        createControllersForGrade(grade);
      }
    }
  }

  void createControllersForGrade(Grade grade) {
    String itemId = grade.id;
    
    editingControllers['$itemId-Grade'] =
        TextEditingController(text: grade.grade_Symbol);
    editingControllers['$itemId-Range'] =
        TextEditingController(text: grade.start);
    editingControllers['$itemId-Remark'] =
        TextEditingController(text: grade.remark);

    // Initialize focus nodes for each input field
    focusNodes['$itemId-Grade'] = FocusNode();
    focusNodes['$itemId-Range'] = FocusNode();
    focusNodes['$itemId-Remark'] = FocusNode();

    // Ensure editing state is initialized, defaults to false
    editingStates[itemId] = false;
    
    // Create a form key for this grade
    formKeys[itemId] = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    for (var controller in editingControllers.values) {
      controller.dispose();
    }
    for (var focusNode in focusNodes.values) {
      focusNode.dispose();
    }
    gradeController.dispose();
    rangeController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Grade Settings',
          style: AppTextStyles.normal600(
            fontSize: 18.0,
            color: AppColors.primaryLight,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Consumer<GradeProvider>(
        builder: (context, gradeProvider, child) {
          if (gradeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            // Very important - ensure controllers exist for all grades, including newly added ones
            for (var grade in gradeProvider.grades) {
              if (!editingControllers.containsKey('${grade.id}-Grade')) {
                createControllersForGrade(grade);
              }
            }
            
            return Padding(
              padding: const EdgeInsets.all(Constants.padding),
              child: ListView(
                children: [
                  const Text(
                    'Add and update grade details',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ...gradeProvider.grades
                      .map((grade) => buildFirstCard(grade, gradeProvider)),
                  const SizedBox(height: Constants.gap),
                  buildSecondCard(gradeProvider),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: MouseRegion(
        onEnter: (_) => setState(() => isHoveringSave = true),
        onExit: (_) => setState(() => isHoveringSave = false),
        child: FloatingActionButton(
          onPressed: () async {
            await context.read<GradeProvider>().saveNewGrades();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All grades saved successfully!')),
            );
          },
          backgroundColor:
              isHoveringSave ? Colors.blueGrey : AppColors.primaryLight,
          shape: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 7,
                  spreadRadius: 7,
                  offset: const Offset(3, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.save,
              color: AppColors.backgroundLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFirstCard(Grade grade, GradeProvider gradeProvider) {
    String itemId = grade.id;
    bool isEditing = editingStates[itemId] ?? false;

    if (!formKeys.containsKey(itemId)) {
      formKeys[itemId] = GlobalKey<FormState>();
    }

    return Card(
      key: ValueKey('grade-card-${grade.id}'), // Important for widget identity
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.borderRadius),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Form(
          key: formKeys[itemId],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MouseRegion(
                    onEnter: (_) => setState(() => isHoveringEdit = true),
                    onExit: (_) => setState(() => isHoveringEdit = false),
                    child: GestureDetector(
                      onTap: () {
                        if (isEditing) {
                          if (formKeys[itemId]!.currentState!.validate()) {
                            // Save changes if validation passes
                            setState(() {
                              editingStates[itemId] = false;
                            });
                          }
                        } else {
                          editItem(itemId);
                        }
                      },
                      child: SvgPicture.asset(
                        isEditing
                            ? 'assets/icons/result/check.svg'
                            : 'assets/icons/result/edit.svg',
                        color: isHoveringEdit ? Colors.blueGrey : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  MouseRegion(
                    onEnter: (_) => setState(() => isHoveringDelete = true),
                    onExit: (_) => setState(() => isHoveringDelete = false),
                    child: GestureDetector(
                      onTap: () async {
                        await gradeProvider.deleteGrade(grade.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Grade ${grade.grade_Symbol} deleted')),
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/icons/result/delete.svg',
                        color: isHoveringDelete ? Colors.blueGrey : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Constants.gap),
              buildEditableRow('Grade:', itemId, isEditing,
                  (value) => _validateField(value, 'Grade')),
              buildEditableRow('Range:', itemId, isEditing,
                  (value) => _validateField(value, 'Range')),
              buildEditableRow('Remark:', itemId, isEditing,
                  (value) => _validateField(value, 'Remark')),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEditableRow(
    String title,
    String itemId,
    bool isEditing,
    String? Function(String?)? validator,
  ) {
    String key = '$itemId-${title.replaceAll(':', '')}';
    
    // Ensure controllers are created when needed
    if (!editingControllers.containsKey(key)) {
      print('Warning: Missing controller for $key');
      return const SizedBox();
    }
    
    TextEditingController controller = editingControllers[key]!;
    FocusNode focusNode = focusNodes[key] ?? FocusNode();
    
    if (!focusNodes.containsKey(key)) {
      focusNodes[key] = focusNode;
    }

    focusNode.addListener(() {
      if (mounted) {  // Check if the widget is still mounted
        setState(() {
          focusedField = focusNode.hasFocus ? key : null;
        });
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.gap),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.normal500(
              fontSize: 16.0,
              color: AppColors.assessmentColor2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isEditing
                ? TextFormField(
                    key: ValueKey('input-$key'), // Important for widget identity
                    focusNode: focusNode,
                    controller: controller,
                    style: AppTextStyles.normal500(
                      fontSize: 18.0,
                      color: AppColors.backgroundDark,
                    ),
                    cursorColor: AppColors.primaryLight,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: AppColors.primaryLight),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.redAccent),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.redAccent),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    validator: validator,
                  )
                : Text(
                    controller.text,
                    style: AppTextStyles.normal500(
                      fontSize: 18.0,
                      color: AppColors.backgroundDark,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void editItem(String itemId) {
    setState(() {
      editingStates[itemId] = true;
    });
  }

  Widget buildSecondCard(GradeProvider gradeProvider) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.borderRadius),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Form(
          key: _addFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInputField('Grade', gradeController, (value) {},
                  validator: (value) => _validateField(value, 'Grade')),
              buildInputField('Range', rangeController, (value) {},
                  validator: (value) => _validateField(value, 'Range')),
              buildInputField('Remark', remarkController, (value) {},
                  validator: (value) => _validateField(value, 'Remark')),
              const SizedBox(height: Constants.gap),
              Align(
                alignment: Alignment.bottomRight,
                child: MouseRegion(
                  onEnter: (_) => setState(() => isHoveringAdd = true),
                  onExit: (_) => setState(() => isHoveringAdd = false),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_addFormKey.currentState!.validate()) {
                        try {
                          // Add the grade
                          Grade newGrade = await gradeProvider.addGrade(
                            gradeController.text,
                            rangeController.text,
                            remarkController.text,
                          );
                          
                          // Create controllers for the new grade
                          createControllersForGrade(newGrade);
                          
                          // Clear input fields
                          gradeController.clear();
                          rangeController.clear();
                          remarkController.clear();
                          
                          // Show success message
                          MotionToast.success(
                            title: Text(
                              "Grade Added",
                              style: AppTextStyles.normal600(
                                fontSize: 16,
                                color: AppColors.assessmentColor1,
                              ),
                            ),
                            description: Text(
                              "Grade added successfully!",
                              style: AppTextStyles.normal400(
                                fontSize: 14,
                                color: AppColors.assessmentColor1,
                              ),
                            ),
                          ).show(context);
                          
                          // Force rebuild to make new grade visible
                          setState(() {});
                        } catch (error) {
                          print('Error adding grade: ${error.toString()}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error adding grade: ${error.toString()}')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHoveringAdd
                          ? Colors.blueGrey
                          : AppColors.secondaryLight,
                      fixedSize: const Size(100, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Constants.borderRadius),
                      ),
                    ),
                    child: const Text(
                      'Add +',
                      style: AppTextStyles.normal5Light,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(
    String label,
    TextEditingController controller,
    ValueChanged<String> onChanged, {
    String? Function(String?)? validator,
  }) {
    // Create a focus node if one doesn't exist
    if (!focusNodes.containsKey(label)) {
      focusNodes[label] = FocusNode();
    }
    final FocusNode focusNode = focusNodes[label]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.gap),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: AppTextStyles.normal600(fontSize: 12, color: Colors.black),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              validator: validator,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: focusedField == label
                        ? AppColors.primaryLight
                        : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter a $fieldName';
    }
    return null;
  }
}
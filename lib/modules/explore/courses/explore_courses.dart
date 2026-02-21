import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../common/constants.dart';
import 'package:linkschool/modules/providers/explore/courses/course_provider.dart';
import 'package:linkschool/modules/model/explore/courses/category_model.dart';
import 'package:linkschool/modules/model/explore/courses/course_model.dart';
import 'package:linkschool/modules/model/cbt_user_model.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/providers/create_user_profile_provider.dart';
import 'package:linkschool/modules/explore/cbt/widgets/cbt_auth_dialog.dart';
import 'package:linkschool/modules/services/user_profile_update_service.dart';
import 'package:linkschool/modules/services/explore/courses/course_service.dart';
import 'package:linkschool/modules/providers/explore/courses/enrollment_provider.dart';
import 'package:linkschool/modules/widgets/user_profile_update_modal.dart';
import 'package:linkschool/modules/widgets/network_dialog.dart';
import 'course_description_screen.dart';
import 'course_content_screen.dart';
import 'create_user_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreCourses extends StatefulWidget {
  final bool allowProfilePrompt;

  const ExploreCourses({super.key, this.allowProfilePrompt = true});

  @override
  State<ExploreCourses> createState() => _ExploreCoursesState();
}

class _ExploreCoursesState extends State<ExploreCourses>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;
  bool _wasLoading = true;
  bool _animationTriggered = false;
  bool _didCheckProfileModal = false;
  bool _loadedActiveProfile = false;
  CbtUserProfile? _activeProfile;
  bool _navigating = false;
  bool _isBootstrapping = false;
  late final CbtUserProvider _cbtUserProvider;
  int? _lastUserId;
  CourseModel? _pendingCourse;
  CategoryModel? _pendingCategory;
  bool _isShowingAccountSwitcher = false; 
  String? _lastNetworkMessage;
  bool _imagesPrecached = false;
  String? _lastPrecacheKey;

  // Persistent image cache for course thumbnails
  final CacheManager _coursesCacheManager = CacheManager(
    Config(
      'coursesCacheKey',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
    ),
  );



  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Set<int> _selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    // ... your animation setup ...
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );
    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _bounceController.forward();
    });

    _cbtUserProvider = context.read<CbtUserProvider>();
    _lastUserId = _cbtUserProvider.currentUser?.id;
    _cbtUserProvider.addListener(_handleUserChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapScreen();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  String _userFirstName(CbtUserModel user) {
    final first = user.first_name?.trim();
    if (first != null && first.isNotEmpty) return first;
    final name = (user.name ?? '').trim();
    if (name.isEmpty) return 'User';
    return name.split(' ').first;
  }

  String _userLastName(CbtUserModel user) {
    final last = user.last_name?.trim();
    if (last != null && last.isNotEmpty) return last;
    final name = (user.name ?? '').trim();
    final parts = name.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.length <= 1) return '';
    return parts.last;
  }

  void _showNetworkMessage(String message) {
    if (message.isEmpty || message == _lastNetworkMessage) return;
    _lastNetworkMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(message),
      //     backgroundColor: Colors.orange,
      //   ),
      // );
    });
  }

  void _precacheCourseImages(List<CategoryModel> categories) {
    final urls = <String>{};
    for (final category in categories) {
      for (final course in category.courses) {
        final raw = course.imageUrl.trim();
        if (raw.isEmpty) continue;
        final url = raw.startsWith('https')
            ? raw
            : "https://linkskool.net/$raw";
        urls.add(url);
      }
    }

    for (final url in urls) {
      try {
        precacheImage(
          CachedNetworkImageProvider(url, cacheManager: _coursesCacheManager),
          context,
        );
      } catch (_) {
        // ignore errors while precaching
      }
    }
  }
  
  Future<void> _bootstrapScreen() async {
  if (!mounted || _isBootstrapping) return;
  _isBootstrapping = true;
  try {
    final cbtUserProvider = context.read<CbtUserProvider>();

    // 1) Refresh current user
    await cbtUserProvider.refreshCurrentUser();
    if (!mounted) return;

    final user = cbtUserProvider.currentUser;

    // If not signed in: load public courses and exit
    if (user == null) {
      await context.read<ExploreCourseProvider>().fetchCategoriesAndCourses();
      if (!mounted) return;
      setState(() {
        _loadedActiveProfile = true;
        _activeProfile = null;
      });
      return;
    }

    // 2) Fetch profiles immediately
    try {
      final profileProvider = context.read<CreateUserProfileProvider>();
      final profiles =
          await profileProvider.fetchUserProfiles(user.id.toString());
      if (profiles.isNotEmpty) {
        await cbtUserProvider.replaceProfiles(profiles);
      }
    } catch (e) {
      debugPrint("Failed to fetch profiles on load: $e");
    }

    if (!mounted) return;

    // 3) Resolve active profile
    final savedId = await _loadActiveProfileId();
    final savedDob = await _loadActiveProfileDob();

    final updatedProfiles =
        cbtUserProvider.currentUser?.profiles ?? <CbtUserProfile>[];

    CbtUserProfile? selected;
    if (savedId != null) {
      try {
        selected = updatedProfiles.firstWhere((p) => p.id == savedId);
      } catch (_) {
        selected = null;
      }
    }
    selected ??= updatedProfiles.isNotEmpty ? updatedProfiles.first : null;

    if (!mounted) return;

    setState(() {
      _activeProfile = selected;
      _loadedActiveProfile = true;
    });

    // 4) Persist selection if needed
    if (selected?.id != null) {
      await _saveActiveProfileId(selected!.id, birthDate: selected.birthDate);
    }

    // 5) Phone modal: show ONCE per screen session, not repeatedly
    if (widget.allowProfilePrompt &&
        cbtUserProvider.isPhoneMissing &&
        !_didCheckProfileModal) {
      _didCheckProfileModal = true;

      await UserProfileUpdateModal.show(
        context,
        user: cbtUserProvider.currentUser,
        onSave: ({
          required String phone,
          required String gender,
          required String birthDate,
        }) async {
          final profileService = UserProfileUpdateService();
          final currentUser = cbtUserProvider.currentUser;
          if (currentUser == null) return;

          try {
            await profileService.updateUserPhone(
              userId: currentUser.id!,
              firstName: currentUser.name!.split(' ').first,
              lastName: currentUser.name!.split(' ').last,
              phone: phone,
              attempt: currentUser.attempt.toString(),
              email: currentUser.email,
              gender: gender,
              birthDate: birthDate,
            );

            await cbtUserProvider.refreshCurrentUser();
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating profile: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );

      // After modal: if still missing, warn and stop (optional)
      await cbtUserProvider.refreshCurrentUser();
      if (!mounted) return;

      if (cbtUserProvider.isPhoneMissing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number is required to access courses'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        // You can return here if you want to block course access entirely:
        // return;
      }
    }

    // 6) Load courses (always runs)
    await context.read<ExploreCourseProvider>().fetchCategoriesAndCourses(
          profileId: selected?.id ?? savedId,
          dateOfBirth: selected?.birthDate ?? savedDob,
        );
  } finally {
    _isBootstrapping = false;
  }
}
  void _handleUserChange() {
    final userId = _cbtUserProvider.currentUser?.id;
    if (userId != _lastUserId) {
      _lastUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _bootstrapScreen();
      });
    }
  }

  @override
  void dispose() {
    _cbtUserProvider.removeListener(_handleUserChange);
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No automatic profile prompt here anymore; profile completion is
    // handled on-demand (course tap) or from CBT Dashboard after sign-in.
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // Fetch categories and courses when the widget is initialized
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<CourseProvider>().fetchCategoriesAndCourses();
  //   });
  // }

  // Helper method to get category color based on category name
  Color _getCategoryColor(String categoryName) {
    final colors = {
      'Animation and Storytelling': const Color(0xFF6366F1),
      'Graphic Design and Visual Arts': const Color(0xFFEC4899),
      'Web Development': const Color(0xFF10B981),
      'Programming and Software Development': const Color(0xFF8B5CF6),
      'Artifical Intelligence': const Color(0xFFEF4444),
      'Animation and Creative Media': const Color(0xFFF59E0B),
      'Engineering and Technology': const Color(0xFF06B6D4),
      'Mobile App Development': const Color(0xFF06B6D4),
    };
    return colors[categoryName] ?? const Color(0xFF6366F1);
  }

  // Helper method to filter courses based on search query and selected category
  List<CategoryModel> _getFilteredCategories(
      List<CategoryModel> allCategories) {
    List<CategoryModel> categoryFiltered;
    if (_selectedCategoryIds.isEmpty) {
      categoryFiltered = List.from(allCategories);
    } else {
      categoryFiltered = allCategories
          .where((cat) => _selectedCategoryIds.contains(cat.id))
          .toList();
    }

    List<CategoryModel> searchFiltered;
    if (_searchQuery.isEmpty) {
      searchFiltered = categoryFiltered;
    } else {
      searchFiltered = [];
      final lowerQuery = _searchQuery.toLowerCase();

      for (var category in categoryFiltered) {
        final matchingCourses = category.courses.where((course) {
          return course.courseName.toLowerCase().contains(lowerQuery) ||
              course.description.toLowerCase().contains(lowerQuery);
        }).toList();

        if (matchingCourses.isNotEmpty) {
          searchFiltered.add(CategoryModel(
            id: category.id,
            name: category.name,
            description: category.description,
            imageUrl: category.imageUrl,
            courses: matchingCourses,
          ));
        }
      }
    }

    return _groupEnrolledCourses(searchFiltered);
  }

  List<CategoryModel> _groupEnrolledCourses(List<CategoryModel> categories) {
    final List<CourseModel> enrolledCourses = [];
    final List<CategoryModel> remainingCategories = [];

    for (final category in categories) {
      final enrolled =
          category.courses.where((course) => course.isEnrolled).toList();
      final notEnrolled =
          category.courses.where((course) => !course.isEnrolled).toList();

      if (enrolled.isNotEmpty) {
        enrolledCourses.addAll(enrolled);
      }

      if (notEnrolled.isNotEmpty) {
        remainingCategories.add(CategoryModel(
          id: category.id,
          name: category.name,
          description: category.description,
          imageUrl: category.imageUrl,
          courses: notEnrolled,
        ));
      }
    }

    if (enrolledCourses.isEmpty) {
      return remainingCategories;
    }

    return [
      CategoryModel(
        id: -1,
        name: 'Enrolled Courses',
        description: '',
        imageUrl: null,
        courses: enrolledCourses,
      ),
      ...remainingCategories,
    ];
  }

  void _showFilterBottomSheet(List<CategoryModel> categories) {
    // Local state for the bottom sheet
    Set<int> tempSelectedIds = Set.from(_selectedCategoryIds);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter by Category',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: categories.map((category) {
                          final isSelected =
                              tempSelectedIds.contains(category.id);
                          return FilterChip(
                            label: Text(category.name),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setModalState(() {
                                if (selected) {
                                  tempSelectedIds.add(category.id);
                                } else {
                                  tempSelectedIds.remove(category.id);
                                }
                              });
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor:
                                const Color(0xFFFFA500).withOpacity(0.2),
                            checkmarkColor: const Color(0xFFFFA500),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFFFA500)
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFFFA500)
                                  : Colors.grey.shade300,
                              width: isSelected ? 1.5 : 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              tempSelectedIds.clear();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategoryIds = tempSelectedIds;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA500),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleSignIn() async {
    if (!mounted) return;
    try {
      final signedIn = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) => const CbtAuthDialog(),
      );

      if (signedIn == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed in successfully')),
          );

          final cbtUserProvider =
              Provider.of<CbtUserProvider>(context, listen: false);
          await cbtUserProvider.refreshCurrentUser();

          if (widget.allowProfilePrompt && cbtUserProvider.isPhoneMissing) {
            await Future.delayed(const Duration(milliseconds: 500));
            if (!mounted) return;

            await UserProfileUpdateModal.show(
              context,
              user: cbtUserProvider.currentUser,
              onSave: ({
                required String phone,
                required String gender,
                required String birthDate,
              }) async {
                final profileService = UserProfileUpdateService();
                final currentUser = cbtUserProvider.currentUser;
                if (currentUser == null) return;

                try {
                  await profileService.updateUserPhone(
                    userId: currentUser.id!,
                    firstName: _userFirstName(currentUser),
                    lastName: _userLastName(currentUser),
                    phone: phone,
                    attempt: currentUser.attempt.toString(),
                    email: currentUser.email,
                    gender: gender,
                    birthDate: birthDate,
                  );
                  await cbtUserProvider.refreshCurrentUser();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating profile: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          }

          await _bootstrapScreen();
          if (!mounted) return;

          final profiles = cbtUserProvider.currentUser?.profiles ??
              <CbtUserProfile>[];
          final savedId = await _loadActiveProfileId();
          CbtUserProfile? activeProfile;

          if (savedId != null) {
            try {
              activeProfile = profiles.firstWhere((p) => p.id == savedId);
            } catch (_) {
              activeProfile = null;
            }
          }
          activeProfile ??= profiles.isNotEmpty ? profiles.first : null;

          setState(() {
            _activeProfile = activeProfile;
          });

          debugPrint(
              'After bootstrap - _pendingCourse: ${_pendingCourse?.courseName}');
          debugPrint(
              'After bootstrap - _pendingCategory: ${_pendingCategory?.name}');
          debugPrint('After bootstrap - _activeProfile: ${_activeProfile?.id}');

          if (_pendingCourse != null && _pendingCategory != null) {
            debugPrint('Entering enrollment check block');
            final profileId = _activeProfile?.id;
            debugPrint('Profile ID: $profileId');
            debugPrint('Cohort ID: ${_pendingCourse!.cohortId}');

            if (profileId != null && _pendingCourse!.cohortId != null) {
              debugPrint('About to check enrollment...');
              try {
                final isEnrolled = await CourseService().checkIsEnrolled(
                  cohortId: _pendingCourse!.cohortId!,
                  profileId: profileId,
                );
                debugPrint(
                    'Enrollment check after sign-in: isEnrolled=$isEnrolled for course ${_pendingCourse!.courseName}');
              } catch (e) {
                debugPrint('Error checking enrollment after sign-in: $e');
              }
            } else {
              debugPrint(
                  'Skipped enrollment check - profileId: $profileId, cohortId: ${_pendingCourse!.cohortId}');
            }
          } else {
            debugPrint(
                'Skipped enrollment check - _pendingCourse: $_pendingCourse, _pendingCategory: $_pendingCategory');
          }

          await _resumePendingCourseSelection();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign-in was cancelled')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

 Future<void> _showAccountSwitcherDialog(BuildContext context, dynamic user) async {
  // Prevent multiple dialogs from opening
  if (_isShowingAccountSwitcher) {
    debugPrint('Dialog already showing, ignoring tap');
    return;
  }
  
 _isShowingAccountSwitcher = true;
 debugPrint('Opening account switcher dialog, flag set to: $_isShowingAccountSwitcher');

  final userId = user?.id;
  if (userId == null) {
    _isShowingAccountSwitcher = false;
    return;
  }

  try {
    final canUseNetwork = await NetworkDialog.ensureOnline(
      context,
      message:
          'This action requires an internet connection. Please connect and try again.',
    );
    if (!canUseNetwork || !mounted) {
      _isShowingAccountSwitcher = false;
      return;
    }
    final profileProvider =
        Provider.of<CreateUserProfileProvider>(context, listen: false);
    final profiles =
        await profileProvider.fetchUserProfiles(userId.toString());
    if (profiles.isNotEmpty) {
      await Provider.of<CbtUserProvider>(context, listen: false)
          .replaceProfiles(profiles);
    }
  } catch (e) {
    debugPrint("Failed to fetch profiles: $e");
    _isShowingAccountSwitcher = false;
    return;
  }

  if (!mounted) {
    _isShowingAccountSwitcher = false;
    return;
  }

  final dialogUser =
      Provider.of<CbtUserProvider>(context, listen: false).currentUser ?? user;
  final profiles = (dialogUser?.profiles as List<CbtUserProfile>?) ??
      <CbtUserProfile>[];
  final activeProfileId = _activeProfile?.id;
  
  try {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Switch Profile',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                if (profiles.isNotEmpty)
                  Column(
                    children: profiles.map((profile) {
                      final name = _profileName(profile);
                      final subtitle = dialogUser?.email?.toString() ?? "";
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildAccountItem(
                          profile: profile,
                          name: name,
                          email: subtitle,
                          imageUrl: profile.avatar,
                          isActive: activeProfileId == profile.id,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _activeProfile = profile;
                            });
                            _saveActiveProfileId(profile.id,
                                birthDate: profile.birthDate);
                            if (profile.id != null) {
                              context.read<ExploreCourseProvider>().fetchCategoriesAndCourses(
                                profileId: profile.id,
                                dateOfBirth: profile.birthDate,
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push<CbtUserProfile>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateUserProfileScreen(
                            userId: userId.toString(),
                          ),
                        ),
                      );
                      if (mounted && result != null) {
                        setState(() => _activeProfile = result);
                        await _saveActiveProfileId(result.id, birthDate: result.birthDate);
                        await context.read<ExploreCourseProvider>().fetchCategoriesAndCourses(
                          profileId: result.id,
                          dateOfBirth: result.birthDate,
                        );
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add New Profile'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.black87,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  } finally {
    debugPrint('Account switcher dialog closed');
    debugPrint('Flag before reset: $_isShowingAccountSwitcher');
    
    // Add a small delay to ensure the dialog animation completes
    await Future.delayed(const Duration(milliseconds: 300));
    
    _isShowingAccountSwitcher = false;
    debugPrint('Flag after reset: $_isShowingAccountSwitcher');
  }
}
  
  void _setPendingCourseSelection(
      CourseModel course,
      CategoryModel category,
    ) {
      _pendingCourse = course;
      _pendingCategory = category;
    }

  void _clearPendingCourseSelection() {
      _pendingCourse = null;
      _pendingCategory = null;
    }

  Future<void> _resumePendingCourseSelection() async {
      final pendingCourse = _pendingCourse;
      final pendingCategory = _pendingCategory;
      if (pendingCourse == null || pendingCategory == null) return;

      _clearPendingCourseSelection();
      await _handleCourseTap(pendingCourse, pendingCategory);
    }

  Future<void> _handleCourseTap(CourseModel course, CategoryModel category) async {
      if (_navigating) return;
      _navigating = true;
      try {
        final canUseNetwork = await NetworkDialog.ensureOnline(context);
        if (!canUseNetwork || !mounted) return;
        final cbtUserProvider =
            Provider.of<CbtUserProvider>(context, listen: false);
        final isSignedIn = cbtUserProvider.currentUser != null;

        if (!isSignedIn) {
          _setPendingCourseSelection(course, category);
          await _handleSignIn();
          return;
        }
        if (cbtUserProvider.isPhoneMissing) {
          await UserProfileUpdateModal.show(
            context,
            user: cbtUserProvider.currentUser,
            onSave: (
                {required String phone,
                required String gender,
                required String birthDate}) async {
              final profileService = UserProfileUpdateService();
              final user = cbtUserProvider.currentUser;
              if (user == null) return;
              await profileService.updateUserPhone(
                userId: user.id!,
                firstName: _userFirstName(user),
                lastName: _userLastName(user),
                phone: phone,
                attempt: user.attempt.toString(),
                email: user.email,
                gender: gender,
                birthDate: birthDate,
              );
              await cbtUserProvider.refreshCurrentUser();
            },
          );

          if (cbtUserProvider.isPhoneMissing) {
            return;
          }
        }

        if (!course.hasActiveCohort) {
          showDialog(
            context: context,
            builder: (context) => Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.orange, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'No Active Cohort',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'There is no active cohort for this course.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA500),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('OK'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          return;
        }

        final profileId = _activeProfile?.id;
        bool isEnrolled = false;

        if (profileId != null && course.cohortId != null) {
          try {
            isEnrolled = await CourseService().checkIsEnrolled(
              cohortId: course.cohortId!,
              profileId: profileId,
            );
          } catch (e) {
            // If verification fails, fall back to showing the course description.
          }
        }

        if (isEnrolled) {
          bool isPaid = true;
          if (!course.isFree) {
            if (profileId == null || course.cohortId == null) {
              isPaid = false;
            } else {
              try {
                isPaid = await context
                    .read<EnrollmentProvider>()
                    .checkPaymentStatus(
                      cohortId: course.cohortId!.toString(),
                      profileId: profileId,
                    );
              } catch (e) {
                final status = (course.paymentStatus ?? '').toLowerCase();
                isPaid = status == 'paid' ||
                    status == 'true' ||
                    status == '1';
              }
            }
          }

          final imageUrl = course.imageUrl.startsWith('https')
              ? course.imageUrl
              : "https://linkskool.net/${course.imageUrl}";
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseContentScreen(
                lessonImage: imageUrl,
                cohortId: course.cohortId.toString(),
                isFree: course.isFree,
                trialExpiryDate: course.trialExpiryDate,
                courseTitle: course.courseName,
                courseDescription: course.description,
                provider: category.name,
                courseId: course.id,
                courseName: course.courseName,
                categoryId: course.programId ?? category.id,
                providerSubtitle: 'Powered By Digital Dreams',
                category: category.name.toUpperCase(),
                categoryColor: _getCategoryColor(category.name),
                profileId: _activeProfile?.id,
                trialType: course.trialType,
                trialValue: course.trialValue,
                lessonsTaken: course.lessonsTaken,
                cohortCost: course.cost.toInt(),
              ),
            ),
          );
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDescriptionScreen(
              profileId: _activeProfile?.id,
              firstName: _activeProfile?.firstName,
              lastName: _activeProfile?.lastName,
              course: course,
              categoryName: category.name,
              categoryId: course.programId ?? category.id,
              provider: category.name,
              cohortId: course.cohortId.toString(),
              isFree: course.isFree,
              trialExpiryDate: course.trialExpiryDate,
              providerSubtitle: 'Powered By Digital Dreams',
              categoryColor: _getCategoryColor(category.name),
              hasEnrolled: isEnrolled,
            ),
          ),
        );
      } finally {
        _navigating = false;
      }
    }

    Widget _profileSwitcherBadge() {
  return Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: const Icon(
      Icons.keyboard_arrow_down,
      size: 18,
      color: Colors.black87,
    ),
  );
}

    Widget _buildAccountItem({
    required CbtUserProfile profile,
    required String name,
    required String email,
    String? imageUrl,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: Colors.grey.shade200) : null,
        ),
        child: Row(
          children: [
            _avatarWidget(
              imageUrl: imageUrl,
              name: name,
              radius: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            //  delete and update icons
            //  popupmenubutton
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  // handle edit
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateUserProfileScreen(
                        userId: profile.userId.toString(),
                        existingProfile: profile,
                      ),
                    ),
                  );

                  // If edit was successful, refresh profiles and close the modal
                  if (result == true && mounted) {
                    try {
                      final profileProvider = Provider.of<CreateUserProfileProvider>(
                          context,
                          listen: false);
                      final cbtUserProvider =
                          Provider.of<CbtUserProvider>(context, listen: false);
                      
                      // Fetch updated profiles
                      final userId = cbtUserProvider.currentUser?.id.toString();
                      if (userId != null) {
                        final updatedProfiles =
                            await profileProvider.fetchUserProfiles(userId);
                        if (updatedProfiles.isNotEmpty) {
                          await cbtUserProvider.replaceProfiles(updatedProfiles);
                        }
                      }
                      
                      // Close the dialog to reflect changes
                      Navigator.of(context).pop();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error refreshing profiles: $e')),
                        );
                      }
                    }
                  }
                } else if (value == 'delete') {
                  // handle delete
                  final profileProvider =
                      Provider.of<CreateUserProfileProvider>(context,
                          listen: false);
                  final cbtUserProvider =
                      Provider.of<CbtUserProvider>(context, listen: false);
                  try {
                    await profileProvider
                        .deleteUserProfile(profile.id.toString());

                    // Remove from local profiles list
                    final currentProfiles = List<CbtUserProfile>.from(
                        cbtUserProvider.currentUser?.profiles ?? []);
                    currentProfiles.removeWhere((p) => p.id == profile.id);
                    await cbtUserProvider.replaceProfiles(currentProfiles);

                    // If it was the active profile, clear it
                    if (_activeProfile?.id == profile.id) {
                      setState(() {
                        _activeProfile = null;
                      });
                      await _saveActiveProfileId(null);
                    }

                    // Close the dialog to reflect changes
                    Navigator.of(context).pop();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Profile deleted successfully')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting profile: $e')),
                      );
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _profileName(CbtUserProfile profile) {
    final first = profile.firstName?.trim() ?? '';
    final last = profile.lastName?.trim() ?? '';
    final name = "$first $last".trim();
    if (name.isNotEmpty) return name;
    if (profile.id != null) return "Profile ${profile.id}";

    return 'Profile';
  }

  String _profileInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Future<void> _saveActiveProfileId(int? id, {String? birthDate}) async {
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setInt('active_profile_id', id);
      if (birthDate != null) {
        await prefs.setString('active_profile_dob', birthDate);
      } else {
        await prefs.remove('active_profile_dob');
      }
    } else {
      await prefs.remove('active_profile_id');
      await prefs.remove('active_profile_dob');
      // Also clear provider persisted values
      if (mounted) {
        Provider.of<ExploreCourseProvider>(context, listen: false)
            .clearPersistedProfile();
      }
    }
  }

  Future<int?> _loadActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('active_profile_id');
  }

  Future<String?> _loadActiveProfileDob() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('active_profile_dob');
  }


  Widget _avatarWidget(
      {String? imageUrl, required String name, double radius = 20}) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final colors = [
        Colors.blue.shade300,
        Colors.purple.shade300,
        Colors.pink,
        Colors.orange,
        Colors.teal,
        Colors.indigo,
      ];
      final randomColor = colors[name.hashCode % colors.length];
      
      return CircleAvatar(
        radius: radius,
        backgroundColor: randomColor,
        backgroundImage: NetworkImage(imageUrl),
      );
    }

 final colors = [
        Colors.blue.shade300,
        Colors.purple.shade300,
        Colors.pink,
        Colors.orange,
        Colors.teal,
        Colors.indigo,
      ];
      final randomColor = colors[name.hashCode % colors.length];
      
    


    final initials = _profileInitials(name);
    return CircleAvatar(
      radius: radius,
      backgroundColor: randomColor,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.6,
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 800 + (index * 200)),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Urbanist',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Icon(
                            icon,
                            size: 24,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCard({
    required Widget child,
    required int index,
  }) {
    final start = (index * 0.06).clamp(0.0, 0.85);
    final end = (start + 0.25).clamp(0.0, 1.0);

    final fade = CurvedAnimation(
      parent: _fadeController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    final slide = CurvedAnimation(
      parent: _slideController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    // Use a stronger elastic scale for a visible bounce effect
    final scale = CurvedAnimation(
      parent: _bounceController,
      curve: Interval(start, end, curve: Curves.elasticOut),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(slide),
        child: ScaleTransition(
          // Increase scale delta so the bounce is noticeable
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(scale),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access user provider to get current user info
    final cbtUserProvider = Provider.of<CbtUserProvider>(context);
    final user = cbtUserProvider.currentUser;
    final profiles = user?.profiles ?? <CbtUserProfile>[];
    final firstProfile = profiles.isNotEmpty ? profiles.first : null;
    CbtUserProfile? activeProfile = _activeProfile;
    if (activeProfile != null) {
      final stillExists =
          profiles.any((profile) => profile.id == activeProfile?.id);
      if (!stillExists) {
        activeProfile = null;
      }
    }
    activeProfile ??= firstProfile;
    if (!_loadedActiveProfile && profiles.isNotEmpty) {
      _loadedActiveProfile = true;
  
    }
    // if (_activeProfile == null && activeProfile != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (!mounted) return;
    //     setState(() {
    //       _activeProfile = activeProfile;
    //     });
    //     if (activeProfile?.id != null) {
    //       _saveActiveProfileId(activeProfile!.id, birthDate: activeProfile!.birthDate);
    //     }
    //     if (mounted && activeProfile != null) {
    //       context.read<ExploreCourseProvider>().fetchCategoriesAndCourses(
    //             profileId: activeProfile.id,
    //             dateOfBirth: activeProfile.birthDate,
    //           );
    //     }
    //   });
    // }

    final displayName =
        activeProfile != null ? _profileName(activeProfile) : '__';

    return Container(
      decoration: Constants.customBoxDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer<ExploreCourseProvider>(
          builder: (context, courseProvider, child) {
            _showNetworkMessage(courseProvider.errorMessage);
            final loading = courseProvider.isLoading;

            final precacheKey =
                '${_activeProfile?.id ?? 'public'}:${_activeProfile?.birthDate ?? ''}';
            if (_lastPrecacheKey != precacheKey) {
              _lastPrecacheKey = precacheKey;
              _imagesPrecached = false;
            }

            if (!_imagesPrecached &&
                !loading &&
                courseProvider.categories.isNotEmpty) {
              _imagesPrecached = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _precacheCourseImages(courseProvider.categories);
              });
            }

// If we go back into loading (refresh / retry), allow replay
            if (!_wasLoading && loading) {
              _animationTriggered = false;
              _fadeController.reset();
              _slideController.reset();
              _bounceController.reset();
            }

// When loading finishes, start animations AFTER first real-content frame
            if (_wasLoading && !loading && !_animationTriggered) {
              _animationTriggered = true;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                _fadeController
                  ..reset()
                  ..forward();

                _slideController
                  ..reset()
                  ..forward();

                _bounceController
                  ..reset()
                  ..forward();
              });
            }

            _wasLoading = loading;
            // Helper function to render result content
            Widget buildContent() {
              if (courseProvider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFA500),
                    ),
                  ),
                );
              }

              if (courseProvider.errorMessage.isNotEmpty &&
                  courseProvider.categories.isEmpty) {
                // Show error state only when there's no cached data to display.
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: Colors.grey,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            courseProvider.fetchCategoriesAndCourses(
                              profileId: _activeProfile?.id,
                              dateOfBirth: _activeProfile?.birthDate,
                              forceRefresh: true,
                            );
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 25, 32, 171),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (courseProvider.categories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                    child: Text(
                      'No courses available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }

              final filteredCategories =
                  _getFilteredCategories(courseProvider.categories);

              if (filteredCategories.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No courses found',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: filteredCategories.asMap().entries.map((entry) {
                  final category = entry.value;
                  if (category.courses.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return _buildAnimatedCard(
                      index: entry.key + 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Card as Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: _buildCategoryHeaderCard(category),
                          ),

                          const SizedBox(height: 12),

                          // Courses Horizontal List
                          SizedBox(
                            height: 250,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: category.courses.length,
                              itemBuilder: (context, index) {
                                return _buildCompactCourseCard(
                                    category.courses[index], category);
                              },
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ));
                }).toList(),
              );
            }

            return RefreshIndicator(
                  onRefresh: () async {
    await context.read<ExploreCourseProvider>().refresh(
      profileId: activeProfile?.id,
      dateOfBirth: activeProfile?.birthDate,
    );

                  if (courseProvider.errorMessage.isNotEmpty) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(courseProvider.errorMessage),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Profile Header Section
                      if (user != null)
                        _buildAnimatedCard(
                          index: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                              child: GestureDetector(
                                onTap: () async {
    if (_isShowingAccountSwitcher) {
      debugPrint('Dialog already showing, ignoring tap');
      return;
    }
    await _showAccountSwitcherDialog(context, user);
  },
                                child: Row(
                                  children: [
                                    Stack(
  clipBehavior: Clip.none,
  children: [
    _avatarWidget(
      imageUrl: activeProfile?.avatar,
      name: displayName,
      radius: 24,
    ),
    Positioned(
      bottom: -2,
      right: -2,
      child: _profileSwitcherBadge(),
    ),
  ],
),
                                    const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hi, $displayName',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'What would you like to learn today?',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Search Bar and Filter
                      _buildAnimatedCard(
                        index: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Search for courses...',
                                      prefixIcon: Icon(Icons.search,
                                          color: Colors.grey),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                    ),
                                    onChanged: (value) {
                                      // State updated via listener
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFA500)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFFFA500)
                                              .withOpacity(0.3)),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.filter_list_rounded,
                                        color: Color(0xFFFFA500),
                                      ),
                                      onPressed: () => _showFilterBottomSheet(
                                          courseProvider.categories),
                                    ),
                                  ),
                                  if (_selectedCategoryIds.isNotEmpty)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 8,
                                          minHeight: 8,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Main Content
                      buildContent(),

                      const SizedBox(height: 100),
                    ],
                  ),
                ));
          },
        ),
      ),
    );
  }

  Widget _buildCategoryHeaderCard(CategoryModel category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildCompactCourseCard(CourseModel course, CategoryModel category) {
    return GestureDetector(
      onTap: () => _handleCourseTap(course, category),
      child: Container(
          width: 240,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      cacheManager: _coursesCacheManager,
                      imageUrl: course.imageUrl.startsWith('https')
                          ? course.imageUrl
                          : "https://linkskool.net/${course.imageUrl}",
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return Container(
                          height: 120,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFFA500),
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return Container(
                          height: 120,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 32,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                    // Category badge

                    // Price & Trial badges
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Price badge (Free / Paid)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (course.isFree == true)
                                  ? Colors.green.shade600
                                  : Colors.red.shade600,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (course.isFree == true)
                                  ? 'Free'
                                  : course.priceLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),

                          // Optional Trial badge
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Course Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Title
                      Text(
                        course.courseName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Description
                      Expanded(
                        child: Text(
                          course.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Provider
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFA500), Color(0xFFFF6B00)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'B',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Powered By Digital Dreams',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Take Course Button
                      // SizedBox(
                      //   width: double.infinity,
                      //   height: 32,
                      //   child: OutlinedButton(
                      //     onPressed: () {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(
                      //           content: Text('Starting ${course['title']} course...'),
                      //           duration: const Duration(seconds: 2),
                      //         ),
                      //       );
                      //     },
                      //     style: OutlinedButton.styleFrom(
                      //       side: const BorderSide(color: Color(0xFFFFA500), width: 1.5),
                      //       padding: EdgeInsets.zero,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //     ),
                      //     child: const Text(
                      //       'Take Course',
                      //       style: TextStyle(
                      //         fontSize: 12,
                      //         fontWeight: FontWeight.w700,
                      //         color: Color(0xFFFFA500),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}





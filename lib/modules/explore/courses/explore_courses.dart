import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../common/constants.dart';
import 'package:linkschool/modules/providers/explore/courses/course_provider.dart';
import 'package:linkschool/modules/model/explore/courses/category_model.dart';
import 'package:linkschool/modules/model/explore/courses/course_model.dart';
import 'package:linkschool/modules/model/cbt_user_model.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/providers/create_user_profile_provider.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:linkschool/modules/services/user_profile_update_service.dart';
import 'package:linkschool/modules/widgets/user_profile_update_modal.dart';
import 'course_description_screen.dart';
import 'create_user_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreCourses extends StatefulWidget {
  final bool allowProfilePrompt;

  const ExploreCourses({super.key, this.allowProfilePrompt = true});

  @override
  State<ExploreCourses> createState() => _ExploreCoursesState();
}

class _ExploreCoursesState extends State<ExploreCourses> with TickerProviderStateMixin {
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


  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Set<int> _selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();

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

    // Add mounted checks
    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _bounceController.forward();
    });

    // Fetch categories and courses when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreCourseProvider>().fetchCategoriesAndCourses();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
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
    // 1. First filter by category if any are selected
    List<CategoryModel> categoryFiltered;
    if (_selectedCategoryIds.isEmpty) {
      categoryFiltered = List.from(allCategories);
    } else {
      categoryFiltered = allCategories
          .where((cat) => _selectedCategoryIds.contains(cat.id))
          .toList();
    }

    // 2. Then filter courses inside each category by search query
    if (_searchQuery.isEmpty) {
      return categoryFiltered;
    }

    List<CategoryModel> searchFiltered = [];
    final lowerQuery = _searchQuery.toLowerCase();

    for (var category in categoryFiltered) {
      final matchingCourses = category.courses.where((course) {
        return course.courseName.toLowerCase().contains(lowerQuery) ||
            course.description.toLowerCase().contains(lowerQuery);
      }).toList();

      if (matchingCourses.isNotEmpty) {
        // Create a copy of the category with only matching courses
        searchFiltered.add(CategoryModel(
          id: category.id,
          name: category.name,
          short: category.short,
          available: category.available,
          isFree: category.isFree,
          limit: category.limit,
          startDate: category.startDate,
          endDate: category.endDate,
          courses: matchingCourses,
        ));
      }
    }

    return searchFiltered;
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

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Color(0xFFFFA500),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sign In Required',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please sign in to access course content and track your progress.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _handleSignIn();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA500),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign In with Google',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSignIn() async {
    if (!mounted) return;
    final authService = FirebaseAuthService();
    try {
      final userCredential = await authService.signInWithGoogle();
      final user = userCredential?.user;
      if (user != null) {
        // Register user in backend via CbtUserProvider
        final userProvider =
            Provider.of<CbtUserProvider>(context, listen: false);
        await userProvider.handleFirebaseSignUp(
          email: user.email ?? '',
          name: user.displayName ?? '',
          profilePicture: user.photoURL ?? '',
        );
        // Profile prompt is handled by CBT Dashboard after sign-in now.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed in successfully')),
          );
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
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAccountSwitcherDialog(BuildContext context, dynamic user) {
    final profiles = (user?.profiles as List<CbtUserProfile>?) ?? <CbtUserProfile>[];
    final activeProfileId = _activeProfile?.id;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      final subtitle = user.email.toString();
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
                            _saveActiveProfileId(profile.id);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                // Add New Profile Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Navigate to create profile screen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateUserProfileScreen(
                            userId: user.id.toString(),

                          ),
                        ),
                      );
                      // If profile was created successfully, refresh user data
                      if (result == true && mounted) {
                        // Refresh user list if needed and select the newly created profile
                        final updatedUser = Provider.of<CbtUserProvider>(context, listen: false).currentUser;
                        final profiles = (updatedUser?.profiles ?? []);
                        setState(() {
                          if (profiles.isNotEmpty) {
                            _activeProfile = profiles.last;
                            _saveActiveProfileId(_activeProfile?.id);
                          } else {
                            _activeProfile = null;
                            _saveActiveProfileId(null);
                          }
                        });
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
    } else if (value == 'delete') {
      // handle delete
      final profileProvider = Provider.of<CreateUserProfileProvider>(context, listen: false);
      final cbtUserProvider = Provider.of<CbtUserProvider>(context, listen: false);
      try {
        await profileProvider.deleteUserProfile(profile.id.toString());
        
        // Remove from local profiles list
        final currentProfiles = List<CbtUserProfile>.from(cbtUserProvider.currentUser?.profiles ?? []);
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
            const SnackBar(content: Text('Profile deleted successfully')),
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

  Future<void> _saveActiveProfileId(int? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setInt('active_profile_id', id);
    } else {
      await prefs.remove('active_profile_id');
    }
  }

  Future<int?> _loadActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('active_profile_id');
  }

  Widget _avatarWidget({String? imageUrl, required String name, double radius = 20}) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: NetworkImage(imageUrl),
      );
    }

    final initials = _profileInitials(name);
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade300,
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
    final profiles = (user?.profiles as List<CbtUserProfile>?) ?? <CbtUserProfile>[];
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
      _loadActiveProfileId().then((savedId) {
        if (savedId != null && mounted) {
          final savedProfile = profiles.where((p) => p.id == savedId).isNotEmpty
              ? profiles.firstWhere((p) => p.id == savedId)
              : null;
          if (savedProfile != null) {
            setState(() {
              _activeProfile = savedProfile;
            });
            if (mounted) {
              context.read<ExploreCourseProvider>().fetchCategoriesAndCourses(
                profileId: savedProfile.id,
                dateOfBirth: savedProfile.birthDate,
              );
            }
          }
        }
      });
    }
    if (_activeProfile == null && activeProfile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _activeProfile = activeProfile;
        });
        if (mounted && activeProfile != null) {
          context.read<ExploreCourseProvider>().fetchCategoriesAndCourses(
            profileId: activeProfile.id,
            dateOfBirth: activeProfile.birthDate,
          );
        }
      });
    }

    final displayName = activeProfile != null ? _profileName(activeProfile) : 'User';


    return Container(
      decoration: Constants.customBoxDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer<ExploreCourseProvider>(
        builder: (context, courseProvider, child) {

          final loading = courseProvider.isLoading;

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

            if (courseProvider.errorMessage.isNotEmpty) {
              // fine error section with retry button
              return 
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
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
                        courseProvider.fetchCategoriesAndCourses();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 25, 32, 171),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                      Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No courses found',
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: filteredCategories.map((category) {
                if (category.courses.isEmpty) {
                  return const SizedBox.shrink();
                }

                return _buildAnimatedCard(
                  index: courseProvider.categories.indexOf(category) + 2,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: category.courses.length,
                        itemBuilder: (context, index) {
                          return _buildCompactCourseCard(
                              category.courses[index], category);
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                 ) );
              }).toList(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await courseProvider.fetchCategoriesAndCourses(
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
                          onTap: () => _showAccountSwitcherDialog(context, user),
                          child: Row(
                            children: [
                              _avatarWidget(
                                imageUrl: activeProfile?.avatar,
                                name: displayName,
                                radius: 24,
                              ),
                              const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search for courses...',
                                prefixIcon:
                                    Icon(Icons.search, color: Colors.grey),
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
                                color: const Color(0xFFFFA500).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color:
                                        const Color(0xFFFFA500).withOpacity(0.3)),
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
        onTap: () async {
          // Check if user is signed in
          final authService = FirebaseAuthService();
          final isSignedIn = await authService.isUserSignedUp();

          if (!isSignedIn) {
            // Show sign-in dialog if not signed in
            _showSignInDialog();
            return;
          }

          // Before navigating, ensure phone is present; if missing show modal
          final cbtUserProvider = Provider.of<CbtUserProvider>(context, listen: false);
          if (cbtUserProvider.isPhoneMissing) {
            // Show profile modal and block navigation until filled
            await UserProfileUpdateModal.show(
              context,
              user: cbtUserProvider.currentUser,
              onSave: ({required String phone, required String gender, required String birthDate}) async {
                final profileService = UserProfileUpdateService();
                final user = cbtUserProvider.currentUser;
                if (user == null) return;
                await profileService.updateUserPhone(
                  userId: user.id!,
                  firstName: user.name!.split(' ').first,
                  lastName: user.name!.split(' ').last,
                  phone: phone,
                  attempt: user.attempt.toString(),
                  email: user.email,
                  gender: gender,
                  birthDate: birthDate,
                );
                await cbtUserProvider.refreshCurrentUser();
              },
            );

            // Recheck phone after modal
            if (cbtUserProvider.isPhoneMissing) {
              return; // still missing - don't proceed
            }
          }

          // Check if course has active cohort
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
                    const Icon(Icons.info_outline, color: Colors.orange, size: 48),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

          // Navigate to course description if signed in
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDescriptionScreen(
                profileId: _activeProfile?.id,

                course: course,
                categoryName: category.name,
                categoryId: category.id,
                provider: category.name,
                cohortId: course.cohortId.toString(),
                providerSubtitle: 'Powered By Digital Dreams',
                categoryColor: _getCategoryColor(course.category),
              ),
            ),
          );
        },
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12
                  ),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      course.imageUrl.startsWith('https') ? course.imageUrl : "https://linkskool.net/${course.imageUrl}",
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
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
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 120,
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFFFFA500),
                              strokeWidth: 2,
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
                              color: (course.isFree == true || course.isFree == null)
                                  ? Colors.green.shade600
                                  : Colors.red.shade600,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (course.isFree == true || course.isFree == null) ? 'Free' : course.priceLabel,
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



















import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/videos/video_model.dart';
import 'package:linkschool/modules/services/explore/video/video_service.dart';


class CourseVideoProvider extends ChangeNotifier {
  final CourseVideoService _courseVideoService;
  
  List<CourseVideoModel> _courses = [];
  bool _isLoading = false;
  String? _error;
  String? _currentCourseId;

  CourseVideoProvider(this._courseVideoService);

  // Getters
  List<CourseVideoModel> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentCourseId => _currentCourseId;

  // Get course by id
  CourseVideoModel? getCourseById(int courseId) {
    try {
      return _courses.firstWhere((course) => course.courseId == courseId);
    } catch (e) {
      return null;
    }
  }

  // Get syllabus by id
  SyllabusModel? getSyllabusById(int syllabusId) {
    for (var course in _courses) {
      try {
        return course.syllabi.firstWhere((syllabus) => syllabus.syllabusId == syllabusId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  // Get all syllabi for a course
  List<SyllabusModel> getSyllabiForCourse(int courseId) {
    final course = getCourseById(courseId);
    return course?.syllabi ?? [];
  }

  // Get all videos for a course
  List<VideoModel> getVideosForCourse(int courseId) {
    final course = getCourseById(courseId);
    if (course == null) return [];
    
    List<VideoModel> allVideos = [];
    for (var syllabus in course.syllabi) {
      allVideos.addAll(syllabus.videos);
    }
    return allVideos;
  }

  // Get videos for a specific syllabus
  List<VideoModel> getVideosForSyllabus(int syllabusId) {
    final syllabus = getSyllabusById(syllabusId);
    return syllabus?.videos ?? [];
  }

  // Get videos by author
  List<VideoModel> getVideosByAuthor(String authorName) {
    List<VideoModel> videos = [];
    for (var course in _courses) {
      for (var syllabus in course.syllabi) {
        videos.addAll(
          syllabus.videos.where((video) => video.authorName == authorName)
        );
      }
    }
    return videos;
  }

  // Get all unique author names
  List<String> get uniqueAuthors {
    Set<String> authors = {};
    for (var course in _courses) {
      for (var syllabus in course.syllabi) {
        for (var video in syllabus.videos) {
          if (video.authorName.isNotEmpty) {
            authors.add(video.authorName);
          }
        }
      }
    }
    return authors.toList();
  }

  // Get total video count across all courses
  int get totalVideosCount {
    return _courses.fold(0, (sum, course) => sum + course.totalVideos);
  }

  // Get course names
  List<String> get courseNames {
    return _courses.map((course) => course.courseName).toList();
  }

  // Search videos by title or description
  List<VideoModel> searchVideos(String query) {
    if (query.isEmpty) return [];
    
    List<VideoModel> results = [];
    final lowerQuery = query.toLowerCase();
    
    for (var course in _courses) {
      for (var syllabus in course.syllabi) {
        results.addAll(
          syllabus.videos.where((video) =>
            video.title.toLowerCase().contains(lowerQuery) ||
            video.description.toLowerCase().contains(lowerQuery)
          )
        );
      }
    }
    return results;
  }

  // Load course videos with optional filter
  Future<void> loadCourseVideos({required String courseId, required String levelId}) async {
    _isLoading = true;
    _error = null;
    _currentCourseId = courseId;
    notifyListeners();

    try {
      final response = await _courseVideoService.fetchCourseVideos(
        courseId: courseId ,levelId: levelId
      );

      if (response.success) {
        _courses = response.courses;
        
        print('✅ Course videos loaded successfully:');
        print('   Total courses: ${_courses.length}');
        print('   Total videos: $totalVideosCount');
      } else {
        _error = 'Failed to load course videos';
        print('❌ Failed to load course videos');
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error in CourseVideoProvider: $_error');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Refresh course videos (reload with current filter)
 

  // Clear all data
  void clearCourseVideos() {
    _courses = [];
    _currentCourseId = null;
    _error = null;
    notifyListeners();
  }

  // Get videos with thumbnails only
  List<VideoModel> get videosWithThumbnails {
    List<VideoModel> videos = [];
    for (var course in _courses) {
      for (var syllabus in course.syllabi) {
        videos.addAll(
          syllabus.videos.where((video) => video.thumbnailUrl.isNotEmpty)
        );
      }
    }
    return videos;
  }

  // Get video count by course
  Map<String, int> get videoCountByCourse {
    final Map<String, int> counts = {};
    for (var course in _courses) {
      counts[course.courseName] = course.totalVideos;
    }
    return counts;
  }

  // Get syllabus count by course
  Map<String, int> get syllabusCountByCourse {
    final Map<String, int> counts = {};
    for (var course in _courses) {
      counts[course.courseName] = course.syllabi.length;
    }
    return counts;
  }
}
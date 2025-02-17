
class Course {

  final String? id;
    final String? name;
    final List<Category> category;

    Course({
        required this.id,
        required this.name,
        required this.category,
    });

    factory Course.fromJson(Map<String, dynamic> json){ 
        return Course(
            id: json["id"],
            name: json["name"],
            category: json["category"] == null ? [] : List<Category>.from(json["category"]!.map((json) => Category.fromJson(json))),
        );
    }

}

class Category {
    Category({
        required this.id,
        required this.level,
        required this.levelName,
        required this.name,
        required this.videos,
    });

    final String? id;
    final String? level;
    final String? levelName;
    final String? name;
    final List<Video> videos;

    factory Category.fromJson(Map<String, dynamic> json){ 
        return Category(
            id: json["id"],
            level: json["level"],
            levelName: json["level_name"],
            name: json["name"],
            videos: json["videos"] == null ? [] : List<Video>.from(json["videos"]!.map((x) => Video.fromJson(x))),
        );
    }

}

class Video {
   final String? id;
    final String? title;
    final String? url;
    final String? thumbnail;
    Video({
        required this.id,
        required this.title,
        required this.url,
        required this.thumbnail,
    });
    factory Video.fromJson(Map<String, dynamic> json){ 
        return Video(
            id: json["id"],
            title: json["title"],
            url: json["url"],
            thumbnail: json["thumbnail"],
        );
    }

}

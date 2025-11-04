import 'dart:convert';

AdmissionResponse admissionResponseFromJson(String str) =>
    AdmissionResponse.fromJson(json.decode(str));

class AdmissionResponse {
  final bool status;
  final AdmissionData data;

  AdmissionResponse({
    required this.status,
    required this.data,
  });

  factory AdmissionResponse.fromJson(Map<String, dynamic> json) =>
      AdmissionResponse(
        status: json["status"],
        data: AdmissionData.fromJson(json["data"]),
      );
}

class AdmissionData {
  final List<School> nearMe;
  final List<School> recommend;
  final List<School> top;

  AdmissionData({
    required this.nearMe,
    required this.recommend,
    required this.top,
  });

  factory AdmissionData.fromJson(Map<String, dynamic> json) => AdmissionData(
        nearMe: List<School>.from(json["near_me"].map((x) => School.fromJson(x))),
        recommend: List<School>.from(json["recommend"].map((x) => School.fromJson(x))),
        top: List<School>.from(json["top"].map((x) => School.fromJson(x))),
      );
}

class School {
  final int id;
  final String schoolName;
  final bool isAdmission;
  final double rating;
  final String? startDate;
  final String? endDate;
  final Contact contact;
  final int admissionPrice;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final String motto;
  final String schoolType;
  final String about;
  final List<String> gallery;
  final String banner;
  final String logo;
  final List<Testimonial> testimonials;

  School({
    required this.id,
    required this.schoolName,
    required this.isAdmission,
    required this.rating,
    this.startDate,
    this.endDate,
    required this.contact,
    required this.admissionPrice,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.motto,
    required this.schoolType,
    required this.about,
    required this.gallery,
    required this.banner,
    required this.logo,
    required this.testimonials,
  });

  factory School.fromJson(Map<String, dynamic> json) => School(
        id: json["id"],
        schoolName: json["school_name"],
        isAdmission: json["is_admission"],
        rating: (json["rating"] as num).toDouble(),
        startDate: json["start_date"],
        endDate: json["end_date"],
        contact: Contact.fromJson(json["contact"]),
        admissionPrice: json["admission_price"],
        location: json["location"],
        address: json["address"],
        latitude: (json["latitude"] as num).toDouble(),
        longitude: (json["longitude"] as num).toDouble(),
        motto: json["motto"],
        schoolType: json["school_type"],
        about: json["about"],
        gallery: List<String>.from(json["gallery"].map((x) => x)),
        banner: json["banner"],
        logo: json["logo"],
        testimonials:
            List<Testimonial>.from(json["testimonials"].map((x) => Testimonial.fromJson(x))),
      );
}

class Contact {
  final String phone;
  final String email;

  Contact({
    required this.phone,
    required this.email,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        phone: json["phone"],
        email: json["email"],
      );
}

class Testimonial {
  final int id;
  final String name;
  final String content;
  final double rating;
  final String date;

  Testimonial({
    required this.id,
    required this.name,
    required this.content,
    required this.rating,
    required this.date,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) => Testimonial(
        id: json["id"],
        name: json["name"],
        content: json["content"],
        rating: (json["rating"] as num).toDouble(),
        date: json["date"],
      );
}

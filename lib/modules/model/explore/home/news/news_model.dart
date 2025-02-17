class NewsModel {
  final String id;
  final String subject;
  final String content;
  final String datePosted;
  final String user;
  final String publish;
  final String audience;
  final String views;
  final String picRef;

  NewsModel({
    required this.id,
    required this.subject,
    required this.content,
    required this.datePosted,
    required this.user,
    required this.publish,
    required this.audience,
    required this.views,
    required this.picRef,
  });

  factory NewsModel.fromJson(List<dynamic> json) {
    return NewsModel(
      id: json[0].toString(),
      subject: json[1].toString(),
      content: json[2].toString(),
      datePosted: json[3].toString(),
      user: json[4].toString(),
      publish: json[5].toString(),
      audience: json[6].toString(),
      views: json[7].toString(),
      picRef: json[8].toString(),
    );
  }
}


// class NewsModel {
//   final String id;
//   final String subject;
//   final String content;
//   final String date_posted;
//   final String user;
//   final String publish;
//   final String audience;
//   final String views;
//   final String pic_ref;

//   NewsModel({
//     required this.id,
//     required this.subject,
//     required this.content,
//     required this.date_posted,
//     required this.user,
//     required this.publish,
//     required this.audience,
//     required this.views,
//     required this.pic_ref,
//   });

//   factory NewsModel.fromJson(Map<String, dynamic> json) {
//     return NewsModel(
//       id: json['id'],
//       subject: json['subject'],
//       content: json['content'],
//       date_posted: json['date_posted'],
//       user: json['user'],
//       publish: json['publish'],
//       audience: json['audience'],
//       views: json['views'],
//       pic_ref: json['pic_ref'],
//     );
//   }
// }

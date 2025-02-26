// class Games {
//   Games({
//     required this.cardGames,
//     required this.puzzleGames,
//     required this.boardGames,
//   });

//   final BoardGamesClass cardGames;
//   final BoardGamesClass puzzleGames;
//   final BoardGamesClass boardGames;

//   factory Games.fromJson(Map<String, dynamic> json) {
//     return Games(
//       cardGames: BoardGamesClass.fromJson(json["Card Games"] ?? {}),
//       puzzleGames: BoardGamesClass.fromJson(json["Puzzle Games"] ?? {}),
//       boardGames: BoardGamesClass.fromJson(json["Board Games"] ?? {}),
//     );
//   }
// }

// class BoardGamesClass {
//   BoardGamesClass({
//     required this.id,
//     required this.name,
//     required this.games,
//   });

//   final String id;
//   final String name;
//   final List<Game> games;

//   factory BoardGamesClass.fromJson(Map<String, dynamic> json) {
//     return BoardGamesClass(
//       id: json["id"] ?? '',
//       name: json["name"] ?? '',
//       games: List<Game>.from((json["games"] ?? []).map((x) => Game.fromJson(x))),
//     );
//   }
// }

// class Game {
//   Game({
//     required this.id,
//     required this.gameUrl,
//     required this.thumbnail,
//     required this.rating,
//     required this.date,
//     required this.title,
//   });

//   final String id;
//   final String gameUrl;
//   final String thumbnail;
//   final String rating;
//   final String date;
//   final String title;

//   factory Game.fromJson(Map<String, dynamic> json) {
//     return Game(
//       id: json["id"] ?? '',
//       gameUrl: json["gameUrl"] ?? '',
//       thumbnail: json["thumbnail"] ?? '',
//       rating: json["rating"] ?? '',
//       date: json["date"] ?? '',
//       title: json["title"] ?? '',
//     );
//   }
// }

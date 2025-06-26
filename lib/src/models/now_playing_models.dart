import 'dart:convert';

import 'package:code_warriors/src/models/movie_models.dart';

class NowPlaying {
  Dates dates;
  int page;
  List<Movie> results;
  int totalPages;
  int totalResults;

  NowPlaying({
    required this.dates,
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory NowPlaying.fromRawJson(String str) =>
      NowPlaying.fromJson(json.decode(str));

  //String toRawJson() => json.encode(toJson());

  factory NowPlaying.fromJson(Map<String, dynamic> json) => NowPlaying(
        dates: Dates.fromJson(json["dates"]),
        page: json["page"],
        results:
            List<Movie>.from(json["results"].map((x) => Movie.fromJson(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );

}

class Dates {
  DateTime maximum;
  DateTime minimum;

  Dates({
    required this.maximum,
    required this.minimum,
  });

  factory Dates.fromRawJson(String str) => Dates.fromJson(json.decode(str));

  //String toRawJson() => json.encode(toJson());

  factory Dates.fromJson(Map<String, dynamic> json) => Dates(
        maximum: DateTime.parse(json["maximum"]),
        minimum: DateTime.parse(json["minimum"]),
      );

}

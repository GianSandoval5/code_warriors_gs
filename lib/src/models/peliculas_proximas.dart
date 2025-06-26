import 'dart:convert';

import 'package:code_warriors/src/models/movie_models.dart';
import 'package:code_warriors/src/models/now_playing_models.dart';

class PeliculasProximas {
  Dates dates;
  int page;
  List<Movie> results;
  int totalPages;
  int totalResults;

  PeliculasProximas({
    required this.dates,
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory PeliculasProximas.fromRawJson(String str) =>
      PeliculasProximas.fromJson(json.decode(str));

  factory PeliculasProximas.fromJson(Map<String, dynamic> json) =>
      PeliculasProximas(
        dates: Dates.fromJson(json["dates"]),
        page: json["page"],
        results:
            List<Movie>.from(json["results"].map((x) => Movie.fromJson(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );
}

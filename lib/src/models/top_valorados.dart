import 'dart:convert';

import 'package:code_warriors/src/models/movie_models.dart';

class TopValorados {
  int page;
  List<Movie> results;
  int totalPages;
  int totalResults;

  TopValorados({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory TopValorados.fromRawJson(String str) =>
      TopValorados.fromJson(json.decode(str));

  factory TopValorados.fromJson(Map<String, dynamic> json) => TopValorados(
        page: json["page"],
        results:
            List<Movie>.from(json["results"].map((x) => Movie.fromJson(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );
}

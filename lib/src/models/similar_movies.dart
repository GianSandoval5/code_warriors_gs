import 'dart:convert';

import 'package:code_warriors/src/models/movie_models.dart';

class SimilarMovie {
  int page;
  List<Movie> results;
  int totalPages;
  int totalResults;

  SimilarMovie({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory SimilarMovie.fromRawJson(String str) =>
      SimilarMovie.fromJson(json.decode(str));

  factory SimilarMovie.fromJson(Map<String, dynamic> json) => SimilarMovie(
        page: json["page"],
        results: List<Movie>.from(
            json["results"].map((x) => Movie.fromJson(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );
}

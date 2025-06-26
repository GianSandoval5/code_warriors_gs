import 'dart:convert';

import 'package:code_warriors/src/models/movie_models.dart';

class SearchResult {
  int page;
  List<Movie> results;
  int totalPages;
  int totalResults;

  SearchResult({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory SearchResult.fromRawJson(String str) =>
      SearchResult.fromJson(json.decode(str));

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
        page: json["page"],
        results:
            List<Movie>.from(json["results"].map((x) => Movie.fromJson(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );
}

import 'dart:convert';

import 'package:code_warriors/src/models/generos_models.dart';

class CategoriaModels {
  List<Genre> genres;

  CategoriaModels({
    required this.genres,
  });

  factory CategoriaModels.fromRawJson(String str) =>
      CategoriaModels.fromJson(json.decode(str));

  factory CategoriaModels.fromJson(Map<String, dynamic> json) =>
      CategoriaModels(
        genres: List<Genre>.from(json["genres"].map((x) => Genre.fromJson(x))),
      );
}

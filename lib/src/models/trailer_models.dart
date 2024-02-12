import 'dart:convert';

class TrailerModels {
  int id;
  List<Video> results;

  TrailerModels({
    required this.id,
    required this.results,
  });

  factory TrailerModels.fromRawJson(String str) =>
      TrailerModels.fromJson(json.decode(str));

  factory TrailerModels.fromJson(Map<String, dynamic> json) => TrailerModels(
        id: json["id"],
        results:
            List<Video>.from(json["results"].map((x) => Video.fromJson(x))),
      );
}

class Video {
  String iso6391;
  String iso31661;
  String name;
  String key;
  String site;
  int size;
  String type;
  bool official;
  DateTime publishedAt;
  String id;

  Video({
    required this.iso6391,
    required this.iso31661,
    required this.name,
    required this.key,
    required this.site,
    required this.size,
    required this.type,
    required this.official,
    required this.publishedAt,
    required this.id,
  });

  factory Video.fromRawJson(String str) => Video.fromJson(json.decode(str));

  get fullTrailerImg {
    return 'https://www.youtube.com/watch?v=$key';
  }

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        iso6391: json["iso_639_1"],
        iso31661: json["iso_3166_1"],
        name: json["name"],
        key: json["key"],
        site: json["site"],
        size: json["size"],
        type: json["type"],
        official: json["official"],
        publishedAt: DateTime.parse(json["published_at"]),
        id: json["id"],
      );
}

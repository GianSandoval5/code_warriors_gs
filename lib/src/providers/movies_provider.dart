import 'dart:convert';
import 'package:code_warriors/src/models/actores_models.dart';
import 'package:code_warriors/src/models/categoria_models.dart';
import 'package:code_warriors/src/models/generos_models.dart';
import 'package:code_warriors/src/models/movie_models.dart';
import 'package:code_warriors/src/models/now_playing_models.dart';
import 'package:code_warriors/src/models/peliculas_proximas.dart';
import 'package:code_warriors/src/models/populars_movies.dart';
import 'package:code_warriors/src/models/similar_movies.dart';
import 'package:code_warriors/src/models/top_valorados.dart';
import 'package:code_warriors/src/models/trailer_models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MoviesProvider extends ChangeNotifier {
  final String _apiKey = 'e5906a1b3c019a50c4da7da7ee9e8724';
  final String _baseUrl = 'api.themoviedb.org';
  final String _language = 'es-ES';

  List<Movie> _searchedMovies = [];
  List<Movie> get searchedMovies => _searchedMovies;

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  List<Movie> topRatedMovies = [];
  List<Movie> comingSoonMovies = [];
  int _popularPage = 1;
  int _comingSoonPage = 2;
  int _topRatedPage = 0;
  int _genrePage = 0;

  Map<int, List<Cast>> movieCast = {};
  Map<int, List<Genre>> genres = {};
  Map<int, List<Video>> videoTrailer = {};
  Map<int, List<Movie>> similarMovies = {};
  List<Genre> genresList = [];

  // Genre(id: 28, name: 'Acción'),
  // Genre(id: 12, name: 'Aventura'),
  // Genre(id: 16, name: 'Animación'),
  // Genre(id: 35, name: 'Comedia'),
  // Genre(id: 80, name: 'Crimen'),
  // Genre(id: 99, name: 'Documental'),
  // Genre(id: 18, name: 'Drama'),
  // Genre(id: 10751, name: 'Familia'),
  // Genre(id: 14, name: 'Fantasía'),
  // Genre(id: 36, name: 'Historia'),
  // Genre(id: 27, name: 'Terror'),
  // Genre(id: 10402, name: 'Música'),
  // Genre(id: 9648, name: 'Misterio'),
  // Genre(id: 10749, name: 'Romance'),
  // Genre(id: 878, name: 'Ciencia ficción'),
  // Genre(id: 10770, name: 'Película de TV'),
  // Genre(id: 53, name: 'Suspense'),
  // Genre(id: 10752, name: 'Bélica'),
  // Genre(id: 37, name: 'Oeste'),

  MoviesProvider() {
    getNowPlayingMovies();
    getPopularMovies();
    getTopRatedMovies();
    getComingSoonMovies();
  }

  //obtener datos de la API
  Future<String> getJsonData(String endPoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endPoint, {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page',
    });

    final response = await http.get(url);
    return response.body;
  }

  //mostrar películas en cartelera
  getNowPlayingMovies() async {
    final jsonData = await getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlaying.fromJson(json.decode(jsonData));
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  //mostrar películas populares
  getPopularMovies() async {
    _popularPage++;
    final jsonData = await getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularsMovie.fromJson(json.decode(jsonData));
    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  //mostrar películas mejor valoradas
  getTopRatedMovies() async {
    _topRatedPage++;
    final jsonData = await getJsonData('3/movie/top_rated', _topRatedPage);
    final topRatedResponse = TopValorados.fromJson(json.decode(jsonData));
    topRatedMovies = [...topRatedMovies, ...topRatedResponse.results];
    notifyListeners();
  }

  //mostrar películas próximas
  getComingSoonMovies() async {
    _comingSoonPage++;
    final jsonData = await getJsonData('3/movie/upcoming', _comingSoonPage);
    final comingSoonResponse =
        PeliculasProximas.fromJson(json.decode(jsonData));
    comingSoonMovies = [...comingSoonMovies, ...comingSoonResponse.results];
    notifyListeners();
  }

  //mostrar actores por película
  Future<List<Cast>> getMovieCast(int movieId) async {
    if (movieCast.containsKey(movieId)) return movieCast[movieId]!;

    final jsonData = await getJsonData('3/movie/$movieId/credits');
    final creditsResponse = ActoresModels.fromJson(json.decode(jsonData));
    movieCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  //mostrar películas similares
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    if (similarMovies.containsKey(movieId)) return similarMovies[movieId]!;

    final jsonData = await getJsonData('3/movie/$movieId/similar');
    final similarMoviesResponse = SimilarMovie.fromJson(json.decode(jsonData));
    similarMovies[movieId] = similarMoviesResponse.results;
    return similarMoviesResponse.results;
  }

  //mostrar géneros por película
  Future<List<Genre>> getMovieGenres(int movieId) async {
    if (genres.containsKey(movieId)) return genres[movieId]!;

    final jsonData = await getJsonData('3/movie/$movieId');
    final movieDetailResponse = GenerosModels.fromJson(json.decode(jsonData));
    genres[movieId] = movieDetailResponse.genres;
    return movieDetailResponse.genres;
  }

  //para obtener el runtime
  Future<int> getMovieRuntime(int movieId) async {
    final jsonData = await getJsonData('3/movie/$movieId');
    final movieDetailResponse = GenerosModels.fromJson(json.decode(jsonData));
    return movieDetailResponse.runtime;
  }

  //mostrar géneros
  Future<List<Genre>> getGenres() async {
    final jsonData = await getJsonData('3/genre/movie/list');
    final genresResponse = CategoriaModels.fromJson(json.decode(jsonData));
    genresList = genresResponse.genres;
    return genresResponse.genres;
  }

  //mostrar películas por género
  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    _genrePage++;
    var url = Uri.https(_baseUrl, '3/discover/movie', {
      'api_key': _apiKey,
      'language': _language,
      'with_genres': '$genreId',
      'page': '$_genrePage',
    });

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      final List<Movie> movies =
          results.map((json) => Movie.fromJson(json)).toList();
      return movies;
    } else {
      throw Exception('Fallo al leer la lista de películas por género');
    }
  }

  // Buscar películas por nombre
  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey,
      'language': _language,
      'query': query,
    });

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      final List<Movie> movies =
          results.map((json) => Movie.fromJson(json)).toList();
      _searchedMovies = movies;
      return movies;
    } else {
      throw Exception('Fallo al leer la lista de películas');
    }
  }

  // Buscar películas por nombre solo en las próximas películas
  Future<List<Movie>> searchComingSoonMovies(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey,
      'language': _language,
      'query': query,
    });

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      final List<Movie> movies =
          results.map((json) => Movie.fromJson(json)).toList();
      _searchedMovies =
          movies.where((movie) => comingSoonMovies.contains(movie)).toList();
      return _searchedMovies;
    } else {
      throw Exception('Fallo al leer la lista de películas');
    }
  }

  //mostrar trailers por película
  Future<List<Video>> getMovieTrailer(int movieId) async {
    if (videoTrailer.containsKey(movieId)) return videoTrailer[movieId]!;

    final jsonData = await getJsonData('3/movie/$movieId/videos');
    final trailerResponse = TrailerModels.fromJson(json.decode(jsonData));
    videoTrailer[movieId] = trailerResponse.results;
    return trailerResponse.results;
  }
}

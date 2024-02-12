import 'package:code_warriors/src/models/movie_models.dart';
import 'package:code_warriors/src/providers/movies_provider.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieSearchDelegate extends SearchDelegate {
  final dynamic userData;

  MovieSearchDelegate({required this.userData});

  //color del appbar
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.light().copyWith(
      primaryColor: AppColors.lightColor,
      primaryIconTheme: const IconThemeData(color: AppColors.darkColor),
    );
  }

  @override
  String get searchFieldLabel => 'Buscar película';

  //estilo del texto de la busqueda
  @override
  TextStyle get searchFieldStyle => const TextStyle(
        color: AppColors.darkColor,
        fontFamily: "CM",
        fontSize: 18,
      );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear, color: AppColors.darkColor),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back, color: AppColors.darkColor),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  Widget _emptyContainer() {
    return Center(
      child: Icon(
        Icons.movie_creation_outlined,
        size: 100,
        color: AppColors.darkColor.withOpacity(0.5),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _emptyContainer();
    }

    final movieProvider = Provider.of<MoviesProvider>(context, listen: false);

    return FutureBuilder(
      future: movieProvider.searchMovies(query),
      builder: (_, AsyncSnapshot<List<Movie>> snapshot) {
        if (!snapshot.hasData) return _emptyContainer();

        //mostrar solo los que tienen imagen
        final movies =
            snapshot.data!.where((movie) => movie.posterPath != null).toList();

        return ListView.builder(
          itemCount: movies.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (_, int index) {
            final movie = movies[index];
            movie.heroId = 'search-${movie.id}';
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Hero(
                tag: movie.heroId!,
                child: Card(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.lightColor,
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FadeInImage(
                          placeholder:
                              const AssetImage('assets/gif/vertical.gif'),
                          placeholderFit: BoxFit.contain,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const Image(
                                image: AssetImage('assets/images/noimage.png'),
                                width: 50,
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                          image: NetworkImage(movie.fullPosterImg),
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                      title: Text(
                        movie.title,
                        style: const TextStyle(
                          color: AppColors.darkColor,
                          fontFamily: "CB",
                        ),
                      ),
                      subtitle: Text(
                        movie.originalTitle,
                        style: const TextStyle(
                          color: AppColors.darkColor,
                          fontFamily: "CM",
                        ),
                      ),
                      onTap: () {
                        close(context, null);
                        //movieProvider.selectedMovie = movie;
                        // Navigator.pushNamed(context, '/detalle',
                        //     arguments: movie);
                        Navigator.pushNamed(
                          context,
                          "/detalle",
                          arguments: {
                            'movie': movie,
                            'userData': userData,
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

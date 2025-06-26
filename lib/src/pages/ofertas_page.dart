import 'package:code_warriors/src/models/generos_models.dart';
import 'package:code_warriors/src/models/movie_models.dart';
import 'package:code_warriors/src/providers/movies_provider.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:code_warriors/src/widgets/circularprogress_widget.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

class OfertasPage extends StatefulWidget {
  final dynamic userData;
  const OfertasPage({super.key, this.userData});

  @override
  State<OfertasPage> createState() => _OfertasPageState();
}

class _OfertasPageState extends State<OfertasPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final movie = Provider.of<MoviesProvider>(context, listen: false);
    bool isDarkMode = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkColor : AppColors.lightColor,
      body: Column(
        children: [
          _CarouselOfertas(movie: movie, userData: widget.userData),
          _Categorias(movie: movie, userData: widget.userData),
        ],
      ),
    );
  }
}

class _Categorias extends StatefulWidget {
  final MoviesProvider movie;
  final dynamic userData;
  const _Categorias({
    required this.movie,
    required this.userData,
  });

  @override
  _CategoriasState createState() => _CategoriasState();
}

class _CategoriasState extends State<_Categorias> {
  List<Movie> moviesByGenre = [];
  int selectedCategoryIndex = 0;
  Color selectedColor = const Color.fromARGB(255, 240, 1, 1);
  Color unselectedColor = AppColors.text;
  final ScrollController scrollController = ScrollController();
  bool isLoading = false;
  List<Genre> genres = [];
  Map<int, List<Movie>> moviesByGenreMap = {};
  Map<int, double> scrollOffsets = {};

  @override
  void initState() {
    super.initState();
    widget.movie.getGenres().then((genres) {
      if (genres.isNotEmpty) {
        setState(() {
          genres = genres;
          // Establecer el primer género como seleccionado inicialmente
          selectedCategoryIndex = 0;
          // Cargar películas del primer género
          _loadMoviesBySelectedGenre(genres.first.id);
        });
      }
    });

    // Agregar un listener para detectar el final de la lista
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        // Cargar más películas cuando se llegue al final de la lista
        _loadMoreMovies();
      }
    });
  }

  // Método para cargar películas por género
  void _loadMoviesBySelectedGenre(int genreId) {
    setState(() {
      isLoading = true;
    });
    if (moviesByGenreMap.containsKey(genreId)) {
      // Si ya se han cargado las películas para este género, obtenerlas del mapa
      setState(() {
        moviesByGenre = moviesByGenreMap[genreId]!;
        isLoading = false;
      });
      // Llevar la lista de películas al desplazamiento guardado
      if (scrollOffsets.containsKey(selectedCategoryIndex)) {
        scrollController.jumpTo(scrollOffsets[selectedCategoryIndex] ?? 0);
      }
    } else {
      // Si no se han cargado las películas para este género, cargarlas
      widget.movie.getMoviesByGenre(genreId).then((movies) {
        setState(() {
          moviesByGenreMap[genreId] = movies;
          moviesByGenre = movies;
          isLoading = false;
        });
        // reiniciar a 0 la lista si es la primera vez que se carga
        scrollController.jumpTo(0);
      });
    }
  }

  // Método para cargar más películas cuando se alcanza el final de la lista
  void _loadMoreMovies() {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      widget.movie.getGenres().then((genres) {
        if (genres.isNotEmpty) {
          widget.movie.getMoviesByGenre(genres.first.id).then((movies) {
            setState(() {
              moviesByGenre.addAll(movies);
              isLoading = false;
            });
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Categorías',
              style: TextStyle(
                color: AppColors.darkColor,
                fontSize: 20,
                fontFamily: "CB",
              ),
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder(
            future: widget.movie.getGenres(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Genre>> snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final genres = snapshot.data!;
              return SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: genres.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      child: MaterialButton(
                        splashColor: Colors.transparent,
                        color: index == selectedCategoryIndex
                            ? selectedColor
                            : unselectedColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: const BorderSide(
                            color: AppColors.darkColor,
                            width: 2,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            // Guardar el desplazamiento actual antes de cambiar de categoría
                            scrollOffsets[selectedCategoryIndex] =
                                scrollController.position.pixels;
                            selectedCategoryIndex = index;
                            _loadMoviesBySelectedGenre(genres[index].id);
                          });
                        },
                        child: Text(
                          genres[index].name,
                          style: TextStyle(
                            fontSize: 15,
                            color: index == selectedCategoryIndex
                                ? AppColors.text
                                : AppColors.darkColor,
                            fontFamily: "CB",
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: moviesByGenre.length + 1,
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              itemBuilder: (context, index) {
                if (index == moviesByGenre.length) {
                  // Último índice, mostrar el mensaje de carga
                  return _buildLoadingIndicator();
                } else {
                  final movie = moviesByGenre[index];
                  movie.heroId = 'ofertas-${movie.id}';
                  return GestureDetector(
                    onTap: () {
                      // Navigator.pushNamed(context, '/detalle',
                      //     arguments: movie);
                      Navigator.pushNamed(
                        context,
                        "/detalle",
                        arguments: {
                          'movie': movie,
                          'userData': widget.userData,
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Card(
                        elevation: 15,
                        shadowColor: isDarkMode
                            ? AppColors.lightColor.withAlpha(130)
                            : AppColors.darkAcentsColor,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.text,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode
                                  ? AppColors.red
                                  : AppColors.darkAcentsColor,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Hero(
                                tag: movie.heroId!,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                  child: FadeInImage(
                                    placeholder:
                                        const AssetImage('assets/gif/anim.gif'),
                                    image: NetworkImage(movie.fullPosterImg),
                                    width: 90,
                                    height: 120,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontFamily: "CB",
                                        color: AppColors.darkColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      movie.overview,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: "CB",
                                        color: AppColors.darkColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_month_rounded,
                                          color: AppColors.red,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          movie.releaseDate.toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: "CB",
                                            color: AppColors.red,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      alignment: Alignment.center,
      child: const CircularProgressWidget(text: "Cargando..."),
    );
  }
}

class _CarouselOfertas extends StatelessWidget {
  final MoviesProvider movie;
  final dynamic userData;
  const _CarouselOfertas({
    required this.movie,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final moviesWithImage = movie.onDisplayMovies
        .where((movie) => movie.fullBackdropPath.isNotEmpty)
        .toList();
    bool isDarkMode = context.isDarkMode;
    return Column(
      children: [
        const SizedBox(height: 50),
        Text(
          'Ofertas',
          style: TextStyle(
            fontSize: 20,
            fontFamily: "CB",
            color: isDarkMode ? AppColors.lightColor : AppColors.darkColor,
          ),
        ),
        const SizedBox(height: 20),
        CarouselSlider.builder(
          itemCount: moviesWithImage.length,
          itemBuilder: (context, index, realIndex) {
            final movie = moviesWithImage[index];

            // movie.heroId = '${movie.id}-$index';
            return InkWell(
              onTap: () {
                // Navigator.pushNamed(
                //   context,
                //   '/detalle',
                //   arguments: moviesWithImage[index],
                // );
                Navigator.pushNamed(
                  context,
                  "/detalle",
                  arguments: {
                    'movie': moviesWithImage[index],
                    'userData': userData,
                  },
                );
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.red,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Hero(
                      tag: movie.id,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: FadeInImage(
                          width: double.infinity,
                          height: 120,
                          placeholderFit: BoxFit.fill,
                          placeholder: const AssetImage('assets/gif/anim.gif'),
                          image:
                              NetworkImage(movie.fullBackdropPath.toString()),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(13),
                            bottomRight: Radius.circular(13),
                          ),
                        ),
                        child: Text(
                          movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: "CB",
                          ),
                        ),
                      ),
                    ),
                    //circulo con la oferta
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            topRight: Radius.circular(13),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            '-50% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontFamily: "CB",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 120,
            aspectRatio: 16 / 9,
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

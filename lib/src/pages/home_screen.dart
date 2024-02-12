// ignore_for_file: library_private_types_in_public_api

import 'package:card_swiper/card_swiper.dart';
import 'package:code_warriors/src/models/movie_models.dart';
import 'package:code_warriors/src/pages/admin/admin_page.dart';
import 'package:code_warriors/src/pages/buscador/search_delegate.dart';
import 'package:code_warriors/src/providers/movies_provider.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final dynamic userData;
  const HomeScreen({Key? key, this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context);
    final imagesWithTop = moviesProvider.topRatedMovies
        .where((movie) => movie.posterPath != null);
    final imagesWithPopular =
        moviesProvider.popularMovies.where((movie) => movie.posterPath != null);
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: moviesProvider.onDisplayMovies.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final movie = moviesProvider.onDisplayMovies[index];
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(movie.fullPosterImg),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black26,
                        Colors.black,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardSwiper(
                  userData: widget.userData,
                  movies: moviesProvider.onDisplayMovies,
                  onIndexChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    _pageController.animateToPage(
                      _currentIndex,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Mejor valoradas",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "CB",
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CardMoviesSlider(
                  userData: widget.userData,
                  movies: imagesWithTop.toList(),
                  title: moviesProvider.onDisplayMovies[_currentIndex].title,
                  onNextPage: () {
                    moviesProvider.getTopRatedMovies();
                  },
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Más populares",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "CB",
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CardMoviesSlider(
                  userData: widget.userData,
                  movies: imagesWithPopular.toList(),
                  title: moviesProvider.onDisplayMovies[_currentIndex].title,
                  onNextPage: () {
                    moviesProvider.getPopularMovies();
                  },
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 35, right: 10),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: IconButton(
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: MovieSearchDelegate(userData: widget.userData),
                    );
                  },
                  icon: const Icon(Icons.search,
                      size: 25, color: AppColors.darkColor),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.userData["rol"] == "admin"
          ? Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: FloatingActionButton(
                backgroundColor: AppColors.greenColor2,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AdminPage(userData: widget.userData);
                  }));
                },
                child: const Icon(
                  Icons.add,
                  size: 30,
                  color: AppColors.text,
                ),
              ),
            )
          : null,
    );
  }
}

class CardMoviesSlider extends StatefulWidget {
  final dynamic userData;
  final List<Movie> movies;
  final String title;
  final Function onNextPage;
  const CardMoviesSlider({
    super.key,
    required this.userData,
    required this.movies,
    required this.onNextPage,
    required this.title,
  });

  @override
  State<CardMoviesSlider> createState() => _CardMoviesSliderState();
}

class _CardMoviesSliderState extends State<CardMoviesSlider> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 500) {
        widget.onNextPage();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: widget.movies.length,
        controller: scrollController,
        itemBuilder: (context, index) {
          final movie = widget.movies[index];

          return _cardSlider(context, movie,
              "${widget.title}-$index-${widget.movies[index].id}");
        },
      ),
    );
  }

  Widget _cardSlider(BuildContext context, Movie movie, String heroId) {
    movie.heroId = heroId;

    return GestureDetector(
      onTap: () {
        //Navigator.pushNamed(context, "/detalle", arguments: movie);
        Navigator.pushNamed(
          context,
          "/detalle",
          arguments: {
            'movie': movie,
            'userData': widget.userData,
          },
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Hero(
              tag: movie.heroId!,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: FadeInImage(
                    placeholderFit: BoxFit.fill,
                    height: 240,
                    width: 180,
                    placeholder: const AssetImage("assets/gif/vertical.gif"),
                    imageErrorBuilder: (context, error, stackTrace) {
                      return const Image(
                        image: AssetImage("assets/images/noimage.png"),
                        height: 220,
                        width: 180,
                        fit: BoxFit.fill,
                      );
                    },
                    image: NetworkImage(movie.fullPosterImg),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: "CB",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardSwiper extends StatelessWidget {
  final dynamic userData;
  final List<Movie> movies;
  final Function(int) onIndexChanged;
  const CardSwiper({
    Key? key,
    required this.userData,
    required this.movies,
    required this.onIndexChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Filtrar las películas que tienen imagen
    final moviesWithImage =
        movies.where((movie) => movie.posterPath != null).toList();

    return Container(
      margin: EdgeInsets.only(top: size.height * 0.07),
      height: size.height * 0.5,
      width: double.infinity,
      child: Swiper(
        itemCount: moviesWithImage.length,
        layout: SwiperLayout.STACK,
        itemHeight: size.height * 0.5,
        itemWidth: size.width * 0.7,
        onIndexChanged: onIndexChanged,
        itemBuilder: (context, index) {
          final movie = moviesWithImage[index];

          movie.heroId = "swiper-${movie.id}";

          return InkWell(
            onTap: () {
              //Navigator.pushNamed(context, "/detalle", arguments: movie);
              Navigator.pushNamed(
                context,
                "/detalle",
                arguments: {
                  'movie': movie,
                  'userData': userData,
                },
              );
            },
            child: Hero(
              tag: movie.heroId!,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: FadeInImage(
                    height: size.height * 0.5,
                    placeholderFit: BoxFit.cover,
                    placeholder: const AssetImage("assets/gif/vertical.gif"),
                    placeholderErrorBuilder: (context, error, stackTrace) {
                      return Image(
                        image: const AssetImage("assets/images/noimage.png"),
                        height: size.height * 0.5,
                        fit: BoxFit.cover,
                      );
                    },
                    image: NetworkImage(movie.fullPosterImg),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

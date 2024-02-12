// ignore_for_file: use_build_context_synchronously, camel_case_types

import 'dart:io';

import 'package:code_warriors/src/models/actores_models.dart';
import 'package:code_warriors/src/models/generos_models.dart';
import 'package:code_warriors/src/models/movie_models.dart';
import 'package:code_warriors/src/models/trailer_models.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:code_warriors/src/utils/export.dart';
import 'package:code_warriors/src/widgets/circularprogress_widget.dart';
import 'package:code_warriors/src/widgets/materialbuttom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailsMoviePage extends StatefulWidget {
  const DetailsMoviePage({Key? key}) : super(key: key);

  @override
  State<DetailsMoviePage> createState() => _DetailsMoviePageState();
}

class _DetailsMoviePageState extends State<DetailsMoviePage> {
  @override
  void initState() {
    super.initState();
  }

  //COMPARTIR POST A OTRAS REDES SOCIALES
  Future<void> sharePost(String id, String title, String imageUrl) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/image.jpg');

    final request = await HttpClient().getUrl(Uri.parse(imageUrl));
    final response = await request.close();
    final sink = file.openWrite();
    await response.pipe(sink);
    await sink.close();

    await Share.shareFiles(
      [file.path],
      text: 'Mira esta película: *$title* en la app de CodeWarriors',
      subject: 'Película: $title',
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final Movie movie = arguments['movie'];
    final dynamic userData = arguments['userData'];

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    bool isDarkMode = context.isDarkMode;

    //movie.heroId = '${movie.id}';

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkColor : AppColors.lightColor,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Hero(
            tag: movie.id,
            child: Image.network(
              movie.fullBackdropPath,
              fit: BoxFit.cover,
              height: 280,
              width: double.infinity,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 220),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ClipPath(
                      clipper: _HeaderClipper(),
                      child: Container(
                        width: double.infinity,
                        color: isDarkMode
                            ? AppColors.darkColor
                            : AppColors.lightColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 20),
                                  //iconbutton para compartir
                                  IconButton(
                                    onPressed: () {
                                      sharePost(
                                        movie.id.toString(),
                                        movie.title,
                                        movie.fullPosterImg,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.share_rounded,
                                      color: AppColors.red,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            _rowDetails(movie: movie),
                            _posterAndTitle(movie: movie),
                            const SizedBox(height: 20),
                            Generos(movie.id),
                            const SizedBox(height: 20),
                            _overview(movie: movie),
                            const SizedBox(height: 20),
                            Actores(movie.id),
                            SimilarMovies(userData, movie.id),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                    _buttomPlayTrailer(
                        moviesProvider: moviesProvider, movie: movie),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 35,
            left: 5,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.lightColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkColor,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: AppColors.red,
                    size: 25,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkColor : AppColors.lightColor,
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.darkAcentsColor,
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButtomWidget(
                  title: "Comprar boletos",
                  color: AppColors.red,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "/boleteria",
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
        ],
      ),
    );
  }

  String convertMinutes(int minutes) {
    // Usa la división entera para obtener las horas
    int hours = minutes ~/ 60;
    // Usa el operador de módulo para obtener los minutos restantes
    int remainingMinutes = minutes % 60;
    return "${hours}h ${remainingMinutes}min";
  }

  Widget _posterAndTitle({required Movie movie}) {
    final voteAverage = movie.voteAverage;
    //convertir de 7.445 a 7.4 o de 7.888 a 7.9
    final voteAverageString = voteAverage.toStringAsFixed(1);

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    bool isDarkMode = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Hero(
            tag: movie.heroId!,
            child: Card(
              elevation: 10,
              shadowColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeInImage(
                  placeholderFit: BoxFit.cover,
                  placeholder: const AssetImage('assets/gif/vertical.gif'),
                  imageErrorBuilder: (context, error, stackTrace) {
                    return const Image(
                      image: AssetImage("assets/images/noimage.png"),
                      fit: BoxFit.cover,
                      height: 150,
                    );
                  },
                  image: NetworkImage(movie.fullPosterImg),
                  fit: BoxFit.cover,
                  height: 150,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  movie.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "CB",
                    color:
                        isDarkMode ? AppColors.lightColor : AppColors.darkColor,
                  ),
                ),
                Text(
                  movie.originalTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: "CM",
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      "Rating: ",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "CB",
                        color: AppColors.red,
                      ),
                    ),
                    Icon(Icons.star,
                        size: 25, color: Colors.yellowAccent.shade700),
                    const SizedBox(width: 5),
                    Text(
                      voteAverageString,
                      style: const TextStyle(fontSize: 16, fontFamily: "CB"),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Votos: ",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "CB",
                        color: AppColors.red,
                      ),
                    ),
                    const Icon(Icons.people_rounded,
                        size: 25, color: AppColors.red),
                    const SizedBox(width: 5),
                    Text(
                      movie.voteCount.toString(),
                      style: const TextStyle(fontSize: 16, fontFamily: "CB"),
                    ),
                  ],
                ),
                FutureBuilder<int>(
                  future: moviesProvider.getMovieRuntime(movie.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Error"),
                      );
                    } else if (snapshot.hasData) {
                      final runtime = snapshot.data!;
                      final runtimeString = convertMinutes(runtime);
                      return Row(
                        children: [
                          const Text(
                            "Duración: ",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "CB",
                              color: AppColors.red,
                            ),
                          ),
                          const Icon(Icons.timer_rounded,
                              size: 25, color: AppColors.red),
                          const SizedBox(width: 5),
                          Text(
                            runtimeString,
                            style:
                                const TextStyle(fontSize: 16, fontFamily: "CB"),
                          ),
                        ],
                      );
                    }
                    return const Text("Duración...",
                        style: TextStyle(fontFamily: "CM"));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overview({required Movie movie}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Sinopsis",
            style: TextStyle(
              fontSize: 20,
              fontFamily: "CB",
            ),
          ),
        ),
        movie.overview.isEmpty
            ? const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "No hay sinopsis disponible",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "CS",
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  movie.overview,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 16, fontFamily: "CR"),
                ),
              ),
      ],
    );
  }

  Widget _rowDetails({required Movie movie}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _detailsItem(
          title: "Se estreno",
          text: convertDate(movie.releaseDate.toString()),
          icon: Icons.date_range_rounded,
        ),
        Container(
          color: AppColors.red,
          height: 40,
          width: 2,
        ),
        _detailsItem(
          title: "Popularidad",
          text: movie.popularity.toString(),
          icon: Icons.group_rounded,
        ),
        Container(
          color: AppColors.red,
          height: 40,
          width: 2,
        ),
        _detailsItem(
          title: "Idioma",
          text: movie.originalLanguage,
          icon: Icons.language_rounded,
        ),
      ],
    );
  }

  Widget _detailsItem(
      {required String title, required String text, IconData? icon}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontFamily: "CB",
            color: Colors.redAccent.shade700,
          ),
        ),
        const SizedBox(height: 5),
        Icon(
          icon,
          color: AppColors.deepOrange,
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: "CB",
          ),
        ),
      ],
    );
  }
}

class _buttomPlayTrailer extends StatelessWidget {
  const _buttomPlayTrailer({
    required this.moviesProvider,
    required this.movie,
  });

  final MoviesProvider moviesProvider;
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 5,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightColor,
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [
            BoxShadow(
              color: AppColors.darkAcentsColor,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.play_arrow_rounded),
          onPressed: () async {
            final List<Video> trailers =
                await moviesProvider.getMovieTrailer(movie.id);
            if (trailers.isNotEmpty) {
              final String videoKey = trailers.first.key;
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: AppColors.lightColor,
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        movie.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: "CB",
                          color: AppColors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: YoutubePlayer(
                            controller: YoutubePlayerController(
                              initialVideoId: videoKey,
                              flags: const YoutubePlayerFlags(
                                forceHD: true,
                                captionLanguage: 'es',
                              ),
                            ),
                            showVideoProgressIndicator: true,
                            progressIndicatorColor: AppColors.red,
                            progressColors: const ProgressBarColors(
                              playedColor: AppColors.red,
                              handleColor: AppColors.red,
                            ),
                            onEnded: (_) {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        splashColor: AppColors.darkColor,
                        color: AppColors.red,
                        onPressed: () {
                          SystemChrome.setPreferredOrientations(
                              [DeviceOrientation.portraitUp]);
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(
                            color: AppColors.lightColor,
                            fontSize: 16,
                            fontFamily: "CB",
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: AppColors.lightColor,
                    title: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "No hay trailers disponibles",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "CS",
                          color: AppColors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    actions: <Widget>[
                      Center(
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          splashColor: AppColors.darkColor,
                          color: AppColors.red,
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Cerrar',
                              style: TextStyle(
                                color: AppColors.lightColor,
                                fontSize: 16,
                                fontFamily: "CB",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          },
          iconSize: 50,
          color: AppColors.red,
        ),
      ),
    );
  }
}

class Actores extends StatelessWidget {
  final int movieId;
  const Actores(this.movieId);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    return FutureBuilder(
      future: moviesProvider.getMovieCast(movieId),
      builder: (BuildContext context, AsyncSnapshot<List<Cast>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressWidget(text: "Cargando..."),
          );
        } else if (snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "No hay actores disponibles",
              style: TextStyle(
                fontSize: 16,
                fontFamily: "CS",
                color: AppColors.red,
              ),
            ),
          );
        }

        //mostrar solo los actores que tengan foto
        final actores =
            snapshot.data!.where((actor) => actor.profilePath != null).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Actores",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "CB",
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 240,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: actores.length,
                itemBuilder: (BuildContext context, int index) {
                  //no mostrar los actores que no tengan foto

                  return _actorCard(
                      actor: actores[index], isDarkMode: isDarkMode);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _actorCard({required Cast actor, required bool isDarkMode}) {
    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            elevation: 20,
            shadowColor: AppColors.darkAcentsColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FadeInImage(
                width: 160,
                height: 150,
                placeholderFit: BoxFit.cover,
                fit: BoxFit.cover,
                placeholder: const AssetImage('assets/gif/vertical.gif'),
                image: NetworkImage(actor.fullProfilePath),
                imageErrorBuilder: (context, error, stackTrace) {
                  return const Image(
                    image: AssetImage("assets/images/noimage.png"),
                    fit: BoxFit.cover,
                    height: 150,
                    width: 160,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            actor.gender == 2 ? "Actor" : "Actriz",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.red,
              fontSize: 13,
              fontFamily: "CB",
            ),
          ),
          const SizedBox(height: 5),
          //mostrar nombre si hay foto
          Text(
            actor.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? AppColors.lightColor : AppColors.darkColor,
              fontSize: 13,
              fontFamily: "CB",
            ),
          ),
        ],
      ),
    );
  }
}

class Generos extends StatelessWidget {
  final int movieId;
  const Generos(this.movieId);

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Género",
            style: TextStyle(
              fontSize: 18,
              fontFamily: "CB",
            ),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder(
          future: moviesProvider.getMovieGenres(movieId),
          builder: (BuildContext context, AsyncSnapshot<List<Genre>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressWidget(text: "Cargando..."),
              );
            } else if (snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "No hay géneros disponibles",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "CS",
                    color: AppColors.red,
                  ),
                ),
              );
            }
            final generos = snapshot.data!;

            return SizedBox(
              height: 35,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: generos.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.primaries[index % Colors.primaries.length],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Text(
                          generos[index].name,
                          style: const TextStyle(
                            color: AppColors.lightColor,
                            fontSize: 15,
                            fontFamily: "CB",
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    //path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0,
      size.height * 0,
      size.width * 0,
      size.height * 0,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.08,
      size.width,
      size.height * 0,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_HeaderClipper oldClipper) => false;
}

class SimilarMovies extends StatelessWidget {
  final dynamic userData;
  final int movieId;
  const SimilarMovies(this.userData, this.movieId, {super.key});

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    bool isDarkMode = context.isDarkMode;
    return FutureBuilder(
      future: moviesProvider.getSimilarMovies(movieId),
      builder: (BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressWidget(text: "Cargando..."),
          );
        } else if (snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  "No hay películas similares disponibles",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "CS",
                    color: AppColors.red,
                  ),
                ),
                SizedBox(height: 80),
              ],
            ),
          );
        }

        //solo mostrar las películas que tengan foto
        final movies =
            snapshot.data!.where((movie) => movie.posterPath != null).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Películas similares",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "CB",
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 230,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                      onTap: () {
                        // Navigator.pushNamed(context, "/detalle",
                        //     arguments: movies[index]);
                        Navigator.pushNamed(
                          context,
                          "/detalle",
                          arguments: {
                            'movie': movies[index],
                            'userData': userData,
                          },
                        );
                      },
                      child: _similarMovieCard(
                          movie: movies[index], isDarkMode: isDarkMode));
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _similarMovieCard({required Movie movie, required bool isDarkMode}) {
    movie.heroId = 'similar-${movie.id}';
    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Hero(
            tag: movie.heroId!,
            child: Card(
              elevation: 20,
              shadowColor: AppColors.darkAcentsColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeInImage(
                  width: 160,
                  height: 150,
                  placeholderFit: BoxFit.cover,
                  fit: BoxFit.cover,
                  placeholder: const AssetImage('assets/gif/vertical.gif'),
                  image: NetworkImage(movie.fullPosterImg),
                  imageErrorBuilder: (context, error, stackTrace) {
                    return const Image(
                      image: AssetImage("assets/images/noimage.png"),
                      fit: BoxFit.cover,
                      height: 150,
                      width: 160,
                    );
                  },
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
            style: TextStyle(
              color: isDarkMode ? AppColors.lightColor : AppColors.darkColor,
              fontSize: 13,
              fontFamily: "CB",
            ),
          ),
          //si el formato de la fecha es invalido, no mostrar la fecha
          movie.releaseDate.toString().isNotEmpty
              ? Text(
                  convertDate(movie.releaseDate.toString()),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 13,
                    fontFamily: "CB",
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

String convertDate(String date) {
  DateTime parsedDate = DateTime.parse(date);
  String formattedDate = DateFormat('MMM dd, yyyy').format(parsedDate);
  return formattedDate[0].toUpperCase() + formattedDate.substring(1);
}

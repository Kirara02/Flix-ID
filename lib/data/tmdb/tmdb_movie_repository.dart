import 'package:dio/dio.dart';
import 'package:flix_id/data/repositories/movie_repository.dart';
import 'package:flix_id/domain/entities/actor.dart';
import 'package:flix_id/domain/entities/movie.dart';
import 'package:flix_id/domain/entities/movie_detail.dart';
import 'package:flix_id/domain/entities/result.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class TmdbMovieRepository implements MovieRepository {
  final Dio? _dio;

  final String token =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4OTVhNzliNjkxZGI5YjY5MmU2YTEwZDY1NDI5OGFlMyIsIm5iZiI6MTcyNjYyNzkwNS45MTc4MDUsInN1YiI6IjY0YmQ4ODg1ZTlkYTY5MDBlY2VhOGM5ZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.5KVlrpWbzRwEJzS-uRrE2Wz9iYUlWzm35bp3N4Zj-7Y';

  late final Options _options = Options(headers: {
    'Authorization': 'Bearer $token',
    'accept': 'application/json',
  });

  TmdbMovieRepository({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<Result<List<Actor>>> getActors({required int id}) async {
    try {
      final response = await _dio!.get(
        "https://api.themoviedb.org/3/movie/$id/credits?language=en-US",
        options: _options,
      );

      final result = List<Map<String, dynamic>>.from(response.data['cast']);

      return Result.success(
        result.map((e) => Actor.fromJson(e)).toList(),
      );
    } on DioException catch (e) {
      return Result.failed("${e.message}");
    }
  }

  @override
  Future<Result<MovieDetail>> getDetail({required int id}) async {
    try {
      final response = await _dio!.get(
        "https://api.themoviedb.org/3/movie/$id?language=en-US",
        options: _options,
      );

      return Result.success(MovieDetail.fromJson(response.data));
    } on DioException catch (e) {
      return Result.failed("${e.message}");
    }
  }

  @override
  Future<Result<List<Movie>>> getNowPlaying({int page = 1}) async =>
      _getMovies(_MovieCategory.nowPlaying.toString(), page: page);

  @override
  Future<Result<List<Movie>>> getUpcoming({int page = 1}) async =>
      _getMovies(_MovieCategory.upcoming.toString(), page: page);

  Future<Result<List<Movie>>> _getMovies(String category, {int page = 1}) async {
    try {
      _dio!.interceptors.add(PrettyDioLogger(
        error: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: true,
      ));
      final response = await _dio.get(
        "https://api.themoviedb.org/3/movie/$category?language=en-US&page=$page",
        options: _options,
      );

      final result = List<Map<String, dynamic>>.from(response.data['results']);

      return Result.success(
        result.map((e) => Movie.fromJson(e)).toList(),
      );
    } on DioException catch (e) {
      return Result.failed("${e.message}");
    }
  }
}

enum _MovieCategory {
  nowPlaying('now_playing'),
  upcoming('upcoming');

  final String _instring;

  const _MovieCategory(String instring) : _instring = instring;

  @override
  String toString() => _instring;
}

import 'package:dio/dio.dart';
import '../core/dio_error.dart';
import '../models/post.dart';
import 'post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<Post>> getPosts({int page = 1, int limit = 20}) {
    return _guard(() async {
      final res = await _dio.get<List<dynamic>>(
        '/posts',
        queryParameters: {'_page': page, '_limit': limit},
      );
      return res.data!
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Post> getPostById(int id) {
    return _guard(() async {
      final res = await _dio.get<Map<String, dynamic>>('/posts/$id');
      return Post.fromJson(res.data!);
    });
  }

  @override
  Future<Post> createPost(Post post) {
    return _guard(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/posts',
        data: post.toJson()..remove('id'),
      );
      return Post.fromJson(res.data!);
    });
  }

  @override
  Future<Post> updatePost(Post post) {
    return _guard(() async {
      final res = await _dio.put<Map<String, dynamic>>(
        '/posts/${post.id}',
        data: post.toJson(),
      );
      return Post.fromJson(res.data!);
    });
  }

  @override
  Future<void> deletePost(int id) {
    return _guard(() async {
      await _dio.delete('/posts/$id');
    });
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

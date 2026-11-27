import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_exception.dart';
import '../models/post.dart';
import 'dio_client.dart';
import 'mock_post_repository.dart';
import 'post_repository.dart';
import 'post_repository_impl.dart';

// Ubah menjadi true untuk bekerja tanpa internet
const pakaiMock = false;

final postRepositoryProvider = Provider<PostRepository>((ref) {
  if (pakaiMock) return MockPostRepository();
  return PostRepositoryImpl(createDio());
});

final postListProvider =
    AsyncNotifierProvider<PostListNotifier, List<Post>>(
  PostListNotifier.new,
);

class PostListNotifier extends AsyncNotifier<List<Post>> {
  PostRepository get _repo => ref.read(postRepositoryProvider);

  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  Future<List<Post>> build() {
    _page = 1;
    _hasMore = true;
    return ref.watch(postRepositoryProvider).getPosts();
  }

  Future<void> loadMore() async {
    final sekarang = state.value;
    if (sekarang == null || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    try {
      final berikut = await _repo.getPosts(page: _page + 1);
      _page++;
      _hasMore = berikut.length == 20;
      state = AsyncData([...sekarang, ...berikut]);
    } on ApiException {
      // biarkan; akan dicoba lagi saat pengguna menggulir
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> tambah(String title, String body) async {
    final baru = await _repo.createPost(
      Post(id: 0, userId: 1, title: title, body: body),
    );
    state = AsyncData([baru, ...?state.value]);
  }

  Future<void> ubah(Post post) async {
    final hasil = await _repo.updatePost(post);
    state = AsyncData([
      for (final p in state.value ?? <Post>[])
        p.id == hasil.id ? hasil : p,
    ]);
  }

  Future<void> hapus(int id) async {
    await _repo.deletePost(id);
    state = AsyncData([
      for (final p in state.value ?? <Post>[])
        if (p.id != id) p,
    ]);
  }
}

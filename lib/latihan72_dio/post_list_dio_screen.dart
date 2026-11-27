import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/error_view.dart';
import '../widgets/post_card.dart';
import 'post_detail_dio_screen.dart';
import 'post_form_screen.dart';
import 'post_providers.dart';

class PostListDioScreen extends ConsumerStatefulWidget {
  const PostListDioScreen({super.key});

  @override
  ConsumerState<PostListDioScreen> createState() => _PostListDioScreenState();
}

class _PostListDioScreenState extends ConsumerState<PostListDioScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final pos = _scroll.position;
      if (pos.pixels >= pos.maxScrollExtent - 200) {
        ref.read(postListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Latihan 7.2 Dio + Riverpod')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PostFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          pesan: '$e',
          onRetry: () => ref.invalidate(postListProvider),
        ),
        data: (posts) => RefreshIndicator(
          onRefresh: () async {
            try {
              final _ = await ref.refresh(postListProvider.future);
            } catch (_) {
              // error ditampilkan oleh ErrorView
            }
          },
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: posts.length,
            itemBuilder: (context, i) => PostCard(
              post: posts[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostDetailDioScreen(post: posts[i]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

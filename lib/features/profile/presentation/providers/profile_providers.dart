import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../feed/domain/models.dart';
import '../../../feed/presentation/providers/feed_provider.dart';

// Fetches all replies made by a specific user
final userRepliesProvider = FutureProvider.family<List<Comment>, String>((ref, userId) async {
  final repository = ref.watch(feedRepositoryProvider);
  return repository.fetchRepliesByUser(userId);
});
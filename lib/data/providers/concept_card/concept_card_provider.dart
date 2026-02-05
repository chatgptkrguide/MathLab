// 📚 Concept Card Provider
//
// Manages concept cards and user progress

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../models/concept_card_model.dart';
import '../api_provider.dart';

final logger = Logger();

/// Concept Card State
class ConceptCardState {
  final List<ConceptCardModel> conceptCards;
  final List<ConceptCardModel> bookmarkedCards;
  final Map<String, ConceptCardProgressModel> progressMap;
  final bool isLoading;
  final String? error;

  const ConceptCardState({
    this.conceptCards = const [],
    this.bookmarkedCards = const [],
    this.progressMap = const {},
    this.isLoading = false,
    this.error,
  });

  ConceptCardState copyWith({
    List<ConceptCardModel>? conceptCards,
    List<ConceptCardModel>? bookmarkedCards,
    Map<String, ConceptCardProgressModel>? progressMap,
    bool? isLoading,
    String? error,
  }) {
    return ConceptCardState(
      conceptCards: conceptCards ?? this.conceptCards,
      bookmarkedCards: bookmarkedCards ?? this.bookmarkedCards,
      progressMap: progressMap ?? this.progressMap,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Get progress for a concept card
  ConceptCardProgressModel? getProgress(String conceptCardId) {
    return progressMap[conceptCardId];
  }

  /// Check if card is bookmarked
  bool isBookmarked(String conceptCardId) {
    return progressMap[conceptCardId]?.isBookmarked ?? false;
  }

  /// Check if card is viewed
  bool isViewed(String conceptCardId) {
    return progressMap[conceptCardId]?.isViewed ?? false;
  }

  /// Get view count for card
  int getViewCount(String conceptCardId) {
    return progressMap[conceptCardId]?.viewCount ?? 0;
  }
}

/// Concept Card Notifier
class ConceptCardNotifier extends StateNotifier<ConceptCardState> {
  final Ref _ref;
  final String userId;

  ConceptCardNotifier(this._ref, this.userId) : super(const ConceptCardState()) {
    loadConceptCards();
  }

  /// Load all concept cards
  Future<void> loadConceptCards() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final lessonAPI = _ref.read(lessonAPIProvider);

      // Load concept cards
      final cardsData = await lessonAPI.getConceptCards();
      final conceptCards = cardsData
          .map((data) => ConceptCardModel.fromJson(data))
          .toList();

      // Load user progress
      final progressData =
          await lessonAPI.getConceptCardProgress(userId: userId);
      final progressList = progressData
          .map((data) => ConceptCardProgressModel.fromJson(data))
          .toList();

      // Create progress map
      final progressMap = <String, ConceptCardProgressModel>{};
      for (var progress in progressList) {
        progressMap[progress.conceptCardId] = progress;
      }

      // Get bookmarked cards
      final bookmarkedCards = conceptCards
          .where((card) => progressMap[card.id]?.isBookmarked ?? false)
          .toList();

      state = state.copyWith(
        conceptCards: conceptCards,
        bookmarkedCards: bookmarkedCards,
        progressMap: progressMap,
        isLoading: false,
      );

      logger.i('Loaded ${conceptCards.length} concept cards');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      logger.e('Failed to load concept cards: $e');
    }
  }

  /// Mark card as viewed
  Future<void> markAsViewed(String conceptCardId) async {
    try {
      final lessonAPI = _ref.read(lessonAPIProvider);

      await lessonAPI.markConceptCardViewed(
        userId: userId,
        conceptCardId: conceptCardId,
      );

      // Update local state
      final currentProgress = state.progressMap[conceptCardId];
      final updatedProgress = currentProgress != null
          ? currentProgress.copyWith(
              isViewed: true,
              viewedAt: DateTime.now(),
              viewCount: currentProgress.viewCount + 1,
            )
          : ConceptCardProgressModel(
              id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
              userId: userId,
              conceptCardId: conceptCardId,
              isViewed: true,
              viewedAt: DateTime.now(),
              viewCount: 1,
            );

      final updatedProgressMap = Map<String, ConceptCardProgressModel>.from(
        state.progressMap,
      );
      updatedProgressMap[conceptCardId] = updatedProgress;

      state = state.copyWith(progressMap: updatedProgressMap);

      logger.i('Marked concept card as viewed: $conceptCardId');
    } catch (e) {
      logger.e('Failed to mark as viewed: $e');
    }
  }

  /// Toggle bookmark
  Future<void> toggleBookmark(String conceptCardId) async {
    try {
      final lessonAPI = _ref.read(lessonAPIProvider);

      final currentProgress = state.progressMap[conceptCardId];
      final isCurrentlyBookmarked = currentProgress?.isBookmarked ?? false;

      await lessonAPI.toggleConceptCardBookmark(
        userId: userId,
        conceptCardId: conceptCardId,
        isBookmarked: !isCurrentlyBookmarked,
      );

      // Update local state
      final updatedProgress = currentProgress != null
          ? currentProgress.copyWith(
              isBookmarked: !isCurrentlyBookmarked,
              bookmarkedAt:
                  !isCurrentlyBookmarked ? DateTime.now() : currentProgress.bookmarkedAt,
            )
          : ConceptCardProgressModel(
              id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
              userId: userId,
              conceptCardId: conceptCardId,
              isBookmarked: true,
              bookmarkedAt: DateTime.now(),
            );

      final updatedProgressMap = Map<String, ConceptCardProgressModel>.from(
        state.progressMap,
      );
      updatedProgressMap[conceptCardId] = updatedProgress;

      // Update bookmarked cards
      final bookmarkedCards = state.conceptCards
          .where((card) => updatedProgressMap[card.id]?.isBookmarked ?? false)
          .toList();

      state = state.copyWith(
        progressMap: updatedProgressMap,
        bookmarkedCards: bookmarkedCards,
      );

      logger.i('Toggled bookmark for concept card: $conceptCardId');
    } catch (e) {
      logger.e('Failed to toggle bookmark: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Filter cards by category
  List<ConceptCardModel> filterByCategory(String category) {
    return state.conceptCards
        .where((card) => card.category == category)
        .toList();
  }

  /// Filter cards by difficulty
  List<ConceptCardModel> filterByDifficulty(ConceptDifficulty difficulty) {
    return state.conceptCards
        .where((card) => card.difficulty == difficulty)
        .toList();
  }

  /// Search cards by query
  List<ConceptCardModel> search(String query) {
    final lowerQuery = query.toLowerCase();
    return state.conceptCards
        .where((card) =>
            card.title.toLowerCase().contains(lowerQuery) ||
            card.description.toLowerCase().contains(lowerQuery) ||
            card.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  /// Get categories
  List<String> getCategories() {
    final categories = state.conceptCards.map((card) => card.category).toSet();
    return categories.toList()..sort();
  }
}

/// Concept Card Provider
final conceptCardProvider = StateNotifierProvider.family<
    ConceptCardNotifier,
    ConceptCardState,
    String>(
  (ref, userId) => ConceptCardNotifier(ref, userId),
);

/// Related Concepts Provider
final relatedConceptsProvider =
    FutureProvider.family<List<ConceptCardModel>, String>(
  (ref, conceptCardId) async {
    final lessonAPI = ref.watch(lessonAPIProvider);

    try {
      final relatedData =
          await lessonAPI.getRelatedConcepts(conceptCardId: conceptCardId);

      return relatedData
          .map((data) => ConceptCardModel.fromJson(data))
          .toList();
    } catch (e) {
      logger.e('Failed to load related concepts: $e');
      return [];
    }
  },
);

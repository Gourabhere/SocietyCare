import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ai_extraction.dart';
import '../../domain/repositories/ai_extraction_repository.dart';
import 'puja_dependencies.dart';

class AiExtractionState {
  final List<int>? imageBytes;
  final String? mimeType;
  final AiExtractionResult? result;
  final bool isLoading;
  final Object? error;

  const AiExtractionState({
    this.imageBytes,
    this.mimeType,
    this.result,
    this.isLoading = false,
    this.error,
  });

  AiExtractionState copyWith({
    List<int>? imageBytes,
    String? mimeType,
    AiExtractionResult? result,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return AiExtractionState(
      imageBytes: imageBytes ?? this.imageBytes,
      mimeType: mimeType ?? this.mimeType,
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final aiExtractionProvider = StateNotifierProvider.autoDispose<AiExtractionController, AiExtractionState>((ref) {
  final repo = ref.watch(aiExtractionRepositoryProvider);
  return AiExtractionController(repo);
});

class AiExtractionController extends StateNotifier<AiExtractionState> {
  final AiExtractionRepository _repo;

  AiExtractionController(this._repo) : super(const AiExtractionState());

  Future<void> extract({
    required List<int> bytes,
    required String mimeType,
  }) async {
    state = state.copyWith(
      imageBytes: bytes,
      mimeType: mimeType,
      isLoading: true,
      clearError: true,
    );
    try {
      final result = await _repo.extractFromImage(bytes: bytes, mimeType: mimeType);
      state = state.copyWith(result: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      rethrow;
    }
  }

  void clear() {
    state = const AiExtractionState();
  }
}

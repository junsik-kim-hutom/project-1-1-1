import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/providers/dio_provider.dart';
import '../data/repositories/image_upload_repository.dart';

final imageUploadRepositoryProvider = Provider<ImageUploadRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ImageUploadRepository(dio);
});

class ImageUploadState {
  final List<String> uploadedUrls;
  final bool isUploading;
  final String? error;
  final double uploadProgress;

  ImageUploadState({
    this.uploadedUrls = const [],
    this.isUploading = false,
    this.error,
    this.uploadProgress = 0.0,
  });

  ImageUploadState copyWith({
    List<String>? uploadedUrls,
    bool? isUploading,
    String? error,
    double? uploadProgress,
  }) {
    return ImageUploadState(
      uploadedUrls: uploadedUrls ?? this.uploadedUrls,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

class ImageUploadNotifier extends StateNotifier<ImageUploadState> {
  final ImageUploadRepository _imageUploadRepository;

  ImageUploadNotifier(this._imageUploadRepository) : super(ImageUploadState());

  /// 이미지 업로드
  Future<List<String>> uploadImages(List<File> images) async {
    state = state.copyWith(isUploading: true, error: null, uploadProgress: 0.0);
    try {
      final urls = await _imageUploadRepository.uploadImages(images);

      state = state.copyWith(
        uploadedUrls: [...state.uploadedUrls, ...urls],
        isUploading: false,
        uploadProgress: 1.0,
      );

      return urls;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
        uploadProgress: 0.0,
      );
      rethrow;
    }
  }

  /// 단일 이미지 업로드
  Future<String> uploadSingleImage(File image) async {
    final urls = await uploadImages([image]);
    return urls.first;
  }

  /// 업로드된 URL 초기화
  void clearUploadedUrls() {
    state = ImageUploadState();
  }
}

final imageUploadProvider = StateNotifierProvider<ImageUploadNotifier, ImageUploadState>((ref) {
  final imageUploadRepository = ref.watch(imageUploadRepositoryProvider);
  return ImageUploadNotifier(imageUploadRepository);
});

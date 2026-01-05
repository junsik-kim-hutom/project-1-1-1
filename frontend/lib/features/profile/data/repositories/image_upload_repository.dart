import 'package:dio/dio.dart';
import 'dart:io';

class ImageUploadRepository {
  final Dio _dio;

  ImageUploadRepository(this._dio);

  /// 이미지 업로드
  Future<List<String>> uploadImages(List<File> images) async {
    try {
      final formData = FormData();

      // 여러 파일을 'images' 필드에 추가
      for (var image in images) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/api/profile/images/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        final List<String> imageUrls =
            List<String>.from(response.data['data']['images']);
        return imageUrls;
      } else {
        throw Exception('Failed to upload images: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw Exception('Upload error: ${e.response?.data['error']}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// 단일 이미지 업로드
  Future<String> uploadSingleImage(File image) async {
    final urls = await uploadImages([image]);
    return urls.first;
  }
}

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../core/dio_error.dart';

class UploadService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.escuelajs.co/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<String> uploadFoto(
    XFile file, {
    void Function(double progress)? onProgress,
  }) async {
    final bytes = await file.readAsBytes();
    final namaFile = file.name.isNotEmpty ? file.name : 'profil.jpg';

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: namaFile),
    });

    try {
      final res = await _dio.post(
        '/files/upload',
        data: formData,
        onSendProgress: (terkirim, total) {
          if (total > 0) onProgress?.call(terkirim / total);
        },
      );
      final data = res.data as Map<String, dynamic>;
      return data['location'] as String;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
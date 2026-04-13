import 'dart:io';
import 'package:dio/dio.dart';

class ImgBBApiService {
  static const String _apiKey = 'c8add219164a685cdf3905856b9e29ca';
  static const String _baseUrl = 'https://api.imgbb.com/1/upload';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final dio = Dio();
      
      FormData formData = FormData.fromMap({
        'key': _apiKey,
        'image': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await dio.post(_baseUrl, data: formData);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        return data['display_url'];
      }
      return null;
    } catch (e) {
      print('ImgBB Upload Error: $e');
      return null;
    }
  }
}

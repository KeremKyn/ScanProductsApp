import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PhotoProductService {
  final String ec2Url = 'http://3.91.249.237';

  PhotoProductService();

  Future<String> uploadPhotoAndGetMessage(File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$ec2Url/upload'));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responseData.body);

        // JSON yanıtını doğrudan geri döndür
        return responseData.body;
      } else {
        print('File upload failed with status: ${response.statusCode}');
        return 'Dosya yükleme durumu başarısız oldu: ${response.statusCode}';
      }
    } catch (e) {
      print('Error occurred: $e');
      return 'Bir hata oluştu: $e';
    }
  }
}

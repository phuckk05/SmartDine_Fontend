import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryAPI {
  //trao đổi ảnh bằng API => url
  Future<String> changeUrl(File imageFile) async {
    final cloudName = 'ddqouziau';
    final uploadPreset = 'phuckk';
    var giveRequset = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
    );
    giveRequset.fields['upload_preset'] = uploadPreset;
    giveRequset.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );
    var response = await giveRequset.send();

    if (response.statusCode == 200) {
      var res = await http.Response.fromStream(response);
      var data = jsonDecode(res.body);
      return data['secure_url'];
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }

  //lấy url
  Future<String> getURL(File? image) async {
    if (image != null) {
      final url = await changeUrl(image);
      return url;
    }
    return "0";
  }
}

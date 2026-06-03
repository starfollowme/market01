import 'package:dio/dio.dart';

void main() async {
  try {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://styless.my.id/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ));

    print("Fetching...");
    final res = await dio.get('/products');
    print("STATUS: " + res.statusCode.toString());
    print("DATA: " + res.data.toString());
  } on DioException catch (e) {
    print("DIO ERROR: " + e.message.toString());
    final r = e.response?.data;
    print("DIO ERROR RESPONSE: " + r.toString());
  } catch (e) {
    print("ERROR: " + e.toString());
  }
}

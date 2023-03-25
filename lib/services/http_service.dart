import 'package:dio/dio.dart';
import '../models/app_config_model.dart';
import 'package:get_it/get_it.dart';

class HTTPService {
  final Dio dio = Dio();

  AppConfig? appConfig;
  String? base_url;

  HTTPService() {
    appConfig = GetIt.instance.get<AppConfig>();
    base_url = appConfig!.coinApiBaseUrl;
  }
  Future<Response?> get(String path) async {
    try {
      String url = "$base_url$path";
      Response response = await dio.get(url);
      return response;
    } catch (e) {
      print('HTTPService: Unable to perform get request.');
      print(e);
    }
  }
}

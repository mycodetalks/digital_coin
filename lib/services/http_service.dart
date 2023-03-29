import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../models/app_config_model.dart';

typedef CoinResponse = Map<String, dynamic>;

class ApiService {
  final Dio dio = Dio();

  AppConfig? appConfig;
  String? baseUrl;

  ApiService() {
    appConfig = GetIt.instance.get<AppConfig>();
    baseUrl = appConfig!.coinApiBaseUrl;
  }

  Future<Response> _apiGet(String path) async {
    try {
      return await dio.get("$baseUrl$path");
    } catch (error, stackTrace) {
      print('$error\n$stackTrace');
      throw 'HTTPService: Unable to perform get request.';
    }
  }

  Future<CoinResponse> getCoin(String coin) async {
    final response = await _apiGet("coins/$coin");
    return (response.data as Map).cast();
  }
}

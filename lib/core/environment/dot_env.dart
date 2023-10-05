import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Environment {
  Future<String?> get(String key);
}

class EnvironmentImpl implements Environment {

  @override
  Future<String?> get(String key) async {
    return dotenv.env[key];
  }
}
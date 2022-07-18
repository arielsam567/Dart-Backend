import 'package:shelf/shelf.dart';

abstract class SecurityService<T> {
  Future<String> generateJWT(String userID);
  Future<T?> validateJWT(String token);
  Future<int> userId(String token);

  Middleware get verifyJwt;
  Middleware get authorization;
}

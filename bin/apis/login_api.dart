import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../infra/security/security_service.dart';
import '../models/usuario_model.dart';
import '../services/login_service.dart';
import '../services/usuario_service.dart';
import '../to/auth_to.dart';
import 'api.dart';

class LoginApi extends Api {
  final UsuarioService _usuarioService;
  final SecurityService _securityService;
  final LoginService _loginService;
  LoginApi(
    this._securityService,
    this._loginService,
    this._usuarioService,
  );

  @override
  Handler getHandler({
    List<Middleware>? middlewares,
    bool isSecurity = false,
  }) {
    Router router = Router();

    router.post('/login', (Request req) async {
      var body = await req.readAsString();
      var authTO = AuthTO.fromRequest(body);

      var userID = await _loginService.authenticate(authTO);
      if (userID > 0) {
        var jwt = await _securityService.generateJWT(userID.toString());
        return Response.ok(jsonEncode({'token': jwt}));
      } else {
        return Response(401);
      }
    });

    router.post('/create-user', (Request req) async {
      var body = await req.readAsString();
      if (body.isEmpty) return Response(400);
      var user = UsuarioModel.fromRequest(jsonDecode(body));
      var result = await _usuarioService.save(user);
      return result ? Response(201) : Response(500);
    });

    return createHandler(
      router: router,
      middlewares: middlewares,
    );
  }
}

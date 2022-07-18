import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../infra/security/security_service.dart';
import '../models/noticia_model.dart';
import '../services/generic_service.dart';
import 'api.dart';

class NoticiasApi extends Api {
  final GenericService<NoticiaModel> _service;
  final SecurityService _securityService;

  NoticiasApi(this._service, this._securityService);

  @override
  Handler getHandler({
    List<Middleware>? middlewares,
    bool isSecurity = false,
  }) {
    Router router = Router();

    ///GET BY ID
    router.get('/noticia', (Request req) async {
      String? id = req.url.queryParameters['id'];
      if (id == null) return Response(400);

      var noticia = await _service.findOne(int.parse(id));
      if (noticia == null) return Response(400);

      return Response.ok(jsonEncode(noticia.toJson()));
    });

    ///GET ALL
    router.get('/noticias', (Request req) async {
      List<NoticiaModel> noticias = await _service.findAll();
      List<Map> noticiasMap = noticias.map((e) => e.toJson()).toList();
      return Response.ok(jsonEncode(noticiasMap));
    });

    //CREATE  NEWS
    router.post('/create-news', (Request req) async {
      var body = await req.readAsString();
      NoticiaModel noticiaModel = NoticiaModel.fromRequest(jsonDecode(body));
      int userId = await _securityService.userId(req.headers['Authorization']!);
      noticiaModel.userId = userId;
      var result = await _service.save(noticiaModel);
      return result ? Response(201) : Response(500);
    });

    //UPDATE
    router.put('/noticia', (Request req) async {
      var body = await req.readAsString();
      var result = await _service.save(
        NoticiaModel.fromRequest(jsonDecode(body)),
      );
      return result ? Response(200) : Response(500);
    });

    //DELETE
    router.delete('/noticia', (Request req) async {
      String? id = req.url.queryParameters['id'];
      if (id == null) return Response(400);

      var result = await _service.delete(int.parse(id));
      return result ? Response(200) : Response.internalServerError();
    });

    return createHandler(
      router: router,
      isSecurity: isSecurity,
      middlewares: middlewares,
    );
  }
}

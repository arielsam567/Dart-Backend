import '../../apis/noticias_api.dart';
import '../../apis/login_api.dart';
import '../../apis/usuario_api.dart';
import '../../dao/noticia_dao.dart';
import '../../dao/usuario_dao.dart';
import '../../models/noticia_model.dart';
import '../../services/generic_service.dart';
import '../../services/login_service.dart';
import '../../services/noticia_service.dart';
import '../../services/usuario_service.dart';
import '../database/db_configuration.dart';
import '../database/mysql_db_configuration.dart';
import '../security/security_service.dart';
import '../security/security_service_imp.dart';
import 'dependency_injector.dart';

class Injects {
  static DependencyInjector initialize() {
    var di = DependencyInjector();

    di.register<DBConfiguration>(() => MySqlDBConfiguration());
    di.register<SecurityService>(() => SecurityServiceImp());

    // noticias
    di.register<NoticiaDAO>(() => NoticiaDAO(di<DBConfiguration>()));
    di.register<GenericService<NoticiaModel>>(
      () => NoticiaService(di<NoticiaDAO>()),
    );
    di.register<NoticiasApi>(
      () => NoticiasApi(
        di<GenericService<NoticiaModel>>(),
        di<SecurityService>(),
      ),
    );

    // usuario
    di.register<UsuarioDAO>(() => UsuarioDAO(di<DBConfiguration>()));
    di.register<UsuarioService>(() => UsuarioService(di<UsuarioDAO>()));
    di.register<UsuarioApi>(() => UsuarioApi(di<UsuarioService>()));

    // login
    di.register<LoginService>(() => LoginService(di<UsuarioService>()));
    di.register<LoginApi>(
      () => LoginApi(
        di<SecurityService>(),
        di<LoginService>(),
        di<UsuarioService>(),
      ),
    );

    return di;
  }
}

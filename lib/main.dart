import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'services/preferencias_service.dart';

Future<void> main() async {
  // Necessário porque o SharedPreferences é lido antes do runApp.
  WidgetsFlutterBinding.ensureInitialized();

  final servico = PreferenciasService();
  final preferencias = await servico.carregar();

  runApp(
    MinhaListaApp(
      preferenciasIniciais: preferencias,
      preferenciasService: servico,
    ),
  );
}

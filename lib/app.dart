import 'package:material_ui/material_ui.dart';

import 'data/lista_compras_repository.dart';
import 'screens/home_page.dart';
import 'services/preferencias_service.dart';

/// Raiz do app: guarda o estado das preferências perto do MaterialApp.
class MinhaListaApp extends StatefulWidget {
  final Preferencias preferenciasIniciais;
  final PreferenciasService preferenciasService;
  final ListaComprasRepository? repositorio;

  const MinhaListaApp({
    super.key,
    required this.preferenciasIniciais,
    required this.preferenciasService,
    this.repositorio,
  });

  @override
  State<MinhaListaApp> createState() => _MinhaListaAppState();
}

class _MinhaListaAppState extends State<MinhaListaApp> {
  late bool _temaEscuro = widget.preferenciasIniciais.temaEscuro;
  late bool _somentePendentes = widget.preferenciasIniciais.somentePendentes;

  /// Grava primeiro; só depois atualiza a interface.
  Future<void> _alterarTemaEscuro(bool valor) async {
    await widget.preferenciasService.salvarTemaEscuro(valor);
    if (mounted) setState(() => _temaEscuro = valor);
  }

  Future<void> _alterarSomentePendentes(bool valor) async {
    await widget.preferenciasService.salvarSomentePendentes(valor);
    if (mounted) setState(() => _somentePendentes = valor);
  }

  ThemeData _tema(Brightness brilho) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: brilho,
      ),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha Lista de Compras',
      theme: _tema(Brightness.light),
      darkTheme: _tema(Brightness.dark),
      themeMode: _temaEscuro ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(
        repositorio: widget.repositorio ?? ListaComprasRepository.instancia,
        temaEscuro: _temaEscuro,
        somentePendentes: _somentePendentes,
        onTemaEscuroChanged: _alterarTemaEscuro,
        onSomentePendentesChanged: _alterarSomentePendentes,
      ),
    );
  }
}

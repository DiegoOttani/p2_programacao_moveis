import 'package:material_ui/material_ui.dart';

import '../data/lista_compras_repository.dart';
import 'catalogo_page.dart';
import 'configuracoes_page.dart';
import 'minha_lista_page.dart';

/// Navegação principal com três destinos.
class HomePage extends StatefulWidget {
  final ListaComprasRepository repositorio;
  final bool temaEscuro;
  final bool somentePendentes;
  final Future<void> Function(bool) onTemaEscuroChanged;
  final Future<void> Function(bool) onSomentePendentesChanged;

  const HomePage({
    super.key,
    required this.repositorio,
    required this.temaEscuro,
    required this.somentePendentes,
    required this.onTemaEscuroChanged,
    required this.onSomentePendentesChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indice = 0;

  /// Muda sempre que a aba Minha lista é aberta, recriando a tela e
  /// forçando uma nova leitura do SQLite.
  int _versaoLista = 0;

  void _selecionar(int indice) {
    setState(() {
      if (indice == 1) _versaoLista++;
      _indice = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantém o catálogo carregado ao trocar de aba.
      body: IndexedStack(
        index: _indice,
        children: [
          CatalogoPage(repositorio: widget.repositorio),
          MinhaListaPage(
            key: ValueKey(_versaoLista),
            repositorio: widget.repositorio,
            somentePendentes: widget.somentePendentes,
          ),
          ConfiguracoesPage(
            temaEscuro: widget.temaEscuro,
            somentePendentes: widget.somentePendentes,
            onTemaEscuroChanged: widget.onTemaEscuroChanged,
            onSomentePendentesChanged: widget.onSomentePendentesChanged,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: _selecionar,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Minha lista',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}

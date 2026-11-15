import 'package:material_ui/material_ui.dart';

import '../data/lista_compras_repository.dart';
import '../models/produto_remoto.dart';
import '../services/produtos_api_service.dart';
import '../utils/formatacao.dart';
import 'produto_detalhe_page.dart';

/// Catálogo consultado na DummyJSON.
class CatalogoPage extends StatefulWidget {
  final ListaComprasRepository repositorio;
  final ProdutosApiService? servico;

  const CatalogoPage({super.key, required this.repositorio, this.servico});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  late final ProdutosApiService _servico =
      widget.servico ?? ProdutosApiService();
  late Future<List<ProdutoRemoto>> _produtosFuturos;

  @override
  void initState() {
    super.initState();
    // A consulta começa uma única vez e o Future fica guardado.
    _produtosFuturos = _servico.buscarProdutos();
  }

  /// Atualizar e Tentar novamente criam um NOVO Future (novo GET).
  void _recarregar() {
    setState(() {
      _produtosFuturos = _servico.buscarProdutos();
    });
  }

  void _abrirDetalhes(ProdutoRemoto produto) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProdutoDetalhePage(
          produto: produto,
          repositorio: widget.repositorio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _recarregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<ProdutoRemoto>>(
        future: _produtosFuturos,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Carregando produtos...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return _MensagemErro(onTentarNovamente: _recarregar);
          }

          final produtos = snapshot.data ?? const <ProdutoRemoto>[];
          if (produtos.isEmpty) {
            return const Center(child: Text('Nenhum produto retornado.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _recarregar();
              await _produtosFuturos.catchError((_) => <ProdutoRemoto>[]);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: produtos.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, indice) {
                final produto = produtos[indice];
                return ListTile(
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: Image.network(
                      produto.imagem,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                  title: Text(produto.titulo),
                  subtitle: Text(formatarPreco(produto.preco)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _abrirDetalhes(produto),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MensagemErro extends StatelessWidget {
  final VoidCallback onTentarNovamente;

  const _MensagemErro({required this.onTentarNovamente});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 56, color: cores.error),
            const SizedBox(height: 12),
            Text(
              'Não foi possível consultar o catálogo.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Verifique sua conexão com a internet e tente novamente. '
              'Sua lista de compras continua disponível sem internet.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onTentarNovamente,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../data/lista_compras_repository.dart';
import '../models/produto_remoto.dart';
import '../utils/formatacao.dart';

/// Detalhes de um produto da API, com a ação Adicionar à lista.
class ProdutoDetalhePage extends StatefulWidget {
  final ProdutoRemoto produto;
  final ListaComprasRepository repositorio;

  const ProdutoDetalhePage({
    super.key,
    required this.produto,
    required this.repositorio,
  });

  @override
  State<ProdutoDetalhePage> createState() => _ProdutoDetalhePageState();
}

class _ProdutoDetalhePageState extends State<ProdutoDetalhePage> {
  bool _salvando = false;

  Future<void> _adicionar() async {
    if (_salvando) return;
    setState(() => _salvando = true);

    final mensageiro = ScaffoldMessenger.of(context);
    try {
      // Aguarda a gravação no SQLite antes de avisar o usuário.
      final inseriu = await widget.repositorio.adicionar(widget.produto);
      mensageiro
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              inseriu
                  ? '"${widget.produto.titulo}" foi adicionado à lista.'
                  : '"${widget.produto.titulo}" já está na lista. '
                      'O item existente foi mantido.',
            ),
          ),
        );
    } catch (erro) {
      mensageiro.showSnackBar(
        SnackBar(content: Text('Não foi possível adicionar: $erro')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final produto = widget.produto;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(
            height: 220,
            child: Image.network(
              produto.imagem,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.image_not_supported_outlined, size: 80),
            ),
          ),
          const SizedBox(height: 16),
          Text(produto.titulo, style: textos.headlineSmall),
          const SizedBox(height: 8),
          Text(
            formatarPreco(produto.preco),
            style: textos.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text('Código do produto: ${produto.id}', style: textos.bodySmall),
          const SizedBox(height: 16),
          Text(produto.descricao, style: textos.bodyLarge),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _salvando ? null : _adicionar,
            icon: const Icon(Icons.add_shopping_cart),
            label: Text(_salvando ? 'Adicionando...' : 'Adicionar à lista'),
          ),
        ],
      ),
    );
  }
}

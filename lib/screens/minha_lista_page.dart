import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../data/lista_compras_repository.dart';
import '../models/item_compra.dart';
import '../utils/formatacao.dart';

/// Lista de compras lida do SQLite. Funciona sem internet.
class MinhaListaPage extends StatefulWidget {
  final ListaComprasRepository repositorio;
  final bool somentePendentes;

  const MinhaListaPage({
    super.key,
    required this.repositorio,
    required this.somentePendentes,
  });

  @override
  State<MinhaListaPage> createState() => _MinhaListaPageState();
}

class _MinhaListaPageState extends State<MinhaListaPage> {
  /// Todos os registros do banco (base para o total estimado).
  List<ItemCompra> _itens = const [];
  bool _carregando = true;
  Object? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final itens = await widget.repositorio.listar();
      if (!mounted) return;
      setState(() {
        _itens = itens;
        _erro = null;
        _carregando = false;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _erro = erro;
        _carregando = false;
      });
    }
  }

  /// Executa uma gravação, aguarda a conclusão e relê o banco.
  Future<bool> _gravar(Future<void> Function() operacao) async {
    var sucesso = true;
    try {
      await operacao();
    } catch (erro) {
      sucesso = false;
      _mostrarMensagem('Não foi possível salvar: $erro');
    }
    await _carregar();
    return sucesso;
  }

  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _alterarQuantidade(ItemCompra item, int novaQuantidade) async {
    if (!ItemCompra.quantidadeValida(novaQuantidade)) {
      _mostrarMensagem('Quantidade inválida. Use um número inteiro de 1 a 99.');
      return;
    }
    await _gravar(
      () => widget.repositorio.atualizarQuantidade(
        item.produtoId,
        novaQuantidade,
      ),
    );
  }

  Future<void> _editarQuantidade(ItemCompra item) async {
    final novaQuantidade = await showDialog<int>(
      context: context,
      builder: (_) => _DialogoQuantidade(item: item),
    );
    if (novaQuantidade == null || novaQuantidade == item.quantidade) return;
    await _alterarQuantidade(item, novaQuantidade);
  }

  Future<void> _alternarComprado(ItemCompra item, bool comprado) async {
    await _gravar(
      () => widget.repositorio.marcarComprado(item.produtoId, comprado),
    );
  }

  Future<void> _excluir(ItemCompra item) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Excluir item?'),
        content: Text('Deseja remover "${item.nome}" da lista de compras?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;
    final excluiu =
        await _gravar(() => widget.repositorio.excluir(item.produtoId));
    if (excluiu) _mostrarMensagem('"${item.nome}" foi removido da lista.');
  }

  @override
  Widget build(BuildContext context) {
    // Itens visíveis derivados dos registros do banco.
    final visiveis = widget.somentePendentes
        ? _itens.where((item) => !item.comprado).toList()
        : _itens;
    final ocultos = _itens.length - visiveis.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha lista'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.somentePendentes)
            _AvisoFiltro(ocultos: ocultos),
          Expanded(child: _conteudo(visiveis)),
        ],
      ),
      bottomNavigationBar: _itens.isEmpty
          ? null
          : _BarraTotal(
              totalCentavos: ItemCompra.totalCentavos(_itens),
              quantidadeItens: _itens.length,
              ocultos: ocultos,
            ),
    );
  }

  Widget _conteudo(List<ItemCompra> visiveis) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Erro ao ler a lista salva no aparelho.'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _carregar,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_itens.isEmpty) {
      return const _Vazio(
        icone: Icons.shopping_cart_outlined,
        texto: 'Ainda não há itens na lista.\n'
            'Adicione produtos pelo Catálogo.',
      );
    }
    if (visiveis.isEmpty) {
      return const _Vazio(
        icone: Icons.task_alt,
        texto: 'Não há itens pendentes.\n'
            'Desligue o filtro em Configurações para ver os comprados.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemCount: visiveis.length,
      itemBuilder: (context, indice) {
        final item = visiveis[indice];
        return _CartaoItem(
          key: ValueKey(item.produtoId),
          item: item,
          onCompradoChanged: (valor) => _alternarComprado(item, valor),
          onDiminuir: () => _alterarQuantidade(item, item.quantidade - 1),
          onAumentar: () => _alterarQuantidade(item, item.quantidade + 1),
          onEditarQuantidade: () => _editarQuantidade(item),
          onExcluir: () => _excluir(item),
        );
      },
    );
  }
}

class _CartaoItem extends StatelessWidget {
  final ItemCompra item;
  final ValueChanged<bool> onCompradoChanged;
  final VoidCallback onDiminuir;
  final VoidCallback onAumentar;
  final VoidCallback onEditarQuantidade;
  final VoidCallback onExcluir;

  const _CartaoItem({
    super.key,
    required this.item,
    required this.onCompradoChanged,
    required this.onDiminuir,
    required this.onAumentar,
    required this.onEditarQuantidade,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: item.comprado,
              onChanged: (valor) => onCompradoChanged(valor ?? false),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome,
                    style: tema.textTheme.titleMedium?.copyWith(
                      decoration:
                          item.comprado ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Preço unitário: ${formatarCentavos(item.precoCentavos)}'),
                  Text(
                    'Subtotal: ${formatarCentavos(item.subtotalCentavos)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Chip(
                        visualDensity: VisualDensity.compact,
                        avatar: Icon(
                          item.comprado ? Icons.check_circle : Icons.schedule,
                          size: 18,
                          color: item.comprado ? cores.primary : cores.tertiary,
                        ),
                        label: Text(item.comprado ? 'Comprado' : 'Pendente'),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Diminuir quantidade',
                        onPressed: item.quantidade > ItemCompra.quantidadeMinima
                            ? onDiminuir
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      TextButton(
                        onPressed: onEditarQuantidade,
                        child: Text(
                          'Qtd: ${item.quantidade}',
                          style: tema.textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Aumentar quantidade',
                        onPressed: item.quantidade < ItemCompra.quantidadeMaxima
                            ? onAumentar
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Excluir',
              onPressed: onExcluir,
              icon: Icon(Icons.delete_outline, color: cores.error),
            ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo para digitar a quantidade. Rejeita valores fora de 1 a 99.
class _DialogoQuantidade extends StatefulWidget {
  final ItemCompra item;

  const _DialogoQuantidade({required this.item});

  @override
  State<_DialogoQuantidade> createState() => _DialogoQuantidadeState();
}

class _DialogoQuantidadeState extends State<_DialogoQuantidade> {
  final _formulario = GlobalKey<FormState>();
  late final _controle =
      TextEditingController(text: widget.item.quantidade.toString());

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  String? _validar(String? texto) {
    final valor = int.tryParse((texto ?? '').trim());
    if (valor == null || !ItemCompra.quantidadeValida(valor)) {
      return 'Informe um número inteiro de 1 a 99.';
    }
    return null;
  }

  void _salvar() {
    if (_formulario.currentState?.validate() != true) return;
    Navigator.pop(context, int.parse(_controle.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alterar quantidade'),
      content: Form(
        key: _formulario,
        child: TextFormField(
          controller: _controle,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: widget.item.nome,
            helperText: 'Valores aceitos: 1 a 99',
          ),
          validator: _validar,
          onFieldSubmitted: (_) => _salvar(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}

class _AvisoFiltro extends StatelessWidget {
  final int ocultos;

  const _AvisoFiltro({required this.ocultos});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: cores.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Filtro ativo: mostrando somente pendentes'
        '${ocultos > 0 ? ' ($ocultos comprado(s) oculto(s))' : ''}.',
        style: TextStyle(color: cores.onSecondaryContainer),
      ),
    );
  }
}

class _BarraTotal extends StatelessWidget {
  final int totalCentavos;
  final int quantidadeItens;
  final int ocultos;

  const _BarraTotal({
    required this.totalCentavos,
    required this.quantidadeItens,
    required this.ocultos,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Material(
      color: tema.colorScheme.primaryContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Total estimado ($quantidadeItens '
                  '${quantidadeItens == 1 ? 'item' : 'itens'}'
                  '${ocultos > 0 ? ', inclui ocultos' : ''})',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Text(
                formatarCentavos(totalCentavos),
                style: tema.textTheme.titleLarge?.copyWith(
                  color: tema.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _Vazio({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(texto, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

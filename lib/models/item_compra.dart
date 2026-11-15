/// Registro local da lista de compras (tabela `itens_compra` do SQLite).
class ItemCompra {
  static const int quantidadeMinima = 1;
  static const int quantidadeMaxima = 99;

  final int produtoId;
  final String nome;
  final int precoCentavos;
  final int quantidade;
  final bool comprado;

  const ItemCompra({
    required this.produtoId,
    required this.nome,
    required this.precoCentavos,
    required this.quantidade,
    required this.comprado,
  });

  /// Lê um registro do banco. `comprado`: 0 = pendente, 1 = comprado.
  factory ItemCompra.fromMap(Map<String, Object?> mapa) {
    return ItemCompra(
      produtoId: (mapa['produto_id'] as num).toInt(),
      nome: mapa['nome'] as String,
      precoCentavos: (mapa['preco_centavos'] as num).toInt(),
      quantidade: (mapa['quantidade'] as num).toInt(),
      comprado: (mapa['comprado'] as num).toInt() == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'produto_id': produtoId,
      'nome': nome,
      'preco_centavos': precoCentavos,
      'quantidade': quantidade,
      'comprado': comprado ? 1 : 0,
    };
  }

  /// Subtotal = preço em centavos × quantidade (somente inteiros).
  int get subtotalCentavos => precoCentavos * quantidade;

  /// Quantidade aceita pelo app: inteiro de 1 a 99.
  static bool quantidadeValida(int quantidade) =>
      quantidade >= quantidadeMinima && quantidade <= quantidadeMaxima;

  /// Total estimado = soma dos subtotais de TODOS os itens recebidos
  /// (inclusive comprados e ocultos pelo filtro).
  static int totalCentavos(Iterable<ItemCompra> itens) =>
      itens.fold(0, (soma, item) => soma + item.subtotalCentavos);
}

/// Produto recebido da API REST da DummyJSON.
///
/// Representa apenas os campos usados pelo app. Os dados vêm do JSON
/// e não são alterados pelo aplicativo.
class ProdutoRemoto {
  final int id;
  final String titulo;
  final String descricao;
  final double preco;
  final String imagem;

  const ProdutoRemoto({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.preco,
    required this.imagem,
  });

  /// Converte o mapa de UM produto do JSON em um objeto Dart.
  ///
  /// `price` pode chegar como int ou double no JSON, por isso é lido
  /// como `num` e convertido com `toDouble()`.
  factory ProdutoRemoto.fromJson(Map<String, dynamic> json) {
    return ProdutoRemoto(
      id: (json['id'] as num).toInt(),
      titulo: json['title'] as String,
      descricao: json['description'] as String? ?? '',
      preco: (json['price'] as num).toDouble(),
      imagem: json['thumbnail'] as String? ?? '',
    );
  }

  /// Preço convertido para centavos, como é gravado no SQLite.
  int get precoCentavos => (preco * 100).round();
}

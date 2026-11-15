import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/produto_remoto.dart';

/// Responsável apenas pela comunicação HTTP com a DummyJSON.
class ProdutosApiService {
  static const int limite = 20;
  static const Duration tempoLimite = Duration(seconds: 15);

  final http.Client _cliente;

  /// O cliente pode ser trocado nos testes; no app usa o padrão.
  ProdutosApiService({http.Client? cliente})
      : _cliente = cliente ?? http.Client();

  Future<List<ProdutoRemoto>> buscarProdutos() async {
    final url = Uri.parse('https://dummyjson.com/products?limit=$limite');

    // O timeout impede que a tela fique carregando indefinidamente.
    final resposta = await _cliente.get(url).timeout(tempoLimite);

    if (resposta.statusCode != 200) {
      throw Exception('Erro HTTP: ${resposta.statusCode}');
    }

    // bodyBytes + utf8.decode evita problemas com acentuação.
    final dynamic dados = jsonDecode(utf8.decode(resposta.bodyBytes));

    if (dados is! Map<String, dynamic>) {
      throw const FormatException('Resposta JSON inesperada.');
    }

    final dynamic itens = dados['products'];
    if (itens is! List) {
      throw const FormatException('Campo products ausente.');
    }

    return itens
        .map((item) => ProdutoRemoto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

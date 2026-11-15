import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:minha_lista_de_compras/services/produtos_api_service.dart';

void main() {
  test('faz GET com limit=20 e converte a lista products', () async {
    late Uri urlChamada;
    final cliente = MockClient((requisicao) async {
      urlChamada = requisicao.url;
      return http.Response.bytes(
        utf8.encode(jsonEncode({
          'products': [
            {'id': 1, 'title': 'Pão de queijo', 'price': 2.5},
            {'id': 2, 'title': 'Café', 'price': 10},
          ],
          'total': 194,
        })),
        200,
      );
    });

    final produtos =
        await ProdutosApiService(cliente: cliente).buscarProdutos();

    expect(urlChamada.toString(), 'https://dummyjson.com/products?limit=20');
    expect(produtos, hasLength(2));
    expect(produtos.first.titulo, 'Pão de queijo');
    expect(produtos.last.preco, 10.0);
  });

  test('status diferente de 200 gera erro', () async {
    final cliente = MockClient((_) async => http.Response('erro', 500));
    expect(
      ProdutosApiService(cliente: cliente).buscarProdutos(),
      throwsException,
    );
  });

  test('JSON sem products gera FormatException', () async {
    final cliente = MockClient((_) async => http.Response('{"x": 1}', 200));
    expect(
      ProdutosApiService(cliente: cliente).buscarProdutos(),
      throwsFormatException,
    );
  });

  test('falha de conexão é propagada para a tela tratar', () async {
    final cliente = MockClient(
      (_) async => throw http.ClientException('sem rede'),
    );
    expect(
      ProdutosApiService(cliente: cliente).buscarProdutos(),
      throwsA(isA<http.ClientException>()),
    );
  });
}

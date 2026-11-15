import 'package:flutter_test/flutter_test.dart';
import 'package:minha_lista_de_compras/models/item_compra.dart';
import 'package:minha_lista_de_compras/models/produto_remoto.dart';
import 'package:minha_lista_de_compras/utils/formatacao.dart';

void main() {
  group('ProdutoRemoto.fromJson', () {
    test('converte um produto do JSON', () {
      final produto = ProdutoRemoto.fromJson({
        'id': 1,
        'title': 'Essence Mascara Lash Princess',
        'description': 'Descrição',
        'price': 9.99,
        'thumbnail': 'https://cdn.dummyjson.com/x.webp',
        'rating': 4.9,
      });

      expect(produto.id, 1);
      expect(produto.titulo, 'Essence Mascara Lash Princess');
      expect(produto.descricao, 'Descrição');
      expect(produto.preco, 9.99);
      expect(produto.imagem, 'https://cdn.dummyjson.com/x.webp');
      expect(produto.precoCentavos, 999);
    });

    test('aceita price inteiro e campos opcionais ausentes', () {
      final produto = ProdutoRemoto.fromJson({
        'id': 7,
        'title': 'Produto',
        'price': 8,
      });

      expect(produto.preco, 8.0);
      expect(produto.descricao, '');
      expect(produto.imagem, '');
    });
  });

  group('ItemCompra', () {
    test('fromMap converte comprado 0/1 e toMap faz o inverso', () {
      final item = ItemCompra.fromMap({
        'produto_id': 3,
        'nome': 'Arroz',
        'preco_centavos': 1250,
        'quantidade': 3,
        'comprado': 1,
      });

      expect(item.comprado, isTrue);
      expect(item.subtotalCentavos, 3750);
      expect(item.toMap()['comprado'], 1);
      expect(
        ItemCompra.fromMap({...item.toMap(), 'comprado': 0}).comprado,
        isFalse,
      );
    });

    test('total do exemplo do roteiro: US\$ 45,50', () {
      const itens = [
        ItemCompra(
          produtoId: 1,
          nome: 'A',
          precoCentavos: 1250,
          quantidade: 3,
          comprado: true,
        ),
        ItemCompra(
          produtoId: 2,
          nome: 'B',
          precoCentavos: 800,
          quantidade: 1,
          comprado: false,
        ),
      ];

      expect(ItemCompra.totalCentavos(itens), 4550);
      expect(formatarCentavos(ItemCompra.totalCentavos(itens)), 'US\$ 45,50');
    });

    test('quantidade válida somente de 1 a 99', () {
      expect(ItemCompra.quantidadeValida(0), isFalse);
      expect(ItemCompra.quantidadeValida(1), isTrue);
      expect(ItemCompra.quantidadeValida(99), isTrue);
      expect(ItemCompra.quantidadeValida(100), isFalse);
    });
  });

  group('formatação', () {
    test('duas casas decimais com US\$', () {
      expect(formatarCentavos(0), 'US\$ 0,00');
      expect(formatarCentavos(5), 'US\$ 0,05');
      expect(formatarCentavos(123456), 'US\$ 1234,56');
      expect(formatarPreco(9.99), 'US\$ 9,99');
      expect(formatarPreco(12.5), 'US\$ 12,50');
    });
  });
}

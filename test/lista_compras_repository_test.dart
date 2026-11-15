import 'package:flutter_test/flutter_test.dart';
import 'package:minha_lista_de_compras/data/lista_compras_repository.dart';
import 'package:minha_lista_de_compras/models/item_compra.dart';
import 'package:minha_lista_de_compras/models/produto_remoto.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Testa o repositório com o SQLite real (FFI) em um banco em memória.
void main() {
  late ListaComprasRepository repositorio;

  const produtoA = ProdutoRemoto(
    id: 10,
    titulo: 'Produto A',
    descricao: '',
    preco: 12.5,
    imagem: '',
  );
  const produtoB = ProdutoRemoto(
    id: 20,
    titulo: 'Produto B',
    descricao: '',
    preco: 8.0,
    imagem: '',
  );

  setUpAll(sqfliteFfiInit);

  setUp(() {
    repositorio = ListaComprasRepository(
      abrirBanco: () => databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          singleInstance: false,
          onCreate: ListaComprasRepository.criarTabela,
        ),
      ),
    );
  });

  tearDown(() => repositorio.fechar());

  test('T3: adicionar duas vezes mantém uma linha com quantidade 1', () async {
    expect(await repositorio.adicionar(produtoA), isTrue);
    expect(await repositorio.adicionar(produtoA), isFalse);

    final itens = await repositorio.listar();
    expect(itens, hasLength(1));
    expect(itens.single.produtoId, 10);
    expect(itens.single.quantidade, 1);
    expect(itens.single.comprado, isFalse);
    expect(itens.single.precoCentavos, 1250);
  });

  test('duplicata não altera o registro existente', () async {
    await repositorio.adicionar(produtoA);
    await repositorio.atualizarQuantidade(10, 3);
    expect(await repositorio.adicionar(produtoA), isFalse);
    expect((await repositorio.buscarPorId(10))!.quantidade, 3);
  });

  test('T4: quantidade 0 e 100 são rejeitadas e 3 é preservada', () async {
    await repositorio.adicionar(produtoA);
    await repositorio.adicionar(produtoB);
    await repositorio.atualizarQuantidade(10, 3);

    expect(() => repositorio.atualizarQuantidade(10, 0), throwsArgumentError);
    expect(
      () => repositorio.atualizarQuantidade(10, 100),
      throwsArgumentError,
    );

    final item = (await repositorio.buscarPorId(10))!;
    expect(item.quantidade, 3);
    expect(item.subtotalCentavos, 3 * 1250);
  });

  test('a tabela também barra quantidade fora de 1 a 99 (CHECK)', () async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        singleInstance: false,
        onCreate: ListaComprasRepository.criarTabela,
      ),
    );
    addTearDown(db.close);

    Future<void> inserir(int quantidade) => db.insert('itens_compra', {
          'produto_id': quantidade,
          'nome': 'X',
          'preco_centavos': 100,
          'quantidade': quantidade,
          'comprado': 0,
        });

    await inserir(99);
    expect(() => inserir(0), throwsA(isA<DatabaseException>()));
    expect(() => inserir(100), throwsA(isA<DatabaseException>()));
  });

  test('T5: marcar comprado persiste e o total inclui todos', () async {
    await repositorio.adicionar(produtoA);
    await repositorio.adicionar(produtoB);
    await repositorio.atualizarQuantidade(10, 3);
    await repositorio.marcarComprado(10, true);

    final itens = await repositorio.listar();
    expect(itens.firstWhere((i) => i.produtoId == 10).comprado, isTrue);
    expect(ItemCompra.totalCentavos(itens), 4550);

    await repositorio.marcarComprado(10, false);
    expect((await repositorio.buscarPorId(10))!.comprado, isFalse);
  });

  test('T7: excluir remove somente o item escolhido', () async {
    await repositorio.adicionar(produtoA);
    await repositorio.adicionar(produtoB);

    await repositorio.excluir(10);

    final itens = await repositorio.listar();
    expect(itens.map((i) => i.produtoId), [20]);
    expect(ItemCompra.totalCentavos(itens), 800);
  });
}

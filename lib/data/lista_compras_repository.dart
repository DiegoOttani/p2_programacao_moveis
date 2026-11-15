import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item_compra.dart';
import '../models/produto_remoto.dart';

/// Abre o banco local `compras.db` e executa as operações sobre os itens.
class ListaComprasRepository {
  static const String nomeBanco = 'compras.db';
  static const String tabela = 'itens_compra';

  /// Instância única usada pelo app, para não abrir o banco várias vezes.
  static final ListaComprasRepository instancia = ListaComprasRepository();

  /// Permite usar outro banco nos testes (ex.: em memória).
  /// Quando nulo, abre o arquivo `compras.db` do aparelho.
  final Future<Database> Function()? abrirBanco;
  Future<Database>? _banco;

  ListaComprasRepository({this.abrirBanco});

  static Future<void> criarTabela(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE $tabela (
        produto_id INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        preco_centavos INTEGER NOT NULL CHECK (preco_centavos >= 0),
        quantidade INTEGER NOT NULL CHECK (quantidade BETWEEN 1 AND 99),
        comprado INTEGER NOT NULL CHECK (comprado IN (0, 1))
      )
    ''');
  }

  Future<Database> get _database => _banco ??= (abrirBanco ?? _abrirPadrao)();

  Future<Database> _abrirPadrao() async {
    final pasta = await getDatabasesPath();
    return openDatabase(
      join(pasta, nomeBanco),
      version: 1,
      onCreate: criarTabela,
    );
  }

  /// Adiciona o produto com quantidade 1 e estado pendente.
  ///
  /// Retorna `true` se inseriu e `false` se o produto já estava na lista
  /// (o registro existente é mantido). A consulta e a inclusão acontecem
  /// na mesma transação, usando o objeto `txn` nas duas operações.
  Future<bool> adicionar(ProdutoRemoto produto) async {
    final db = await _database;
    return db.transaction((txn) async {
      final existentes = await txn.query(
        tabela,
        columns: ['produto_id'],
        where: 'produto_id = ?',
        whereArgs: [produto.id],
        limit: 1,
      );
      if (existentes.isNotEmpty) return false;

      await txn.insert(
        tabela,
        ItemCompra(
          produtoId: produto.id,
          nome: produto.titulo,
          precoCentavos: produto.precoCentavos,
          quantidade: 1,
          comprado: false,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return true;
    });
  }

  Future<List<ItemCompra>> listar() async {
    final db = await _database;
    final linhas = await db.query(tabela, orderBy: 'nome COLLATE NOCASE');
    return linhas.map(ItemCompra.fromMap).toList();
  }

  Future<ItemCompra?> buscarPorId(int produtoId) async {
    final db = await _database;
    final linhas = await db.query(
      tabela,
      where: 'produto_id = ?',
      whereArgs: [produtoId],
      limit: 1,
    );
    return linhas.isEmpty ? null : ItemCompra.fromMap(linhas.first);
  }

  /// Altera a quantidade. Aceita somente inteiros de 1 a 99.
  Future<void> atualizarQuantidade(int produtoId, int quantidade) async {
    if (!ItemCompra.quantidadeValida(quantidade)) {
      throw ArgumentError.value(
        quantidade,
        'quantidade',
        'A quantidade deve ser um número inteiro de 1 a 99.',
      );
    }
    final db = await _database;
    await db.update(
      tabela,
      {'quantidade': quantidade},
      where: 'produto_id = ?',
      whereArgs: [produtoId],
    );
  }

  Future<void> marcarComprado(int produtoId, bool comprado) async {
    final db = await _database;
    await db.update(
      tabela,
      {'comprado': comprado ? 1 : 0},
      where: 'produto_id = ?',
      whereArgs: [produtoId],
    );
  }

  Future<void> excluir(int produtoId) async {
    final db = await _database;
    await db.delete(
      tabela,
      where: 'produto_id = ?',
      whereArgs: [produtoId],
    );
  }

  Future<void> fechar() async {
    final banco = _banco;
    _banco = null;
    if (banco != null) await (await banco).close();
  }
}

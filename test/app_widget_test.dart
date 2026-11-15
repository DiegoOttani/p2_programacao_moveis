import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:minha_lista_de_compras/app.dart';
import 'package:minha_lista_de_compras/data/lista_compras_repository.dart';
import 'package:minha_lista_de_compras/models/item_compra.dart';
import 'package:minha_lista_de_compras/models/produto_remoto.dart';
import 'package:minha_lista_de_compras/screens/minha_lista_page.dart';
import 'package:minha_lista_de_compras/services/preferencias_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repositório em memória para testar as telas sem SQLite.
class RepositorioFalso extends ListaComprasRepository {
  final Map<int, ItemCompra> itens = {};

  @override
  Future<bool> adicionar(ProdutoRemoto produto) async {
    if (itens.containsKey(produto.id)) return false;
    itens[produto.id] = ItemCompra(
      produtoId: produto.id,
      nome: produto.titulo,
      precoCentavos: produto.precoCentavos,
      quantidade: 1,
      comprado: false,
    );
    return true;
  }

  @override
  Future<List<ItemCompra>> listar() async => itens.values.toList();

  @override
  Future<void> atualizarQuantidade(int produtoId, int quantidade) async {
    if (!ItemCompra.quantidadeValida(quantidade)) throw ArgumentError();
    final item = itens[produtoId]!;
    itens[produtoId] = ItemCompra.fromMap({
      ...item.toMap(),
      'quantidade': quantidade,
    });
  }

  @override
  Future<void> marcarComprado(int produtoId, bool comprado) async {
    final item = itens[produtoId]!;
    itens[produtoId] = ItemCompra.fromMap({
      ...item.toMap(),
      'comprado': comprado ? 1 : 0,
    });
  }

  @override
  Future<void> excluir(int produtoId) async => itens.remove(produtoId);
}

RepositorioFalso _repositorioComDoisItens() {
  return RepositorioFalso()
    ..itens[1] = const ItemCompra(
      produtoId: 1,
      nome: 'Primeiro',
      precoCentavos: 1250,
      quantidade: 3,
      comprado: true,
    )
    ..itens[2] = const ItemCompra(
      produtoId: 2,
      nome: 'Segundo',
      precoCentavos: 800,
      quantidade: 1,
      comprado: false,
    );
}

Widget _lista(RepositorioFalso repositorio, {bool somentePendentes = false}) {
  return MaterialApp(
    home: MinhaListaPage(
      repositorio: repositorio,
      somentePendentes: somentePendentes,
    ),
  );
}

void main() {
  testWidgets('lista vazia informa que ainda não há itens', (tester) async {
    await tester.pumpWidget(_lista(RepositorioFalso()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ainda não há itens'), findsOneWidget);
  });

  testWidgets('T5: filtro oculta comprado e total inclui os dois',
      (tester) async {
    final repositorio = _repositorioComDoisItens();

    await tester.pumpWidget(_lista(repositorio, somentePendentes: true));
    await tester.pumpAndSettle();
    expect(find.text('Primeiro'), findsNothing);
    expect(find.text('Segundo'), findsOneWidget);
    expect(find.text('US\$ 45,50'), findsOneWidget);

    // Desligando o filtro o item reaparece como comprado.
    await tester.pumpWidget(_lista(repositorio));
    await tester.pumpAndSettle();
    expect(find.text('Primeiro'), findsOneWidget);
    expect(find.text('Comprado'), findsOneWidget);
    expect(find.text('Subtotal: US\$ 37,50'), findsOneWidget);
  });

  testWidgets('filtro com todos comprados informa que não há pendentes',
      (tester) async {
    final repositorio = _repositorioComDoisItens();
    await repositorio.marcarComprado(2, true);

    await tester.pumpWidget(_lista(repositorio, somentePendentes: true));
    await tester.pumpAndSettle();
    expect(find.textContaining('Não há itens pendentes'), findsOneWidget);
  });

  testWidgets('T4: diálogo rejeita 0 e 100 e preserva a quantidade',
      (tester) async {
    final repositorio = _repositorioComDoisItens();
    await tester.pumpWidget(_lista(repositorio));
    await tester.pumpAndSettle();

    for (final invalido in ['0', '100']) {
      await tester.tap(find.text('Qtd: 3'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), invalido);
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(find.text('Informe um número inteiro de 1 a 99.'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
    }

    expect(repositorio.itens[1]!.quantidade, 3);
    expect(find.text('Qtd: 3'), findsOneWidget);
  });

  testWidgets('marcar comprado grava e atualiza a tela', (tester) async {
    final repositorio = _repositorioComDoisItens();
    await tester.pumpWidget(_lista(repositorio));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();

    expect(repositorio.itens[2]!.comprado, isTrue);
    expect(find.text('Comprado'), findsNWidgets(2));
  });

  testWidgets('T7: cancelar mantém o item e confirmar exclui', (tester) async {
    final repositorio = _repositorioComDoisItens();
    await tester.pumpWidget(_lista(repositorio));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Excluir').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repositorio.itens, hasLength(2));

    await tester.tap(find.byTooltip('Excluir').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();
    expect(repositorio.itens, hasLength(1));
    expect(find.text('US\$ 8,00'), findsOneWidget);
  });

  testWidgets('T6: tema e filtro salvos são restaurados ao abrir',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      PreferenciasService.chaveTemaEscuro: true,
      PreferenciasService.chaveSomentePendentes: true,
    });
    final servico = PreferenciasService();
    final preferencias = await servico.carregar();

    await tester.pumpWidget(
      MinhaListaApp(
        preferenciasIniciais: preferencias,
        preferenciasService: servico,
        repositorio: _repositorioComDoisItens(),
      ),
    );
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    // Na aba Configurações os dois switches aparecem ligados.
    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();
    final switches =
        tester.widgetList<SwitchListTile>(find.byType(SwitchListTile));
    expect(switches.every((s) => s.value), isTrue);

    // Desligar o tema grava a preferência.
    await tester.tap(find.text('Tema escuro'));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(PreferenciasService.chaveTemaEscuro), isFalse);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });
}

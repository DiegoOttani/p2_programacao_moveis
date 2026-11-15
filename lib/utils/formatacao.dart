/// Formata valores em centavos como "US$ 12,50" (convenção do projeto:
/// valores da DummyJSON exibidos em dólar, sem conversão de moeda).
String formatarCentavos(int centavos) {
  final sinal = centavos < 0 ? '-' : '';
  final absoluto = centavos.abs();
  final inteiro = absoluto ~/ 100;
  final resto = (absoluto % 100).toString().padLeft(2, '0');
  return '${sinal}US\$ $inteiro,$resto';
}

/// Formata um preço em dólares (double vindo da API) com duas casas.
String formatarPreco(double preco) => formatarCentavos((preco * 100).round());

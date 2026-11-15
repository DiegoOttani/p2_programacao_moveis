import 'package:shared_preferences/shared_preferences.dart';

/// Valores das duas preferências do usuário.
class Preferencias {
  final bool temaEscuro;
  final bool somentePendentes;

  const Preferencias({
    this.temaEscuro = false,
    this.somentePendentes = false,
  });
}

/// Lê e grava as preferências no SharedPreferences.
class PreferenciasService {
  static const String chaveTemaEscuro = 'tema_escuro';
  static const String chaveSomentePendentes = 'somente_pendentes';

  Future<Preferencias> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return Preferencias(
      temaEscuro: prefs.getBool(chaveTemaEscuro) ?? false,
      somentePendentes: prefs.getBool(chaveSomentePendentes) ?? false,
    );
  }

  Future<void> salvarTemaEscuro(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(chaveTemaEscuro, valor);
  }

  Future<void> salvarSomentePendentes(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(chaveSomentePendentes, valor);
  }
}

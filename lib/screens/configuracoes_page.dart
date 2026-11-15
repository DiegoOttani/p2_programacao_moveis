import 'package:material_ui/material_ui.dart';

/// Preferências do usuário gravadas no SharedPreferences.
class ConfiguracoesPage extends StatefulWidget {
  final bool temaEscuro;
  final bool somentePendentes;
  final Future<void> Function(bool) onTemaEscuroChanged;
  final Future<void> Function(bool) onSomentePendentesChanged;

  const ConfiguracoesPage({
    super.key,
    required this.temaEscuro,
    required this.somentePendentes,
    required this.onTemaEscuroChanged,
    required this.onSomentePendentesChanged,
  });

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  bool _gravando = false;

  /// Bloqueia os controles enquanto a gravação não termina.
  Future<void> _alterar(Future<void> Function(bool) acao, bool valor) async {
    setState(() => _gravando = true);
    try {
      await acao(valor);
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar: $erro')),
        );
      }
    } finally {
      if (mounted) setState(() => _gravando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Tema escuro'),
            subtitle: const Text('Aplica o tema escuro em todas as telas.'),
            value: widget.temaEscuro,
            onChanged: _gravando
                ? null
                : (valor) => _alterar(widget.onTemaEscuroChanged, valor),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.filter_alt_outlined),
            title: const Text('Mostrar somente pendentes'),
            subtitle: const Text(
              'Oculta de Minha lista os itens marcados como comprados.',
            ),
            value: widget.somentePendentes,
            onChanged: _gravando
                ? null
                : (valor) => _alterar(widget.onSomentePendentesChanged, valor),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'As duas opções ficam salvas no aparelho e são restauradas '
              'ao fechar e abrir o aplicativo novamente.',
            ),
          ),
        ],
      ),
    );
  }
}

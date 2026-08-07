import 'package:boulder_competition/features/clienti/model/cliente_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ClienteFormPage extends StatefulWidget {
  /// Se null: modalità inserimento. Se valorizzato: modalità modifica.
  final Cliente? cliente;

  const ClienteFormPage({super.key, this.cliente});

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codiceController;
  late final TextEditingController _descrizioneController;
  late final TextEditingController _urlController;
  late final TextEditingController _anonKeyController;
  final _passwordController = TextEditingController();

  late bool _attivo;
  bool _salvataggioInCorso = false;
  bool _passwordVisibile = false;

  bool get _modificaEsistente => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _codiceController = TextEditingController(text: c?.codiceCliente ?? '');
    _descrizioneController =
        TextEditingController(text: c?.descrizioneCliente ?? '');
    _urlController = TextEditingController(text: c?.supabaseUrl ?? '');
    _anonKeyController = TextEditingController(text: c?.supabaseAnonKey ?? '');
    _attivo = c?.attivo ?? true;
  }

  @override
  void dispose() {
    _codiceController.dispose();
    _descrizioneController.dispose();
    _urlController.dispose();
    _anonKeyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _salva() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvataggioInCorso = true);
    final client = Supabase.instance.client;

    try {
      String? passwordHash;
      final nuovaPassword = _passwordController.text.trim();

      if (nuovaPassword.isNotEmpty) {
        final res = await client.rpc('hash_password', params: {
          'p_password': nuovaPassword,
        });
        passwordHash = res as String;
      } else if (!_modificaEsistente) {
        throw Exception('La password è obbligatoria per un nuovo cliente');
      }

      final dati = <String, dynamic>{
        'descrizione_cliente': _descrizioneController.text.trim(),
        'supabase_url': _urlController.text.trim(),
        'supabase_anon_key': _anonKeyController.text.trim(),
        'attivo': _attivo,
        if (passwordHash != null) 'password_hash': passwordHash,
      };

      if (_modificaEsistente) {
        await client
            .from('clienti')
            .update(dati)
            .eq('codice_cliente', widget.cliente!.codiceCliente);
      } else {
        dati['codice_cliente'] = _codiceController.text.trim();
        await client.from('clienti').insert(dati);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante il salvataggio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvataggioInCorso = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modificaEsistente ? 'Modifica cliente' : 'Nuovo cliente'),
      ),
      body: AbsorbPointer(
        absorbing: _salvataggioInCorso,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _codiceController,
                enabled: !_modificaEsistente,
                decoration: const InputDecoration(
                  labelText: 'Codice cliente',
                  helperText: 'Chiave primaria, non modificabile dopo la creazione',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descrizioneController,
                decoration: const InputDecoration(
                  labelText: 'Descrizione cliente',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Supabase URL',
                  hintText: 'https://xxxxxxxx.supabase.co',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _anonKeyController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Supabase anon key',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisibile,
                decoration: InputDecoration(
                  labelText: _modificaEsistente
                      ? 'Nuova password (lascia vuoto per non modificarla)'
                      : 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisibile
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _passwordVisibile = !_passwordVisibile),
                  ),
                ),
                validator: (v) {
                  if (!_modificaEsistente && (v == null || v.trim().isEmpty)) {
                    return 'Campo obbligatorio per un nuovo cliente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Attivo'),
                subtitle: const Text('Se disattivato, il login da app viene rifiutato'),
                value: _attivo,
                onChanged: (v) => setState(() => _attivo = v),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvataggioInCorso ? null : _salva,
                icon: _salvataggioInCorso
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_salvataggioInCorso ? 'Salvataggio...' : 'Salva'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

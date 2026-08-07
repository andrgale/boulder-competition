import 'package:boulder_competition/features/clienti/model/cliente_model.dart';
import 'package:boulder_competition/features/clienti/pages/cliente_form_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

class ClientiListPage extends StatefulWidget {
  const ClientiListPage({super.key});

  @override
  State<ClientiListPage> createState() => _ClientiListPageState();
}

class _ClientiListPageState extends State<ClientiListPage> {
  late Future<List<Cliente>> _futureClienti;

  @override
  void initState() {
    super.initState();
    _futureClienti = _carica();
  }

  Future<List<Cliente>> _carica() async {
    final data = await Supabase.instance.client
        .from('clienti')
        .select()
        .order('codice_cliente');
    return (data as List)
        .map((e) => Cliente.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  void _ricarica() {
    // NB: la closure passata a setState deve essere sincrona.
    // _carica() ritorna un Future, ma qui lo stiamo solo ASSEGNANDO
    // (riavviando il FutureBuilder), non stiamo facendo await dentro setState.
    setState(() {
      _futureClienti = _carica();
    });
  }

  Future<void> _apriForm({Cliente? cliente}) async {
    final salvato = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ClienteFormPage(cliente: cliente)),
    );
    if (salvato == true) _ricarica();
  }

  Future<void> _elimina(Cliente c) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Eliminare definitivamente il cliente "${c.codiceCliente}"?\n'
          '${c.descrizioneCliente}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              backgroundColor: Colors.red.shade50,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (conferma != true) return;

    try {
      await Supabase.instance.client
          .from('clienti')
          .delete()
          .eq('codice_cliente', c.codiceCliente);
      _ricarica();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cliente "${c.codiceCliente}" eliminato')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante l\'eliminazione: $e')),
        );
      }
    }
  }

  Future<void> _esci() async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Uscita'),
        content: const Text('Chiudere la console admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Esci'),
          ),
        ],
      ),
    );
    if (conferma == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Console Admin · Clienti'),
        centerTitle: false,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'esci',
            onPressed: _esci,
            icon: const Icon(Icons.logout),
            label: const Text('Uscita'),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'nuovo',
            onPressed: () => _apriForm(),
            icon: const Icon(Icons.add),
            label: const Text('Nuovo cliente'),
          ),
        ],
      ),
      body: FutureBuilder<List<Cliente>>(
        future: _futureClienti,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Errore nel caricamento:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final clienti = snapshot.data ?? [];
          if (clienti.isEmpty) {
            return const Center(child: Text('Nessun cliente presente'));
          }

          return RefreshIndicator(
            onRefresh: () async => _ricarica(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: clienti.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = clienti[index];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: c.attivo
                        ? Colors.green.shade100
                        : Colors.grey.shade300,
                    child: Icon(
                      c.attivo ? Icons.check : Icons.pause,
                      color: c.attivo
                          ? Colors.green.shade800
                          : Colors.grey.shade700,
                    ),
                  ),
                  title: Text(
                    '${c.codiceCliente} · ${c.descrizioneCliente}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    c.supabaseUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Modifica',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _apriForm(cliente: c),
                      ),
                      IconButton(
                        tooltip: 'Elimina',
                        icon: Icon(Icons.delete_outline,
                            color: Colors.red.shade600),
                        onPressed: () => _elimina(c),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
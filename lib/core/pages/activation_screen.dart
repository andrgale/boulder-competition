import 'package:flutter/material.dart';

class ActivationScreen extends StatefulWidget {
  final Future<void> Function(String clientId, String password) onSubmit;
  final String? error;
  const ActivationScreen({super.key, required this.onSubmit, this.error});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _clientIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  bool _obscure = true;

  Future<void> _submit() async {
    if (_clientIdController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) return;
    setState(() => _submitting = true);
    await widget.onSubmit(
      _clientIdController.text.trim(),
      _passwordController.text,
    );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Attivazione dispositivo', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 16),
                TextField(
                  controller: _clientIdController,
                  decoration: const InputDecoration(labelText: 'Codice cliente'),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                if (widget.error != null) ...[
                  const SizedBox(height: 8),
                  Text(widget.error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Attiva'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

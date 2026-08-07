class Cliente {
  final String codiceCliente;
  final String descrizioneCliente;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool attivo;

  const Cliente({
    required this.codiceCliente,
    required this.descrizioneCliente,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.attivo,
  });

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      codiceCliente: map['codice_cliente'] as String,
      descrizioneCliente: map['descrizione_cliente'] as String,
      supabaseUrl: map['supabase_url'] as String,
      supabaseAnonKey: map['supabase_anon_key'] as String,
      attivo: map['attivo'] as bool? ?? true,
    );
  }
}

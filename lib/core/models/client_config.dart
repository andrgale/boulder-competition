class ClientConfig {
  final String clientId;
  final String description;
  final String supabaseUrl;
  final String supabaseAnonKey;

  const ClientConfig({
    required this.clientId,
    required this.description,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });
}
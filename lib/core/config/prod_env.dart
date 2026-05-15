import 'env.dart';

class ProdEnv {
  static void load() {
    Env.supabaseUrl =
        'https://tassfrdwbynrspwzsjil.supabase.co';

    Env.supabaseAnonKey =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRhc3NmcmR3YnlucnNwd3pzamlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NDQ1NjAsImV4cCI6MjA5NDQyMDU2MH0.M5SGlwlYlg5eIqWefrp4-nn7L5PgWuF8U-mBCf9KxIw';
  }
}
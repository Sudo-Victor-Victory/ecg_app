/// Gathers env variables from cmd line args in real time
class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static String get url {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is NOT SET from cmd line args!');
    }
    return supabaseUrl;
  }

  static String get anonKey {
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is NOT SET from cmd line args!');
    }
    return supabaseAnonKey;
  }
}

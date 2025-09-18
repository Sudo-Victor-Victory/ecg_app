class KConstants {
  static const String brightnessKey = 'brightnessKey';
}

// Global variable for the user's name
String firstName = '';

/// Database table names
/// Database table names
class KTables {
  static const ecgSession = 'ecg_session';
  static const userProfile = 'profiles';
  static const ecgData = 'ecg_data';
}

/// Columns for `profiles` table
class KProfileColumns {
  static const id = 'id';
  static const firstName = 'first_name';
  static const lastName = 'last_name';
  static const signUpReason = 'signup_reason';
}

/// Columns for `ecg_session` table
class KSessionColumns {
  static const id = 'id';
  static const userId = 'user_id';
  static const startTime = 'start_time';
  static const endTime = 'end_time';
}

/// Columns for `ecg_data` table
class KECGDataColumns {
  static const id = 'id';
  static const sessionId = 'session_id';
  static const ecgData = 'ecg_data';
  static const timestamp = 'timestamp_ms';
  static const bpm = 'bpm';
}

class KEcgConstants {
  static const double sampleSpacingMs = 4.0;
  static const int packetSize = 28;
}

/// Text / font sizes
class KTextSize {
  static const double body = 14.0;
  static const double title = 18.0;
  static const double headline = 24.0;
}

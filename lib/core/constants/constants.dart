class Constants {
  // Prevents instantiation and extension
  Constants._();

  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String selectedSubdomainKey = 'selected_subdomain';
  static const String selectedShopIdKey = 'selected_shop_id';
  static const String selectedShopNameKey = 'selected_shop_name';
  static const String selectedDeviceIdKey = 'selected_device_id';
  static const String selectedConnectionTypeKey = 'selected_connection_type';
  static const String selectedPaperSizeKey = 'selected_paper_size';
  static const String selectedBrightnessKey = 'selected_brightness';

  static const int minSyncIntervalToleranceForCriticalInMinutes = 5;
  static const int minSyncIntervalToleranceForLessCriticalInMinutes = 100;

  // Google OAuth scopes required for user authentication
  static const List<String> authScopes = [
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/userinfo.email',
  ];

  // Non-critical error libraries that should be logged but not navigate to error screen
  static const nonCriticalErrorLibraries = {
    'image resource service',
  };
}

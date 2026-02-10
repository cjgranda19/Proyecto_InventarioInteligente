class AppConstants {
  // API URLs
  static const String baseApiUrl = 'https://isteremplea.ldcruminahui.com/api';
  static const String validationEndpoint = '/valida';
  
  // Valid credentials
  static const String validEmail = 'admin@admin.com';
  static const String validPassword = '123123123';
  
  // Database
  static const String databaseName = 'inventory_db.db';
  static const int databaseVersion = 1;
  
  // Sync
  static const Duration syncInterval = Duration(minutes: 15);
  static const String lastSyncKey = 'last_sync_timestamp';
  
  // Notifications
  static const String notificationChannelId = 'inventory_notifications';
  static const String notificationChannelName = 'Inventory Notifications';
  
  // Storage
  static const String imagesFolder = 'inventory_images';
  
  // Shared Preferences Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String userIdKey = 'user_id';
  static const String isLoggedInKey = 'is_logged_in';
  static const String offlineModeKey = 'offline_mode';
}

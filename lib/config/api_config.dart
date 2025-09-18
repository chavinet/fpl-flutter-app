class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000', // Default to local
  );
  
  // Optional: Add other environment-specific configs
  static const bool isProduction = String.fromEnvironment('ENVIRONMENT') == 'production';
  static const bool enableLogging = !isProduction;
}
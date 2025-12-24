// Google Places API Configuration
// Replace this value with your actual Google Places API key

// Central runtime configuration for Google Places API.
// Values are sourced from compile-time environment where possible to avoid committing secrets.

class GooglePlacesConfig {
  // Prefer passing API key via --dart-define for builds/dev runs
  // e.g., --dart-define=GOOGLE_PLACES_API_KEY=your_api_key_here
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: '',
  );

  static bool get isValid => apiKey.isNotEmpty;
  
  /// Get API key with fallback to direct value (for development)
  /// In production, always use environment variable
  static String getApiKey() {
    if (apiKey.isNotEmpty) {
      return apiKey;
    }
    
    // Fallback: You can set your API key here directly for development
    // WARNING: Never commit this file with a real API key!
    // TODO: Replace with your actual API key or use environment variable
    return 'AIzaSyDKz1R_H9deprlLXL3Q8xvf0A1lDVJljaA'; // Set your API key here for local development
  }
}


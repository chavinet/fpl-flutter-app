import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/league.dart';
import '../models/player.dart';

class ApiService {
  // Replace with your Railway URL
  static const String baseUrl = 'https://fpl-backend-production.up.railway.app/';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  // HTTP client with timeout
  final http.Client _client = http.Client();
  
  // Common headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
  
  // Get current gameweek
  Future<int> getCurrentGameweek() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/gameweek/current'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['current_gameweek'] ?? 1;
      }
      throw Exception('Failed to get current gameweek');
    } catch (e) {
      print('Error getting current gameweek: $e');
      return 1;
    }
  }
  
  // Collect fresh data from FPL API
  Future<Map<String, dynamic>> collectLeagueData(int leagueId) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/collect-data/$leagueId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 120)); // 2 minutes timeout
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to collect data: ${response.statusCode}');
    } catch (e) {
      print('Error collecting league data: $e');
      rethrow;
    }
  }
  
  // Get league standings
  Future<LeagueStandings> getLeagueStandings(int leagueId, {int? gameweek}) async {
    try {
      String url = '$baseUrl/league/$leagueId/standings';
      if (gameweek != null) {
        url += '?gameweek=$gameweek';
      }
      
      final response = await _client
          .get(Uri.parse(url), headers: _headers)
          .timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LeagueStandings.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('League not found. Try collecting data first.');
      }
      throw Exception('Failed to get standings: ${response.statusCode}');
    } catch (e) {
      print('Error getting league standings: $e');
      rethrow;
    }
  }
  
  // Get comprehensive league summary
  Future<LeagueSummary> getLeagueSummary(int leagueId) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/league/$leagueId/summary'), headers: _headers)
          .timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LeagueSummary.fromJson(data);
      }
      throw Exception('Failed to get league summary: ${response.statusCode}');
    } catch (e) {
      print('Error getting league summary: $e');
      rethrow;
    }
  }
  
  // Get captain analysis
  Future<CaptainAnalysis> getCaptainAnalysis(int leagueId) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/league/$leagueId/captain-analysis'), headers: _headers)
          .timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CaptainAnalysis.fromJson(data);
      }
      throw Exception('Failed to get captain analysis: ${response.statusCode}');
    } catch (e) {
      print('Error getting captain analysis: $e');
      rethrow;
    }
  }
  
  // Get player trends
  Future<PlayerTrends> getPlayerTrends(int entryId) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/player/$entryId/trends'), headers: _headers)
          .timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PlayerTrends.fromJson(data);
      }
      throw Exception('Failed to get player trends: ${response.statusCode}');
    } catch (e) {
      print('Error getting player trends: $e');
      rethrow;
    }
  }
  
  // Dispose resources
  void dispose() {
    _client.close();
  }
}

// API Response Models
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;
  
  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });
  
  factory ApiResponse.success(T data) {
    return ApiResponse(success: true, data: data);
  }
  
  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse(success: false, error: error, statusCode: statusCode);
  }
}
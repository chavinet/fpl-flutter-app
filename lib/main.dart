import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/api_config.dart';

void main() {
  runApp(const FPLApp());
}

class FPLApp extends StatelessWidget {
  const FPLApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FPL League Analytics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: const Color(0xFF37003C),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF37003C),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static String get apiBaseUrl => ApiConfig.baseUrl;
  
  bool isLoading = false;
  String? error;
  Map<String, dynamic>? leagueData;
  int? currentLeagueId;
  bool showLeagueInput = true;
  
  final TextEditingController _leagueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedLeague();
  }

  Color _getChipColor(String? chipName) {
  if (chipName == null || chipName.isEmpty || chipName == 'None') {
    return Colors.grey;
  }
  
  switch (chipName.toLowerCase()) {
    case 'wildcard':
    case 'wc':
      return Colors.purple;
    case 'freehit':
    case 'free hit':
    case 'fh':
      return Colors.blue;
    case 'triplecaptain':
    case 'triple captain':
    case '3xc':
      return Colors.orange;
    case 'benchboost':
    case 'bench boost':
    case 'bb':
      return Colors.green;
    default:
      return Colors.indigo;
  }
}

String _getChipDisplayName(String? chipName) {
  if (chipName == null || chipName.isEmpty || chipName == 'None') {
    return 'None';
  }
  
  switch (chipName.toLowerCase()) {
    case 'wildcard':
      return 'Wildcard';
    case 'freehit':
    case 'free hit':
      return 'Free Hit';
    case 'triplecaptain':
    case '3xc':
    case 'triple captain':
      return 'Triple Captain';
    case 'benchboost':
    case 'bench boost':
      return 'Bench Boost';
    default:
      return chipName.substring(0, 2).toUpperCase();
  }
}

  // Load previously used league ID
  Future<void> _loadSavedLeague() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLeagueId = prefs.getInt('league_id');
      
      if (savedLeagueId != null) {
        setState(() {
          currentLeagueId = savedLeagueId;
          _leagueController.text = savedLeagueId.toString();
          showLeagueInput = false;
        });
        
        // Try to load existing data
        await _loadStandings();
      }
    } catch (e) {
      print('Error loading saved league: $e');
    }
  }

  // Save league ID for next time
  Future<void> _saveLeagueId(int leagueId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('league_id', leagueId);
    } catch (e) {
      print('Error saving league ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentLeagueId != null 
              ? 'FPL League $currentLeagueId'
              : 'FPL League Analytics'
        ),
        actions: [
          if (currentLeagueId != null) ...[
            IconButton(
              onPressed: isLoading ? null : _refreshData,
              icon: isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: _changeLeague,
              icon: const Icon(Icons.edit),
              tooltip: 'Change League',
            ),
          ],
        ],
      ),
      body: showLeagueInput ? _buildLeagueInput() : _buildBody(),
    );
  }

  Widget _buildLeagueInput() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          
          Text(
            'Enter Your FPL League',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Enter your Fantasy Premier League mini-league ID to get started',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _leagueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'League ID',
                      hintText: 'e.g., 559261',
                      prefixIcon: const Icon(Icons.numbers),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      helperText: 'Find this in your FPL league URL',
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'How to find your League ID:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. Go to your FPL league page',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                        Text(
                          '2. Look at the URL:',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                        Text(
                          'fantasy.premierleague.com/leagues/559261/standings',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontFamily: 'monospace'),
                        ),
                        Text(
                          '3. Your League ID is: 559261',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _submitLeagueId,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.sports),
                      label: Text(isLoading ? 'Loading League...' : 'Load League'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading FPL data...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Error Loading Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadStandings,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _collectData,
              child: const Text('Collect Fresh Data'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _changeLeague,
              child: const Text('Change League'),
            ),
          ],
        ),
      );
    }

    if (leagueData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No Data Available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Click the button below to collect data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _collectData,
              icon: const Icon(Icons.download),
              label: const Text('Collect League Data'),
            ),
          ],
        ),
      );
    }

    return _buildLeagueStandings();
  }

  Widget _buildLeagueStandings() {
    final standings = leagueData!['standings'] as List<dynamic>? ?? [];
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // League header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'League $currentLeagueId',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Gameweek ${leagueData!['gameweek']} • ${leagueData!['total_players']} players',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Change league button
                  IconButton(
                    onPressed: _changeLeague,
                    icon: const Icon(Icons.edit),
                    tooltip: 'Change League',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Standings table
          Card(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 30, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 3, child: Text('Manager', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Points', style: TextStyle(fontWeight: FontWeight.bold))),
                      //Expanded(flex: 2, child: Text('Captain', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 3, child: Text('Captain/Vice captain', style: TextStyle(fontWeight: FontWeight.bold))), // Updated
                      Expanded(flex: 2, child: Text('Transfers/Cost', style: TextStyle(fontWeight: FontWeight.bold))), // NEW
                      Expanded(flex: 2, child: Text('Chip', style: TextStyle(fontWeight: FontWeight.bold))), // NEW
                    ],
                  ),
                ),
                
                // Player rows
                ...standings.asMap().entries.map((entry) {
                  final index = entry.key;
                  final player = entry.value as Map<String, dynamic>;
                  
                  return InkWell(
                    onTap: () => _showPlayerDetails(player),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Position with trophy for top 3
                          SizedBox(
                            width: 30,
                            child: Row(
                              children: [
                                if (index < 3) ...[
                                  Icon(
                                    Icons.emoji_events,
                                    size: 16,
                                    color: index == 0 ? Colors.amber : 
                                           index == 1 ? Colors.grey[400] : 
                                           Colors.brown[300],
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  '${player['position'] ?? index + 1}',
                                  style: TextStyle(
                                    fontWeight: index < 3 ? FontWeight.bold : FontWeight.normal,
                                    color: index < 3 ? Theme.of(context).primaryColor : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Manager info
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  player['player_name'] ?? 'Unknown Player',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  player['team_name'] ?? 'Unknown Team',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          
                          // Points
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${player['total_points'] ?? 0}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getPointsColor(player['gameweek_points'] ?? 0).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'GW: ${player['gameweek_points'] ?? 0}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _getPointsColor(player['gameweek_points'] ?? 0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Captain
                          Expanded(
                            flex: 3, // Increased from 2 to 3 to fit both
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '(C) ${player['captain'] ?? 'No Captain'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '(VC) ${player['vice_captain'] ?? 'No Vice Captain'}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                        // NEW: Transfers
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${player['transfers'] ?? 0}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                (player['transfers_cost'] ?? 0) > 0 
                                    ? '-${player['transfers_cost']}' 
                                    : '${player['transfers_cost'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: (player['transfers_cost'] ?? 0) > 0 ? Colors.red[600] : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // NEW: Chip
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getChipColor(player['active_chip']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getChipColor(player['active_chip']).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getChipDisplayName(player['active_chip']),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getChipColor(player['active_chip']),
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Color _getPointsColor(int points) {
    if (points >= 80) return Colors.green;
    if (points >= 60) return Colors.blue;
    if (points >= 40) return Colors.orange;
    return Colors.red;
  }

  void _showPlayerDetails(Map<String, dynamic> player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Player details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            '${player['position'] ?? '?'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player['player_name'] ?? 'Unknown Player',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                player['team_name'] ?? 'Unknown Team',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Stats cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Points',
                            '${player['total_points'] ?? 0}',
                            Colors.purple,
                            Icons.emoji_events,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Gameweek',
                            '${player['gameweek_points'] ?? 0}',
                            Colors.blue,
                            Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Captain info
                    _buildInfoCard(
                      'Team Selection',
                      [
                        _buildInfoRow('Captain', player['captain'] ?? 'No Captain', Icons.star),
                        _buildInfoRow('Vice Captain', player['vice_captain'] ?? 'No Vice Captain', Icons.star_border),
                        _buildInfoRow('Active Chip', player['active_chip'] ?? 'None', Icons.casino),
                        _buildInfoRow('Transfer Cost', '-${player['transfers_cost'] ?? 0}', Icons.swap_horiz),
                        _buildInfoRow('Bench Points', '${player['points_on_bench'] ?? 0}', Icons.chair),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitLeagueId() async {
    final leagueIdText = _leagueController.text.trim();
    
    if (leagueIdText.isEmpty) {
      setState(() {
        error = 'Please enter a league ID';
      });
      return;
    }
    
    final leagueId = int.tryParse(leagueIdText);
    if (leagueId == null) {
      setState(() {
        error = 'Please enter a valid league ID (numbers only)';
      });
      return;
    }
    
    setState(() {
      currentLeagueId = leagueId;
      showLeagueInput = false;
      error = null;
    });
    
    // Save for next time
    await _saveLeagueId(leagueId);
    
    // Collect data for this league
    await _collectData();
  }

  void _changeLeague() {
    setState(() {
      showLeagueInput = true;
      leagueData = null;
      error = null;
      currentLeagueId = null;
    });
  }

  Future<void> _collectData() async {
    if (currentLeagueId == null) return;
    
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      print('Making POST request to: $apiBaseUrl/collect-data/$currentLeagueId');
      
      final collectResponse = await http.post(
        Uri.parse('$apiBaseUrl/collect-data/$currentLeagueId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 120));

      print('Collect response status: ${collectResponse.statusCode}');

      if (collectResponse.statusCode != 200) {
        throw Exception('Failed to collect data: ${collectResponse.statusCode}');
      }

      // Wait for processing
      await Future.delayed(const Duration(seconds: 5));

      // Load standings
      await _loadStandings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Collection error: $e');
      setState(() {
        error = 'Failed to collect data: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadStandings() async {
    if (currentLeagueId == null) return;
    
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      print('Making GET request to: $apiBaseUrl/league/$currentLeagueId/standings');
      
      final response = await http.get(
        Uri.parse('$apiBaseUrl/league/$currentLeagueId/standings'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          leagueData = data;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          error = 'No data found. Try collecting fresh data first.';
        });
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Loading error: $e');
      setState(() {
        error = 'Failed to load standings: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadStandings();
  }

  @override
  void dispose() {
    _leagueController.dispose();
    super.dispose();
  }
}
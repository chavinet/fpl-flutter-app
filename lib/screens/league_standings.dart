import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/league.dart';

class LeagueStandingsScreen extends StatefulWidget {
  const LeagueStandingsScreen({Key? key}) : super(key: key);

  @override
  State<LeagueStandingsScreen> createState() => _LeagueStandingsScreenState();
}

class _LeagueStandingsScreenState extends State<LeagueStandingsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch standings when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FPLDataProvider>().fetchLeagueStandings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FPLDataProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Loading league standings...'),
              ],
            ),
          );
        }

        if (provider.error != null) {
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
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchLeagueStandings(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => provider.collectLeagueData(),
                  child: const Text('Collect Fresh Data'),
                ),
              ],
            ),
          );
        }

        if (provider.currentStandings == null || provider.currentStandings!.standings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_soccer,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 20),
                Text(
                  'No League Data',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the button below to load your league data',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => provider.collectLeagueData(),
                  icon: const Icon(Icons.download),
                  label: const Text('Load League Data'),
                ),
              ],
            ),
          );
        }

        final standings = provider.currentStandings!;
        
        return RefreshIndicator(
          onRefresh: () => provider.fetchLeagueStandings(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // League header card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                  'League ${standings.leagueId}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Gameweek ${standings.gameweek} • ${standings.totalPlayers} players',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                    // Table header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 40, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                          const Expanded(flex: 3, child: Text('Manager', style: TextStyle(fontWeight: FontWeight.bold))),
                          const Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                          const Expanded(flex: 2, child: Text('GW', style: TextStyle(fontWeight: FontWeight.bold))),
                          const Expanded(flex: 2, child: Text('Captain', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    
                    // Player rows
                    ...standings.standings.asMap().entries.map((entry) {
                      final index = entry.key;
                      final player = entry.value;
                      final isTopThree = index < 3;
                      
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _showPlayerDetails(context, player),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                // Position with medal for top 3
                                SizedBox(
                                  width: 40,
                                  child: Row(
                                    children: [
                                      if (isTopThree) ...[
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
                                        '${player.position}',
                                        style: TextStyle(
                                          fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
                                          color: isTopThree ? Theme.of(context).primaryColor : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Manager name and team
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        player.playerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        player.teamName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Total points
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${player.totalPoints}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                
                                // Gameweek points
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getGameweekPointsColor(player.gameweekPoints).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${player.gameweekPoints}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: _getGameweekPointsColor(player.gameweekPoints),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Captain
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    player.captainDisplay,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Quick stats card
              if (standings.standings.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Stats',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                'Highest GW Score',
                                '${standings.standings.map((p) => p.gameweekPoints).reduce((a, b) => a > b ? a : b)}',
                                Icons.trending_up,
                                Colors.green,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                'Average Points',
                                '${(standings.standings.map((p) => p.totalPoints).reduce((a, b) => a + b) / standings.standings.length).round()}',
                                Icons.analytics,
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getGameweekPointsColor(int points) {
    if (points >= 80) return Colors.green;
    if (points >= 60) return Colors.blue;
    if (points >= 40) return Colors.orange;
    return Colors.red;
  }

  void _showPlayerDetails(BuildContext context, PlayerStanding player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          '${player.position}',
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
                              player.playerName,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              player.teamName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Player details
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildDetailCard(
                        'Points',
                        [
                          _buildDetailRow('Total Points', '${player.totalPoints}', Colors.purple),
                          _buildDetailRow('Gameweek Points', '${player.gameweekPoints}', Colors.blue),
                          _buildDetailRow('Transfer Cost', '-${player.transfersCost}', Colors.red),
                          _buildDetailRow('Net Points', '${player.netPoints}', Colors.green),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildDetailCard(
                        'Team Selection',
                        [
                          _buildDetailRow('Captain', player.captainDisplay, Colors.orange),
                          _buildDetailRow('Vice Captain', player.viceCaptainDisplay, Colors.orange[300]!),
                          _buildDetailRow('Active Chip', player.chipDisplay, Colors.purple),
                          _buildDetailRow('Points on Bench', '${player.pointsOnBench}', Colors.grey),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
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

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
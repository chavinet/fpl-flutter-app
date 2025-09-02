import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'league_standings.dart';
import 'captain_analysis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Check API health on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FPLDataProvider>().checkApiHealth();
      context.read<FPLDataProvider>().fetchCurrentGameweek();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FPL League Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<FPLDataProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  // Current gameweek indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'GW ${provider.currentGameweek}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Refresh button
                  IconButton(
                    onPressed: provider.isLoading ? null : () {
                      provider.refreshAllData();
                    },
                    icon: provider.isLoading 
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
                ],
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          LeagueStandingsScreen(),
          CaptainAnalysisScreen(),
          ComingSoonScreen(feature: 'Player Trends'),
          ComingSoonScreen(feature: 'Historical Analysis'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Standings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports),
            label: 'Captains',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Trends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
      // Floating action button for data collection
      floatingActionButton: Consumer<FPLDataProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton.extended(
            onPressed: provider.isLoading ? null : () => _showDataCollectionDialog(context),
            backgroundColor: Theme.of(context).primaryColor,
            icon: provider.isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.download),
            label: Text(provider.isLoading ? 'Updating...' : 'Update Data'),
          );
        },
      ),
    );
  }

  void _showDataCollectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update League Data'),
          content: const Text(
            'This will fetch the latest data from the Fantasy Premier League API. '
            'It may take 30-60 seconds to complete.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final success = await context.read<FPLDataProvider>().collectLeagueData();
                
                if (!mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                          ? '✅ Data updated successfully!' 
                          : '❌ Failed to update data'
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

// Coming Soon placeholder screen
class ComingSoonScreen extends StatelessWidget {
  final String feature;
  
  const ComingSoonScreen({Key? key, required this.feature}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            '$feature',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
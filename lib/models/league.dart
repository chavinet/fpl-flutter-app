// League Standings Model
class LeagueStandings {
  final int leagueId;
  final String gameweek;
  final int totalPlayers;
  final List<PlayerStanding> standings;
  final String lastUpdated;
  
  LeagueStandings({
    required this.leagueId,
    required this.gameweek,
    required this.totalPlayers,
    required this.standings,
    required this.lastUpdated,
  });
  
  factory LeagueStandings.fromJson(Map<String, dynamic> json) {
    return LeagueStandings(
      leagueId: json['league_id'] ?? 0,
      gameweek: json['gameweek']?.toString() ?? 'latest',
      totalPlayers: json['total_players'] ?? 0,
      standings: (json['standings'] as List<dynamic>?)
          ?.map((e) => PlayerStanding.fromJson(e))
          .toList() ?? [],
      lastUpdated: json['last_updated'] ?? '',
    );
  }
}

// Individual Player Standing
class PlayerStanding {
  final int position;
  final int entryId;
  final String playerName;
  final String teamName;
  final int totalPoints;
  final int gameweekPoints;
  final String? captain;
  final String? viceCaptain;
  final String? activeChip;
  final int gameweek;
  final int transfersCost;
  final int pointsOnBench;
  
  PlayerStanding({
    required this.position,
    required this.entryId,
    required this.playerName,
    required this.teamName,
    required this.totalPoints,
    required this.gameweekPoints,
    this.captain,
    this.viceCaptain,
    this.activeChip,
    required this.gameweek,
    required this.transfersCost,
    required this.pointsOnBench,
  });
  
  factory PlayerStanding.fromJson(Map<String, dynamic> json) {
    return PlayerStanding(
      position: json['position'] ?? 0,
      entryId: json['entry_id'] ?? 0,
      playerName: json['player_name'] ?? 'Unknown Player',
      teamName: json['team_name'] ?? 'Unknown Team',
      totalPoints: json['total_points'] ?? 0,
      gameweekPoints: json['gameweek_points'] ?? 0,
      captain: json['captain'],
      viceCaptain: json['vice_captain'],
      activeChip: json['active_chip'],
      gameweek: json['gameweek'] ?? 0,
      transfersCost: json['transfers_cost'] ?? 0,
      pointsOnBench: json['points_on_bench'] ?? 0,
    );
  }
  
  // Helper getters
  String get captainDisplay => captain ?? 'No Captain';
  String get viceCaptainDisplay => viceCaptain ?? 'No Vice-Captain';
  String get chipDisplay => activeChip ?? 'No Chip';
  
  // Points without transfer costs
  int get netPoints => gameweekPoints - transfersCost;
}

// League Summary Model
class LeagueSummary {
  final Map<String, dynamic> leagueInfo;
  final List<PlayerStanding> currentStandings;
  final int latestGameweek;
  final int totalPlayers;
  final List<CaptainPerformance> captainAnalysis;
  final Map<String, dynamic> chipUsage;
  
  LeagueSummary({
    required this.leagueInfo,
    required this.currentStandings,
    required this.latestGameweek,
    required this.totalPlayers,
    required this.captainAnalysis,
    required this.chipUsage,
  });
  
  factory LeagueSummary.fromJson(Map<String, dynamic> json) {
    return LeagueSummary(
      leagueInfo: json['league_info'] ?? {},
      currentStandings: (json['current_standings'] as List<dynamic>?)
          ?.map((e) => PlayerStanding.fromJson(e))
          .toList() ?? [],
      latestGameweek: json['latest_gameweek'] ?? 0,
      totalPlayers: json['total_players'] ?? 0,
      captainAnalysis: (json['captain_analysis'] as List<dynamic>?)
          ?.map((e) => CaptainPerformance.fromJson(e))
          .toList() ?? [],
      chipUsage: json['chip_usage'] ?? {},
    );
  }
  
  // Helper getters
  String get leagueName => leagueInfo['name'] ?? 'Unknown League';
  DateTime? get createdAt {
    final dateStr = leagueInfo['created_at'];
    return dateStr != null ? DateTime.tryParse(dateStr) : null;
  }
}

// Captain Performance Model
class CaptainPerformance {
  final String playerName;
  final int timesCaptained;
  final int totalPoints;
  final double averagePoints;
  final int? bestPerformance;
  final int? worstPerformance;
  final double? successRate;
  
  CaptainPerformance({
    required this.playerName,
    required this.timesCaptained,
    required this.totalPoints,
    required this.averagePoints,
    this.bestPerformance,
    this.worstPerformance,
    this.successRate,
  });
  
  factory CaptainPerformance.fromJson(Map<String, dynamic> json) {
    return CaptainPerformance(
      playerName: json['player_name'] ?? 'Unknown Player',
      timesCaptained: json['times_captained'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      averagePoints: (json['average_points'] ?? 0.0).toDouble(),
      bestPerformance: json['best_performance'],
      worstPerformance: json['worst_performance'],
      successRate: json['success_rate']?.toDouble(),
    );
  }
}

// Captain Analysis Full Response
class CaptainAnalysis {
  final int leagueId;
  final int latestGameweek;
  final int totalRecords;
  final int totalUniqueCaptains;
  final List<FPLManagerData> fplManagersData;
  final List<CaptainPerformance> captainPerformance;
  final List<FPLManagerData> latestGameweekCaptains;
  final Map<String, dynamic> summary;
  
  CaptainAnalysis({
    required this.leagueId,
    required this.latestGameweek,
    required this.totalRecords,
    required this.totalUniqueCaptains,
    required this.fplManagersData,
    required this.captainPerformance,
    required this.latestGameweekCaptains,
    required this.summary,
  });
  
  factory CaptainAnalysis.fromJson(Map<String, dynamic> json) {
    return CaptainAnalysis(
      leagueId: json['league_id'] ?? 0,
      latestGameweek: json['latest_gameweek'] ?? 0,
      totalRecords: json['total_records'] ?? 0,
      totalUniqueCaptains: json['total_unique_captains'] ?? 0,
      fplManagersData: (json['fpl_managers_data'] as List<dynamic>?)
          ?.map((e) => FPLManagerData.fromJson(e))
          .toList() ?? [],
      captainPerformance: (json['captain_performance'] as List<dynamic>?)
          ?.map((e) => CaptainPerformance.fromJson(e))
          .toList() ?? [],
      latestGameweekCaptains: (json['latest_gameweek_captains'] as List<dynamic>?)
          ?.map((e) => FPLManagerData.fromJson(e))
          .toList() ?? [],
      summary: json['summary'] ?? {},
    );
  }
}

// FPL Manager Data Model (your requested data!)
class FPLManagerData {
  final String fplManager;
  final String teamName;
  final int entryId;
  final int gameweek;
  final int totalPoints;
  final int gameweekPoints;
  final String captain;
  final String viceCaptain;
  final int transfersCost;
  final double teamValue;
  final String? activeChip;
  final int pointsOnBench;
  
  FPLManagerData({
    required this.fplManager,
    required this.teamName,
    required this.entryId,
    required this.gameweek,
    required this.totalPoints,
    required this.gameweekPoints,
    required this.captain,
    required this.viceCaptain,
    required this.transfersCost,
    required this.teamValue,
    this.activeChip,
    required this.pointsOnBench,
  });
  
  factory FPLManagerData.fromJson(Map<String, dynamic> json) {
    return FPLManagerData(
      fplManager: json['fpl_manager'] ?? 'Unknown Player',
      teamName: json['team_name'] ?? 'Unknown Team',
      entryId: json['entry_id'] ?? 0,
      gameweek: json['gameweek'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      gameweekPoints: json['gameweek_points'] ?? 0,
      captain: json['captain'] ?? 'No Captain',
      viceCaptain: json['vice_captain'] ?? 'No Vice-Captain',
      transfersCost: json['transfers_cost'] ?? 0,
      teamValue: (json['team_value'] ?? 0.0).toDouble(),
      activeChip: json['active_chip'],
      pointsOnBench: json['points_on_bench'] ?? 0,
    );
  }
  
  // Helper getters
  int get netPoints => gameweekPoints - transfersCost;
  String get chipDisplay => activeChip ?? 'No Chip Used';
  String get teamValueDisplay => '£${teamValue.toStringAsFixed(1)}m';
}

// Player Trends Model
class PlayerTrends {
  final int entryId;
  final String playerName;
  final int totalGameweeks;
  final List<GameweekTrend> trends;
  
  PlayerTrends({
    required this.entryId,
    required this.playerName,
    required this.totalGameweeks,
    required this.trends,
  });
  
  factory PlayerTrends.fromJson(Map<String, dynamic> json) {
    return PlayerTrends(
      entryId: json['entry_id'] ?? 0,
      playerName: json['player_name'] ?? 'Unknown Player',
      totalGameweeks: json['total_gameweeks'] ?? 0,
      trends: (json['trends'] as List<dynamic>?)
          ?.map((e) => GameweekTrend.fromJson(e))
          .toList() ?? [],
    );
  }
}

// Individual Gameweek Trend
class GameweekTrend {
  final int gameweek;
  final int points;
  final int totalPoints;
  final int? overallRank;
  final int? previousRank;
  final int rankChange;
  final String? captain;
  final int transfersCost;
  final double teamValue;
  final String? activeChip;
  
  GameweekTrend({
    required this.gameweek,
    required this.points,
    required this.totalPoints,
    this.overallRank,
    this.previousRank,
    required this.rankChange,
    this.captain,
    required this.transfersCost,
    required this.teamValue,
    this.activeChip,
  });
  
  factory GameweekTrend.fromJson(Map<String, dynamic> json) {
    return GameweekTrend(
      gameweek: json['gameweek'] ?? 0,
      points: json['points'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      overallRank: json['overall_rank'],
      previousRank: json['previous_rank'],
      rankChange: json['rank_change'] ?? 0,
      captain: json['captain'],
      transfersCost: json['transfers_cost'] ?? 0,
      teamValue: (json['team_value'] ?? 0.0).toDouble(),
      activeChip: json['active_chip'],
    );
  }
  
  // Helper getters
  int get netPoints => points - transfersCost;
  bool get rankImproved => rankChange > 0;
  String get rankChangeDisplay {
    if (rankChange > 0) return '+$rankChange';
    if (rankChange < 0) return '$rankChange';
    return 'No change';
  }
}
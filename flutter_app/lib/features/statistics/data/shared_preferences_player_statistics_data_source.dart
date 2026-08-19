import 'dart:convert';

import 'package:pixel_harmony/features/statistics/data/player_statistics_local_data_source.dart';
import 'package:pixel_harmony/features/statistics/data/player_statistics_snapshot.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesPlayerStatisticsDataSource
    implements PlayerStatisticsLocalDataSource {
  SharedPreferencesPlayerStatisticsDataSource({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _storageKey = 'pixel_harmony.player_statistics.v1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<PlayerStatisticsSnapshot?> read() async {
    final encoded = await _preferences.getString(_storageKey);
    if (encoded == null) return null;
    final json = jsonDecode(encoded) as Map<String, dynamic>;
    return PlayerStatisticsSnapshot(
      statistics: PlayerStatistics(
        totalPuzzlesCompleted: json['totalPuzzlesCompleted'] as int,
        journeyPuzzlesCompleted: json['journeyPuzzlesCompleted'] as int,
        endlessPuzzlesCompleted: json['endlessPuzzlesCompleted'] as int,
        dailyPuzzlesCompleted: json['dailyPuzzlesCompleted'] as int,
        totalMoves: json['totalMoves'] as int,
        bestDailyStreak: json['bestDailyStreak'] as int,
        currentDailyStreak: json['currentDailyStreak'] as int,
      ),
      processedCompletionIds: Set<String>.from(
        json['processedCompletionIds'] as List,
      ),
    );
  }

  @override
  Future<void> write(PlayerStatisticsSnapshot snapshot) {
    final statistics = snapshot.statistics;
    return _preferences.setString(
      _storageKey,
      jsonEncode({
        'totalPuzzlesCompleted': statistics.totalPuzzlesCompleted,
        'journeyPuzzlesCompleted': statistics.journeyPuzzlesCompleted,
        'endlessPuzzlesCompleted': statistics.endlessPuzzlesCompleted,
        'dailyPuzzlesCompleted': statistics.dailyPuzzlesCompleted,
        'totalMoves': statistics.totalMoves,
        'bestDailyStreak': statistics.bestDailyStreak,
        'currentDailyStreak': statistics.currentDailyStreak,
        'processedCompletionIds':
            snapshot.processedCompletionIds.toList()..sort(),
      }),
    );
  }

  @override
  Future<void> clear() => _preferences.remove(_storageKey);
}

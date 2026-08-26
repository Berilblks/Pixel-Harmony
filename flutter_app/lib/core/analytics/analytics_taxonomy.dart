abstract final class AnalyticsEvents {
  static const appOpen = 'app_open';
  static const journeyLevelStart = 'journey_level_start';
  static const journeyLevelComplete = 'journey_level_complete';
  static const endlessPuzzleStart = 'endless_puzzle_start';
  static const endlessPuzzleComplete = 'endless_puzzle_complete';
  static const dailyPuzzleStart = 'daily_puzzle_start';
  static const dailyPuzzleComplete = 'daily_puzzle_complete';
  static const hintUsed = 'hint_used';
  static const levelRestart = 'level_restart';
  static const achievementUnlocked = 'achievement_unlocked';
  static const settingsChanged = 'settings_changed';
}

abstract final class AnalyticsParameters {
  static const levelNumber = 'level_number';
  static const chapterId = 'chapter_id';
  static const boardSize = 'board_size';
  static const moves = 'moves';
  static const difficulty = 'difficulty';
  static const puzzleNumber = 'puzzle_number';
  static const generationVersion = 'generation_version';
  static const currentStreak = 'current_streak';
  static const mode = 'mode';
  static const achievementId = 'achievement_id';
  static const setting = 'setting';
  static const enabled = 'enabled';
}

abstract final class AnalyticsValues {
  static const journey = 'journey';
  static const endless = 'endless';
  static const daily = 'daily';
  static const soundEffects = 'sound_effects';
  static const haptics = 'haptics';
}

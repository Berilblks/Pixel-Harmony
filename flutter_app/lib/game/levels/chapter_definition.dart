class ChapterDefinition {
  ChapterDefinition({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.order,
    required List<String> levelIds,
    this.visualTag,
  }) : levelIds = List.unmodifiable(levelIds) {
    if (id.isEmpty || nameKey.isEmpty || descriptionKey.isEmpty) {
      throw ArgumentError(
        'Chapter identifiers and localization keys are required.',
      );
    }
    if (order < 0) {
      throw ArgumentError.value(order, 'order', 'Must not be negative.');
    }
    if (levelIds.isEmpty || levelIds.toSet().length != levelIds.length) {
      throw ArgumentError.value(
        levelIds,
        'levelIds',
        'Must contain unique level IDs.',
      );
    }
  }

  final String id;
  final String nameKey;
  final String descriptionKey;
  final int order;
  final List<String> levelIds;
  final String? visualTag;
}

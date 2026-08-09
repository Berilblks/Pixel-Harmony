class BoardDropRequest {
  const BoardDropRequest({
    required this.sourceIndex,
    required this.targetIndex,
  });

  final int sourceIndex;
  final int targetIndex;
}

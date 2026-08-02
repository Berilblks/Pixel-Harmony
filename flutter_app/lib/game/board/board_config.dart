class BoardConfig {
  const BoardConfig({this.spacing = 12, this.screenPadding = 24})
    : assert(spacing >= 0),
      assert(screenPadding >= 0);

  final double spacing;
  final double screenPadding;
}

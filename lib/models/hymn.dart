class Hymn {
  final int id;
  final String title;
  final String lyrics;
  final String tune;
  final String audioUrl;
  final String sheetUrl;

  const Hymn({
    required this.id,
    required this.title,
    required this.lyrics,
    required this.tune,
    required this.audioUrl,
    required this.sheetUrl,
  });
}
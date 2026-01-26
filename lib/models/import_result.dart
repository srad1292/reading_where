class ImportResult {
  final bool success;
  final int inserted;
  final int skipped;

  ImportResult({required this.success, required this.inserted, required this.skipped});
}
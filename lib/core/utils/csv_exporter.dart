class CSVExporter {
  static String exportToCSV(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '';

    final headers = data.first.keys.join(',');
    final rows = data
        .map((item) {
          return item.values.map((val) => '"$val"').join(',');
        })
        .join('\n');

    return '$headers\n$rows';
  }
}

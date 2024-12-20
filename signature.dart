import 'dart:io';

void main() {
  final directory = Directory('lib');

  if (!directory.existsSync()) {
    print('Directory not found: lib');
    return;
  }

  final dartFiles = directory
      .listSync(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>();

  for (var file in dartFiles) {
    sortImportsInFile(file);
  }
}

void sortImportsInFile(File file) {
  final lines = file.readAsLinesSync();
  final importLines = <String>[];
  final otherLines = <String>[];

  for (var line in lines) {
    if (line.startsWith('import ')) {
      importLines.add(line.trim());
    } else {
      otherLines.add(line);
    }
  }

  importLines.sort((a, b) => b.length.compareTo(a.length));

  final sortedImports = importLines.join('\n');
  final newContent = sortedImports + '\n' + otherLines.join('\n');

  file.writeAsStringSync(newContent);
  print('Sorted imports in file: ${file.path}');
}
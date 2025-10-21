// Tool to generate a multi-size .ico from assets/images/logo.png
// Usage: dart run tool/generate_windows_icon.dart

import 'dart:io';
import 'package:image/image.dart';

void main(List<String> args) {
  final srcPath = 'assets/images/Canemap.png';
  final outPath = 'windows/runner/resources/app_icon.ico';

  final srcFile = File(srcPath);
  if (!srcFile.existsSync()) {
    stderr.writeln('Source image not found: $srcPath');
    exit(2);
  }

  final bytes = srcFile.readAsBytesSync();
  final src = decodeImage(bytes);
  if (src == null) {
    stderr.writeln('Failed to decode source image.');
    exit(3);
  }

  // Sizes commonly used in Windows icons
  final sizes = [16, 24, 32, 48, 64, 128, 256];
  final images = <Image>[];
  for (final s in sizes) {
    final resized = copyResize(
      src,
      width: s,
      height: s,
      interpolation: Interpolation.cubic,
    );
    images.add(resized);
  }

  // Encode each resized image to PNG bytes and pack into ICO container.
  final pngBytesList = <List<int>>[];
  for (final img in images) {
    pngBytesList.add(encodePng(img));
  }

  final outFile = File(outPath);
  outFile.createSync(recursive: true);
  final sink = outFile.openSync(mode: FileMode.write);

  // ICONDIR header: reserved(2), type(2=1 for icon), count(2)
  final count = pngBytesList.length;
  final header = <int>[];
  header.addAll(_u16(0)); // reserved
  header.addAll(_u16(1)); // type = 1 (icon)
  header.addAll(_u16(count));
  sink.writeFromSync(header);

  // Directory entries: 16 bytes each
  var offset = 6 + (16 * count); // initial offset after headers
  for (var i = 0; i < count; i++) {
    final size = images[i].width;
    final pngBytes = pngBytesList[i];
    final entry = <int>[];
    entry.add(size >= 256 ? 0 : size); // width (0 means 256)
    entry.add(size >= 256 ? 0 : size); // height
    entry.add(0); // color count
    entry.add(0); // reserved
    entry.addAll(_u16(0)); // planes (0 for PNG)
    entry.addAll(_u16(32)); // bit count
    entry.addAll(_u32(pngBytes.length)); // bytes in resource
    entry.addAll(_u32(offset)); // image offset
    sink.writeFromSync(entry);
    offset += pngBytes.length;
  }

  // Write PNG image data sequentially
  for (final bytesPng in pngBytesList) {
    sink.writeFromSync(bytesPng);
  }

  sink.closeSync();
  stdout.writeln('Wrote: $outPath (${outFile.lengthSync()} bytes)');
}

List<int> _u16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
List<int> _u32(int v) => [
  v & 0xFF,
  (v >> 8) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 24) & 0xFF,
];

import 'dart:typed_data';

/// Global, process-wide icon bytes cache by URL + size.
/// Key format: "$url@$sizePx".
class IconGlobalCache {
  static final Map<String, Uint8List> _mem = <String, Uint8List>{};

  static String _k(String url, int sizePx) => '$url@$sizePx';

  static Uint8List? get(String url, int sizePx) => _mem[_k(url, sizePx)];

  static void put(String url, int sizePx, Uint8List bytes) {
    _mem[_k(url, sizePx)] = Uint8List.fromList(bytes);
    if (_mem.length > 96) {
      _mem.remove(_mem.keys.first);
    }
  }

  static bool contains(String url, int sizePx) => _mem.containsKey(_k(url, sizePx));
}

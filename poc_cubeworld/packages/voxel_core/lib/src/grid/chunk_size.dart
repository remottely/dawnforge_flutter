/// The one chunk geometry: 16 × 16 columns, 128 cells tall. A chunk volume is
/// a byte per cell, indexed x-first within z within y.
abstract final class ChunkSize {
  static const int sizeX = 16;
  static const int sizeZ = 16;
  static const int sizeY = 128;
  static const int volume = sizeX * sizeZ * sizeY;

  /// The byte of chunk-local cell ([x], [y], [z]) in a chunk volume.
  static int index(int x, int y, int z) => x + sizeX * (z + sizeZ * y);
}

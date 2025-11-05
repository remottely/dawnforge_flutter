enum CropType { parsnip }

class CropData {
  final String name;
  final int daysToGrow;
  final int sellPrice;
  final String spriteAsset;

  const CropData({
    required this.name,
    required this.daysToGrow,
    required this.sellPrice,
    required this.spriteAsset,
  });
}

const Map<CropType, CropData> cropDatabase = {
  CropType.parsnip: CropData(
    name: 'Parsnip',
    daysToGrow: 4,
    sellPrice: 35,
    spriteAsset: 'crops/parsnip.png',
  ),
};

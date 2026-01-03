/// Weather types mirrored from Stardew Valley style.
enum WeatherType { sunny, rain, storm, snow, festival; }

extension WeatherTypeJson on WeatherType {
  String toJson() => name;

  static WeatherType fromJson(String value) => WeatherType.values.byName(value);
}

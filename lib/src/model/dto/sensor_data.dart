class SensorData {
  final int id;
  final String timestamp;
  final double current;
  final double volt;
  final double temp;
  final double hum;
  final String mode;
  final int speed;
  final double pm1;
  final double pm25;
  final double pm10;
  final String power;

  SensorData({
    required this.id,
    required this.timestamp,
    required this.current,
    required this.volt,
    required this.temp,
    required this.hum,
    required this.mode,
    required this.speed,
    required this.pm1,
    required this.pm25,
    required this.pm10,
    required this.power,
  });

  factory SensorData.fromJson(Map<String, dynamic> j) {
    // 백엔드 JSON 키가 React 코드와 같다고 가정
    double _d(v) => (v == null) ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
    int _i(v) => (v == null) ? 0 : int.tryParse(v.toString()) ?? 0;

    return SensorData(
      id: _i(j['id']),
      timestamp: j['timestamp']?.toString() ?? '-',
      current: _d(j['CURRENT']),
      volt: _d(j['VOLT']),
      temp: _d(j['TEMP']),
      hum: _d(j['HUM']),
      mode: j['MODE']?.toString() ?? '-',
      speed: _i(j['SPEED']),
      pm1: _d(j['PM1']),
      pm25: _d(j['PM2.5']),
      pm10: _d(j['PM10']),
      power: j['POWER']?.toString() ?? '-',
    );
  }
}
import 'package:flutter/material.dart';
import 'location.dart';
import 'networking.dart';
import 'weather_model.dart';

void main() {
  runApp(const ClimaApp());
}

class ClimaApp extends StatelessWidget {
  const ClimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _service = WeatherService();
  final _controller = TextEditingController();
  WeatherModel? _weather;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadByLocation();
  }

  Future<void> _loadByLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pos = await getCurrentLocation();
      _weather = await _service.byLocation(pos.latitude, pos.longitude);
    } catch (e) {
      // Không lấy được GPS thì dùng Hà Nội làm mặc định
      try {
        _weather = await _service.byCity('Hanoi');
      } catch (e2) {
        _error = e2.toString();
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _search() async {
    final city = _controller.text.trim();
    if (city.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _weather = await _service.byCity(city);
    } catch (e) {
      _error = 'Không tìm thấy "$city" ($e)';
    }
    if (mounted) setState(() => _loading = false);
  }

  Widget _detail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.lightBlueAccent),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = _weather;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _loadByLocation,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _search(),
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên thành phố',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _search, child: const Text('Tìm')),
                ],
              ),
              const SizedBox(height: 32),
              if (_loading)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              else if (w != null)
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, size: 18),
                            Text(w.city, style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Icon(w.icon, size: 100, color: Colors.amber),
                        Text(
                          '${w.temp.round()}°C',
                          style: const TextStyle(
                              fontSize: 64, fontWeight: FontWeight.bold),
                        ),
                        Text(w.description,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _detail(Icons.thermostat, 'Cảm giác',
                                '${w.feelsLike.round()}°C'),
                            _detail(Icons.water_drop, 'Độ ẩm', '${w.humidity}%'),
                            _detail(Icons.air, 'Gió', '${w.wind} m/s'),
                          ],
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
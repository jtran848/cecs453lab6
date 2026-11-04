import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'weather_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Weather App',
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController cityController = TextEditingController();
  final WeatherService weatherService = WeatherService();

  Map<String, dynamic>? weather;
  String error = '';
  bool loading = false;

  // Get Weather button: call the service and show the result
  void getWeather() async {
    String city = cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      loading = true;
      error = '';
    });

    try {
      final data = await weatherService.fetchWeather(city);
      setState(() => weather = data);
    } catch (e) {
      setState(() {
        weather = null;
        error = e.toString();
      });
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // City input
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'Enter city name'),
                onSubmitted: (_) => getWeather(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: getWeather,
                child: const Text('Get Weather'),
              ),
              const SizedBox(height: 32),

              if (loading) const CircularProgressIndicator(),
              if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.red)),

              // Weather result: image, temperature, conditions
              if (weather != null && !loading) ...[
                Text(weather!['name'], style: const TextStyle(fontSize: 24)),
                Image.network(
                  'https://openweathermap.org/img/wn/${weather!['weather'][0]['icon']}@4x.png',
                ),
                Text(
                  '${(weather!['main']['temp'] as num).round()}°C',
                  style: const TextStyle(fontSize: 40),
                ),
                Text(
                  weather!['weather'][0]['description'],
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
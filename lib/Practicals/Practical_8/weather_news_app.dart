import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const WeatherNewsApp());

class WeatherNewsApp extends StatelessWidget {
  const WeatherNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather & News App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double humidity;
  final double windSpeed;
  final String country;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.country,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] - 273.15), 
      description: json['weather'][0]['description'] ?? 'No description',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity']?.toDouble() ?? 0.0,
      windSpeed: json['wind']['speed']?.toDouble() ?? 0.0,
      country: json['sys']['country'] ?? 'Unknown',
    );
  }
}

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String source;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? 'No description available',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      source: json['source']['name'] ?? 'Unknown source',
    );
  }
}

class ApiService {
  static const String weatherApiKey = 'demo_key';
  static const String newsApiKey = 'demo_key'; 
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String newsBaseUrl = 'https://newsapi.org/v2';

  static Future<WeatherData> fetchWeather(String cityName) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      if (DateTime.now().millisecond % 10 == 0) {
        throw Exception('Network error: Unable to connect to weather service');
      }
      
      final mockJsonResponse = {
        "name": cityName,
        "main": {
          "temp": 298.15 + (DateTime.now().millisecond % 15), 
          "humidity": 60 + (DateTime.now().millisecond % 30),
        },
        "weather": [
          {
            "description": _getRandomWeatherDescription(),
            "icon": _getRandomWeatherIcon(),
          }
        ],
        "wind": {
          "speed": 3.5 + (DateTime.now().millisecond % 10) / 10,
        },
        "sys": {
          "country": _getCityCountry(cityName),
        }
      };
      
      return WeatherData.fromJson(mockJsonResponse);
    } catch (e) {
      throw Exception('Failed to load weather data: ${e.toString()}');
    }
  }

  static Future<List<NewsArticle>> fetchNews({String category = 'general'}) async {
    try {
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      
      if (DateTime.now().millisecond % 20 == 0) {
        throw Exception('Failed to load news: Server temporarily unavailable');
      }
      
      return _getMockNews(category);
    } catch (e) {
      throw Exception('News service error: ${e.toString()}');
    }
  }

  static String _getRandomWeatherDescription() {
    final descriptions = [
      'Clear sky', 'Few clouds', 'Scattered clouds', 'Broken clouds',
      'Shower rain', 'Rain', 'Thunderstorm', 'Snow', 'Mist'
    ];
    return descriptions[DateTime.now().millisecond % descriptions.length];
  }

  static String _getRandomWeatherIcon() {
    final icons = ['01d', '02d', '03d', '04d', '09d', '10d', '11d', '13d', '50d'];
    return icons[DateTime.now().millisecond % icons.length];
  }

  static String _getCityCountry(String cityName) {
    final cityCountryMap = {
      // Indian cities
      'mumbai': 'IN', 'delhi': 'IN', 'bangalore': 'IN', 'hyderabad': 'IN', 
      'chennai': 'IN', 'kolkata': 'IN', 'pune': 'IN', 'ahmedabad': 'IN',
      'jaipur': 'IN', 'surat': 'IN', 'lucknow': 'IN', 'kanpur': 'IN',
      'nagpur': 'IN', 'indore': 'IN', 'thane': 'IN', 'bhopal': 'IN',
      'visakhapatnam': 'IN', 'pimpri': 'IN', 'patna': 'IN', 'vadodara': 'IN',
      
      // UK cities
      'london': 'GB', 'manchester': 'GB', 'birmingham': 'GB', 'liverpool': 'GB',
      'leeds': 'GB', 'sheffield': 'GB', 'bristol': 'GB', 'glasgow': 'GB',
      'edinburgh': 'GB', 'leicester': 'GB', 'coventry': 'GB', 'bradford': 'GB',
      
      // US cities
      'new york': 'US', 'los angeles': 'US', 'chicago': 'US', 'houston': 'US',
      'phoenix': 'US', 'philadelphia': 'US', 'san antonio': 'US', 'san diego': 'US',
      'dallas': 'US', 'san jose': 'US', 'austin': 'US', 'jacksonville': 'US',
      'seattle': 'US', 'denver': 'US', 'washington': 'US', 'boston': 'US',
      'nashville': 'US', 'baltimore': 'US', 'portland': 'US', 'las vegas': 'US',
      
      // Other major cities
      'tokyo': 'JP', 'osaka': 'JP', 'kyoto': 'JP', 'yokohama': 'JP',
      'paris': 'FR', 'marseille': 'FR', 'lyon': 'FR', 'toulouse': 'FR',
      'berlin': 'DE', 'hamburg': 'DE', 'munich': 'DE', 'cologne': 'DE',
      'sydney': 'AU', 'melbourne': 'AU', 'brisbane': 'AU', 'perth': 'AU',
      'toronto': 'CA', 'vancouver': 'CA', 'montreal': 'CA', 'calgary': 'CA',
      'beijing': 'CN', 'shanghai': 'CN', 'guangzhou': 'CN', 'shenzhen': 'CN',
      'moscow': 'RU', 'saint petersburg': 'RU', 'novosibirsk': 'RU',
      'rome': 'IT', 'milan': 'IT', 'naples': 'IT', 'turin': 'IT',
      'madrid': 'ES', 'barcelona': 'ES', 'valencia': 'ES', 'seville': 'ES',
      'amsterdam': 'NL', 'rotterdam': 'NL', 'the hague': 'NL',
      'brussels': 'BE', 'antwerp': 'BE', 'ghent': 'BE',
      'stockholm': 'SE', 'gothenburg': 'SE', 'malmÃ¶': 'SE',
      'oslo': 'NO', 'bergen': 'NO', 'trondheim': 'NO',
      'helsinki': 'FI', 'espoo': 'FI', 'tampere': 'FI',
      'copenhagen': 'DK', 'aarhus': 'DK', 'odense': 'DK',
      'zurich': 'CH', 'geneva': 'CH', 'basel': 'CH',
      'vienna': 'AT', 'graz': 'AT', 'linz': 'AT',
      'dublin': 'IE', 'cork': 'IE', 'limerick': 'IE',
      'lisbon': 'PT', 'porto': 'PT', 'braga': 'PT',
      'athens': 'GR', 'thessaloniki': 'GR', 'patras': 'GR',
      'bucharest': 'RO', 'cluj-napoca': 'RO', 'timiÈ™oara': 'RO',
      'budapest': 'HU', 'debrecen': 'HU', 'szeged': 'HU',
      'prague': 'CZ', 'brno': 'CZ', 'ostrava': 'CZ',
      'warsaw': 'PL', 'krakÃ³w': 'PL', 'wrocÅ‚aw': 'PL',
      'cairo': 'EG', 'alexandria': 'EG', 'giza': 'EG',
      'lagos': 'NG', 'kano': 'NG', 'ibadan': 'NG',
      'johannesburg': 'ZA', 'cape town': 'ZA', 'durban': 'ZA',
      'nairobi': 'KE', 'mombasa': 'KE', 'kisumu': 'KE',
      'karachi': 'PK', 'lahore': 'PK', 'faisalabad': 'PK',
      'dhaka': 'BD', 'chittagong': 'BD', 'sylhet': 'BD',
      'jakarta': 'ID', 'surabaya': 'ID', 'medan': 'ID',
      'manila': 'PH', 'quezon city': 'PH', 'davao': 'PH',
      'bangkok': 'TH', 'nonthaburi': 'TH', 'pak kret': 'TH',
      'ho chi minh city': 'VN', 'hanoi': 'VN', 'da nang': 'VN',
      'kuala lumpur': 'MY', 'george town': 'MY', 'ipoh': 'MY',
      'singapore': 'SG',
      'istanbul': 'TR', 'ankara': 'TR', 'izmir': 'TR',
      'tehran': 'IR', 'mashhad': 'IR', 'isfahan': 'IR',
      'riyadh': 'SA', 'jeddah': 'SA', 'mecca': 'SA',
      'dubai': 'AE', 'abu dhabi': 'AE', 'sharjah': 'AE',
      'tel aviv': 'IL', 'jerusalem': 'IL', 'haifa': 'IL',
      'mexico city': 'MX', 'guadalajara': 'MX', 'monterrey': 'MX',
      'sÃ£o paulo': 'BR', 'rio de janeiro': 'BR', 'brasÃ­lia': 'BR',
      'buenos aires': 'AR', 'cÃ³rdoba': 'AR', 'rosario': 'AR',
      'lima': 'PE', 'arequipa': 'PE', 'trujillo': 'PE',
      'bogotÃ¡': 'CO', 'medellÃ­n': 'CO', 'cali': 'CO',
      'santiago': 'CL', 'valparaÃ­so': 'CL', 'concepciÃ³n': 'CL',
      'caracas': 'VE', 'maracaibo': 'VE', 'valencia ve': 'VE',
    };
    
    return cityCountryMap[cityName.toLowerCase()] ?? 'Unknown';
  }

  static List<NewsArticle> _getMockNews(String category) {
    final baseNews = {
      'general': [
        {
          'title': 'Breaking: Global Climate Summit Reaches Historic Agreement',
          'description': 'World leaders unite on ambitious climate goals for the next decade, marking a turning point in environmental policy.',
          'image': 'https://images.unsplash.com/photo-1611273426858-450d8e3c9fce?w=400&h=200&fit=crop',
          'source': 'Global News Network'
        },
        {
          'title': 'Technology Giants Announce Major AI Collaboration',
          'description': 'Leading tech companies join forces to develop responsible AI systems with enhanced safety measures.',
          'image': 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=400&h=200&fit=crop',
          'source': 'Tech Daily'
        },
      ],
      'technology': [
        {
          'title': 'Flutter 3.16 Released with Revolutionary Features',
          'description': 'Google unveils Flutter 3.16 with enhanced performance, new widgets, and improved developer experience.',
          'image': 'https://images.unsplash.com/photo-1611224923853-80b023f02d71?w=400&h=200&fit=crop',
          'source': 'Flutter Weekly'
        },
        {
          'title': 'Quantum Computing Breakthrough Achieved',
          'description': 'Scientists demonstrate practical quantum advantage in real-world applications, opening new possibilities.',
          'image': 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400&h=200&fit=crop',
          'source': 'Science & Tech'
        },
      ],
      'business': [
        {
          'title': 'Mobile App Market Reaches \$100 Billion Milestone',
          'description': 'App store revenues hit record highs as mobile-first economy continues unprecedented growth.',
          'image': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=200&fit=crop',
          'source': 'Business Insider'
        },
        {
          'title': 'Startup Revolutionizes API Development',
          'description': 'New platform simplifies REST API creation, reducing development time by 70% for mobile apps.',
          'image': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=200&fit=crop',
          'source': 'Startup Weekly'
        },
      ],
      'sports': [
        {
          'title': 'Mobile Gaming Tournament Sets New Records',
          'description': 'International mobile gaming championship attracts millions of viewers and breaks prize pool records.',
          'image': 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=400&h=200&fit=crop',
          'source': 'Sports Gaming Today'
        },
        {
          'title': 'Athletes Embrace Fitness Tracking Apps',
          'description': 'Professional athletes increasingly rely on mobile apps for performance monitoring and training optimization.',
          'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=200&fit=crop',
          'source': 'Athletic Performance'
        },
      ],
      'health': [
        {
          'title': 'Revolutionary Health Monitoring App Launched',
          'description': 'New mobile app uses AI to predict health issues before symptoms appear, revolutionizing preventive care.',
          'image': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=200&fit=crop',
          'source': 'Health Tech News'
        },
        {
          'title': 'Mental Health Apps Show Promising Results',
          'description': 'Clinical studies confirm significant benefits of mobile mental health applications for anxiety and depression.',
          'image': 'https://images.unsplash.com/photo-1559757175-0eb30cd8c063?w=400&h=200&fit=crop',
          'source': 'Medical Journal'
        },
      ],
      'science': [
        {
          'title': 'Weather Prediction Accuracy Reaches 95%',
          'description': 'Advanced machine learning algorithms and mobile sensors dramatically improve weather forecasting precision.',
          'image': 'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?w=400&h=200&fit=crop',
          'source': 'Weather Science Today'
        },
        {
          'title': 'NASA Launches Mobile App for Space Exploration',
          'description': 'Interactive app allows users to track missions, view real-time data, and explore the universe from their phones.',
          'image': 'https://images.unsplash.com/photo-1446776877081-d282a0f896e2?w=400&h=200&fit=crop',
          'source': 'Space News'
        },
      ],
      'entertainment': [
        {
          'title': 'Mobile Gaming Industry Surpasses Hollywood',
          'description': 'Mobile games generate more revenue than movies and music combined, reshaping entertainment landscape.',
          'image': 'https://images.unsplash.com/photo-1493711662062-fa541adb3fc8?w=400&h=200&fit=crop',
          'source': 'Entertainment Weekly'
        },
        {
          'title': 'Streaming Apps Dominate Mobile Usage',
          'description': 'Video streaming applications account for 60% of mobile data usage as users consume more content on-the-go.',
          'image': 'https://images.unsplash.com/photo-1522869635100-9f4c5e86aa37?w=400&h=200&fit=crop',
          'source': 'Media Analytics'
        },
      ],
    };

    final categoryNews = baseNews[category] ?? baseNews['general']!;
    return categoryNews.map((news) => NewsArticle(
      title: news['title']!,
      description: news['description']!,
      url: 'https://example.com/article/${DateTime.now().millisecondsSinceEpoch}',
      urlToImage: news['image']!,
      publishedAt: DateTime.now().subtract(
        Duration(hours: DateTime.now().millisecond % 12)
      ).toIso8601String(),
      source: news['source']!,
    )).toList();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const WeatherScreen(),
    const NewsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Weather',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'News',
          ),
        ],
      ),
    );
  }
}

// Weather Screen
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  Future<WeatherData>? _weatherFuture;

  @override
  void initState() {
    super.initState();
    _fetchWeather('Mumbai'); // Default city
  }

  void _fetchWeather(String cityName) {
    setState(() {
      _weatherFuture = ApiService.fetchWeather(cityName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: 'Enter city name...',
                      prefixIcon: const Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _fetchWeather(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    if (_cityController.text.isNotEmpty) {
                      _fetchWeather(_cityController.text);
                    }
                  },
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<WeatherData>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(strokeWidth: 3),
                        SizedBox(height: 16),
                        Text(
                          'Fetching weather data...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _fetchWeather('Mumbai'),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.hasData) {
                  final weather = snapshot.data!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${weather.cityName}, ${weather.country}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                weather.description.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getWeatherIcon(weather.icon),
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    '${weather.temperature.round()}Â°C',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            _buildWeatherDetailCard(
                              'Humidity',
                              '${weather.humidity.round()}%',
                              Icons.water_drop,
                              Colors.blue,
                            ),
                            _buildWeatherDetailCard(
                              'Wind Speed',
                              '${weather.windSpeed.toStringAsFixed(1)} m/s',
                              Icons.air,
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return Icons.wb_sunny;
      case '02d':
      case '02n':
        return Icons.wb_cloudy;
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return Icons.cloud;
      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return Icons.grain;
      case '11d':
      case '11n':
        return Icons.flash_on;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.blur_on;
      default:
        return Icons.wb_sunny;
    }
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedCategory = 'general';
  Future<List<NewsArticle>>? _newsFuture;

  final List<String> _categories = [
    'general',
    'business',
    'technology',
    'sports',
    'health',
    'science',
    'entertainment',
  ];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  void _fetchNews() {
    setState(() {
      _newsFuture = ApiService.fetchNews(category: _selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest News'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                        _fetchNews();
                      }
                    },
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.grey[200],
                    elevation: isSelected ? 4 : 0,
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: FutureBuilder<List<NewsArticle>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(strokeWidth: 3),
                        SizedBox(height: 16),
                        Text(
                          'Loading latest news...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.newspaper_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load news\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchNews,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.hasData) {
                  final articles = snapshot.data!;
                  if (articles.isEmpty) {
                    return const Center(
                      child: Text(
                        'No news articles found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _fetchNews(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return NewsCard(article: article);
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  const NewsCard({super.key, required this.article});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(article: article),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  article.urlToImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          article.source,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(article.publishedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inMinutes}m ago';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}

class NewsDetailScreen extends StatelessWidget {
  final NewsArticle article;
  const NewsDetailScreen({super.key, required this.article});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage.isNotEmpty)
              Image.network(
                article.urlToImage,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          article.source,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatFullDate(article.publishedAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Would open: ${article.url}'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Read Full Article',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown date';
    }
  }
}

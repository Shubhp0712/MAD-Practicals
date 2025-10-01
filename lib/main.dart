// import 'package:flutter/material.dart';
//
// import 'practicals/practical_1/splashscreen.dart';
// import 'practicals/practical_2/temp_converterapp.dart';
// import 'practicals/practical_3/to_do.dart';
// import 'Practicals/CIE_1/practical_1.dart';
// import 'Practicals/CIE_1/practical_2.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   MyApp({super.key});
//
//   final List<Map<String, dynamic>> practicals = [
//     {
//       'title': 'Splash Screen',
//       'subtitle': 'App Launch & Branding',
//       'widget': SplashScreen(),
//       'icon': Icons.launch_rounded,
//     },
//     {
//       'title': 'Temperature Converter',
//       'subtitle': 'Unit Conversion System',
//       'widget': TempConverterapp(),
//       'icon': Icons.device_thermostat_rounded,
//     },
//     {
//       'title': 'TODO Application',
//       'subtitle': 'Task Management System',
//       'widget': TodoList(),
//       'icon': Icons.task_alt_rounded,
//     },
//     {
//       'title': 'Waste Management System',
//       'subtitle': 'Waste Management',
//       'widget': SmartWasteApp(),
//       'icon': Icons.delete_outline,
//     },
//     {
//       'title': 'Online Course Platform Management',
//       'subtitle': 'Online Course Management',
//       'widget': const OnlineCourseApp(),
//       'icon': Icons.school,
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Technical Practicals',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: SimpleLauncherScreen(practicals: practicals),
//     );
//   }
// }
//
// class SimpleLauncherScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> practicals;
//
//   const SimpleLauncherScreen({super.key, required this.practicals});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Technical Practicals'),
//         centerTitle: true,
//       ),
//       body: ListView.builder(
//         itemCount: practicals.length,
//         itemBuilder: (context, index) {
//           final practical = practicals[index];
//           return ListTile(
//             leading: Icon(practical['icon']),
//             title: Text(practical['title']),
//             subtitle: Text(practical['subtitle']),
//             trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => practical['widget']),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'dart:async';
import 'practicals/practical_1/splashscreen.dart' as splash1;
import 'practicals/practical_2/temp_converterapp.dart';
import 'practicals/practical_3/to_do.dart';
import 'Practicals/CIE_1/practical_1.dart';
import 'Practicals/CIE_1/practical_2.dart';
import 'Practicals/Practical_4/Registration_form.dart';
import 'Practicals/Practical_5/screens/student_list_screen.dart';
import 'Practicals/Practical_6/notes_app.dart';
import 'Practicals/Practical_7/Product_catalog_app.dart';
import 'Practicals/Practical_8/weather_news_app.dart';
import 'Practicals/Practical_9/screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

final List<Map<String, dynamic>> practicals = [
  {
    'title': 'Splash Screen',
    'subtitle': 'App Launch & Branding',
    'widget': splash1.SplashScreen(),
    'icon': Icons.launch_rounded,
  },
  {
    'title': 'Temperature Converter',
    'subtitle': 'Unit Conversion System',
    'widget': TempConverterapp(),
    'icon': Icons.device_thermostat_rounded,
  },
  {
    'title': 'TODO Application',
    'subtitle': 'Task Management System',
    'widget': TodoList(),
    'icon': Icons.task_alt_rounded,
  },
  {
    'title': 'Waste Management System',
    'subtitle': 'Waste Management',
    'widget': SmartWasteApp(),
    'icon': Icons.delete_outline,
  },
  {
    'title': 'Online Course Platform',
    'subtitle': 'Course Management',
    'widget': const OnlineCourseApp(),
    'icon': Icons.school,
  },
  {
    'title': 'Registration Form',
    'subtitle': 'Registration Form with validation',
    'widget': RegistrationForm(),
    'icon': Icons.app_registration_outlined,
  },
  {
    'title': 'Student Management System',
    'subtitle': 'Manage Student Records',
    'widget': StudentListScreen(),
    'icon': Icons.school_rounded,
  },
  {
    'title': 'Notes App',
    'subtitle': 'Note Taking & Management',
    'widget': NotesApp(),
    'icon': Icons.note,
  },
  {
    'title': 'Product Catalog',
    'subtitle': 'Product Listing & Management',
    'widget': ProductCatalogApp(),
    'icon': Icons.shopping_cart,
  },
  {
    'title': 'Weather & News App',
    'subtitle': 'Weather Forecast & News Updates',
    'widget': WeatherNewsApp(),
    'icon': Icons.cloud,
  },
  {
    'title': 'Login & Auth System',
    'subtitle': 'Comprehensive Auth System',
    'widget': SplashScreen(),
    'icon': Icons.login_rounded,
  }
];

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Technical Practicals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 4,
          shadowColor: Colors.black12,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        cardTheme: const CardThemeData(
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: LauncherScreen(practicals: practicals),
    );
  }
}

class LauncherScreen extends StatelessWidget {
  final List<Map<String, dynamic>> practicals;

  const LauncherScreen({super.key, required this.practicals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Practicals 🚀')),
      body: ListView(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF3E5F5),
                  Color(0xFFE1BEE7),
                  Color(0xFFCE93D8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: practicals.length,
              itemBuilder: (context, index) {
                final practical = practicals[index];
                return PracticalCard(
                  title: practical['title'],
                  subtitle: practical['subtitle'],
                  icon: practical['icon'],
                  targetWidget: practical['widget'],
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PracticalCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget targetWidget;
  final int index;

  const PracticalCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.targetWidget,
    required this.index,
  });

  @override
  State<PracticalCard> createState() => _PracticalCardState();
}

class _PracticalCardState extends State<PracticalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Timer(Duration(milliseconds: widget.index * 120), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          color: colorScheme.primaryContainer.withOpacity(0.95),
          elevation: 5,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => widget.targetWidget),
              );
            },
            splashColor: colorScheme.secondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Icon(
                      widget.icon,
                      size: 30,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

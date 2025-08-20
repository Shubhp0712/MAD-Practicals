import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String username;

  const ProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        actions: [
          IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {},
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
        colors: [Colors.deepPurple, Colors.purpleAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            size: 80,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          username,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Flutter Enthusiast',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 32),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.email, color: Colors.deepPurple),
              title: const Text('Email'),
              subtitle: Text('$username@email.com'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.deepPurple),
              title: const Text('Phone'),
              subtitle: const Text('+91 12345 67890'),
            ),
          ],
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }
}
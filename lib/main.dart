import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // auto-generated after flutterfire configure
import 'package:cloud_firestore/cloud_firestore.dart'; // for database example
import 'splash/splash_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the options from firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaneMap System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashFlow(),
    );
  }
}

class FirebaseHomePage extends StatefulWidget {
  const FirebaseHomePage({super.key});

  @override
  State<FirebaseHomePage> createState() => _FirebaseHomePageState();
}

class _FirebaseHomePageState extends State<FirebaseHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  Future<void> _addFarmer() async {
    if (_nameController.text.isEmpty || _locationController.text.isEmpty) {
      return;
    }

    await _firestore.collection('farmers').add({
      'name': _nameController.text,
      'location': _locationController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _nameController.clear();
    _locationController.clear();
  }

  Stream<QuerySnapshot> _getFarmers() {
    return _firestore
        .collection('farmers')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CaneMap Firebase Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Farmer Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addFarmer,
              child: const Text('Add Farmer'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Farmers List',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getFarmers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No farmers yet.'));
                  }

                  final farmers = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: farmers.length,
                    itemBuilder: (context, index) {
                      final data =
                          farmers[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name'] ?? 'Unknown'),
                        subtitle: Text(data['location'] ?? 'No location'),
                        leading: const Icon(
                          Icons.agriculture,
                          color: Colors.green,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

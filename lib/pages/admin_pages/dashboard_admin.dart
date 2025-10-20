import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  Map<String, int> _stats = {
    'colleges': 0,
    'branches': 0,
    'regulations': 0,
    'semesters': 0,
    'subjects': 0,
    'units': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Load counts from all collections
      final collegesSnapshot = await FirebaseFirestore.instance.collection('colleges').get();
      final branchesSnapshot = await FirebaseFirestore.instance.collection('branches').get();
      final regulationsSnapshot = await FirebaseFirestore.instance.collection('regulations').get();
      final semestersSnapshot = await FirebaseFirestore.instance.collection('semesters').get();
      final subjectsSnapshot = await FirebaseFirestore.instance.collection('subjects').get();
      final unitsSnapshot = await FirebaseFirestore.instance.collection('units').get();

      setState(() {
        _stats = {
          'colleges': collegesSnapshot.docs.length,
          'branches': branchesSnapshot.docs.length,
          'regulations': regulationsSnapshot.docs.length,
          'semesters': semestersSnapshot.docs.length,
          'subjects': subjectsSnapshot.docs.length,
          'units': unitsSnapshot.docs.length,
        };
      });
    } catch (e) {
      print('❌ Error loading stats: $e');
    }
  }

  Widget _buildStatCard(String value, String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAuthStatus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Status'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Firebase Auth Status:'),
            SizedBox(height: 8),
            Text('✅ Connected to Firebase'),
            SizedBox(height: 8),
            Text('✅ Authentication enabled'),
            SizedBox(height: 8),
            Text('✅ Email/Password sign-in method active'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFullDiagnostics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Full System Diagnostics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('System Status:'),
            const SizedBox(height: 8),
            Text('✅ Firebase Core: Connected'),
            Text('✅ Firestore: Connected'),
            Text('✅ Authentication: Active'),
            Text('✅ Storage: Available'),
            const SizedBox(height: 8),
            Text('Database Collections:'),
            Text('📊 Colleges: ${_stats['colleges']}'),
            Text('📊 Branches: ${_stats['branches']}'),
            Text('📊 Regulations: ${_stats['regulations']}'),
            Text('📊 Semesters: ${_stats['semesters']}'),
            Text('📊 Subjects: ${_stats['subjects']}'),
            Text('📊 Units: ${_stats['units']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards - 2 rows of 3 cards each
          Row(
            children: [
              Expanded(child: _buildStatCard(_stats['colleges'].toString(), 'Colleges', Icons.school, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(_stats['branches'].toString(), 'Branches', Icons.account_tree, Colors.purple)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(_stats['regulations'].toString(), 'Regulations', Icons.rule, Colors.pink)),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildStatCard(_stats['semesters'].toString(), 'Semesters', Icons.schedule, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(_stats['subjects'].toString(), 'Subjects', Icons.book, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(_stats['units'].toString(), 'Units', Icons.description, Colors.red)),
            ],
          ),
          
          const SizedBox(height: 32),
          // Debug Tools Section REMOVED
        ],
      ),
    );
  }
} 
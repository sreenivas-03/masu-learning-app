import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BranchesUserPage extends StatefulWidget {
  final String? selectedCollegeId;
  final String? selectedCollegeName;
  
  const BranchesUserPage({
    super.key,
    this.selectedCollegeId,
    this.selectedCollegeName,
  });

  @override
  State<BranchesUserPage> createState() => _BranchesUserPageState();
}

class _BranchesUserPageState extends State<BranchesUserPage> {
  List<Map<String, dynamic>> _branches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      Query query = FirebaseFirestore.instance.collection('branches');
      
      // If a college is selected, filter by college
      if (widget.selectedCollegeId != null) {
        query = query.where('collegeId', isEqualTo: widget.selectedCollegeId);
      }
      
      final querySnapshot = await query.get();
      setState(() {
        _branches = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'description': data['description'] ?? '',
            'collegeId': data['collegeId'] ?? '',
            'collegeName': data['collegeName'] ?? '',
            'logoUrl': data['logoUrl'] ?? '',
            'createdAt': data['createdAt'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading branches: $e');
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Branches',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (widget.selectedCollegeName != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(
                    'College: ${widget.selectedCollegeName}',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Statistics Cards
          Row(
            children: [
              Expanded(child: _buildStatCard(_branches.length.toString(), 'Total Branches', Icons.account_tree, Colors.purple)),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Branches List
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedCollegeName != null 
                      ? 'Branches for ${widget.selectedCollegeName}'
                      : 'All Branches',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_branches.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.account_tree, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            widget.selectedCollegeName != null 
                              ? 'No branches found for this college'
                              : 'No branches available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.selectedCollegeName != null 
                              ? 'Please contact your administrator'
                              : 'Please select a college first',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _branches.length,
                      itemBuilder: (context, index) {
                        final branch = _branches[index];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: branch['logoUrl'].isNotEmpty ? null : Colors.purple,
                                image: branch['logoUrl'].isNotEmpty 
                                  ? DecorationImage(
                                      image: NetworkImage(branch['logoUrl']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              ),
                              child: branch['logoUrl'].isNotEmpty 
                                ? null 
                                : const Icon(Icons.account_tree, color: Colors.white),
                            ),
                            title: Text(branch['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(branch['description'] ?? 'No description available'),
                                if (widget.selectedCollegeName == null)
                                  Text(
                                    'College: ${branch['collegeName']}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () {
                              // Show branch details
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(branch['name']),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Description: ${branch['description'] ?? 'No description available'}'),
                                      const SizedBox(height: 8),
                                      if (widget.selectedCollegeName == null)
                                        Text('College: ${branch['collegeName']}'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
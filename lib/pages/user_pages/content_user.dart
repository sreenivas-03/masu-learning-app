import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContentUserPage extends StatefulWidget {
  final String? selectedCollegeId;
  final String? selectedCollegeName;
  
  const ContentUserPage({
    super.key,
    this.selectedCollegeId,
    this.selectedCollegeName,
  });

  @override
  State<ContentUserPage> createState() => _ContentUserPageState();
}

class _ContentUserPageState extends State<ContentUserPage> {
  List<Map<String, dynamic>> _content = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      Query query = FirebaseFirestore.instance.collection('content');
      
      // If a college is selected, filter by college
      if (widget.selectedCollegeId != null) {
        query = query.where('collegeId', isEqualTo: widget.selectedCollegeId);
      }
      
      final querySnapshot = await query.get();
      setState(() {
        _content = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'title': data['title'] ?? '',
            'description': data['description'] ?? '',
            'content': data['content'] ?? '',
            'collegeId': data['collegeId'] ?? '',
            'collegeName': data['collegeName'] ?? '',
            'regulationId': data['regulationId'] ?? '',
            'regulationName': data['regulationName'] ?? '',
            'semesterId': data['semesterId'] ?? '',
            'semesterName': data['semesterName'] ?? '',
            'branchId': data['branchId'] ?? '',
            'branchName': data['branchName'] ?? '',
            'subjectId': data['subjectId'] ?? '',
            'subjectName': data['subjectName'] ?? '',
            'unitId': data['unitId'] ?? '',
            'unitName': data['unitName'] ?? '',
            'logoUrl': data['logoUrl'] ?? '',
            'createdAt': data['createdAt'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading content: $e');
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
                'Learning Content',
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
              Expanded(child: _buildStatCard(_content.length.toString(), 'Total Content', Icons.article, Colors.teal)),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Content List
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedCollegeName != null 
                      ? 'Content for ${widget.selectedCollegeName}'
                      : 'All Content',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_content.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.article, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            widget.selectedCollegeName != null 
                              ? 'No content found for this college'
                              : 'No content available',
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
                      itemCount: _content.length,
                      itemBuilder: (context, index) {
                        final content = _content[index];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: content['logoUrl'].isNotEmpty ? null : Colors.teal,
                                image: content['logoUrl'].isNotEmpty 
                                  ? DecorationImage(
                                      image: NetworkImage(content['logoUrl']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              ),
                              child: content['logoUrl'].isNotEmpty 
                                ? null 
                                : const Icon(Icons.article, color: Colors.white),
                            ),
                            title: Text(content['title']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content['description'] ?? 'No description available',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text('Unit: ${content['unitName']}'),
                                Text('Subject: ${content['subjectName']}'),
                                Text('Branch: ${content['branchName']}'),
                                Text('Semester: ${content['semesterName']}'),
                                Text('Regulation: ${content['regulationName']}'),
                                if (widget.selectedCollegeName == null)
                                  Text(
                                    'College: ${content['collegeName']}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () {
                              // Show content details
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(content['title']),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Description: ${content['description'] ?? 'No description available'}'),
                                        const SizedBox(height: 8),
                                        Text('Content: ${content['content'] ?? 'No content available'}'),
                                        const SizedBox(height: 8),
                                        Text('Unit: ${content['unitName']}'),
                                        const SizedBox(height: 8),
                                        Text('Subject: ${content['subjectName']}'),
                                        const SizedBox(height: 8),
                                        Text('Branch: ${content['branchName']}'),
                                        const SizedBox(height: 8),
                                        Text('Semester: ${content['semesterName']}'),
                                        const SizedBox(height: 8),
                                        Text('Regulation: ${content['regulationName']}'),
                                        if (widget.selectedCollegeName == null) ...[
                                          const SizedBox(height: 8),
                                          Text('College: ${content['collegeName']}'),
                                        ],
                                      ],
                                    ),
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
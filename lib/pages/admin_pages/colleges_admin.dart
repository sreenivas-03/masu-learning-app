import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:html' as html;

class CollegesAdminPage extends StatefulWidget {
  const CollegesAdminPage({super.key});

  @override
  State<CollegesAdminPage> createState() => _CollegesAdminPageState();
}

class _CollegesAdminPageState extends State<CollegesAdminPage> {
  List<Map<String, dynamic>> _colleges = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  File? _selectedLogo;
  String? _selectedLogoUrl;

  // Controllers for edit dialog
  final _editFormKey = GlobalKey<FormState>();
  final _editNameController = TextEditingController();
  final _editLocationController = TextEditingController();
  final _editDescriptionController = TextEditingController();
  File? _editSelectedLogo;
  String? _editSelectedLogoUrl;

  @override
  void initState() {
    super.initState();
    _loadColleges();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _editNameController.dispose();
    _editLocationController.dispose();
    _editDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadColleges() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('colleges').get();
      setState(() {
        _colleges = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'location': data['location'] ?? '',
            'description': data['description'] ?? '',
            'logoUrl': data['logoUrl'] ?? '',
            'status': data['status'] ?? 'active',
            'createdAt': data['createdAt'] ?? DateTime.now(),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading colleges: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(bool isEdit) async {
    try {
      // Create file input element
      final html.FileUploadInputElement input = html.FileUploadInputElement();
      input.accept = 'image/*';
      input.click();

      input.onChange.listen((event) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final file = files.first;
          final reader = html.FileReader();
          
          reader.onLoad.listen((event) {
            final result = reader.result as String;
            setState(() {
              if (isEdit) {
                _editSelectedLogoUrl = result;
                _editSelectedLogo = null;
              } else {
                _selectedLogoUrl = result;
                _selectedLogo = null;
              }
            });
            print('✅ Image selected: ${file.name}');
          });
          
          reader.readAsDataUrl(file);
        }
      });
    } catch (e) {
      print('❌ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error selecting image: $e')),
        );
      }
    }
  }

  Future<void> _addCollege() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Store the actual logo data URL
      String logoUrl = '';
      if (_selectedLogo != null || _selectedLogoUrl != null) {
        logoUrl = _selectedLogoUrl ?? '';
      }

      await FirebaseFirestore.instance.collection('colleges').add({
        'name': _nameController.text.trim(),
        'location': '',
        'description': '',
        'logoUrl': logoUrl,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear form
      _nameController.clear();
      _selectedLogo = null;
      _selectedLogoUrl = null;

      // Reload colleges
      await _loadColleges();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ College added successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error adding college: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error adding college: $e')),
        );
      }
    }
  }

  Future<void> _editCollege(String collegeId, Map<String, dynamic> college) async {
    if (!_editFormKey.currentState!.validate()) return;

    try {
      String logoUrl = college['logoUrl'];
      if (_editSelectedLogo != null || _editSelectedLogoUrl != null) {
        logoUrl = _editSelectedLogoUrl ?? '';
      }

      await FirebaseFirestore.instance.collection('colleges').doc(collegeId).update({
        'name': _editNameController.text.trim(),
        'location': _editLocationController.text.trim(),
        'description': _editDescriptionController.text.trim(),
        'logoUrl': logoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear edit form
      _editNameController.clear();
      _editLocationController.clear();
      _editDescriptionController.clear();
      _editSelectedLogo = null;
      _editSelectedLogoUrl = null;

      // Reload colleges
      await _loadColleges();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ College updated successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error updating college: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error updating college: $e')),
        );
      }
    }
  }

  Future<void> _deleteCollege(String collegeId, String collegeName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete College'),
        content: Text('Are you sure you want to delete "$collegeName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection('colleges').doc(collegeId).delete();

      // Reload colleges
      await _loadColleges();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ "$collegeName" deleted successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error deleting college: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error deleting college: $e')),
        );
      }
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

  void _showAddCollegeDialog() {
    _selectedLogo = null;
    _selectedLogoUrl = null;
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New College'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'College Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter college name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Logo upload section
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await _pickImage(false);
                      setDialogState(() {}); // Rebuild dialog to show selected image
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_selectedLogo != null || _selectedLogoUrl != null) ...[
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              image: DecorationImage(
                                image: _selectedLogo != null 
                                  ? FileImage(_selectedLogo!) 
                                  : NetworkImage(_selectedLogoUrl!) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Logo selected',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Click to upload logo',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _addCollege();
              },
              child: const Text('Save College'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCollegeDialog(Map<String, dynamic> college) {
    // Pre-fill the edit controllers with current values
    _editNameController.text = college['name'];
    _editLocationController.text = college['location'];
    _editDescriptionController.text = college['description'];
    _editSelectedLogo = null;
    _editSelectedLogoUrl = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit College'),
          content: Form(
            key: _editFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _editNameController,
                  decoration: const InputDecoration(
                    labelText: 'College Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter college name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Logo upload section for edit
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await _pickImage(true);
                      setDialogState(() {}); // Rebuild dialog to show selected image
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_editSelectedLogo != null || _editSelectedLogoUrl != null) ...[
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              image: DecorationImage(
                                image: _editSelectedLogo != null 
                                  ? FileImage(_editSelectedLogo!) 
                                  : NetworkImage(_editSelectedLogoUrl!) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Logo selected',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Click to upload logo',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _editLocationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _editDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _editCollege(college['id'], college);
              },
              child: const Text('Update College'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollegeCard(Map<String, dynamic> college) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // College Logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: college['logoUrl'].isNotEmpty ? null : _getCollegeColor(college['name']),
                image: college['logoUrl'].isNotEmpty 
                  ? DecorationImage(
                      image: NetworkImage(college['logoUrl']),
                      fit: BoxFit.cover,
                    )
                  : null,
              ),
              child: college['logoUrl'].isNotEmpty 
                ? null 
                : Center(
                    child: Text(
                      _getCollegeInitials(college['name']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            ),
            const SizedBox(width: 16),
            // College Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    college['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    college['location'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _showEditCollegeDialog(college),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                ),
                IconButton(
                  onPressed: () => _deleteCollege(college['id'], college['name']),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCollegeColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[name.length % colors.length];
  }

  String _getCollegeInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Manage Colleges',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddCollegeDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add College'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Add, edit, or remove colleges for your platform',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 30),
              
              // Statistics Cards
              Row(
                children: [
                  Expanded(child: _buildStatCard(_colleges.length.toString(), 'Total Colleges', Icons.school, Colors.orange)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(_colleges.where((c) => c['status'] == 'active').length.toString(), 'Active Colleges', Icons.check_circle, Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(_colleges.where((c) => c['status'] == 'inactive').length.toString(), 'Inactive Colleges', Icons.cancel, Colors.red)),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Colleges List
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.white))
              else if (_colleges.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.school, size: 64, color: Colors.white.withOpacity(0.6)),
                      const SizedBox(height: 16),
                      Text(
                        'No colleges found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first college to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _colleges.map((college) => _buildCollegeCard(college)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 
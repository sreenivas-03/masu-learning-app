import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:html' as html;

class SemestersAdminPage extends StatefulWidget {
  const SemestersAdminPage({super.key});

  @override
  State<SemestersAdminPage> createState() => _SemestersAdminPageState();
}

class _SemestersAdminPageState extends State<SemestersAdminPage> {
  List<Map<String, dynamic>> _semesters = [];
  List<Map<String, dynamic>> _regulations = [];
  List<Map<String, dynamic>> _colleges = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedRegulationId;
  String? _selectedRegulationName;
  String? _selectedCollegeId;
  String? _selectedCollegeName;
  File? _selectedLogo;
  String? _selectedLogoUrl;

  // Controllers for edit dialog
  final _editFormKey = GlobalKey<FormState>();
  final _editNameController = TextEditingController();
  String? _editSelectedRegulationId;
  String? _editSelectedRegulationName;
  String? _editSelectedCollegeId;
  String? _editSelectedCollegeName;
  File? _editSelectedLogo;
  String? _editSelectedLogoUrl;

  @override
  void initState() {
    super.initState();
    _loadColleges();
    _loadRegulations();
    _loadSemesters();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _editNameController.dispose();
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
            'logoUrl': data['logoUrl'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('❌ Error loading colleges: $e');
    }
  }

  Future<void> _loadRegulations() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('regulations').get();
      setState(() {
        _regulations = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'logoUrl': data['logoUrl'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('❌ Error loading regulations: $e');
    }
  }

  Future<void> _loadSemesters() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('semesters').get();
      setState(() {
        _semesters = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'regulationId': data['regulationId'] ?? '',
            'regulationName': data['regulationName'] ?? '',
            'collegeId': data['collegeId'] ?? '',
            'collegeName': data['collegeName'] ?? '',
            'logoUrl': data['logoUrl'] ?? '',
            'createdAt': data['createdAt'] ?? DateTime.now(),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading semesters: $e');
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

  Future<void> _addSemester() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Store the actual logo data URL
      String logoUrl = '';
      if (_selectedLogo != null || _selectedLogoUrl != null) {
        logoUrl = _selectedLogoUrl ?? '';
      }

      await FirebaseFirestore.instance.collection('semesters').add({
        'name': _nameController.text.trim(),
        'regulationId': _selectedRegulationId,
        'regulationName': _selectedRegulationName,
        'collegeId': _selectedCollegeId,
        'collegeName': _selectedCollegeName,
        'logoUrl': logoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear form
      _nameController.clear();
      _selectedRegulationId = null;
      _selectedRegulationName = null;
      _selectedCollegeId = null;
      _selectedCollegeName = null;
      _selectedLogo = null;
      _selectedLogoUrl = null;

      // Reload semesters
      await _loadSemesters();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Semester added successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error adding semester: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error adding semester: $e')),
        );
      }
    }
  }

  Future<void> _editSemester(String semesterId, Map<String, dynamic> semester) async {
    if (!_editFormKey.currentState!.validate()) return;

    try {
      String logoUrl = semester['logoUrl'];
      if (_editSelectedLogo != null || _editSelectedLogoUrl != null) {
        logoUrl = _editSelectedLogoUrl ?? '';
      }

      await FirebaseFirestore.instance.collection('semesters').doc(semesterId).update({
        'name': _editNameController.text.trim(),
        'regulationId': _editSelectedRegulationId,
        'regulationName': _editSelectedRegulationName,
        'collegeId': _editSelectedCollegeId,
        'collegeName': _editSelectedCollegeName,
        'logoUrl': logoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear edit form
      _editNameController.clear();
      _editSelectedRegulationId = null;
      _editSelectedRegulationName = null;
      _editSelectedCollegeId = null;
      _editSelectedCollegeName = null;
      _editSelectedLogo = null;
      _editSelectedLogoUrl = null;

      // Reload semesters
      await _loadSemesters();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Semester updated successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error updating semester: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error updating semester: $e')),
        );
      }
    }
  }

  Future<void> _deleteSemester(String semesterId, String semesterName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Semester'),
        content: Text('Are you sure you want to delete "$semesterName"? This action cannot be undone.'),
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
      await FirebaseFirestore.instance.collection('semesters').doc(semesterId).delete();

      // Reload semesters
      await _loadSemesters();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ "$semesterName" deleted successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error deleting semester: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error deleting semester: $e')),
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

  void _showAddSemesterDialog() {
    _selectedRegulationId = null;
    _selectedRegulationName = null;
    _selectedCollegeId = null;
    _selectedCollegeName = null;
    _selectedLogo = null;
    _selectedLogoUrl = null;
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        title: const Text('Add New Semester'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Semester Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter semester name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCollegeId,
                decoration: const InputDecoration(
                    labelText: 'Select College',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a college';
                  }
                  return null;
                },
                  items: _colleges.map((college) {
                    return DropdownMenuItem<String>(
                      value: college['id'],
                      child: Text(college['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCollegeId = value;
                      _selectedCollegeName = _colleges.firstWhere((college) => college['id'] == value)['name'];
                    });
                },
              ),
              const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRegulationId,
                decoration: const InputDecoration(
                    labelText: 'Select Regulation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a regulation';
                  }
                  return null;
                },
                  items: _regulations.map((regulation) {
                    return DropdownMenuItem<String>(
                      value: regulation['id'],
                      child: Text(regulation['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegulationId = value;
                      _selectedRegulationName = _regulations.firstWhere((regulation) => regulation['id'] == value)['name'];
                    });
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
              await _addSemester();
            },
            child: const Text('Add Semester'),
          ),
        ],
        ),
      ),
    );
  }

  void _showEditSemesterDialog(Map<String, dynamic> semester) {
    // Pre-fill the edit controllers with current values
    _editNameController.text = semester['name'];
    _editSelectedRegulationId = semester['regulationId'];
    _editSelectedRegulationName = semester['regulationName'];
    _editSelectedCollegeId = semester['collegeId'];
    _editSelectedCollegeName = semester['collegeName'];
    _editSelectedLogo = null;
    _editSelectedLogoUrl = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        title: const Text('Edit Semester'),
        content: Form(
          key: _editFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _editNameController,
                decoration: const InputDecoration(
                  labelText: 'Semester Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter semester name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _editSelectedCollegeId,
                decoration: const InputDecoration(
                    labelText: 'Select College',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a college';
                  }
                  return null;
                },
                  items: _colleges.map((college) {
                    return DropdownMenuItem<String>(
                      value: college['id'],
                      child: Text(college['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _editSelectedCollegeId = value;
                      _editSelectedCollegeName = _colleges.firstWhere((college) => college['id'] == value)['name'];
                    });
                },
              ),
              const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _editSelectedRegulationId,
                decoration: const InputDecoration(
                    labelText: 'Select Regulation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a regulation';
                  }
                  return null;
                },
                  items: _regulations.map((regulation) {
                    return DropdownMenuItem<String>(
                      value: regulation['id'],
                      child: Text(regulation['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _editSelectedRegulationId = value;
                      _editSelectedRegulationName = _regulations.firstWhere((regulation) => regulation['id'] == value)['name'];
                    });
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
              await _editSemester(semester['id'], semester);
            },
            child: const Text('Update Semester'),
          ),
        ],
        ),
      ),
    );
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
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Semesters Management',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddSemesterDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Semester'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Statistics Cards
              Row(
                children: [
                  Expanded(child: _buildStatCard(_semesters.length.toString(), 'Total Semesters', Icons.school, Colors.orange)),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Semesters List
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Semesters List',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_semesters.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.school, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No semesters found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first semester to get started',
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
                          itemCount: _semesters.length,
                          itemBuilder: (context, index) {
                            final semester = _semesters[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: semester['logoUrl'].isNotEmpty ? null : Colors.orange,
                                    image: semester['logoUrl'].isNotEmpty 
                                      ? DecorationImage(
                                          image: NetworkImage(semester['logoUrl']),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  ),
                                  child: semester['logoUrl'].isNotEmpty 
                                    ? null 
                                    : const Icon(Icons.school, color: Colors.white),
                                ),
                                title: Text(semester['name']),
                                subtitle: Text('College: ${semester['collegeName']} | Regulation: ${semester['regulationName']}'),
                                trailing: PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditSemesterDialog(semester);
                                        } else if (value == 'delete') {
                                          _deleteSemester(semester['id'], semester['name']);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, color: Colors.blue),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Show semester details
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(semester['name']),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('College: ${semester['collegeName']}'),
                                        const SizedBox(height: 8),
                                        Text('Regulation: ${semester['regulationName']}'),
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
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:html' as html;

class SubjectsAdminPage extends StatefulWidget {
  const SubjectsAdminPage({super.key});

  @override
  State<SubjectsAdminPage> createState() => _SubjectsAdminPageState();
}

class _SubjectsAdminPageState extends State<SubjectsAdminPage> {
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _regulations = [];
  List<Map<String, dynamic>> _colleges = [];
  List<Map<String, dynamic>> _semesters = [];
  List<Map<String, dynamic>> _branches = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _creditsController = TextEditingController();
  String? _selectedRegulationId;
  String? _selectedRegulationName;
  String? _selectedCollegeId;
  String? _selectedCollegeName;
  String? _selectedSemesterId;
  String? _selectedSemesterName;
  String? _selectedBranchId;
  String? _selectedBranchName;
  File? _selectedLogo;
  String? _selectedLogoUrl;

  // Controllers for edit dialog
  final _editFormKey = GlobalKey<FormState>();
  final _editNameController = TextEditingController();
  final _editCodeController = TextEditingController();
  final _editCreditsController = TextEditingController();
  String? _editSelectedRegulationId;
  String? _editSelectedRegulationName;
  String? _editSelectedCollegeId;
  String? _editSelectedCollegeName;
  String? _editSelectedSemesterId;
  String? _editSelectedSemesterName;
  String? _editSelectedBranchId;
  String? _editSelectedBranchName;
  File? _editSelectedLogo;
  String? _editSelectedLogoUrl;

  @override
  void initState() {
    super.initState();
    _loadColleges();
    _loadRegulations();
    _loadSemesters();
    _loadBranches();
    _loadSubjects();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _creditsController.dispose();
    _editNameController.dispose();
    _editCodeController.dispose();
    _editCreditsController.dispose();
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
            'logoUrl': data['logoUrl'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('❌ Error loading semesters: $e');
    }
  }

  Future<void> _loadBranches() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('branches').get();
      setState(() {
        _branches = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'logoUrl': data['logoUrl'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('❌ Error loading branches: $e');
    }
  }

  Future<void> _loadSubjects() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('subjects').get();
      setState(() {
        _subjects = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'code': data['code'] ?? '',
            'credits': data['credits'] ?? '',
            'regulationId': data['regulationId'] ?? '',
            'regulationName': data['regulationName'] ?? '',
            'collegeId': data['collegeId'] ?? '',
            'collegeName': data['collegeName'] ?? '',
            'semesterId': data['semesterId'] ?? '',
            'semesterName': data['semesterName'] ?? '',
            'branchId': data['branchId'] ?? '',
            'branchName': data['branchName'] ?? '',
            'logoUrl': data['logoUrl'] ?? '',
            'createdAt': data['createdAt'] ?? DateTime.now(),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading subjects: $e');
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

  Future<void> _addSubject() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Store the actual logo data URL
      String logoUrl = '';
      if (_selectedLogo != null || _selectedLogoUrl != null) {
        logoUrl = _selectedLogoUrl ?? '';
      }

      await FirebaseFirestore.instance.collection('subjects').add({
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'credits': _creditsController.text.trim(),
        'regulationId': _selectedRegulationId,
        'regulationName': _selectedRegulationName,
        'collegeId': _selectedCollegeId,
        'collegeName': _selectedCollegeName,
        'semesterId': _selectedSemesterId,
        'semesterName': _selectedSemesterName,
        'branchId': _selectedBranchId,
        'branchName': _selectedBranchName,
        'logoUrl': logoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear form
      _nameController.clear();
      _codeController.clear();
      _creditsController.clear();
      _selectedRegulationId = null;
      _selectedRegulationName = null;
      _selectedCollegeId = null;
      _selectedCollegeName = null;
      _selectedSemesterId = null;
      _selectedSemesterName = null;
      _selectedBranchId = null;
      _selectedBranchName = null;
      _selectedLogo = null;
      _selectedLogoUrl = null;

      // Reload subjects
      await _loadSubjects();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Subject added successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error adding subject: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error adding subject: $e')),
        );
      }
    }
  }

  Future<void> _editSubject(String subjectId, Map<String, dynamic> subject) async {
    if (!_editFormKey.currentState!.validate()) return;

    try {
      String logoUrl = subject['logoUrl'];
      if (_editSelectedLogo != null || _editSelectedLogoUrl != null) {
        logoUrl = _editSelectedLogoUrl ?? '';
      }

      await FirebaseFirestore.instance.collection('subjects').doc(subjectId).update({
        'name': _editNameController.text.trim(),
        'code': _editCodeController.text.trim(),
        'credits': _editCreditsController.text.trim(),
        'regulationId': _editSelectedRegulationId,
        'regulationName': _editSelectedRegulationName,
        'collegeId': _editSelectedCollegeId,
        'collegeName': _editSelectedCollegeName,
        'semesterId': _editSelectedSemesterId,
        'semesterName': _editSelectedSemesterName,
        'branchId': _editSelectedBranchId,
        'branchName': _editSelectedBranchName,
        'logoUrl': logoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear edit form
      _editNameController.clear();
      _editCodeController.clear();
      _editCreditsController.clear();
      _editSelectedRegulationId = null;
      _editSelectedRegulationName = null;
      _editSelectedCollegeId = null;
      _editSelectedCollegeName = null;
      _editSelectedSemesterId = null;
      _editSelectedSemesterName = null;
      _editSelectedBranchId = null;
      _editSelectedBranchName = null;
      _editSelectedLogo = null;
      _editSelectedLogoUrl = null;

      // Reload subjects
      await _loadSubjects();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Subject updated successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error updating subject: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error updating subject: $e')),
        );
      }
    }
  }

  Future<void> _deleteSubject(String subjectId, String subjectName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "$subjectName"? This action cannot be undone.'),
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
      await FirebaseFirestore.instance.collection('subjects').doc(subjectId).delete();

      // Reload subjects
      await _loadSubjects();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ "$subjectName" deleted successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error deleting subject: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error deleting subject: $e')),
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

  void _showAddSubjectDialog() {
    _selectedRegulationId = null;
    _selectedRegulationName = null;
    _selectedCollegeId = null;
    _selectedCollegeName = null;
    _selectedSemesterId = null;
    _selectedSemesterName = null;
    _selectedBranchId = null;
    _selectedBranchName = null;
    _selectedLogo = null;
    _selectedLogoUrl = null;
    _nameController.clear();
    _codeController.clear();
    _creditsController.clear();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        title: const Text('Add New Subject'),
          content: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Subject Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subject code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _creditsController,
                decoration: const InputDecoration(
                  labelText: 'Credits',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter credits';
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
                  DropdownButtonFormField<String>(
                    value: _selectedSemesterId,
                    decoration: const InputDecoration(
                      labelText: 'Select Semester',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a semester';
                      }
                      return null;
                    },
                    items: _semesters.map((semester) {
                      return DropdownMenuItem<String>(
                        value: semester['id'],
                        child: Text(semester['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSemesterId = value;
                        _selectedSemesterName = _semesters.firstWhere((semester) => semester['id'] == value)['name'];
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedBranchId,
                decoration: const InputDecoration(
                      labelText: 'Select Branch',
                  border: OutlineInputBorder(),
                ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a branch';
                      }
                      return null;
                    },
                    items: _branches.map((branch) {
                      return DropdownMenuItem<String>(
                        value: branch['id'],
                        child: Text(branch['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBranchId = value;
                        _selectedBranchName = _branches.firstWhere((branch) => branch['id'] == value)['name'];
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _addSubject();
            },
            child: const Text('Add Subject'),
          ),
        ],
        ),
      ),
    );
  }

  void _showEditSubjectDialog(Map<String, dynamic> subject) {
    // Pre-fill the edit controllers with current values
    _editNameController.text = subject['name'];
    _editCodeController.text = subject['code'];
    _editCreditsController.text = subject['credits'];
    _editSelectedRegulationId = subject['regulationId'];
    _editSelectedRegulationName = subject['regulationName'];
    _editSelectedCollegeId = subject['collegeId'];
    _editSelectedCollegeName = subject['collegeName'];
    _editSelectedSemesterId = subject['semesterId'];
    _editSelectedSemesterName = subject['semesterName'];
    _editSelectedBranchId = subject['branchId'];
    _editSelectedBranchName = subject['branchName'];
    _editSelectedLogo = null;
    _editSelectedLogoUrl = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        title: const Text('Edit Subject'),
          content: SingleChildScrollView(
            child: Form(
          key: _editFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _editNameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _editCodeController,
                decoration: const InputDecoration(
                  labelText: 'Subject Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subject code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _editCreditsController,
                decoration: const InputDecoration(
                  labelText: 'Credits',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter credits';
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
                  DropdownButtonFormField<String>(
                    value: _editSelectedSemesterId,
                    decoration: const InputDecoration(
                      labelText: 'Select Semester',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a semester';
                      }
                      return null;
                    },
                    items: _semesters.map((semester) {
                      return DropdownMenuItem<String>(
                        value: semester['id'],
                        child: Text(semester['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _editSelectedSemesterId = value;
                        _editSelectedSemesterName = _semesters.firstWhere((semester) => semester['id'] == value)['name'];
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _editSelectedBranchId,
                decoration: const InputDecoration(
                      labelText: 'Select Branch',
                  border: OutlineInputBorder(),
                ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a branch';
                      }
                      return null;
                    },
                    items: _branches.map((branch) {
                      return DropdownMenuItem<String>(
                        value: branch['id'],
                        child: Text(branch['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _editSelectedBranchId = value;
                        _editSelectedBranchName = _branches.firstWhere((branch) => branch['id'] == value)['name'];
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _editSubject(subject['id'], subject);
            },
            child: const Text('Update Subject'),
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
                    'Subjects Management',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddSubjectDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subject'),
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
                  Expanded(child: _buildStatCard(_subjects.length.toString(), 'Total Subjects', Icons.book, Colors.indigo)),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Subjects List
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subjects List',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_subjects.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.book, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No subjects found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first subject to get started',
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
                          itemCount: _subjects.length,
                          itemBuilder: (context, index) {
                            final subject = _subjects[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: subject['logoUrl'].isNotEmpty ? null : Colors.indigo,
                                    image: subject['logoUrl'].isNotEmpty 
                                      ? DecorationImage(
                                          image: NetworkImage(subject['logoUrl']),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  ),
                                  child: subject['logoUrl'].isNotEmpty 
                                    ? null 
                                    : const Icon(Icons.book, color: Colors.white),
                                ),
                                title: Text(subject['name']),
                                subtitle: Text('College: ${subject['collegeName']} | Regulation: ${subject['regulationName']} | Semester: ${subject['semesterName']} | Branch: ${subject['branchName']}'),
                                trailing: PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditSubjectDialog(subject);
                                        } else if (value == 'delete') {
                                          _deleteSubject(subject['id'], subject['name']);
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
                                // Show subject details
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(subject['name']),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Code: ${subject['code']}'),
                                        const SizedBox(height: 8),
                                        Text('Credits: ${subject['credits']}'),
                                        const SizedBox(height: 8),
                                        Text('College: ${subject['collegeName']}'),
                                        const SizedBox(height: 8),
                                        Text('Regulation: ${subject['regulationName']}'),
                                        const SizedBox(height: 8),
                                        Text('Semester: ${subject['semesterName']}'),
                                        const SizedBox(height: 8),
                                        Text('Branch: ${subject['branchName']}'),
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
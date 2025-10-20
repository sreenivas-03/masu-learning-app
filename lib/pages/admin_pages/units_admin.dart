import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:html' as html;

class UnitsAdminPage extends StatefulWidget {
  const UnitsAdminPage({super.key});

  @override
  State<UnitsAdminPage> createState() => _UnitsAdminPageState();
}

class _UnitsAdminPageState extends State<UnitsAdminPage> {
  List<Map<String, dynamic>> _units = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _semesters = [];
  List<Map<String, dynamic>> _regulations = [];
  List<Map<String, dynamic>> _colleges = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();

  // Variables for dropdowns
  String? _selectedCollegeId;
  String? _selectedCollegeName;
  String? _selectedRegulationId;
  String? _selectedRegulationName;
  String? _selectedSemesterId;
  String? _selectedSemesterName;
  String? _selectedBranchId;
  String? _selectedBranchName;
  String? _selectedSubjectId;
  String? _selectedSubjectName;

  // Variables for logo
  File? _selectedLogo;
  String? _selectedLogoUrl;

  // Controllers for edit dialog
  final _editFormKey = GlobalKey<FormState>();
  final _editNameController = TextEditingController();
  final _editNumberController = TextEditingController();

  // Variables for edit dropdowns
  String? _editSelectedCollegeId;
  String? _editSelectedCollegeName;
  String? _editSelectedRegulationId;
  String? _editSelectedRegulationName;
  String? _editSelectedSemesterId;
  String? _editSelectedSemesterName;
  String? _editSelectedBranchId;
  String? _editSelectedBranchName;
  String? _editSelectedSubjectId;
  String? _editSelectedSubjectName;

  // Variables for edit logo
  File? _editSelectedLogo;
  String? _editSelectedLogoUrl;

  @override
  void initState() {
    super.initState();
    _loadUnits();
    _loadColleges();
    _loadRegulations();
    _loadSemesters();
    _loadBranches();
    _loadSubjects();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _editNameController.dispose();
    _editNumberController.dispose();
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
          };
        }).toList();
      });
    } catch (e) {
      print('❌ Error loading subjects: $e');
    }
  }

  Future<void> _pickImage(bool isEdit) async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    await input.onChange.first;
    if (input.files?.isNotEmpty == true) {
      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      await reader.onLoad.first;

      if (isEdit) {
        setState(() {
          _editSelectedLogo = null;
          _editSelectedLogoUrl = reader.result as String;
        });
      } else {
        setState(() {
          _selectedLogo = null;
          _selectedLogoUrl = reader.result as String;
        });
      }
    }
  }

  Future<void> _loadUnits() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('units').get();
      setState(() {
        _units = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'number': data['number'] ?? '',
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
            'logoUrl': data['logoUrl'] ?? '',
            'createdAt': data['createdAt'] ?? DateTime.now(),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading units: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addUnit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance.collection('units').add({
        'name': _nameController.text.trim(),
        'number': _numberController.text.trim(),
        'collegeId': _selectedCollegeId,
        'collegeName': _selectedCollegeName,
        'regulationId': _selectedRegulationId,
        'regulationName': _selectedRegulationName,
        'semesterId': _selectedSemesterId,
        'semesterName': _selectedSemesterName,
        'branchId': _selectedBranchId,
        'branchName': _selectedBranchName,
        'subjectId': _selectedSubjectId,
        'subjectName': _selectedSubjectName,
        'logoUrl': _selectedLogoUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear form
      _nameController.clear();
      _numberController.clear();
      setState(() {
        _selectedCollegeId = null;
        _selectedCollegeName = null;
        _selectedRegulationId = null;
        _selectedRegulationName = null;
        _selectedSemesterId = null;
        _selectedSemesterName = null;
        _selectedBranchId = null;
        _selectedBranchName = null;
        _selectedSubjectId = null;
        _selectedSubjectName = null;
        _selectedLogo = null;
        _selectedLogoUrl = null;
      });

      // Reload units
      await _loadUnits();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Unit added successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error adding unit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error adding unit: $e')),
        );
      }
    }
  }

  Future<void> _editUnit(String unitId, Map<String, dynamic> unit) async {
    if (!_editFormKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance.collection('units').doc(unitId).update({
        'name': _editNameController.text.trim(),
        'number': _editNumberController.text.trim(),
        'collegeId': _editSelectedCollegeId,
        'collegeName': _editSelectedCollegeName,
        'regulationId': _editSelectedRegulationId,
        'regulationName': _editSelectedRegulationName,
        'semesterId': _editSelectedSemesterId,
        'semesterName': _editSelectedSemesterName,
        'branchId': _editSelectedBranchId,
        'branchName': _editSelectedBranchName,
        'subjectId': _editSelectedSubjectId,
        'subjectName': _editSelectedSubjectName,
        'logoUrl': _editSelectedLogoUrl ?? unit['logoUrl'],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear edit form
      _editNameController.clear();
      _editNumberController.clear();
      setState(() {
        _editSelectedCollegeId = null;
        _editSelectedCollegeName = null;
        _editSelectedRegulationId = null;
        _editSelectedRegulationName = null;
        _editSelectedSemesterId = null;
        _editSelectedSemesterName = null;
        _editSelectedBranchId = null;
        _editSelectedBranchName = null;
        _editSelectedSubjectId = null;
        _editSelectedSubjectName = null;
        _editSelectedLogo = null;
        _editSelectedLogoUrl = null;
      });

      // Reload units
      await _loadUnits();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Unit updated successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error updating unit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error updating unit: $e')),
        );
      }
    }
  }

  Future<void> _deleteUnit(String unitId, String unitName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Unit'),
        content: Text('Are you sure you want to delete "$unitName"? This action cannot be undone.'),
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
      await FirebaseFirestore.instance.collection('units').doc(unitId).delete();

      // Reload units
      await _loadUnits();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ "$unitName" deleted successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error deleting unit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error deleting unit: $e')),
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

  void _showAddUnitDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        title: const Text('Add New Unit'),
          content: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Unit Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter unit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Unit Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter unit number';
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
                  DropdownButtonFormField<String>(
                    value: _selectedSubjectId,
                decoration: const InputDecoration(
                      labelText: 'Select Subject',
                  border: OutlineInputBorder(),
                ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a subject';
                      }
                      return null;
                    },
                    items: _subjects.map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject['id'],
                        child: Text(subject['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubjectId = value;
                        _selectedSubjectName = _subjects.firstWhere((subject) => subject['id'] == value)['name'];
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
              await _addUnit();
            },
            child: const Text('Add Unit'),
          ),
        ],
        ),
      ),
    );
  }

  void _showEditUnitDialog(Map<String, dynamic> unit) {
    // Pre-fill the edit controllers with current values
    _editNameController.text = unit['name'];
    _editNumberController.text = unit['number'];
    
    // Set edit dropdown values
    _editSelectedCollegeId = unit['collegeId'];
    _editSelectedCollegeName = unit['collegeName'];
    _editSelectedRegulationId = unit['regulationId'];
    _editSelectedRegulationName = unit['regulationName'];
    _editSelectedSemesterId = unit['semesterId'];
    _editSelectedSemesterName = unit['semesterName'];
    _editSelectedBranchId = unit['branchId'];
    _editSelectedBranchName = unit['branchName'];
    _editSelectedSubjectId = unit['subjectId'];
    _editSelectedSubjectName = unit['subjectName'];
    _editSelectedLogoUrl = unit['logoUrl'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        title: const Text('Edit Unit'),
          content: SingleChildScrollView(
            child: Form(
          key: _editFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _editNameController,
                decoration: const InputDecoration(
                  labelText: 'Unit Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter unit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _editNumberController,
                decoration: const InputDecoration(
                  labelText: 'Unit Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter unit number';
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
                  DropdownButtonFormField<String>(
                    value: _editSelectedSubjectId,
                decoration: const InputDecoration(
                      labelText: 'Select Subject',
                  border: OutlineInputBorder(),
                ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a subject';
                      }
                      return null;
                    },
                    items: _subjects.map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject['id'],
                        child: Text(subject['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _editSelectedSubjectId = value;
                        _editSelectedSubjectName = _subjects.firstWhere((subject) => subject['id'] == value)['name'];
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
              await _editUnit(unit['id'], unit);
            },
            child: const Text('Update Unit'),
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
                    'Units Management',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddUnitDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Unit'),
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
                  Expanded(child: _buildStatCard(_units.length.toString(), 'Total Units', Icons.layers, Colors.deepPurple)),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Units List
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Units List',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_units.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.layers, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No units found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first unit to get started',
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
                          itemCount: _units.length,
                          itemBuilder: (context, index) {
                            final unit = _units[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: unit['logoUrl'].isNotEmpty ? null : Colors.deepPurple,
                                    image: unit['logoUrl'].isNotEmpty 
                                      ? DecorationImage(
                                          image: NetworkImage(unit['logoUrl']),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  ),
                                  child: unit['logoUrl'].isNotEmpty 
                                    ? null 
                                    : const Icon(Icons.layers, color: Colors.white),
                                ),
                                title: Text(unit['name']),
                                subtitle: Text('College: ${unit['collegeName']} | Regulation: ${unit['regulationName']} | Semester: ${unit['semesterName']} | Branch: ${unit['branchName']} | Subject: ${unit['subjectName']}'),
                                trailing: PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditUnitDialog(unit);
                                        } else if (value == 'delete') {
                                          _deleteUnit(unit['id'], unit['name']);
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
                                // Show unit details
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(unit['name']),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Unit Number: ${unit['number']}'),
                                        const SizedBox(height: 8),
                                        Text('College: ${unit['collegeName']}'),
                                        const SizedBox(height: 8),
                                        Text('Regulation: ${unit['regulationName']}'),
                                        const SizedBox(height: 8),
                                        Text('Semester: ${unit['semesterName']}'),
                                        const SizedBox(height: 8),
                                        Text('Branch: ${unit['branchName']}'),
                                        const SizedBox(height: 8),
                                        Text('Subject: ${unit['subjectName']}'),
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
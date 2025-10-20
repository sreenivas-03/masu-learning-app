import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'dart:html' as html;
import 'dart:async';

class ContentAdminPage extends StatefulWidget {
  const ContentAdminPage({super.key});

  @override
  State<ContentAdminPage> createState() => _ContentAdminPageState();
}

class _ContentAdminPageState extends State<ContentAdminPage> {
  List<Map<String, dynamic>> _content = [];
  List<Map<String, dynamic>> _units = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _semesters = [];
  List<Map<String, dynamic>> _regulations = [];
  List<Map<String, dynamic>> _colleges = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pdfUrlController = TextEditingController();
  final _pyqUrlController = TextEditingController();
  final _importantQuestionsController = TextEditingController();
  final _notesController = TextEditingController();
  final _notesContentController = TextEditingController();
  final _importantQuestionsContentController = TextEditingController();
  final _mcqContentController = TextEditingController();

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
  String? _selectedUnitId;
  String? _selectedUnitName;

  // Variables for logo
  File? _selectedLogo;
  String? _selectedLogoUrl;

  // Controllers for edit dialog
  final _editFormKey = GlobalKey<FormState>();
  final _editTitleController = TextEditingController();
  final _editDescriptionController = TextEditingController();
  final _editPdfUrlController = TextEditingController();
  final _editPyqUrlController = TextEditingController();
  final _editImportantQuestionsController = TextEditingController();
  final _editNotesController = TextEditingController();
  final _editNotesContentController = TextEditingController();
  final _editImportantQuestionsContentController = TextEditingController();
  final _editMcqContentController = TextEditingController();

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
  String? _editSelectedUnitId;
  String? _editSelectedUnitName;

  // Variables for edit logo
  File? _editSelectedLogo;
  String? _editSelectedLogoUrl;

  // Variables for PDF files
  String? _selectedPdfUrl;
  String? _editSelectedPdfUrl;
  String? _selectedPyqUrl;
  String? _editSelectedPyqUrl;
  String? _selectedNotesPdfUrl;
  String? _editSelectedNotesPdfUrl;
  String? _selectedImportantQuestionsPdfUrl;
  String? _editSelectedImportantQuestionsPdfUrl;

  // Loading states for PDF uploads
  bool _isUploadingPdf = false;
  bool _isUploadingPyq = false;
  bool _isUploadingNotes = false;
  bool _isUploadingImportantQuestions = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
    _loadColleges();
    _loadRegulations();
    _loadSemesters();
    _loadBranches();
    _loadSubjects();
    _loadUnits();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _importantQuestionsController.dispose();
    _notesController.dispose();
    _editTitleController.dispose();
    _editImportantQuestionsController.dispose();
    _editNotesController.dispose();
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

  Future<void> _loadUnits() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('units').get();
      setState(() {
        _units = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('❌ Error loading units: $e');
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

  Future<String?> _uploadPdfToStorage(html.File file, String fileName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('content_pdfs/$fileName');
      final uploadTask = storageRef.putBlob(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading PDF: $e');
      return null;
    }
  }

  Future<void> _pickPdfFile(bool isEdit) async {
    final input = html.FileUploadInputElement()..accept = '.pdf';
    input.click();

    await input.onChange.first;
    if (input.files?.isNotEmpty == true) {
      final file = input.files!.first;
      final fileName = 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      setState(() {
        _isUploadingPdf = true;
      });
      
      final downloadUrl = await _uploadPdfToStorage(file, fileName);
      if (downloadUrl != null) {
        if (isEdit) {
          setState(() {
            _editSelectedPdfUrl = downloadUrl;
            _isUploadingPdf = false;
          });
        } else {
          setState(() {
            _selectedPdfUrl = downloadUrl;
            _isUploadingPdf = false;
          });
        }
      } else {
        setState(() {
          _isUploadingPdf = false;
        });
      }
    }
  }

  Future<void> _pickPyqFile(bool isEdit) async {
    final input = html.FileUploadInputElement()..accept = '.pdf';
    input.click();

    await input.onChange.first;
    if (input.files?.isNotEmpty == true) {
      final file = input.files!.first;
      final fileName = 'pyq_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      setState(() {
        _isUploadingPyq = true;
      });
      
      final downloadUrl = await _uploadPdfToStorage(file, fileName);
      if (downloadUrl != null) {
        if (isEdit) {
          setState(() {
            _editSelectedPyqUrl = downloadUrl;
            _isUploadingPyq = false;
          });
        } else {
          setState(() {
            _selectedPyqUrl = downloadUrl;
            _isUploadingPyq = false;
          });
        }
      } else {
        setState(() {
          _isUploadingPyq = false;
        });
      }
    }
  }

  Future<void> _pickNotesPdfFile(bool isEdit) async {
    final input = html.FileUploadInputElement()..accept = '.pdf';
    input.click();

    await input.onChange.first;
    if (input.files?.isNotEmpty == true) {
      final file = input.files!.first;
      final fileName = 'notes_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      setState(() {
        _isUploadingNotes = true;
      });
      
      final downloadUrl = await _uploadPdfToStorage(file, fileName);
      if (downloadUrl != null) {
        if (isEdit) {
          setState(() {
            _editSelectedNotesPdfUrl = downloadUrl;
            _isUploadingNotes = false;
          });
        } else {
          setState(() {
            _selectedNotesPdfUrl = downloadUrl;
            _isUploadingNotes = false;
          });
        }
      } else {
        setState(() {
          _isUploadingNotes = false;
        });
      }
    }
  }

  Future<void> _pickImportantQuestionsPdfFile(bool isEdit) async {
    final input = html.FileUploadInputElement()..accept = '.pdf';
    input.click();

    await input.onChange.first;
    if (input.files?.isNotEmpty == true) {
      final file = input.files!.first;
      final fileName = 'important_questions_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      setState(() {
        _isUploadingImportantQuestions = true;
      });
      
      final downloadUrl = await _uploadPdfToStorage(file, fileName);
      if (downloadUrl != null) {
        if (isEdit) {
          setState(() {
            _editSelectedImportantQuestionsPdfUrl = downloadUrl;
            _isUploadingImportantQuestions = false;
          });
        } else {
          setState(() {
            _selectedImportantQuestionsPdfUrl = downloadUrl;
            _isUploadingImportantQuestions = false;
          });
        }
      } else {
        setState(() {
          _isUploadingImportantQuestions = false;
        });
      }
    }
  }

  Future<void> _loadContent() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('content').get();
      setState(() {
        _content = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? '',
            'notesContent': data['notesContent'] ?? '',
            'importantQuestionsContent': data['importantQuestionsContent'] ?? '',
            'mcqContent': data['mcqContent'] ?? '',
            'pdfUrl': data['pdfUrl'] ?? '',
            'pyqUrl': data['pyqUrl'] ?? '',
            'notesPdfUrl': data['notesPdfUrl'] ?? '',
            'importantQuestionsPdfUrl': data['importantQuestionsPdfUrl'] ?? '',
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
            'createdAt': data['createdAt'] ?? DateTime.now(),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading content: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addContent() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance.collection('content').add({
        'title': _titleController.text.trim(),
        'notesContent': _notesContentController.text.trim(),
        'importantQuestionsContent': _importantQuestionsContentController.text.trim(),
        'mcqContent': _mcqContentController.text.trim(),
        'pdfUrl': _selectedPdfUrl ?? '',
        'pyqUrl': _selectedPyqUrl ?? '',
        'notesPdfUrl': _selectedNotesPdfUrl ?? '',
        'importantQuestionsPdfUrl': _selectedImportantQuestionsPdfUrl ?? '',
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
        'unitId': _selectedUnitId,
        'unitName': _selectedUnitName,
        'logoUrl': _selectedLogoUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear form
      _titleController.clear();
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
        _selectedUnitId = null;
        _selectedUnitName = null;
        _selectedLogo = null;
        _selectedLogoUrl = null;
        _selectedPdfUrl = null;
        _selectedPyqUrl = null;
        _selectedNotesPdfUrl = null;
        _selectedImportantQuestionsPdfUrl = null;
      });

      // Reload content
      await _loadContent();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Content added successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error adding content: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error adding content: $e')),
        );
      }
    }
  }

  Future<void> _editContent(String contentId, Map<String, dynamic> content) async {
    if (!_editFormKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance.collection('content').doc(contentId).update({
        'title': _editTitleController.text.trim(),
        'pdfUrl': _editSelectedPdfUrl ?? content['pdfUrl'],
        'pyqUrl': _editSelectedPyqUrl ?? content['pyqUrl'],
        'notesPdfUrl': _editSelectedNotesPdfUrl ?? content['notesPdfUrl'],
        'importantQuestionsPdfUrl': _editSelectedImportantQuestionsPdfUrl ?? content['importantQuestionsPdfUrl'],
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
        'unitId': _editSelectedUnitId,
        'unitName': _editSelectedUnitName,
        'logoUrl': _editSelectedLogoUrl ?? content['logoUrl'],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear edit form
      _editTitleController.clear();
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
        _editSelectedUnitId = null;
        _editSelectedUnitName = null;
        _editSelectedLogo = null;
        _editSelectedLogoUrl = null;
        _editSelectedPdfUrl = null;
        _editSelectedPyqUrl = null;
        _editSelectedNotesPdfUrl = null;
        _editSelectedImportantQuestionsPdfUrl = null;
      });

      // Reload content
      await _loadContent();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Content updated successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error updating content: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error updating content: $e')),
        );
      }
    }
  }

  Future<void> _deleteContent(String contentId, String contentTitle) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Content'),
        content: Text('Are you sure you want to delete "$contentTitle"? This action cannot be undone.'),
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
      await FirebaseFirestore.instance.collection('content').doc(contentId).delete();

      // Reload content
      await _loadContent();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ "$contentTitle" deleted successfully!')),
        );
      }
    } catch (e) {
      print('❌ Error deleting content: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error deleting content: $e')),
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

  void _showAddContentDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        title: const Text('Add New Content'),
          content: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Content Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter content title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesContentController,
                decoration: const InputDecoration(
                  labelText: 'Notes Content',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the notes content that will appear in the Notes tab',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _importantQuestionsContentController,
                decoration: const InputDecoration(
                  labelText: 'Important Questions Content',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the important questions that will appear in the Important Questions tab',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mcqContentController,
                decoration: const InputDecoration(
                  labelText: 'MCQ Content',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the MCQ questions that will appear in the MCQs tab',
                ),
                maxLines: 3,
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
                  DropdownButtonFormField<String>(
                    value: _selectedUnitId,
                    decoration: const InputDecoration(
                      labelText: 'Select Unit',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a unit';
                      }
                      return null;
                    },
                    items: _units.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit['id'],
                        child: Text(unit['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUnitId = value;
                        _selectedUnitName = _units.firstWhere((unit) => unit['id'] == value)['name'];
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
                   const SizedBox(height: 16),
                   // PDF upload section
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
                         await _pickPdfFile(false);
                         setDialogState(() {}); // Rebuild dialog to show selected file
                       },
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           if (_isUploadingPdf) ...[
                             const CircularProgressIndicator(),
                             const SizedBox(height: 8),
                             Text(
                               'Uploading PDF...',
                               style: TextStyle(
                                 color: Colors.blue,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                           ] else if (_selectedPdfUrl != null) ...[
                             Icon(
                               Icons.picture_as_pdf,
                               size: 40,
                               color: Colors.red,
                             ),
                             const SizedBox(height: 8),
                             Text(
                               'PDF selected',
                               style: TextStyle(
                                 color: Colors.green,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                           ] else ...[
                             Icon(
                               Icons.picture_as_pdf,
                               size: 40,
                               color: Colors.grey.shade600,
                             ),
                             const SizedBox(height: 8),
                             Text(
                               'Click to upload PDF',
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
                   // PYQ PDF upload section
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
                         await _pickPyqFile(false);
                         setDialogState(() {}); // Rebuild dialog to show selected file
                       },
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           if (_isUploadingPyq) ...[
                             const CircularProgressIndicator(),
                             const SizedBox(height: 8),
                             Text(
                               'Uploading PYQ PDF...',
                               style: TextStyle(
                                 color: Colors.blue,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                           ] else if (_selectedPyqUrl != null) ...[
                             Icon(
                               Icons.picture_as_pdf,
                               size: 40,
                               color: Colors.red,
                             ),
                             const SizedBox(height: 8),
                             Text(
                               'PYQ PDF selected',
                               style: TextStyle(
                                 color: Colors.green,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                           ] else ...[
                             Icon(
                               Icons.picture_as_pdf,
                               size: 40,
                               color: Colors.grey.shade600,
                             ),
                             const SizedBox(height: 8),
                             Text(
                               'Click to upload PYQ PDF',
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
                   // Notes PDF upload section
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
                         await _pickNotesPdfFile(false);
                         setDialogState(() {}); // Rebuild dialog to show selected file
                       },
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           if (_isUploadingNotes) ...[
                             const CircularProgressIndicator(),
                             const SizedBox(height: 8),
                             Text(
                               'Uploading Notes PDF...',
                               style: TextStyle(
                                 color: Colors.blue,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                           ] else if (_selectedNotesPdfUrl != null) ...[
                             Icon(
                               Icons.picture_as_pdf,
                               size: 40,
                               color: Colors.red,
                             ),
                             const SizedBox(height: 8),
                             Text(
                               'Notes PDF selected',
                               style: TextStyle(
                                 color: Colors.green,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                           ] else ...[
                             Icon(
                               Icons.picture_as_pdf,
                               size: 40,
                               color: Colors.grey.shade600,
                             ),
                             const SizedBox(height: 8),
                             Text(
                               'Click to upload Notes PDF',
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
                   // Important Questions PDF upload section
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
                         await _pickImportantQuestionsPdfFile(false);
                         setDialogState(() {}); // Rebuild dialog to show selected file
                       },
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           if (_isUploadingImportantQuestions) ...[
                             const CircularProgressIndicator(),
                             const SizedBox(height: 8),
                             Text(
                               'Uploading Important Questions PDF...',
                               style: TextStyle(
                                 color: Colors.blue,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                           ] else if (_selectedImportantQuestionsPdfUrl != null) ...[
                             Icon(
                               Icons.picture_as_pdf,
                               size: 40,
                               color: Colors.red,
                             ),
                             const SizedBox(height: 8),
                             Text(
                               'Important Questions PDF selected',
                               style: TextStyle(
                                 color: Colors.green,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                           ] else ...[
                             Icon(
                               Icons.picture_as_pdf,
                               size: 40,
                               color: Colors.grey.shade600,
                             ),
                             const SizedBox(height: 8),
                             Text(
                               'Click to upload Important Questions PDF',
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
              await _addContent();
            },
            child: const Text('Add Content'),
          ),
        ],
        ),
      ),
    );
  }

  void _showEditContentDialog(Map<String, dynamic> content) {
    // Pre-fill the edit controllers with current values, fallback to empty string if null
    _editTitleController.text = content['title'] ?? '';
    _editDescriptionController.text = content['description'] ?? '';
    _editPdfUrlController.text = content['pdfUrl'] ?? '';
    _editPyqUrlController.text = content['pyqUrl'] ?? '';
    _editImportantQuestionsController.text = content['importantQuestionsPdfUrl'] ?? '';
    _editNotesController.text = content['notesPdfUrl'] ?? '';

    // Set selected values for dropdowns
    _editSelectedCollegeId = content['collegeId'] ?? '';
    _editSelectedCollegeName = content['collegeName'] ?? '';
    _editSelectedRegulationId = content['regulationId'] ?? '';
    _editSelectedRegulationName = content['regulationName'] ?? '';
    _editSelectedSemesterId = content['semesterId'] ?? '';
    _editSelectedSemesterName = content['semesterName'] ?? '';
    _editSelectedBranchId = content['branchId'] ?? '';
    _editSelectedBranchName = content['branchName'] ?? '';
    _editSelectedSubjectId = content['subjectId'] ?? '';
    _editSelectedSubjectName = content['subjectName'] ?? '';
    _editSelectedUnitId = content['unitId'] ?? '';
    _editSelectedUnitName = content['unitName'] ?? '';

    // Set logo for edit dialog
    _editSelectedLogoUrl = content['logoUrl'] ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        title: const Text('Edit Content'),
          content: SingleChildScrollView(
            child: Form(
          key: _editFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                  // PDF preview buttons in edit dialog
                  if ((_editPdfUrlController.text ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => _buildPdfViewer(_editPdfUrlController.text, 'Main Content PDF'),
                          ),
                        ),
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        label: const Text('View Main PDF', style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  if ((_editPyqUrlController.text ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => _buildPdfViewer(_editPyqUrlController.text, 'PYQ PDF'),
                          ),
                        ),
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.orange),
                        label: const Text('View PYQ PDF', style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                  if ((_editNotesController.text ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => _buildPdfViewer(_editNotesController.text, 'Notes PDF'),
                          ),
                        ),
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                        label: const Text('View Notes PDF', style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  if ((_editImportantQuestionsController.text ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => _buildPdfViewer(_editImportantQuestionsController.text, 'Important Questions PDF'),
                          ),
                        ),
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.green),
                        label: const Text('View Important Qs PDF', style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
                   const SizedBox(height: 16),
                   // PDF upload section for edit
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
                         await _pickPdfFile(true);
                         setDialogState(() {}); // Rebuild dialog to show selected file
                       },
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           if (_editSelectedPdfUrl != null) ...[
                            Icon(
                              Icons.picture_as_pdf,
                              size: 40,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'PDF selected',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.picture_as_pdf,
                              size: 40,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Click to upload PDF',
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
                  // PYQ PDF upload section for edit
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
                        await _pickPyqFile(true);
                        setDialogState(() {}); // Rebuild dialog to show selected file
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_editSelectedPyqUrl != null) ...[
                            Icon(
                              Icons.picture_as_pdf,
                              size: 40,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'PYQ PDF selected',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.picture_as_pdf,
                              size: 40,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Click to upload PYQ PDF',
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
                  // Notes PDF upload section for edit
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
                        await _pickNotesPdfFile(true);
                        setDialogState(() {}); // Rebuild dialog to show selected file
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_editSelectedNotesPdfUrl != null) ...[
                            Icon(
                              Icons.picture_as_pdf,
                              size: 40,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Notes PDF selected',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.picture_as_pdf,
                              size: 40,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Click to upload Notes PDF',
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
                  // Important Questions PDF upload section for edit
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
                        await _pickImportantQuestionsPdfFile(true);
                        setDialogState(() {}); // Rebuild dialog to show selected file
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_editSelectedImportantQuestionsPdfUrl != null) ...[
                            Icon(
                              Icons.picture_as_pdf,
                              size: 40,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Important Questions PDF selected',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.picture_as_pdf,
                              size: 40,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Click to upload Important Questions PDF',
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
              await _editContent(content['id'], content);
            },
            child: const Text('Update Content'),
          ),
        ],
        ),
      ),
    );
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Content Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          ElevatedButton.icon(
            onPressed: _showAddContentDialog,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Content', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _content.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No content found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add your first content to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _content.length,
                  itemBuilder: (context, index) {
                    final content = _content[index];
                    return _buildContentCard(content);
                  },
                ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: content['logoUrl'].isNotEmpty ? null : Colors.amber,
                    image: content['logoUrl'].isNotEmpty 
                      ? DecorationImage(
                          image: NetworkImage(content['logoUrl']),
                          fit: BoxFit.cover,
                        )
                      : null,
                  ),
                  child: content['logoUrl'].isNotEmpty 
                    ? null 
                    : const Icon(Icons.article, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                                                         child: Text(
                               content['title'],
                               style: const TextStyle(
                                 fontSize: 16,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.black,
                               ),
                             ),
                          ),
                          // PDF indicators
                          if (content['pdfUrl'].isNotEmpty || content['pyqUrl'].isNotEmpty || content['notesPdfUrl'].isNotEmpty || content['importantQuestionsPdfUrl'].isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.picture_as_pdf, size: 16, color: Colors.red.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PDFs',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'College: ${content['collegeName']} | Regulation: ${content['regulationName']} | Semester: ${content['semesterName']} | Branch: ${content['branchName']} | Subject: ${content['subjectName']} | Unit: ${content['unitName']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      // Show PDF count
                      if (content['pdfUrl'].isNotEmpty || content['pyqUrl'].isNotEmpty || content['notesPdfUrl'].isNotEmpty || content['importantQuestionsPdfUrl'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '📄 ${_getPdfCount(content)} PDF(s) available',
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditContentDialog(content);
                    } else if (value == 'delete') {
                      _deleteContent(content['id'], content['title']);
                    } else if (value == 'preview') {
                      _showContentPreview(content);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'preview',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Preview', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.black),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.blue[700],
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: Colors.blue[700],
                    tabs: const [
                      Tab(text: 'Notes'),
                      Tab(text: 'Important Questions'),
                      Tab(text: 'Previous Year Questions'),
                      Tab(text: 'MCQs'),
                    ],
                  ),
                                     SizedBox(
                     height: 200,
                     child: TabBarView(
                       children: [
                         _buildNotesTab(content),
                         _buildImportantQuestionsTab(content),
                         _buildPreviousYearQuestionsTab(content),
                         _buildMCQsTab(content),
                       ],
                     ),
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab(Map<String, dynamic> content) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content['title'] ?? 'Study Material',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (content['notesPdfUrl'].isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => _buildPdfViewer(content['notesPdfUrl'], 'Notes PDF'),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
              label: const Text('View Notes PDF', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            )
          else if (content['notesContent'].isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes Content:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(content['notesContent']),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Text(
                  'No notes available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImportantQuestionsTab(Map<String, dynamic> content) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content['title'] ?? 'Important Questions',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (content['importantQuestionsPdfUrl'].isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => _buildPdfViewer(content['importantQuestionsPdfUrl'], 'Important Questions PDF'),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf, color: Colors.green),
              label: const Text('View Important Questions PDF', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            )
          else if (content['importantQuestionsContent'].isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Important Questions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(content['importantQuestionsContent']),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sample Important Questions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. Define matrix and discuss its types.'),
                  const Text('2. Explain the properties of symmetric and skew-symmetric matrices.'),
                  const Text('3. Solve the system of equations using matrix method.'),
                  const Text('4. Find the rank of the given matrix.'),
                  const Text('5. Prove that similar matrices have the same eigenvalues.'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviousYearQuestionsTab(Map<String, dynamic> content) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content['title'] ?? 'Previous Year Questions',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              DropdownButton<String>(
                value: '2024',
                items: ['2024', '2023', '2022', '2021'].map((year) {
                  return DropdownMenuItem(value: year, child: Text(year));
                }).toList(),
                onChanged: (value) {},
              ),
              const SizedBox(width: 16),
              if (content['pyqUrl'].isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => _buildPdfViewer(content['pyqUrl'], 'Previous Year Questions PDF'),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.orange),
                  label: const Text('View PYQ PDF', style: TextStyle(color: Colors.black)),
                                style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
                ),
            ],
          ),
          if (content['pyqUrl'].isEmpty)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Text(
                  'No previous year questions available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMCQsTab(Map<String, dynamic> content) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content['title'] ?? 'Multiple Choice Questions',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (content['mcqContent'].isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MCQ Content:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(content['mcqContent']),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text(
                        'Submit Answers',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Which of the following is not a type of matrix?',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    title: const Text('Square matrix'),
                    value: 'square',
                    groupValue: null,
                    onChanged: (value) {},
                  ),
                  RadioListTile<String>(
                    title: const Text('Diagonal matrix'),
                    value: 'diagonal',
                    groupValue: null,
                    onChanged: (value) {},
                  ),
                  RadioListTile<String>(
                    title: const Text('Circular matrix'),
                    value: 'circular',
                    groupValue: null,
                    onChanged: (value) {},
                  ),
                  RadioListTile<String>(
                    title: const Text('Identity matrix'),
                    value: 'identity',
                    groupValue: null,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '2. The determinant of an identity matrix is:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    title: const Text('0'),
                    value: '0',
                    groupValue: null,
                    onChanged: (value) {},
                  ),
                  RadioListTile<String>(
                    title: const Text('1'),
                    value: '1',
                    groupValue: null,
                    onChanged: (value) {},
                  ),
                  RadioListTile<String>(
                    title: const Text('-1'),
                    value: '-1',
                    groupValue: null,
                    onChanged: (value) {},
                  ),
                  RadioListTile<String>(
                    title: const Text('Undefined'),
                    value: 'undefined',
                    groupValue: null,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text(
                        'Submit Answers',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showContentPreview(Map<String, dynamic> content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Preview: ${content['title']}'),
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
          body: _buildContentCard(content),
        ),
      ),
    );
  }

  // Helper method to count available PDFs
  int _getPdfCount(Map<String, dynamic> content) {
    int count = 0;
    if (content['pdfUrl'].isNotEmpty) count++;
    if (content['pyqUrl'].isNotEmpty) count++;
    if (content['notesPdfUrl'].isNotEmpty) count++;
    if (content['importantQuestionsPdfUrl'].isNotEmpty) count++;
    return count;
  }

  // PDF Card Widget for inline display
  Widget _buildPdfCard(BuildContext context, String pdfUrl, String title, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _buildPdfViewer(pdfUrl, title),
          ),
        );
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to view',
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PDF Viewer Widget
  Widget _buildPdfViewer(String pdfUrl, String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true, // Extend body behind the app bar
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          ),
        ),
        child: FutureBuilder<String>(
        future: _downloadPdf(pdfUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    const Icon(Icons.error, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                    Text('Error loading PDF: ${snapshot.error}', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      html.window.open(pdfUrl, '_blank');
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                    child: const Text('Open in Browser'),
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasData) {
            return PDFView(
              filePath: snapshot.data!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              defaultPage: 0,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
            );
          }
            return const Center(child: Text('No PDF data', style: TextStyle(color: Colors.white)));
        },
        ),
      ),
    );
  }

  // Download PDF from URL
  Future<String> _downloadPdf(String url) async {
    try {
      final response = await html.HttpRequest.request(url, responseType: 'blob');
      final blob = response.response as html.Blob;
      final reader = html.FileReader();
      
      final completer = Completer<String>();
      reader.onLoad.listen((event) {
        final result = reader.result as String;
        completer.complete(result);
      });
      
      reader.readAsDataUrl(blob);
      return completer.future;
    } catch (e) {
      throw Exception('Failed to download PDF: $e');
    }
  }
} 
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import 'save_json_in_storage.dart';

class JsonFilePickerPage extends StatefulWidget {
  const JsonFilePickerPage({Key? key}) : super(key: key);

  @override
  _JsonFilePickerPageState createState() => _JsonFilePickerPageState();
}

class _JsonFilePickerPageState extends State<JsonFilePickerPage> {
  File? _selectedFile;
  String? _fileName;
  String? _fileContent;
  bool _isLoading = false;

  final TextEditingController _nameSelector = TextEditingController();
  final TextEditingController _groupSelector = TextEditingController();

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();

        // Validate JSON
        jsonDecode(content);

        setState(() {
          _selectedFile = file;
          _fileName = path.basename(file.path);
          _fileContent = content;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveJson() async {
    if (_selectedFile == null || _fileName == null || _fileContent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid JSON file first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> jsonData = jsonDecode(_fileContent!);
      await MultiJsonStorage.saveJson(_nameSelector.text, jsonData,
          group: _groupSelector.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('JSON file saved successfully')),
      );
      Navigator.of(context).pop(); // Return to the previous page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving JSON: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameSelector
        .dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick JSON File'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Wrap the Column in SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _pickFile,
                child: const Text('Select JSON File'),
              ),
              const SizedBox(height: 16),
              if (_fileName != null)
                Text('Selected file: $_fileName',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              if (_fileContent != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_fileContent!),
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameSelector,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name des Songs',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _groupSelector,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Willst du eine Gruppe',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    _isLoading || _selectedFile == null ? null : _saveJson,
                child: const Text('Save JSON'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

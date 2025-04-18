import 'dart:convert';
import 'dart:io';
import 'package:P2pChords/dataManagment/Pages/edit/page.dart';
import 'package:P2pChords/dataManagment/data_class.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerUtil {
  /// Opens file picker and loads a song JSON file
  static Future<void> pickAndEditSongFile(
    BuildContext context, {
    String? groupName,
    VoidCallback? onSongAdded,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && context.mounted) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();

        // Validate JSON and convert to Song
        Map<String, dynamic> jsonData = jsonDecode(content);
        Song loadedSong = Song.fromMap(jsonData);

        // Navigate to the edit page with the loaded song
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SongEditPage(
                song: loadedSong,
                group: groupName,
              ),
            ),
          ).then((_) {
            // Call the callback after returning from edit page
            if (onSongAdded != null) {
              onSongAdded();
            }
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading file: ${e.toString()}')),
        );
      }
    }
  }
}

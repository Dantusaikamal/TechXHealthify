import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  // List to store the uploaded files.
  List<PlatformFile> uploadedFiles = [];

  // Function to pick file(s) from the device.
  Future<void> _pickFile() async {
    // Allow multiple file selection if needed.
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        // Add all picked files to the list.
        uploadedFiles.addAll(result.files);
      });
    } else {
      // User canceled the picker.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medical Records")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Button to trigger file upload.
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload File"),
            ),
            const SizedBox(height: 16),
            // Display the list of uploaded files.
            Expanded(
              child: uploadedFiles.isEmpty
                  ? const Center(child: Text("No files uploaded yet."))
                  : ListView.builder(
                      itemCount: uploadedFiles.length,
                      itemBuilder: (context, index) {
                        final file = uploadedFiles[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.insert_drive_file),
                            title: Text(file.name),
                            subtitle: Text("${file.size} bytes"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  uploadedFiles.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

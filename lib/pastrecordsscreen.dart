// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// class PastRecordsScreen extends StatefulWidget {
//   const PastRecordsScreen({super.key});

//   @override
//   _PastRecordsScreenState createState() => _PastRecordsScreenState();
// }

// class _PastRecordsScreenState extends State<PastRecordsScreen> {
//   List<Map<String, String>> _records = [];
//   List<File> _files = []; // To track file references for deletion

//   // Load saved records from local storage
//   Future<void> _loadSavedRecords() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final folder = Directory('${directory.path}/DailyTimeCapsule');
//     List<Map<String, String>> loadedRecords = [];
//     List<File> loadedFiles = [];

//     if (await folder.exists()) {
//       final files = folder.listSync();
//       for (var file in files) {
//         if (file is File) {
//           final content = await file.readAsString();
//           print('File content: $content'); // Debug print to check content
//           Map<String, String> record = _parseRecordContent(content);
//           loadedRecords.add(record);
//           loadedFiles.add(file); // Keep file reference for deletion
//         }
//       }

//       // Sort records by 'when' field (most recent first)
//       loadedRecords.sort((a, b) {
//         String? whenA = a['when'];
//         String? whenB = b['when'];

//         // Handle null cases: If either 'when' field is null, put those at the end of the list
//         if (whenA == null && whenB == null) return 0;
//         if (whenA == null) return 1; // Move nulls to the end
//         if (whenB == null) return -1;

//         DateTime dateA = DateTime.parse(whenA);
//         DateTime dateB = DateTime.parse(whenB);
//         return dateB.compareTo(dateA); // Sort by date (most recent first)
//       });
//     }

//     setState(() {
//       _records = loadedRecords;
//       _files = loadedFiles;
//     });
//   }

//   // Parse the record content into a map
//   Map<String, String> _parseRecordContent(String content) {
//     List<String> lines = content.split('\n');
//     Map<String, String> record = {};
//     for (var line in lines) {
//       if (line.startsWith('When:')) {
//         record['when'] = line.replaceFirst('When: ', '');
//       } else if (line.startsWith('Where:')) {
//         record['where'] = line.replaceFirst('Where: ', '');
//       } else if (line.startsWith('What:')) {
//         record['what'] = line.replaceFirst('What: ', '');
//       } else if (line.startsWith('How:')) {
//         record['how'] = line.replaceFirst('How: ', '');
//       } else if (line.startsWith('Why:')) {
//         record['why'] = line.replaceFirst('Why: ', '');
//       }
//     }
//     print('Parsed record: $record'); // Debug print to check parsed record
//     return record;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedRecords();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Past Records'),
//         backgroundColor: const Color(0xFFFDCFE8),
//       ),
//       body: _records.isEmpty
//           ? const Center(child: Text('No records found'))
//           : ListView.builder(
//               itemCount: _records.length,
//               itemBuilder: (context, index) {
//                 return _buildPhotocard(index, _records[index]);
//               },
//             ),
//     );
//   }

//   // Build the photocard for each record
//   Widget _buildPhotocard(int index, Map<String, String> record) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       color: const Color(0xFFFFF0F5),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // User avatar
//             const CircleAvatar(
//               radius: 50,
//               backgroundImage:
//                   AssetImage('assets/avatar.png'), // Placeholder for avatar
//             ),
//             const SizedBox(height: 16),

//             // When (Time of record)
//             _buildInfoRow(
//                 Icons.access_time, 'When', record['when'] ?? 'No data'),

//             // Where (Location of record)
//             _buildInfoRow(
//                 Icons.location_on, 'Where', record['where'] ?? 'No data'),

//             // What (Current task)
//             _buildInfoRow(Icons.edit, 'What', record['what'] ?? 'No data'),

//             // How (Difficulty level)
//             _buildInfoRow(Icons.assessment, 'How', record['how'] ?? 'No data'),

//             // Why (Reason)
//             _buildInfoRow(
//                 Icons.question_answer, 'Why', record['why'] ?? 'No data'),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper method to create a row for the photocard
//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: const Color(0xFFFDCFE8),
//             radius: 18,
//             child: Icon(icon, color: Colors.white),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             '$label: $value',
//             style: const TextStyle(fontSize: 16, color: Colors.black87),
//           ),
//         ],
//       ),
//     );
//   }
// }

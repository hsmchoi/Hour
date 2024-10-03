import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:confetti/confetti.dart'; // Confetti 패키지 임포트

void main() {
  runApp(const DailyTimeCapsuleApp());
}

class DailyTimeCapsuleApp extends StatelessWidget {
  const DailyTimeCapsuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Time Capsule',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFFDEEF4),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const RecordEntryScreen(),
    );
  }
}

class RecordEntryScreen extends StatefulWidget {
  const RecordEntryScreen({super.key});

  @override
  _RecordEntryScreenState createState() => _RecordEntryScreenState();
}

class _RecordEntryScreenState extends State<RecordEntryScreen> {
  String? currentTime;
  String? currentLocation;
  String? selectedDifficulty;
  String? selectedWhyKeyword;
  TextEditingController whatController = TextEditingController();

  List<String> difficultyLevels = ['5', '4', '3', '2', '1'];
  List<String> whyKeywords = ['일정', '운동', '공부', '취미', '기타'];

  // Confetti Controller 추가
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3)); // 3초 지속
    _setCurrentTime();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _confettiController.dispose(); // 메모리 해제
    super.dispose();
  }

  // 현재 시간을 가져오는 메소드
  void _setCurrentTime() {
    DateTime now = DateTime.now();
    setState(() {
      currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    });
  }

  // 현재 위치(GPS)를 가져오는 메소드
  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    setState(() {
      currentLocation =
          '위도: ${locationData.latitude}, 경도: ${locationData.longitude}';
    });
  }

  // 로컬 저장소에 파일을 저장하는 메소드
  Future<void> _saveToFile(String content) async {
    final directory = await getApplicationDocumentsDirectory(); // 저장 폴더 가져오기
    final folder = Directory('${directory.path}/DailyTimeCapsule');
    if (!(await folder.exists())) {
      await folder.create(recursive: true); // 폴더가 없으면 생성
    }

    final filePath =
        '${folder.path}/record_${DateTime.now().millisecondsSinceEpoch}.txt'; // 파일 이름 지정
    final file = File(filePath);
    await file.writeAsString(content); // 파일에 기록 내용 저장
    print('기록이 저장되었습니다: $filePath');
  }

  // 저장 성공 시 보여줄 다이얼로그
  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 외부 클릭 시 닫히지 않음
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('저장 완료!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('기록이 성공적으로 저장되었습니다!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }

  // 작성 내용을 저장하는 메소드
  void _saveData() async {
    String content = '''
    When: $currentTime
    Where: $currentLocation
    What: ${whatController.text}
    How: $selectedDifficulty
    Why: $selectedWhyKeyword
    ''';
    await _saveToFile(content);

    _confettiController.play(); // Confetti 애니메이션 실행
    _showSuccessDialog(); // 성공 다이얼로그 표시
  }

  // 하트 아이콘 클릭 시 저장된 기록 목록을 보는 화면으로 이동
  void _navigateToRecordsScreen() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const RecordsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDCFE8),
        title: const Text('Hour', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.white),
          onPressed: _navigateToRecordsScreen, // 하트 버튼 클릭 시 기록 화면으로 이동
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            // 스크롤을 추가하는 부분
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // User Avatar
                  const Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/avatar.png'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // When (현재 시간)
                  _buildDisplayField('When', currentTime ?? '시간 가져오는 중...'),

                  // Where (현재 위치)
                  _buildDisplayField(
                      'Where', currentLocation ?? '위치 가져오는 중...'),

                  // What (사용자가 기록하는 부분)
                  _buildTextInputField('What (현재 하는 일)', whatController),

                  // How (난이도 설정)
                  _buildDropdownField(
                      'How (난이도 선택)', difficultyLevels, selectedDifficulty,
                      (newValue) {
                    setState(() {
                      selectedDifficulty = newValue;
                    });
                  }),

                  // Why (사용자가 미리 지정한 키워드 선택)
                  _buildDropdownField(
                      'Why (이유 선택)', whyKeywords, selectedWhyKeyword,
                      (newValue) {
                    setState(() {
                      selectedWhyKeyword = newValue;
                    });
                  }),

                  const SizedBox(height: 20),

                  // 저장 버튼 추가
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveData, // 저장 버튼 클릭 시 데이터를 저장
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('저장'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // 저장 버튼 색상
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Emoticon Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEmoticonButton(Icons.favorite),
                      _buildEmoticonButton(Icons.thumb_up),
                      _buildEmoticonButton(Icons.thumb_down),
                      _buildEmoticonButton(Icons.mood),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Confetti 애니메이션
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, // 모든 방향으로 날림
              shouldLoop: false, // 반복 여부
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 기존 디자인 적용된 표시용 필드 (When, Where)
  Widget _buildDisplayField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFFDCFE8),
            child: Icon(Icons.access_time, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // 기존 디자인 적용된 텍스트 입력 필드 (What)
  Widget _buildTextInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFFDCFE8),
            child: Icon(Icons.edit, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Colors.black87),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 기존 디자인 적용된 드롭다운 필드 (How, Why)
  Widget _buildDropdownField(String label, List<String> items,
      String? selectedItem, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFFDCFE8),
            child: Icon(Icons.list, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedItem,
              hint: Text(label),
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmoticonButton(IconData iconData) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: const Color(0xFFFDCFE8),
      child: Icon(iconData, color: Colors.white, size: 30),
    );
  }
}

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  // 로컬에 저장된 기록들을 불러오는 함수
  Future<List<String>> _getSavedRecords() async {
    final directory = await getApplicationDocumentsDirectory();
    final folder = Directory('${directory.path}/DailyTimeCapsule');
    List<String> records = [];
    if (await folder.exists()) {
      final files = folder.listSync();
      for (var file in files) {
        if (file is File) {
          final content = await file.readAsString();
          records.add(content);
        }
      }
    }
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDCFE8),
        title:
            const Text('Past Records', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: _getSavedRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading records'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No records found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Record ${index + 1}'),
                  subtitle: Text(snapshot.data![index]),
                );
              },
            );
          }
        },
      ),
    );
  }
}

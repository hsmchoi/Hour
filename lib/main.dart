import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

void main() {
  runApp(const DailyTimeCapsuleApp());
}

class DailyTimeCapsuleApp extends StatelessWidget {
  const DailyTimeCapsuleApp({Key? key}) : super(key: key);

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
  const RecordEntryScreen({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _setCurrentTime();
    _getCurrentLocation();
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
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      currentLocation =
          '위도: ${_locationData.latitude}, 경도: ${_locationData.longitude}';
    });
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
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Avatar
            Center(
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
            ),
            const SizedBox(height: 16),
            
            // When (현재 시간)
            _buildDisplayField('When', currentTime ?? '시간 가져오는 중...'),

            // Where (현재 위치)
            _buildDisplayField('Where', currentLocation ?? '위치 가져오는 중...'),

            // What (사용자가 기록하는 부분)
            _buildTextInputField('What (현재 하는 일)', whatController),

            // How (난이도 설정)
            _buildDropdownField('How (난이도 선택)', difficultyLevels, selectedDifficulty, (newValue) {
              setState(() {
                selectedDifficulty = newValue;
              });
            }),

            // Why (사용자가 미리 지정한 키워드 선택)
            _buildDropdownField('Why (이유 선택)', whyKeywords, selectedWhyKeyword, (newValue) {
              setState(() {
                selectedWhyKeyword = newValue;
              });
            }),

            const SizedBox(height: 20),
            
            // Push Notification Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle push notifications
                },
                icon: const Icon(Icons.notifications, color: Colors.white),
                label: const Text('Push Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFAAACF),
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
  Widget _buildDropdownField(
      String label, List<String> items, String? selectedItem, ValueChanged<String?> onChanged) {
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

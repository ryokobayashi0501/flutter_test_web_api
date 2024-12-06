import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Mains/round_handler.dart';
import 'package:flutter_web_api/Models/course_model.dart';
import 'package:flutter_web_api/Models/hole_model.dart'; // Holeモデルをインポート
import 'package:flutter_web_api/Rounds/add_shot.dart'; // AddShotをインポート

class AddRound extends StatefulWidget {
  final int userId;

  const AddRound({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddRound> createState() => _AddRoundState();
}

class _AddRoundState extends State<AddRound> {
  ApiHandler apiHandler = ApiHandler();
  RoundHandler roundHandler = RoundHandler();
  List<Course> courses = [];
  List<Course> filteredCourses = [];
  String searchTerm = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourses(); // Fetch all courses
  }

  // Fetch all courses
  void fetchCourses() async {
    try {
      setState(() {
        isLoading = true;
      });
      courses = await apiHandler.getAllCourses();
      setState(() {
        filteredCourses = courses;
      });
    } catch (e) {
      print("Error fetching courses: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Search functionality
  void onSearchChanged(String value) {
    setState(() {
      searchTerm = value.toLowerCase();
      filteredCourses = courses
          .where((course) => course.courseName.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  // Add round for a user
  // Add round for a user
// Add round for a user
void selectCourseForUser(Course course) async {
  try {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    // コースのホール情報を取得（必要なら `add_shot` に渡すため）
    List<Hole> holes = await apiHandler.getHolesByCourseId(course.courseId!);

    // ラウンドを追加する（RoundHoles はここでは追加しない）
    final response = await roundHandler.addRoundForUser(widget.userId, course.courseId!);

    if (response.statusCode == 201) {
      // 新しく作成されたラウンドのIDを取得
      final responseData = json.decode(response.body);
      int roundId = responseData['roundId'];

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Round added successfully!')),
      );

      // AddShot画面に遷移（各ホールのショット詳細を入力）
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddShot(
            userId: widget.userId,
            roundId: roundId,
            holes: holes, 
            courseName: course.courseName,
          ),
        ),
      );
    } else {
      // エラー処理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add round: ${response.statusCode} - ${response.reasonPhrase}\n${response.body}'),
        ),
      );
    }
  } catch (e) {
    print("Error adding round: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error adding round')),
    );
  } finally {
    setState(() {
      isLoading = false; // Hide loading indicator
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Round"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Search for a course",
                  labelStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onChanged: onSearchChanged, // Update filteredCourses based on input
              ),
            ),
            const SizedBox(height: 20),

            // Course list or loading indicator
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                  )
                : Expanded(
                    child: filteredCourses.isEmpty
                        ? const Center(
                            child: Text(
                              "No courses found.",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredCourses.length,
                            itemBuilder: (context, index) {
                              final course = filteredCourses[index];
                              return Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Image.network(
                                    course.imageUri,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(
                                    course.courseName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text("Select"),
                                    onPressed: () => selectCourseForUser(course),
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

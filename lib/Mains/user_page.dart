import 'package:flutter/material.dart';
import 'package:flutter_web_api/Models/DTOs/shot_dto_model.dart';
import 'package:flutter_web_api/Models/round_hole_model.dart';
import 'package:flutter_web_api/Models/user_model.dart';
import 'package:flutter_web_api/Models/round_model.dart';
import 'package:flutter_web_api/Rounds/golf_stats%20.dart';
import 'package:flutter_web_api/Users/edit_page.dart';
import 'package:flutter_web_api/Mains/api_handler.dart';
import 'package:flutter_web_api/Mains/round_handler.dart';
import 'package:flutter_web_api/Rounds/add_round.dart';
import 'package:flutter_web_api/Course/add_course.dart';
import 'package:flutter_web_api/Course/edit_course.dart';

class UserPage extends StatefulWidget {
  final User user;

  const UserPage({Key? key, required this.user}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  RoundHandler roundHandler = RoundHandler();
  ApiHandler apiHandler = ApiHandler();
  late List<Round> rounds = [];
  bool isLoading = true;
  String filterOption = "All"; // フィルタリングオプション

  @override
  void initState() {
    super.initState();
    getRounds(); // ラウンドデータを取得
  }

  // ラウンドデータを取得する
  void getRounds() async {
    setState(() {
      isLoading = true; // ローディング中
    });
    rounds = await roundHandler.getRoundsByUserId(widget.user.userId);
    setState(() {
      isLoading = false; // ローディング終了
    });
  }

  // ラウンドデータの削除
  void deleteRound(int roundId) async {
    final response = await roundHandler.deleteRound(roundId);
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Round deleted successfully!')),
      );
      getRounds(); // データを再取得
    } else {
      _showErrorDialog(
        "Failed to delete round: ${response.statusCode} - ${response.reasonPhrase}",
      );
    }
  }

  // エラーダイアログ
  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // 並び替えロジック
  List<Round> getFilteredRounds() {
    if (filterOption == "All") {
      return rounds;
    } else if (filterOption == "Latest") {
      return List.from(rounds)..sort((a, b) => b.roundDate.compareTo(a.roundDate));
    } else if (filterOption == "Course") {
      return List.from(rounds)..sort((a, b) => a.courseName.compareTo(b.courseName));
    }
    return rounds;
  }

  // ページ遷移メソッド
  void navigateToAddRound() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRound(userId: widget.user.userId),
      ),
    );
    if (result != null) {
      getRounds(); // ラウンド追加後に再取得
    }
  }

  void navigateToAddCourse() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCourse(userId: widget.user.userId),
      ),
    );
    getRounds(); // コース追加後に再取得
  }

  void navigateToEditCourse(Round round) async {
    try {
      // コースIDを使用して詳細を取得
      final course = await apiHandler.getCourseById(round.courseId);

      if (course != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCoursePage(course: course),
          ),
        );
        getRounds(); // 編集後にラウンドを再取得
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load course details.')),
        );
      }
    } catch (e) {
      print("Error navigating to edit course: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while editing the course.')),
      );
    }
  }


  // ラウンド詳細画面へのナビゲーション
void navigateToGolfStats(Round round) async {
  try {
  final List<ShotDto> shots = await roundHandler.getShotsByRoundId(widget.user.userId, round.roundId);
  final List<Map<String, dynamic>> shotData = shots.map((shot) => shot.toJson()).toList();
  // RoundHolesデータの取得
    final List<RoundHole> roundHoles = await roundHandler.getRoundHolesForUser(widget.user.userId, round.roundId);
    final List<Map<String, dynamic>> roundHoleData = roundHoles.map((hole) => hole.toJson()).toList();

  // データが空の場合のエラーハンドリング
  if (shotData.isEmpty || roundHoleData.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No data found for this round.")),
    );
    return;
  }

  if (!mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GolfStats(
        shotData: shotData,
        roundHoleData: roundHoleData,
      ),
    ),
  );
  } catch (e) {
    // エラー発生時のハンドリング
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to load data: $e")),
    );
  }
}



// 全ラウンドの統計データを計算してウィジェットを生成
Widget buildStatsHeader() {
  if (rounds.isEmpty) {
    print("Rounds data is empty.");
    return const SizedBox();
  }

  // デバッグ用ログ
  print("Rounds: ${rounds.map((round) => round.toJson()).toList()}");

  // 全ラウンドの統計情報を集計
  int totalScore = rounds.fold<int>(
      0, (sum, round) => sum + round.roundHoles.fold<int>(0, (holeSum, hole) => holeSum + hole.stroke));
  int totalFairways = rounds.fold<int>(
      0, (sum, round) => sum + round.roundHoles.where((hole) => hole.fairwayHit).length);
  int totalGreens = rounds.fold<int>(
      0, (sum, round) => sum + round.roundHoles.where((hole) => hole.greenInRegulation).length);

  if (rounds.isEmpty || totalFairways == 0 || totalGreens == 0) {
    return const Text("No statistics available.");
  }

  double fairwayHitRate = totalFairways /
          rounds.fold<int>(0, (sum, round) => sum + round.roundHoles.length) *
          100;
  double greenInRegulationRate = totalGreens /
          rounds.fold<int>(0, (sum, round) => sum + round.roundHoles.length) *
          100;

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Total Score: $totalScore",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          "Fairway Hit %: ${fairwayHitRate.toStringAsFixed(1)}%",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          "Green in Regulation %: ${greenInRegulationRate.toStringAsFixed(1)}%",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final filteredRounds = getFilteredRounds();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.username,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 11, 11, 11),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: getRounds, // ラウンドデータのリフレッシュ
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                filterOption = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "All", child: Text("All")),
              const PopupMenuItem(value: "Latest", child: Text("Latest")),
              const PopupMenuItem(value: "Course", child: Text("By Course")),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 11, 11, 11),
              ),
              child: Center(
                child: Text(
                  widget.user.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('User Info'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPage(user: widget.user),
                  ),
                ).then((_) {
                  getRounds(); // ユーザー情報更新後に再取得
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Course'),
              onTap: () {
                navigateToAddCourse();
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst); // メインページに戻る
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredRounds.isEmpty
              ? const Center(child: Text("No rounds found."))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 1行に2列を表示
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.9, // 枠の縦横比を小さくする
                  ),
                  itemCount: filteredRounds.length,
                  itemBuilder: (context, index) {
                    final round = filteredRounds[index];
                    return GestureDetector(
                      onTap: () => navigateToGolfStats(round),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 枠を角丸にする
                        ),
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 画像部分
                            AspectRatio(
                              aspectRatio: 16 / 9, // 画像を16:9の比率で表示
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                child: Image.network(
                                  round.imageUri,
                                  fit: BoxFit.cover, // 画像を枠にフィットさせる
                                ),
                              ),
                            ),
                            // テキスト部分
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          round.courseName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          deleteRound(round.roundId);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Played on: ${round.roundDate.toLocal()}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 11, 11, 11),
        foregroundColor: Colors.white,
        onPressed: navigateToAddRound,
        child: const Icon(Icons.add),
      ),
    );
  }
}

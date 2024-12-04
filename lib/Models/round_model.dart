class Round {
  final int roundId;
  final int courseId;
  final int userId;
  final String courseName;
  final String imageUri; // 画像URIを追加
  final DateTime roundDate; // 日付を保持

  const Round({
    required this.roundId,
    required this.courseId,
    required this.userId,
    required this.courseName,
    required this.imageUri, // コンストラクタに追加
    required this.roundDate, // コンストラクタに追加
  });

  // デフォルト値を設定する場合、constではなく通常のコンストラクタを使用
  Round.empty()
      : roundId = 0,
        courseId = 0,
        userId = 0,
        courseName = '',
        imageUri = '', // デフォルト値を設定
        roundDate = DateTime(2000, 1, 1); // デフォルト値を設定

  factory Round.fromJson(Map<String, dynamic> json) => Round(
        roundId: json['roundId'],
        courseId: json['courseId'],
        userId: json['userId'],
        courseName: json['courseName'],
        imageUri: json['imageUri'], // JSONからimageUriを取得
        roundDate: DateTime.parse(json['roundDate']), // JSONから日付をパース
      );

  Map<String, dynamic> toJson() => {
        "roundId": roundId,
        "courseId": courseId,
        "userId": userId,
        "courseName": courseName,
        "imageUri": imageUri, // JSONにimageUriを含める
        "roundDate": roundDate.toIso8601String(), // 日付をISO形式でエンコード
      };
}

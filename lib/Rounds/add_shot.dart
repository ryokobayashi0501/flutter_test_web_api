import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_web_api/Mains/round_handler.dart';
import 'package:flutter_web_api/Models/DTOs/round_hole_dto_model.dart';
import 'package:flutter_web_api/Models/DTOs/shot_dto_model.dart';
import 'package:flutter_web_api/Models/shot_model.dart';
import 'package:flutter_web_api/Models/hole_model.dart';
import 'package:flutter_web_api/Models/Enums/BallDirection.dart';
import 'package:flutter_web_api/Models/Enums/BallHeight.dart';
import 'package:flutter_web_api/Models/Enums/ClubUsed.dart';
import 'package:flutter_web_api/Models/Enums/Lie.dart';
import 'package:flutter_web_api/Models/Enums/ShotResult.dart';
import 'package:flutter_web_api/Models/Enums/ShotType.dart';
import 'package:flutter_web_api/Models/Enums/PuttBallDirection.dart';
import 'package:flutter_web_api/Models/Enums/PuttResult.dart';
import 'package:flutter_web_api/Models/Enums/PuttType.dart';

class AddShot extends StatefulWidget {
  final int userId;
  final int roundId;
  final List<Hole> holes;
  final String courseName;

  const AddShot({
    Key? key,
    required this.userId,
    required this.roundId,
    required this.holes,
    required this.courseName,
  }) : super(key: key);

  @override
  _AddShotState createState() => _AddShotState();
}

class _AddShotState extends State<AddShot> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int currentHoleIndex = 0;
  int score = 1;
  int putts = 0;
  List<Map<String, dynamic>> shots = [];
  String weatherCondition = "Clear";
  bool _isSaving = false; // データ保存中かどうかを管理するフラグ
  bool _isHoleDataSaved = false; // ホールデータが保存されたかどうかを管理するフラグ
  // ここでholeShotsを定義する
  Map<int, List<Map<String, dynamic>>> holeShots = {}; // 各ホールのショットデータを保持する

  @override
  void initState() {
    super.initState();
    _generateShots();
  }

  @override
Widget build(BuildContext context) {
  Hole currentHole = widget.holes[currentHoleIndex];

  return WillPopScope(
    onWillPop: () async {
      return await _onWillPop();
    },
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            // バックボタン押下時の処理
            bool canPop = await _onWillPop();
            if (canPop) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.courseName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Par ${currentHole.par} || ${currentHole.yardage} Yards',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ホールナビゲーションドット
            Center(
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.holes.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                        // 現在のホールのデータを保存
                          holeShots[currentHoleIndex] = List<Map<String, dynamic>>.from(shots);

                        // 新しいホールに移動
                        currentHoleIndex = index;

                              // 新しいホールのデータを生成またはロード
                        _generateShots();

                            // 保存済みフラグをリセット
                        _isHoleDataSaved = false;
                        });
                      },

                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: currentHoleIndex == index ? Colors.orange : Colors.grey,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 天候の選択
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Weather Condition'),
              value: weatherCondition,
              onChanged: (String? value) {
                setState(() {
                  weatherCondition = value!;
                });
              },
              items: ['Clear', 'Rain', 'Windy', 'Cloudy', 'Foggy']
                  .map((String condition) => DropdownMenuItem(value: condition, child: Text(condition)))
                  .toList(),
            ),
            const SizedBox(height: 10),
            // 合計打数とパット数の入力
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Score'),
                        keyboardType: TextInputType.number,
                        initialValue: score.toString(),
                        validator: (String? value) {
                          if (value == null || value.isEmpty || int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onChanged: (String value) {
                          setState(() {
                            score = int.tryParse(value) ?? 1;
                            _generateShots();
                            _isHoleDataSaved = false; // スコアが変更されたときに、保存済みフラグをリセット
                          });
                        },
                      ),
                      // パット数の入力
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Putts'),
                        keyboardType: TextInputType.number,
                        initialValue: putts.toString(),
                        validator: (String? value) {
                          if (value == null || value.isEmpty || int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onChanged: (String value) {
                          setState(() {
                            putts = int.tryParse(value) ?? 0;
                            if (putts > score) {
                              putts = score; // パット数がスコアを超えないようにする
                            }
                            _generateShots(); // ショットを生成しなおす
                            _isHoleDataSaved = false; // パット数が変更されたときに、保存済みフラグをリセット
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ...shots.map((Map<String, dynamic> shot) {
                        return _buildShotInputForm(shot);
                      }).toList(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isSaving || _isHoleDataSaved ? null : _submitHole, // 保存中または保存済みであればボタンを無効化
                        child: _isSaving
                            ? const CircularProgressIndicator() // 保存中はインジケーターを表示
                            : const Text('Save Hole Data'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
  );
  }

  // 戻るときの処理
Future<bool> _onWillPop() async {
  // 全ホールが入力済みか判定
  List<int> missingHoles = [];
  for (int i = 0; i < widget.holes.length; i++) {
    if (!holeShots.containsKey(i) || (holeShots[i]?.isEmpty ?? true)) {
      missingHoles.add(i + 1); // ホール番号は+1してユーザーに表示
    }
  }

  // 全ホール入力済みなら、ダイアログなしで戻ることを許可
  if (missingHoles.isEmpty) {
    return true;
  }

  // 未登録ホールがある場合、ダイアログ表示
  String missingHolesString = missingHoles.map((h) => 'Hole$h').join(', ');
  bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('There are unregistered holes'),
        content: Text('$missingHolesString is not registered. \nIf you return, the round will be deleted. Is this OK?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // キャンセル
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // OKの場合ラウンド削除処理
              bool deleteSuccess = await _deleteRoundAndPop();
              Navigator.of(context).pop(deleteSuccess);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}

Future<bool> _deleteRoundAndPop() async {
  // ラウンド削除処理を行う
  RoundHandler roundHandler = RoundHandler();
  final response = await roundHandler.deleteRound(widget.roundId);
  if (response.statusCode >= 200 && response.statusCode <= 299) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Round deleted successfully!')),
    );
    // 削除後に前の画面に戻る
    Navigator.of(context).pop();
    return true;
  } else {
    // 削除失敗時のエラーダイアログ（任意）
    _showErrorDialog("Failed to delete round: ${response.statusCode} - ${response.reasonPhrase}");
    return false;
  }
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

 // ショットを自動生成するメソッド (更新済み)
void _generateShots() {
  if (!_isHoleDataSaved) {
    shots.clear();
    int totalShots = score;
    int puttStartIndex = totalShots - putts + 1;

    for (int shotIndex = 1; shotIndex <= totalShots; shotIndex++) {
      String shotType = (shotIndex == 1)
          ? 'tee'
          : (shotIndex >= puttStartIndex && putts > 0)
              ? 'putt'
              : 'shot';

      shots.add({
        'shotNumber': shotIndex,
        'type': shotType,
        'distance': '',
        'remainingDistance': (shotIndex == totalShots && shotType == 'putt') ? '0' : '',
        'clubUsed': shotType == 'putt' ? ClubUsed.Putter : null,
        'ballDirection': null,
        'shotType': shotType == 'putt' ? PuttType.StraightPutt : null,
        'puttType': shotType == 'putt' ? PuttType.StraightPutt : null,
        'ballHeight': shotType == 'putt' ? BallHeight.Default : null,
        'lie': shotType == 'tee' ? Lie.Tee : (shotType == 'putt' ? Lie.Green : null),
        'shotResult': null,
        'notes': '',
      });
    }

    // 保存済みデータをholeShotsに保存
    holeShots[currentHoleIndex] = List<Map<String, dynamic>>.from(shots);
  } else {
    // 保存されたデータをロードする
    shots = List<Map<String, dynamic>>.from(holeShots[currentHoleIndex]!);
  }
}

  // ショットごとの入力フォームを生成
Widget _buildShotInputForm(Map<String, dynamic> shot) {
  bool isPutter = shot['type'] == 'putt';
  bool isTeeShot = shot['type'] == 'tee';

  // 次のショットがパットかどうかを判定
  // 現在のショットのインデックスを取得
  int currentIndex = shots.indexOf(shot);
  bool nextShotIsPutt = false;
  if (currentIndex < shots.length - 1) {
    // 次のショットが存在する場合、そのショットがputtかどうかを確認
    nextShotIsPutt = (shots[currentIndex + 1]['type'] == 'putt');
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Divider(),
      Text(
        '${isTeeShot ? "TEE SHOT" : isPutter ? "PUTT" : "SHOT"} ${shot['shotNumber']}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      // Distance
      TextFormField(
        decoration: InputDecoration(labelText: 'Distance (${isPutter ? "feet" : "yards"})'),
        keyboardType: TextInputType.number,
        initialValue: shot['distance'],
        validator: (String? value) {
          if (value == null || int.tryParse(value) == null) {
            return 'Please enter a valid distance';
          }
          return null;
        },
        onChanged: (String value) {
          shot['distance'] = value;
        },
      ),
      // Remaining Distance
      // パットの場合またはパット直前の場合はfeet、それ以外はyards
      if (!isPutter || shot['shotNumber'] != shots.length)
        TextFormField(
          decoration: InputDecoration(
            // ここでnextShotIsPuttを用いて単位をfeetにするかyardsにするかを判断
            labelText: 'Remaining Distance (${(isPutter || nextShotIsPutt) ? "feet" : "yards"})',
          ),
          keyboardType: TextInputType.number,
          initialValue: shot['remainingDistance'],
          validator: (String? value) {
            if (value == null || int.tryParse(value) == null) {
              return 'Please enter a valid remaining distance';
            }
            return null;
          },
          onChanged: (String value) {
            shot['remainingDistance'] = value;
          },
        ),
      /// Club Used (puttingの場合はPutterと自動設定)
      if (!isPutter)
        DropdownButtonFormField<ClubUsed>(
          decoration: const InputDecoration(labelText: 'Club Used'),
         value: shot['clubUsed'] as ClubUsed?,
         onChanged: (ClubUsed? value) {
            setState(() {
              shot['clubUsed'] = value ?? ClubUsed.Driver; // 値がnullでないことを保証する
            });
          },
          items: ClubUsed.values.map((ClubUsed club) {
            return DropdownMenuItem<ClubUsed>(
              value: club,
              child: Text(club.toString().split('.').last),
          );
        }).toList(),
      ),
      if (isPutter)
        DropdownButtonFormField<ClubUsed>(
          decoration: const InputDecoration(labelText: 'Club Used'),
          value: ClubUsed.Putter, // 必ずPutterを設定
          onChanged: null,  // puttingの場合は選択を許容しない
          items: [ClubUsed.Putter].map((ClubUsed club) {
            return DropdownMenuItem<ClubUsed>(
              value: club,
             child: Text(club.toString().split('.').last),
           );
          }).toList(),
        ),



//bool isPutter = shot['type'] == 'putt'; // shot['type']やclubUsedなどでisPutterを判定

DropdownButtonFormField<Enum>(
  decoration: const InputDecoration(labelText: 'Ball Direction'),
  // valueを現在の状態に合わせてEnum型にキャスト
  value: shot['ballDirection'] as Enum?,
  onChanged: (Enum? value) {
    setState(() {
      shot['ballDirection'] = value;

      // Score、Puttsから初期状態に戻す
      _generateShots();

      // 現在のShotを取得
      int currentIndex = shots.indexWhere((s) => s['shotNumber'] == shot['shotNumber']);
      var currentShot = shots.firstWhere(
        (s) => s['shotNumber'] == shot['shotNumber'],
        orElse: () => <String, dynamic>{},
      );

      if (currentShot.isEmpty) return;

      currentShot['ballDirection'] = value;

      if (value != null) {
        // Puttの場合はPuttBallDirection、通常ショットはBallDirectionで条件分岐
        if (isPutter && value is PuttBallDirection) {
          // PuttBallDirectionに応じた処理
          switch (value) {
            case PuttBallDirection.ShortofHole:
              currentShot['lie'] = Lie.Green;
              break;
            // 他のPuttBallDirectionケース
            default:
              currentShot['lie'] = Lie.Green;
          }
        } else if (!isPutter && value is BallDirection) {
          // 通常ショットのBallDirectionに応じた処理
          switch (value) {
            case BallDirection.Fairway:
              currentShot['lie'] = Lie.Fairway;
              break;
            case BallDirection.LeftOB:
            case BallDirection.RightOB:
              {
                int idx = shots.indexOf(currentShot);
                if (idx + 1 < shots.length) {
                  shots.removeAt(idx + 1);
                }
                if (idx + 1 < shots.length) {
                  shots[idx + 1]['lie'] = Lie.Tee;
                }
                break;
              }
            case BallDirection.WaterHazardLeft:
            case BallDirection.WaterHazardRight:
            case BallDirection.WaterHazardFront:
              {
                int idx = shots.indexOf(currentShot);
                if (idx + 1 < shots.length) {
                  shots.removeAt(idx + 1);
                }
                if (idx + 1 < shots.length) {
                  shots[idx + 1]['lie'] = Lie.Rough;
                }
                break;
              }
            // 他のBallDirectionケース
            default:
              currentShot['lie'] = null;
          }
        }
      }
    });
  },
  items: isPutter
    ? PuttBallDirection.values.map((PuttBallDirection direction) {
        return DropdownMenuItem<Enum>(
          value: direction,
          child: Text(direction.toString().split('.').last),
        );
      }).toList()
    : BallDirection.values.map((BallDirection direction) {
        return DropdownMenuItem<Enum>(
          value: direction,
          child: Text(direction.toString().split('.').last),
        );
      }).toList(),
),



      // Shot Type
      DropdownButtonFormField(
        decoration: const InputDecoration(labelText: 'Shot Type'),
        value: shot['shotType'],
        onChanged: (value) {
          setState(() {
            shot['shotType'] = value;
          });
        },
        items: isPutter
            ? PuttType.values.map((PuttType type) {
                return DropdownMenuItem<PuttType>(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList()
            : ShotType.values.map((ShotType type) {
                return DropdownMenuItem<ShotType>(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
      ),
      // Ball Height (putting の場合は N/A を設定)
      DropdownButtonFormField<BallHeight>(
        decoration: const InputDecoration(labelText: 'Ball Height'),
        value: isPutter ? BallHeight.Default : shot['ballHeight'] as BallHeight?,
        onChanged: (BallHeight? value) {
          setState(() {
            shot['ballHeight'] = value;
          });
        },
        items: BallHeight.values.map((BallHeight height) {
          return DropdownMenuItem<BallHeight>(
            value: height,
            child: Text(height == BallHeight.Default ? 'N/A' : height.toString().split('.').last),
          );
        }).toList(),
      ),
      // Lie
      DropdownButtonFormField<Lie>(
        decoration: const InputDecoration(labelText: 'Lie'),
        value: _getLieValueForShot(shot),
        onChanged: (Lie? value) {
          setState(() {
            shot['lie'] = value;
          });
        },
        items: _getLieItemsForShot(shot),
      ),
      // Shot Result
      DropdownButtonFormField<Enum>(
        decoration: const InputDecoration(labelText: 'Shot Result'),
        value: shot['shotResult'] as Enum?,
        onChanged: (Enum? value) {
         setState(() {
           shot['shotResult'] = value;
         });
        },
        items: isPutter
         ? PuttResult.values.map((PuttResult type) {
              return DropdownMenuItem<Enum>(
               value: type,
               child: Text(type.toString().split('.').last),
              );
            }).toList()
         : ShotResult.values.map((ShotResult type) {
             return DropdownMenuItem<Enum>(
                value: type,
               child: Text(type.toString().split('.').last),
              );
          }).toList(),
      ),


      // Notes
      TextFormField(
        decoration: const InputDecoration(labelText: 'Notes'),
        initialValue: shot['notes'],
        onChanged: (value) {
          shot['notes'] = value;
        },
      ),
    ],
  );
}


  // ショットに応じて適切な初期値を取得するメソッド
  Lie? _getLieValueForShot(Map<String, dynamic> shot) {
    bool isTeeShot = shot['shotNumber'] == 1; // 1打目はティーショット
    bool isPutter = shot['type'] == 'putt';

    if (isTeeShot) {
      return Lie.Tee;
    } else if (isPutter) {
      return Lie.Green; // パットの場合はデフォルトでGreenを設定
    } else {
      return shot['lie'] as Lie?; // その他のショットでは既存の値を使用
    }
  }

  // ショットに応じて適切な選択肢を取得するメソッド
  List<DropdownMenuItem<Lie>> _getLieItemsForShot(Map<String, dynamic> shot) {
    bool isTeeShot = shot['shotNumber'] == 1;
    bool isPutter = shot['type'] == 'putt';

    if (isTeeShot) {
      // ティーショットの場合は選択肢はTeeのみ
      return [Lie.Tee].map((Lie lie) {
        return DropdownMenuItem<Lie>(
          value: lie,
          child: Text(lie.toString().split('.').last),
        );
      }).toList();
    } else if (isPutter) {
      // パットの場合はGreenまたはFringeのみ
      return [Lie.Green, Lie.Fringe].map((Lie lie) {
        return DropdownMenuItem<Lie>(
          value: lie,
          child: Text(lie.toString().split('.').last),
        );
      }).toList();
    } else {
      // 通常のショットの場合は全てのLieの選択肢
      return Lie.values.map((Lie lie) {
        return DropdownMenuItem<Lie>(
          value: lie,
          child: Text(lie.toString().split('.').last),
        );
      }).toList();
    }
  }

  void _updateRoundHoleFields(RoundHoleDto roundHoleDto) {
  int? par = widget.holes[currentHoleIndex].par;
  if (par == null) {
    // パーの情報がない場合は処理を終了
    return;
  }

  // 初期化
  roundHoleDto.penaltyStrokes = 0;
  roundHoleDto.bunkerShotsCount = 0;
  roundHoleDto.scrambleAttempted = false;
  roundHoleDto.scrambleSuccess = false;
  roundHoleDto.fairwayHit = false;
  roundHoleDto.greenInRegulation = false;
  roundHoleDto.bunkerRecovery = null;

  // 各ショット情報からRoundHoleを更新
  for (var shot in shots) {
    // フェアウェイヒットの更新（ティーショットのみ）
    if (shot['shotNumber'] == 1 && shot['ballDirection'] == BallDirection.Fairway) {
      roundHoleDto.fairwayHit = true;
    }

    // OB の場合、ペナルティストロークを追加
    if (shot['ballDirection'] == BallDirection.LeftOB || shot['ballDirection'] == BallDirection.RightOB) {
      roundHoleDto.penaltyStrokes = (roundHoleDto.penaltyStrokes ?? 0) + 2;
    } else if (shot['ballDirection'] == BallDirection.WaterHazardLeft || shot['ballDirection'] == BallDirection.WaterHazardRight || shot['ballDirection'] == BallDirection.WaterHazardFront) {
      roundHoleDto.penaltyStrokes = (roundHoleDto.penaltyStrokes ?? 0) + 1;
    }

    // バンカーショットのカウント
    if (shot['ballDirection'] == BallDirection.SandBunkerLeft || shot['ballDirection'] == BallDirection.SandBunkerRight) {
      roundHoleDto.bunkerShotsCount = (roundHoleDto.bunkerShotsCount ?? 0) + 1;
    }
  }

  // パーオンの更新
  int totalStrokes = shots.length;
  int totalPutts = putts;
  if ((totalStrokes - totalPutts) <= (par - 2)) {
    roundHoleDto.greenInRegulation = true;
  } else {
    roundHoleDto.greenInRegulation = false;
    roundHoleDto.scrambleAttempted = true;
  }

  // スクランブルの更新
  if (roundHoleDto.scrambleAttempted == true && totalStrokes <= par) {
    roundHoleDto.scrambleSuccess = true;
}


  // バンカーからのリカバリーの処理
  for (int i = 1; i < shots.length; i++) {
    var previousShot = shots[i - 1];
    var currentShot = shots[i];
    if ((previousShot['ballDirection'] == BallDirection.SandBunkerLeft || previousShot['ballDirection'] == BallDirection.SandBunkerRight) && currentShot['remainingDistance'] <= 50) {
      if (currentShot['ballDirection'] == BallDirection.Green && totalPutts == 1) {
        roundHoleDto.bunkerRecovery = true;
      } else {
        roundHoleDto.bunkerRecovery = false;
      }
    }
  }
}


  void _submitHole() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isSaving = true; // 保存中の状態に設定
  });

  try {
    RoundHandler roundHandler = RoundHandler();
    int userId = widget.userId;
    int roundId = widget.roundId;
    int holeId = widget.holes[currentHoleIndex].holeId ?? -1;

    // RoundHole の存在確認
    final existingRoundHoleResponse = await roundHandler.getRoundHoleForUser(userId, roundId, holeId);
    int roundHoleId;

    if (existingRoundHoleResponse.statusCode == 200) {
      final existingRoundHoleData = json.decode(existingRoundHoleResponse.body);
      roundHoleId = existingRoundHoleData['roundHoleId'];
    } else if (existingRoundHoleResponse.statusCode == 404) {
      RoundHoleDto newRoundHoleDto = RoundHoleDto(
        stroke: score,
        putts: putts,
        weatherConditions: weatherCondition,
      );

      final newRoundHoleResponse = await roundHandler.addRoundHoleForUser(userId, roundId, holeId, newRoundHoleDto);

      if (newRoundHoleResponse.statusCode != 201 && newRoundHoleResponse.statusCode != 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add RoundHole: ${newRoundHoleResponse.statusCode}')),
        );
        return;
      }

      final newRoundHoleData = json.decode(newRoundHoleResponse.body);
      roundHoleId = newRoundHoleData['roundHoleId'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching roundHole: ${existingRoundHoleResponse.statusCode}')),
      );
      return;
    }

     // ショット情報からRoundHoleを更新
    //_updateRoundHoleFields(RoundHoleDto);

    // 各ショットをサーバーに送信（ショット情報をまとめて保存する）
    List<ShotDto> newShotDtos = shots.map((shot) {
      final shotTypeValue = shot['shotType'];
      final puttTypeValue = shot['puttType'];

      if (shot['clubUsed'] == ClubUsed.Putter) {
        if (puttTypeValue != null && puttTypeValue is PuttType) {
          final puttResultValue = shot['shotResult'] as PuttResult?;
          if (puttResultValue != null) {
            return ShotDto(
              shotNumber: shot['shotNumber'] as int,
              distance: int.tryParse(shot['distance']) ?? 0,
              remainingDistance: int.tryParse(shot['remainingDistance']) ?? 0,
              clubUsed: shot['clubUsed'] as ClubUsed,
              ballDirection: shot['ballDirection'] as BallDirection,
              shotType: puttTypeValue,
              shotTypeName: 'PuttType', // shotTypeName を追加
              ballHeight: shot['ballHeight'] as BallHeight,
              lie: shot['lie'] as Lie,
              shotResult: puttResultValue,
              shotResultName: 'PuttResult', // shotResultName を追加
              notes: shot['notes'] as String?,
            );
          } else {
            throw TypeError();
          }
        } else {
          throw TypeError();
        }
      } else {
        if (shotTypeValue != null && shotTypeValue is ShotType) {
          final shotResultValue = shot['shotResult'] as ShotResult?;
          if (shotResultValue != null) {
            return ShotDto(
              shotNumber: shot['shotNumber'] as int,
              distance: int.tryParse(shot['distance']) ?? 0,
              remainingDistance: int.tryParse(shot['remainingDistance']) ?? 0,
              clubUsed: shot['clubUsed'] as ClubUsed,
              ballDirection: shot['ballDirection'] as BallDirection,
              shotType: shotTypeValue,
              shotTypeName: 'ShotType', // shotTypeName を追加
              ballHeight: shot['ballHeight'] as BallHeight,
              lie: shot['lie'] as Lie,
              shotResult: shotResultValue,
              shotResultName: 'ShotResult', // shotResultName を追加
              notes: shot['notes'] as String?,
            );
          } else {
            throw Exception('Shot result is missing or incorrect.');
          }
        } else {
          throw TypeError();
        }
      }
    }).toList();

    final shotResponse = await roundHandler.bulkPostShots(
      userId: userId,
      roundId: roundId,
      holeId: holeId,
      roundHoleId: roundHoleId,
      shots: newShotDtos,
    );

    if (shotResponse.statusCode != 201 && shotResponse.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add shots: ${shotResponse.statusCode}')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hole data saved successfully')),
    );

    // 保存成功時の処理
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hole data saved successfully')),
    );

    setState(() {
      _isHoleDataSaved = true; // 保存が成功したため、保存済みフラグを設定
    });

    // すべてのホールが完了したらユーザーページに戻る処理
    if (currentHoleIndex == widget.holes.length - 1) {
      // 最後のホールの場合、ユーザーページに戻る
      Navigator.of(context).pop(); // ユーザーページに戻る（もしくは別のページに遷移する）
    } else {
      // まだホールが残っている場合は次のホールに進む
      setState(() {
        currentHoleIndex++;
        _generateShots(); // 新しいホールのショット情報を生成
        _isHoleDataSaved = false; // 新しいホールのデータを保存する準備
      });
    }
  } finally {
    setState(() {
      _isSaving = false; // 処理終了後、保存中フラグをリセット
    });
  }
}
}
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_web_api/Mains/api_handler.dart';
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

  @override
  void initState() {
    super.initState();
    _generateShots();
  }

  @override
  Widget build(BuildContext context) {
    Hole currentHole = widget.holes[currentHoleIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
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
                          currentHoleIndex = index;
                          _generateShots();
                          _isHoleDataSaved = false; // ホールを変更したときに、保存済みフラグをリセット
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
    );
  }


  // ショットの入力フォームを生成
  void _generateShots() {
    shots.clear();
    int totalShots = score;
    int puttStartIndex = totalShots - putts + 1;

    for (int shotIndex = 1; shotIndex <= totalShots; shotIndex++) {
      String shotType = (shotIndex == 1) ? 'tee' : (shotIndex >= puttStartIndex && putts > 0) ? 'putt' : 'shot';
      shots.add({
        'shotNumber': shotIndex,
        'type': shotType,
        'distance': '',
        'remainingDistance': (shotIndex == totalShots && shotType == 'putt') ? '0' : '',
        'clubUsed': shotType == 'putt' ? ClubUsed.Putter : ClubUsed.Driver, 
        'ballDirection': (shotIndex == totalShots && shotType == 'putt') ? BallDirection.Holed : null,
        'shotType': shotType == 'putt' ? PuttType.StraightPutt : ShotType.Straight,
        'puttType': shotType == 'putt' ? PuttType.StraightPutt : null, // ここでputtTypeを初期化
        'ballHeight': shotType == 'putt' ? BallHeight.Default : null,
        'lie': shotType == 'tee' ? Lie.Tee : (shotType == 'putt' ? Lie.Green : null),
        'shotResult': (shotIndex == totalShots && shotType == 'putt') ? PuttResult.PuttHoled : ShotResult.Perfect,
        'notes': '',
      });
    }
  }

  // ショットごとの入力フォームを生成
Widget _buildShotInputForm(Map<String, dynamic> shot) {
  bool isPutter = shot['type'] == 'putt';
  bool isTeeShot = shot['type'] == 'tee';

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
      if (!isPutter || shot['shotNumber'] != shots.length)
        TextFormField(
          decoration: InputDecoration(labelText: 'Remaining Distance (${isPutter ? "feet" : "yards"})'),
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




      // Ball Direction
      DropdownButtonFormField<BallDirection>(
        decoration: const InputDecoration(labelText: 'Ball Direction'),
        value: shot['ballDirection'] as BallDirection?,
        onChanged: (BallDirection? value) {
          setState(() {
            shot['ballDirection'] = value;
            _updateRoundHoleDataAfterBallDirectionSelection(shot['shotNumber'], value);
          });
        },
        items: BallDirection.values.map((BallDirection direction) {
          return DropdownMenuItem<BallDirection>(
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
  value: shot['shotResult'],
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

  void _updateRoundHoleDataAfterBallDirectionSelection(int shotNumber, BallDirection? ballDirection) {
    // Tee Shot の場合
    if (shotNumber == 1 && ballDirection == BallDirection.Fairway) {
      setState(() {
        // Fairway Hit を更新
        // ラウンドホールのオブジェクトを更新する
        // TODO: Implement round hole fairway hit state here
      });
    }
    // それ以外のケース
    else if (ballDirection == BallDirection.LeftOB || ballDirection == BallDirection.RightOB) {
      setState(() {
        // Penalty Strokesに2加算
        // TODO: Implement penalty strokes addition here
      });
    }
    // 他のビジネスロジックに応じた処理を追加する
    // TODO: Add more business logic based on different BallDirection values
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

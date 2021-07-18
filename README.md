# RollingBall
Arduinoと連動する玉転がしゲーム

## 構成

Arduionoで6軸センサーの加速度・角速度を取得し **傾き** を検出します．
この傾きを **シリアル通信** でProcessingに送信し，Processing側で玉転がしゲームを実行します．

- Arduino UNO
- MPU6050(6軸センサー)

## 操作方法の変更

ゲームの操作は，傾きセンサー（MPU6050），マウス，キーボードが利用できます．

```python
// 操作方法
final int MOUSE = 0;
final int SENSOR = 1;
final int KEYBOARD = 2;
int CONTROLLER = KEYBOARD;
```

## コースの作成

コースはJSONファイルに記述します．
ファイル名は **stage1.json** のように記述します．
コースには，**ボール**，**ゴール**，**スロープ（坂道）**，**リフト** の4種類を配置することができます．
また，スロープとリフトは複数配置することが可能です．

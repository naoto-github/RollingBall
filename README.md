# RollingBall
Arduinoと連動する玉転がしゲーム

## 構成

Arduionoで6軸センサーの加速度・角速度を取得し **傾き** を検出します．
この傾きを **シリアル通信** でProcessingに送信し，Processing側で玉転がしゲームを実行します．

- Arduino UNO
- MPU6050(6軸センサー)

ブレッドボードを介して，MPU6050とArduinoを配線します．
MPU6050はI2Cインタフェースによりデータ送信（シリアル通信）します．
ここで，SCLはクロック信号，SDAはデータ信号です．

- VCC -> 5V
- GND -> GND
- SCL -> A5(SCL)
- SDA -> A4(SDA)

<a href="https://gyazo.com/7115ed40be43a0723ddb92b48f653cbd"><img src="https://i.gyazo.com/7115ed40be43a0723ddb92b48f653cbd.jpg" alt="Image from Gyazo" width="400"/></a>

## Processingの設定

次のライブラリをインストールする必要があります．

- [Fisica](http://www.ricardmarxer.com/fisica/)（物理演算）
- [ControlP5](http://www.sojamo.de/libraries/controlP5/)（GUI）
- Minim（サウンド）

## 操作方法の変更

ゲームの操作は，傾きセンサー（MPU6050），マウス，キーボードが利用できます．

```java
// 操作方法
final int MOUSE = 0;
final int SENSOR = 1;
final int KEYBOARD = 2;
int CONTROLLER = KEYBOARD;
```

また，キーボードの**r**でリセット，**ESC**でゲームは終了します．

<a href="https://gyazo.com/60715489692e73e9ecca297f129087b6"><img src="https://i.gyazo.com/60715489692e73e9ecca297f129087b6.gif" alt="Image from Gyazo" width="640"/></a>

## コースの作成

コースはJSONファイルに記述します．
ファイル名は **stage1.json** のように設定し，番号の小さなファイルから読み込まれます．
コースサイズは **1200x800** であり，**ボール**，**ゴール**，**スロープ（坂道）**，**リフト**，**ジャンプボール** の5種類を配置することができます．
また，スロープ，リフト，ジャンプボールは複数配置することが可能です．

### 作成者名

コースの作成者名を設定します．
作成者名はアルファベット表記のみです．

```json
"author": "Naoto"
```

### ボール

ボールの落下位置:xを設定します．

```json
"ball": {
	"x": 100
}
```

### ゴール

ゴールの位置:x,yを設定します．

```json
"goal": {
	"x": 350,
	"y": 650
}
```

### スロープ（坂道）

スロープの位置:x,yと大きさ:w,hを設定します．
位置は重心で表されることに注意してください（左上の座標ではない）．

```json
"slopes":[
	{
		"x": 400,
		"y": 200,
		"w": 700,
		"h": 10
	},
	{
		"x": 800,
		"y": 400,
		"w": 700,
		"h": 10
	}
]
```

### リフト

リフトの位置:x,y，大きさ:w,h，移動距離:l，回転角度:rを設定します．
位置は重心で表されることに注意してください．
また，回転角度は **0** にはせず，必ず角度（ラジアン角）を設定してください．

```json
"lifts":[
	{
		"x": 400,
		"y": 200,
		"w": 100,
		"h": 10,
		"l": 200,
		"r": 0.2
	},
	{
		"x": 900,
		"y": 400,
		"w": 100,
		"h": 10,
		"l": 200,
		"r": 0.2
	}
]
```

### ジャンプボール

ジャンプボールの位置:x,yを設定します．

```json
"jumps":[
	{
		"x":900,
		"y":650
	}
]
```

## コースのサンプル

指定の用紙に記入したコースをJSONで再現します．

<a href="https://gyazo.com/c36c261522e49fadf0fdbd364d9c72df"><img src="https://i.gyazo.com/c36c261522e49fadf0fdbd364d9c72df.png" alt="Image from Gyazo" width="400"/></a>

<a href="https://gyazo.com/3a77791f91bfbfbdfb5792322af173d1"><img src="https://i.gyazo.com/3a77791f91bfbfbdfb5792322af173d1.gif" alt="Image from Gyazo" width="400"/></a>

```json
{
  "author": "Naoto",
  "ball": {
	   	"x": 250
   },
   "goal": {
     	"x": 1050,
    	"y": 650
   },
   "slopes":[
     {
       "x": 300,
	     "y": 250,
	     "w": 400,
	     "h": 100
     }
   ],
   "lifts":[
     {
       "x": 800,
       "y": 450,
       "w": 400,
       "h": 100,
       "l": 200,
       "r": 0.01
     }
   ],
   "jumps":[
     {
	      "x":550,
        "y":350
      }
    ]
}
```

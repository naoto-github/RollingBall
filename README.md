# RollingBall
Arduinoと連動する玉転がしゲーム

## 構成

Arduionoで6軸センサーの加速度・角速度を取得し **傾き** を検出します．
この傾きを **シリアル通信** でProcessingに送信し，Processing側で玉転がしゲームを実行します．

- Arduino UNO
- MPU6050(6軸センサー)

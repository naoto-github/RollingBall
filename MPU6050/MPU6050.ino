#include <Wire.h>
#include <MPU6050.h>

MPU6050 mpu;

int16_t ax, ay, az;
int16_t gx, gy, gz;

void setup() {

  Wire.begin();
  Serial.begin(9600);

  // 初期化
  mpu.initialize();
  delay(10);

  // 角速度の計測範囲
  mpu.setFullScaleGyroRange(MPU6050_GYRO_FS_2000);
  delay(10);

  // キャリブレーション
  mpu.CalibrateGyro();
  mpu.CalibrateAccel();

}

void loop() {

  // 加速度と角速度を取得
  mpu.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);

  // X軸の角度
  float degX = atan2(ay, az) * RAD_TO_DEG;

  // Y軸の角度
  float degY = atan2(ax, az) * RAD_TO_DEG;

  Serial.print(degX);
  Serial.print(",");
  Serial.println(degY);

  //delay(500);

}

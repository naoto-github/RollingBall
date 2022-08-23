// センサー操作
void sensorRotate(){
  
  if(CONTROLLER == SENSOR){
    // シリアルポートからデータ取得
    serialEvent(port);
    
    for(Slope slope: slopes){
     float angle = radians(int(degX)+1);
     slope.setRotation(angle);
    }
  }
}

// シリアル通信
void serialEvent(Serial port){
  String data = port.readStringUntil('\n');

  if (data != null) {
    data = trim(data);
  
    float sensors[] = float(split(data, ","));
    
    if(sensors.length == 2){
      degX = sensors[0];
      degY = sensors[1];
      
      if(CONTROLLER == SENSOR){
        println(degX + ":" + degY);
      }
    }
   
  }
}

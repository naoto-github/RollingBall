// マウス操作
void mouseDragged(){
  
  if(CONTROLLER == MOUSE){
    
    float diff_x = pmouseX - mouseX;

    if(diff_x > 0){
      for(Slope slope: slopes){
        slope.rotate(+1 * UNIT_ANGLE);
      }    
    }
    else{
      for(Slope slope: slopes){
        slope.rotate(-1 * UNIT_ANGLE);
      }  
    }
  }

}

// キーボード操作
void keyPressed(){
  
  if(stage != -1 && stage != -2){
    // 強制的に失敗
    if(key == 'f'){ 
      println("fail");
      fail();
    }
    // リセット
    else if(key == 'r'){
      println("reset");
      life = 0;
      fail();
    }
    // 次のステージへ
    else if(key == 'n'){
      println("next");
      nextStage();
    }
  }
  
  if(CONTROLLER == KEYBOARD){
    
    if(key == CODED){
      if(keyCode == LEFT){
        for(Slope slope: slopes){
          slope.rotate(-1 * UNIT_ANGLE);
        }  
      }
      else if(keyCode == RIGHT){
        for(Slope slope: slopes){
          slope.rotate(+1 * UNIT_ANGLE);
        } 
      }
    }
    
  }

}

public void drawOpening(){
  background(color(0, 0, 0));
  fill(255);
  textSize(128);
  text("ROLLING BALL", width / 2 - 460, height/2 - 100);
  textSize(32);
  fill(color(255, 255, 0));
  text("Developed by mLab", width / 2 - 130, height/2 - 30);
}

public void drawEnding(ScoreLog score){ 
  
  // 順位の取得
  int rank = score_list.getRank(score);
  
  background(color(0, 0, 0));
  fill(color(255, 255, 0));
  textSize(128);
  text("GAME CLEAR", width / 2 - 420, height/2 - 200);
  
  textSize(96);
  fill(color(255, 255, 255));
  text("Your Stage: ", width / 2 - 400, height/2 - 50);
  fill(color(255, 255, 0));
  text(score.stage, width /2 + 150,  height/2 - 50);
  fill(color(255, 255, 255));
  text("Your Time: ", width / 2 - 400, height/2 + 50);
  fill(color(255, 255, 0));
  text(score.time / 1000.0, width /2 + 120,  height/2 + 50);
  fill(color(255, 255, 255));
  text("Your Rank: ", width / 2 - 400, height/2 + 150);
  fill(color(255, 255, 0));
  text(rank + " / " + score_list.size(), width / 2 + 150, height/2 + 150);

}

public void drawRank(ScoreLog score, int elapsed_time){
  // 順位の取得
  int rank = score_list.getRank(score);
  
  background(color(0, 0, 0));
  fill(color(255, 0, 0));
  textSize(128);
  text("GAME OVER", width / 2 - 420, height/2 - 200);
  
  textSize(96);
  fill(color(255, 255, 255));
  text("Your Stage: ", width / 2 - 400, height/2 - 50);
  fill(color(255, 255, 0));
  text(score.stage, width /2 + 150,  height/2 - 50);
  fill(color(255, 255, 255));
  text("Your Time: ", width / 2 - 400, height/2 + 50);
  fill(color(255, 255, 0));
  text(score.time / 1000.0, width /2 + 120,  height/2 + 50);
  fill(color(255, 255, 255));
  text("Your Rank: ", width / 2 - 400, height/2 + 150);
  fill(color(255, 255, 0));
  text(rank + " / " + score_list.size(), width / 2 + 150, height/2 + 150);
  
  if(elapsed_time > 5000){
    nextStage();
  }
  
}

public void drawStage(FWorld world, String author, int stage, int life, int gravity, int elapsed_time){
  
  String stage_name;
  if(stage == STAGE_ORIGINAL){
    stage_name = "original";
  }
  else{
    stage_name = Integer.toString(stage);
  }
  
  background(color(0, 0, 0)); // 背景色
    
  world.draw();
  world.step();
  
  fill(255);
  textSize(20);
  text("Author: " + author, width-250, 50);
  text("Stage: " + stage_name, width-250, 90);
  text("Life: " + life, width-250, 130);
  text("Gravity: " + gravity, width-250, 170);
  text("Time: " + floor(elapsed_time / 100) / 10.0 + " sec.", width-250, 210);
}

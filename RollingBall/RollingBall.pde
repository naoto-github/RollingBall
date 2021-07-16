import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import fisica.*;
import java.util.ArrayList;
import processing.serial.*;

// 操作方法
final int MOUSE = 0;
final int SENSOR = 1;
int CONTROLLER = MOUSE;

// 物理演算
FWorld world;
FCircle ball;
FCircle goal;
ArrayList<Slope> slopes;
ArrayList<Jump> jumps;

// スロープの角度
float UNIT_ANGLE = PI / 180;

// 効果音
Minim minim;
AudioPlayer fall_sound;
AudioPlayer clear_sound;
AudioPlayer fail_sound;
AudioPlayer bgm_sound;

// ボタン
ControlP5 start_bt;
PFont font;

// シリアル通信
Serial port;
float degX;
float degY;

// 最大ステージ数
int MAX_STAGE = 4;

// 現在のステージ
int stage = 0;

// ライフ
int MAX_LIFE = 5;
int life = MAX_LIFE;

// 重力
int MIN_GRAVITY = 500;
int gravity = MIN_GRAVITY;

void setup(){
  size(1200, 800);
  smooth();
  
  initFont();
  initButton();
  initSound();
  initWorld();
  initStage();
  
  // シリアルポート
  if(CONTROLLER == SENSOR){
    port = new Serial(this, "COM5", 9600);
    port.bufferUntil('\n'); // 改行までをバッファ
  }
}

void draw(){
  
  if(stage == 0){

    background(color(0, 0, 0));
    fill(255);
    textSize(128);
    text("Rolling Ball", width / 2 - 410, height/2 - 100);
    textSize(32);
    text("Developed by mLab", width / 2 - 180, height/2 - 30);
  }
  else{
        
    sensorRotate();
    
    background(color(0, 0, 0));
    world.draw();
    world.step();
    
    textSize(30);
    text("Stage: " + stage, width-250, 50);
    text("Life: " + life, width-250, 90);
    text("Gravity: " + gravity, width-250, 130);
  
    if(isFail()){
      if(life == 0){
        stage = 0;
        life = MAX_LIFE;
        initStage();
      }
      else{
        initBall();
      }
    }
  }
}

void initWorld(){
  Fisica.init(this);
  world = new FWorld();
  world.setGravity(0, gravity);
  world.setEdges(0, -100, width, height+100, color(105,105,105));
}

void initBall(){
  ball = new Ball(30, 100, 0);
  world.add(ball);
  
  fall_sound.rewind();
  fall_sound.play();
}

void initGoal(){
  world.add(goal);
}

void initJump(){
  for(Jump jump: jumps){
    world.add(jump);
  }
}

void initSlope(){
  for(Slope slope: slopes){
    world.add(slope);
  }
}

void contactStarted(FContact contact){

  // ボールとゴールの接触
  if(contact.contains(ball, goal)){
    println("clear stage" + stage);
    clear_sound.rewind();
    clear_sound.play();
    world.remove(ball);
    
    nextStage();
  }
  
}


void initSound(){
  minim = new Minim(this);
  
  fall_sound = minim.loadFile("sound/fall.mp3");
  clear_sound = minim.loadFile("sound/clear.mp3");
  fail_sound = minim.loadFile("sound/fail.mp3");
  bgm_sound = minim.loadFile("sound/bgm.mp3");
  bgm_sound.setGain(-15);
}

void initButton(){
    
  start_bt = new ControlP5(this);
  
  start_bt.addButton("nextStage")
    .setLabel("START")
    .setPosition(width/2 - 150, height/2 + 100)
    .setSize(300, 100)
    .setFont(font);
    
  start_bt.setVisible(false);
  
}

void initFont(){
  font = createFont("Verdana Bold Italic", 64);
  textFont(font);
}

void initStage(){
 
  slopes = new ArrayList<Slope>();
  jumps = new ArrayList<Jump>();
  world.clear();
  
  if(stage == 0){
    
    bgm_sound.pause();
    
    gravity = MIN_GRAVITY;
    world.setGravity(0, gravity);
    start_bt.setVisible(true);
  }
  else{
    
    bgm_sound.loop();
    
    gravity = gravity + 500;
    world.setGravity(0, gravity);
    
    String filename = "stage" + stage + ".json";
    loadStage(filename);
    
    initBall();
    initGoal();
    initSlope();
    initJump();
  }
  
}

void loadStage(String filename){
    JSONObject json = loadJSONObject("./json/" + filename);
    
    JSONArray json_slopes = json.getJSONArray("slopes");
    
    for(int i=0; i<json_slopes.size(); i++){
      JSONObject json_slope = json_slopes.getJSONObject(i);
      int x = json_slope.getInt("x");
      int y = json_slope.getInt("y");
      int w = json_slope.getInt("w");
      int h = json_slope.getInt("h");
      
      Slope slope = new Slope(w, h);
      slope.setPosition(x, y);
      slope.rotate(UNIT_ANGLE);
      slopes.add(slope);
      
    }
    
    JSONArray json_jumps = json.getJSONArray("jumps");
    
    if(json_jumps != null){
      for(int i=0; i<json_jumps.size(); i++){
        JSONObject json_jump = json_jumps.getJSONObject(i);
        int x = json_jump.getInt("x");
        int y = json_jump.getInt("y");
        
        Jump jump = new Jump(50, x, y);
        jumps.add(jump);
        
      }   
    }
    
    JSONObject json_goal = json.getJSONObject("goal");
    int x = json_goal.getInt("x");
    int y = json_goal.getInt("y");
    goal = new Goal(50, x, y);
    
}

void nextStage(){
  start_bt.setVisible(false);
  
  stage = ((stage + 1) % (MAX_STAGE+1));
  
  initStage();
}

// ボールが落下
boolean isFail(){
  if(ball.getY() > (height + 2*ball.getSize())){
    println("Fail");
    fail_sound.rewind();
    fail_sound.play();
    life = max(life - 1, 0);
    delay(1000);
        
    return true;
  }else{
    return false;
  }
}

// マウス操作
void mouseDragged(){
  
  if(CONTROLLER == MOUSE){
    
    float diff_x = pmouseX - mouseX;

    if(diff_x > 0){
      for(Slope slope: slopes){
        slope.rotate(UNIT_ANGLE);
      }    
    }
    else{
      for(Slope slope: slopes){
        slope.rotate(-1 * UNIT_ANGLE);
      }  
    }
  }

}

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

class Ball extends FCircle{
  
  Ball(float radius, float circle_x, float circle_y){
    super(radius);
    this.setPosition(circle_x, circle_y);
    this.setFillColor(color(255, 255, 0));
    this.setStrokeColor(color(255, 255, 0));
  }
  
}

class Jump extends FCircle{
  
  Jump(float radius, float circle_x, float circle_y){
    super(radius);
    this.setPosition(circle_x, circle_y);
    this.setFillColor(color(0, 255, 0));
    this.setStrokeColor(color(0, 255, 0));
    this.setStatic(true);
    this.setRestitution(1);
  }
  
}

class Goal extends FCircle{
  
   Goal(float radius, float goal_x, float goal_y){
    super(radius);
    this.setStatic(true);
    this.setPosition(goal_x, goal_y);
    this.setFillColor(color(255, 0, 0));
    this.setStrokeColor(color(255, 0, 0));
  }
  
}

class Slope extends FBox{
  
  Slope(float width, float height){
    super(width, height);
    this.setStatic(true);
  }
  
  void rotate(float angle){
      float base_angle = this.getRotation();
      translate(500, 500);
      this.setRotation(base_angle + angle);
  }
  
}

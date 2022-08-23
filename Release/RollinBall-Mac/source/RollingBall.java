import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.signals.*; 
import ddf.minim.spi.*; 
import ddf.minim.ugens.*; 
import fisica.*; 
import java.util.UUID; 
import java.util.Comparator; 
import java.util.Collections; 
import java.util.Random; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class RollingBall extends PApplet {















// 操作方法
final int MOUSE = 0;
final int SENSOR = 1;
final int KEYBOARD = 2;
int CONTROLLER = KEYBOARD;

// 物理演算
FWorld world;
Ball ball;
Goal goal;
ArrayList<Slope> slopes;
ArrayList<Jump> jumps;
ArrayList<Lift> lifts;
ArrayList<Worp> worps;
String author;

// スロープの角度
float UNIT_ANGLE = PI / 180;

// 効果音
Minim minim;
AudioPlayer fall_sound;
AudioPlayer clear_sound;
AudioPlayer fail_sound;
AudioPlayer bgm_sound;
AudioPlayer end_sound;
AudioPlayer rank_sound;
AudioPlayer worp_sound;

// ボタン
PFont font;
ControlP5 start_bt;
ControlP5 original_bt;
ControlP5 restart_bt;

// シリアル通信
Serial port;
float degX;
float degY;
//String PORT = "COM5"; // for Windows
String PORT = "/dev/cu.usbmodem11101"; // for Mac

// ステージ
final int STAGE_OPENING = -1;
final int STAGE_ENDING = -2;
final int STAGE_ORIGINAL = -3;
final int STAGE_RANK = -4;
int MAX_STAGE = 10; // 最大ステージ数
int stage = STAGE_OPENING;

// ライフ
int MAX_LIFE = 10;
int life = MAX_LIFE;

// 重力
int DIFF_GRAVITY = 1000;
int MIN_GRAVITY = 1000;
int gravity = MIN_GRAVITY;

// タイマー
int start_time = 0;
int elapsed_time = 0;
int total_time = 0;

// スコア管理
ScoreLog score = new ScoreLog(stage, total_time, gravity);
ScoreList score_list = new ScoreList();

// 乱数生成
Random rand = new Random();

// ワープ
boolean worp_contact = false;
float worp_time = 0;
float worp_elapsed_time = 0;
float worp_limit_time = 3000;
float worp_x = 0;
float worp_y = 0;

public void setup(){
  
  // ウィンドウ・サイズ
  
  
  // アンチ・エイリアス
  
  
  // フォントの初期化
  initFont();
  
  // ボタンの初期化
  initButton();
  
  // 効果音の初期化
  initSound();
  
  // 空間の初期化
  initWorld();
  
  // ステージの初期化
  initStage();
  
  // ログの初期化
  score_list.load();
  
  // シリアルポート
  if(CONTROLLER == SENSOR){
    port = new Serial(this, PORT, 9600);
    port.bufferUntil('\n'); // 改行までをバッファ
  }
  
}

// フレーム毎の処理
public void draw(){
  
  // タイマーのカウント
  countTimer();
  
  if(stage == STAGE_OPENING){
    drawOpening();
  }
  else if(stage == STAGE_ENDING){
   drawEnding(score);
  }
  else if(stage == STAGE_RANK){
    drawRank(score, elapsed_time);
  }
  else{
    sensorRotate(); // センサによる回転
    updateLift(); // リフトの上下運動  
    isFail(); // 落下判定
    worp(); // ワープ
    drawStage(world, author, stage, life, gravity, elapsed_time);
  }
}

// タイマーの初期化
public void initTimer(){
  start_time = millis();
}

// タイマーのカウント
public void countTimer(){
  elapsed_time = millis() - start_time;
}

// 空間の初期化
public void initWorld(){
  Fisica.init(this);
  world = new FWorld();
  world.setGravity(0, gravity);
  world.setEdges(0, -100, width, height+100, color(105,105,105));
}

// 効果音の初期化
public void initSound(){
  minim = new Minim(this);
  
  fall_sound = minim.loadFile("sound/fall.mp3");
  clear_sound = minim.loadFile("sound/clear.mp3");
  fail_sound = minim.loadFile("sound/fail.mp3");
  end_sound = minim.loadFile("sound/end.mp3");
  rank_sound = minim.loadFile("sound/rank.mp3");
  worp_sound = minim.loadFile("sound/worp.mp3");
  bgm_sound = minim.loadFile("sound/bgm.mp3");
  bgm_sound.setGain(-15);
}

// ボタンの初期化
public void initButton(){
    
  // スタートボタン
  start_bt = new ControlP5(this);
  
  start_bt.addButton("nextStage")
    .setLabel("START")
    .setPosition(width/2 - 450, height/2 + 100)
    .setSize(400, 100)
    .setFont(font);
    
  start_bt.setVisible(false);
  
  restart_bt = new ControlP5(this);
  
  // オリジナルボタン
  original_bt = new ControlP5(this);
  
  original_bt.addButton("originalStage")
    .setLabel("ORIGINAL")
    .setPosition(width/2  + 50,  height/2 + 100)
    .setSize(400, 100)
    .setFont(font);
    
  original_bt.setVisible(false);
  
  restart_bt = new ControlP5(this);
  
  // リスタートボタン
  restart_bt.addButton("nextStage")
    .setLabel("RESTART")
    .setPosition(width/2 - 200,  height/2 + 250)
    .setSize(400, 100)
    .setFont(font);
    
  restart_bt.setVisible(false);
  
}

// フォントの初期化
public void initFont(){
  font = loadFont("Baskerville-SemiBoldItalic-64.vlw");
  textFont(font);
}

// ボールの初期化
public void initBall(){
  ball.reset();
  world.remove(ball);
  world.add(ball);
  
  fall_sound.rewind();
  fall_sound.play();
}

// ゴールの初期化
public void initGoal(){
  world.add(goal);
}

// ジャンプ台の初期化
public void initJump(){
  for(Jump jump: jumps){
    world.add(jump);
  }
}

// ワープの初期化
public void initWorp(){
  for(Worp worp: worps){
    world.add(worp);  
  }
}

// リフトの初期化
public void initLift(){
  for(Lift lift: lifts){
    world.add(lift);
  }
}

// リフトの更新
public void updateLift(){
  for(Lift lift: lifts){
    lift.update();
  }
}

// スロープの初期化
public void initSlope(){
  for(Slope slope: slopes){
    world.add(slope);
  }
}

// スロープの回転をリセット
public void resetSlope(){
  for(Slope slope:slopes){
    slope.setRotation(UNIT_ANGLE);
  }
}

// 接触判定
public void contactStarted(FContact contact){

  // ボールとゴールの接触
  if(contact.contains(ball, goal)){
    println("Clear Stage: " + stage);
    clear_sound.rewind();
    clear_sound.play();
    world.remove(ball);
    nextStage();
  }
  
  // ボールとワープの接触
  if(isWorp()){
    for(Worp worp: worps){
      if(contact.contains(ball, worp)){
        worp_sound.rewind();
        worp_sound.play();
        println("Worp");
        
        ArrayList<Worp> target_worps = (ArrayList<Worp>)worps.clone();
        target_worps.remove(worp);
        int target_index = rand.nextInt(target_worps.size());
        Worp target_worp = target_worps.get(target_index);
        worp_x = target_worp.x;
        worp_y = target_worp.y;
        worp_contact = true;
        
        break;
      }
    }
  }
  
}

// オリジナルステージに遷移
public void originalStage(){
  start_bt.setVisible(false);
  original_bt.setVisible(false);
  restart_bt.setVisible(false);
  
  if(stage == STAGE_OPENING){
    stage = STAGE_ORIGINAL;
    life = MAX_LIFE;
    gravity = MIN_GRAVITY;
    world.setGravity(0, gravity);
  }
  
  initStage();
}

// 次のステージに遷移
public void nextStage(){
  start_bt.setVisible(false);
  original_bt.setVisible(false);
  restart_bt.setVisible(false);
  
  if(stage == MAX_STAGE){
    score = new ScoreLog(stage, total_time, gravity);
    score_list.add(score);
    score_list.save();
    stage = STAGE_ENDING;
  }
  else if(stage == STAGE_OPENING){
    stage = 1;
    life = MAX_LIFE;
    total_time = 0;
    gravity = MIN_GRAVITY;
  }
  else if(stage == STAGE_ENDING){
    stage = 1;
    life = MAX_LIFE;
    gravity = gravity + DIFF_GRAVITY;
    world.setGravity(0, gravity);
  }
  else if(stage == STAGE_RANK){
    stage = STAGE_OPENING;
  }
  else if(stage == STAGE_ORIGINAL){
    stage = STAGE_OPENING;
  }
  else{
    stage = stage + 1;
    total_time += elapsed_time;
  }
  
  initStage();
}

// ステージの初期化
public void initStage(){
  
  slopes = new ArrayList<Slope>();
  jumps = new ArrayList<Jump>();
  lifts = new ArrayList<Lift>();
  worps = new ArrayList<Worp>();
  
  world.clear();
  
  if(stage == STAGE_OPENING){
    
    bgm_sound.pause();
    
    world.setGravity(0, gravity);
    start_bt.setVisible(true);
    original_bt.setVisible(true);
  }
  else if(stage == STAGE_ENDING){
    
    bgm_sound.pause();
    end_sound.rewind();
    end_sound.play();
    
    restart_bt.setVisible(true);
  }
  else if(stage == STAGE_RANK){
    bgm_sound.pause();
    rank_sound.rewind();
    rank_sound.play();
  }
  else if(stage == STAGE_ORIGINAL){
      bgm_sound.loop();
    
      String filename = "original.json";
      loadStage(filename);
    
      initBall();
      initGoal();
      initSlope();
      initJump();
      initLift();
      initWorp();
  }
  else{
    
    bgm_sound.loop();
    
    String filename = "stage" + stage + ".json";
    loadStage(filename);
    
    initBall();
    initGoal();
    initSlope();
    initJump();
    initLift();
    initWorp();
  }  
  
  // タイマーの初期化
  initTimer();
}

// ボールの落下判定
public boolean isFail(){
  if(ball.getY() > (height + 2*ball.getSize())){
    fail(); 
    return true;
  }else{
    return false;
  }
}

// 失敗時の処理
public void fail(){
  fail_sound.rewind();
  fail_sound.play();
  life = max(life - 1, 0);
  delay(1000);
  
  if(life == 0){    
    if(stage == STAGE_ORIGINAL){
      stage = STAGE_OPENING;
    }
    else{
      score = new ScoreLog(stage-1, total_time, gravity);
      score_list.add(score);
      score_list.save();
      stage = STAGE_RANK;
    }
    initStage();
  }
  else{
    resetSlope();
    initBall();
  }
}

// ボールのワープ処理
public void worp(){
  if(worp_contact){
    ball.setPosition(worp_x, worp_y);
    offWorp();
    worp_contact = false;
    worp_time = millis();
  }
  else{
    worp_elapsed_time = millis() - worp_time;
    if(worp_elapsed_time > worp_limit_time){
      onWorp();
    }
  }
}
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
  text(score.time / 1000.0f, width /2 + 120,  height/2 + 50);
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
  text(score.time / 1000.0f, width /2 + 120,  height/2 + 50);
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
  text("Time: " + floor(elapsed_time / 100) / 10.0f + " sec.", width-250, 210);
}
// マウス操作
public void mouseDragged(){
  
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
public void keyPressed(){
  
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
// ボール
class Ball extends FCircle{
  
  static final int radius = 30;
  float init_x;
  float init_y = 0;
  
  Ball(float init_x){
    super(radius);
    this.init_x = init_x;
    this.setGrabbable(false);
    this.setRestitution(0.5f);
    this.setFriction(0);
    this.setPosition(init_x, init_y);
    this.setFillColor(color(255, 255, 0));
    this.setStrokeColor(color(255, 255, 0));
  }
  
  public void reset(){
    this.setPosition(init_x, init_y);
  }
  
  public void move(float x, float y){
    this.setPosition(x, y);
  }
  
}

// ゴール
class Goal extends FCircle{
  
  static final int radius = 50;
  
  Goal(float goal_x, float goal_y){
    super(radius);
    this.setStatic(true);
    this.setGrabbable(false);
    this.setPosition(goal_x, goal_y);
    this.setFillColor(color(255, 0, 0));
    this.setStrokeColor(color(255, 0, 0));
  }
  
}

// スロープ
class Slope extends FBox{
  
  float x;
  float y;
  
  Slope(float x, float y, float width, float height){
    super(width, height);
    this.x = x;
    this.y = y;
    this.setStatic(true);
    this.setGrabbable(false);
    this.setRestitution(0.5f);
    this.setFillColor(color(255));
    this.setStrokeColor(color(255));
  }
  
  public void rotate(float angle){
      float base_angle = this.getRotation();
      translate(500, 500);
      this.setRotation(base_angle + angle);
  }
  
}

// リフト
class Lift extends FBox{
  
  float upper;
  float lower;
  float speed = 1;
  
  Lift(float x, float y, float width, float height, float length, float angle){
    super(width, height);
    this.setPosition(x, y);
    this.upper = y + (length / 2);
    this.lower = y - (length / 2);
    this.setStatic(true);
    this.setGrabbable(false);
    this.setRestitution(0.5f);
    this.setRotation(angle);
    this.setFriction(0);
    this.setFillColor(color(0, 0, 255));
    this.setStrokeColor(color(0, 0, 255));
  }
  
  public void update(){
    float x = this.getX();
    float y = this.getY() + speed;
    this.setPosition(x, y);
    
    if(y >= this.upper){
      speed = -1 * speed;
    }
    else if(y <= this.lower){
       speed = -1 * speed;
    }
  }
  
}

// ジャンプ台
class Jump extends FCircle{
  
  static final int radius = 100;
  
  Jump(float circle_x, float circle_y){

    super(radius);
    this.setPosition(circle_x, circle_y);
    this.setFillColor(color(0, 255, 0));
    this.setStrokeColor(color(0, 255, 0));
    this.setStatic(true);
    this.setGrabbable(false);
    this.setRestitution(1);
  }
  
}

// ワープ
boolean worp_flg = true;
class Worp extends FPoly{
  
  static final int length = 20;
  public float x;
  public float y;
  
  Worp(float x, float y){
    worp_flg = true;
    this.x = x;
    this.y = y;
    this.vertex(x - length, y - length);
    this.vertex(x + length, y - length);
    this.vertex(x + length, y + length);
    this.vertex(x - length, y + length);
    this.vertex(x - length, y - length);
    this.setFillColor(color(0, 255, 255));
    this.setStrokeColor(color(0, 255, 255));
    this.setStatic(true);
    this.setGrabbable(false);
    this.setRestitution(1);
  }  
}

  
public boolean isWorp(){
  return worp_flg;
}

public void onWorp(){
  worp_flg = true;
  for(Worp worp: worps){
    worp.setFillColor(color(0, 255, 255));
    worp.setStrokeColor(color(0, 255, 255));
  }
}
 
public void offWorp(){
  worp_flg = false;
  for(Worp worp: worps){
    worp.setFillColor(color(55, 55, 55));
    worp.setStrokeColor(color(55, 55, 55));
  }
}
// JSONのロード
public void loadStage(String filename){
    JSONObject json = loadJSONObject("./json/" + filename);
    
    JSONArray json_slopes = json.getJSONArray("slopes");
    
    for(int i=0; i<json_slopes.size(); i++){
      JSONObject json_slope = json_slopes.getJSONObject(i);
      int x = json_slope.getInt("x");
      int y = json_slope.getInt("y");
      int w = json_slope.getInt("w");
      int h = json_slope.getInt("h");
      
      Slope slope = new Slope(x, y, w, h);
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
        
        Jump jump = new Jump(x, y);
        jumps.add(jump);
        
      }   
    }
    
    JSONArray json_lifts = json.getJSONArray("lifts");
    if(json_lifts != null){
      for(int i=0; i<json_lifts.size(); i++){
        JSONObject json_lift = json_lifts.getJSONObject(i);
        int x = json_lift.getInt("x");
        int y = json_lift.getInt("y");
        int w = json_lift.getInt("w");
        int h = json_lift.getInt("h");
        int l = json_lift.getInt("l");
        float a = json_lift.getFloat("r");
        
        Lift lift = new Lift(x, y, w, h, l, a);
        lifts.add(lift);
      }
    }
 
    JSONArray json_worps = json.getJSONArray("worps");
    if(json_worps != null){
      for(int i=0; i<json_worps.size(); i++){
        JSONObject json_worp = json_worps.getJSONObject(i);
        int x = json_worp.getInt("x");
        int y = json_worp.getInt("y");
        
        Worp worp = new Worp(x, y);
        worps.add(worp);
      }
    }
 
    JSONObject json_ball = json.getJSONObject("ball");
    int init_x = json_ball.getInt("x");
    ball = new Ball(init_x); 
    
    JSONObject json_goal = json.getJSONObject("goal");
    int x = json_goal.getInt("x");
    int y = json_goal.getInt("y");
    goal = new Goal(x, y);
    
    String json_author = json.getString("author");
    author = json_author;
    
}
class ScoreLog implements Comparable{
  
  public String uuid;
  public int score;
  public int stage;
  public int time;
  public int gravity;
  
  public ScoreLog(int stage, int time, int gravity){
    this.uuid = UUID.randomUUID().toString();
    this.score = stage * gravity - PApplet.parseInt(time / 100);
    this.stage = stage;
    this.time = time;
    this.gravity = gravity;
  }
  
  public ScoreLog(String uuid, int score, int stage, int time, int gravity){
    this.uuid = uuid;
    this.score = score;
    this.stage = stage;
    this.time = time;
    this.gravity = gravity;
  }
  
  public int compareTo(Object obj){
    ScoreLog s2 = (ScoreLog)obj;
    return s2.score - this.score;
  }
  
}

class ScoreComparator implements Comparator<ScoreLog>{
  public int compare(ScoreLog s1, ScoreLog s2){
    return s1.compareTo(s2);
  }
}

class ScoreList extends ArrayList<ScoreLog>{
  
  public String log_file = "./log/score_log.json";
  public ScoreComparator comparator = new ScoreComparator();
  
  public ScoreList(){
    super();
  }
  
  public boolean add(ScoreLog s){
    boolean flg = super.add(s);
    Collections.sort(this, comparator);
    return flg;
  }
  
  public void save(){
    
    JSONArray json_array = new JSONArray();
    
    Collections.sort(this, comparator);
    
    for(ScoreLog score_log: this){
      JSONObject json_object = new JSONObject();
      json_object.setString("uuid", score_log.uuid);
      json_object.setInt("score", score_log.score);
      json_object.setInt("stage", score_log.stage);
      json_object.setInt("time", score_log.time);
      json_object.setInt("gravity", score_log.gravity);
      json_array.append(json_object);
    }
    
    saveJSONArray(json_array,  log_file);
    
  }
  
  public void load(){
    
    try{
      JSONArray json_array = loadJSONArray(log_file);
      
      // リストの初期化
      clear();
      
      for(int i=0; i<json_array.size(); i++){
        JSONObject json_object = json_array.getJSONObject(i);
        String uuid = json_object.getString("uuid");
        int score = json_object.getInt("score");
        int stage = json_object.getInt("stage");
        int time = json_object.getInt("time");
        int gravity = json_object.getInt("gravity");
        
        ScoreLog score_log = new ScoreLog(uuid, score, stage, time, gravity);
        add(score_log);
      }
      
      Collections.sort(this, comparator);
      
    }
    catch(NullPointerException e){
      println("Initialize log file");
    }
  }
  
  public int getRank(ScoreLog target_score){
    Collections.sort(this, comparator);
    
    for(int i=0; i<this.size(); i++){
      ScoreLog score = get(i);
      if(target_score.uuid == score.uuid){
        return (i+1);
      }
    }
    
    return -1;
  }
  
  public String toString(){
    Collections.sort(this, comparator);
    StringBuffer sb = new StringBuffer();
    for(int i=0; i<this.size(); i++){
      ScoreLog s = this.get(i);
      sb.append("Score:" + s.score + " Gravity:" + s.gravity + " Stage:" + s.stage + " Time:" + s.time + "\n");
    }
    return sb.toString();
  }
}
// センサー操作
public void sensorRotate(){
  
  if(CONTROLLER == SENSOR){
    // シリアルポートからデータ取得
    serialEvent(port);
    
    for(Slope slope: slopes){
     float angle = radians(PApplet.parseInt(degX)+1);
     slope.setRotation(angle);
    }
  }
}

// シリアル通信
public void serialEvent(Serial port){
  String data = port.readStringUntil('\n');

  if (data != null) {
    data = trim(data);
  
    float sensors[] = PApplet.parseFloat(split(data, ","));
    
    if(sensors.length == 2){
      degX = sensors[0];
      degY = sensors[1];
      
      if(CONTROLLER == SENSOR){
        println(degX + ":" + degY);
      }
    }
   
  }
}
  public void settings() {  size(1200, 800);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "RollingBall" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

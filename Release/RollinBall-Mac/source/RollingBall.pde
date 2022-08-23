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

void setup(){
  
  // ウィンドウ・サイズ
  size(1200, 800);
  
  // アンチ・エイリアス
  smooth();
  
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
void draw(){
  
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
void initTimer(){
  start_time = millis();
}

// タイマーのカウント
void countTimer(){
  elapsed_time = millis() - start_time;
}

// 空間の初期化
void initWorld(){
  Fisica.init(this);
  world = new FWorld();
  world.setGravity(0, gravity);
  world.setEdges(0, -100, width, height+100, color(105,105,105));
}

// 効果音の初期化
void initSound(){
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
void initButton(){
    
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
void initFont(){
  font = loadFont("Baskerville-SemiBoldItalic-64.vlw");
  textFont(font);
}

// ボールの初期化
void initBall(){
  ball.reset();
  world.remove(ball);
  world.add(ball);
  
  fall_sound.rewind();
  fall_sound.play();
}

// ゴールの初期化
void initGoal(){
  world.add(goal);
}

// ジャンプ台の初期化
void initJump(){
  for(Jump jump: jumps){
    world.add(jump);
  }
}

// ワープの初期化
void initWorp(){
  for(Worp worp: worps){
    world.add(worp);  
  }
}

// リフトの初期化
void initLift(){
  for(Lift lift: lifts){
    world.add(lift);
  }
}

// リフトの更新
void updateLift(){
  for(Lift lift: lifts){
    lift.update();
  }
}

// スロープの初期化
void initSlope(){
  for(Slope slope: slopes){
    world.add(slope);
  }
}

// スロープの回転をリセット
void resetSlope(){
  for(Slope slope:slopes){
    slope.setRotation(UNIT_ANGLE);
  }
}

// 接触判定
void contactStarted(FContact contact){

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
void originalStage(){
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
void nextStage(){
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
void initStage(){
  
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
boolean isFail(){
  if(ball.getY() > (height + 2*ball.getSize())){
    fail(); 
    return true;
  }else{
    return false;
  }
}

// 失敗時の処理
void fail(){
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
void worp(){
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

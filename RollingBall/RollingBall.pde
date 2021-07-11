import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import fisica.*;
import java.util.ArrayList;

FWorld world;
FCircle ball;
FCircle goal;
ArrayList<Slope> slopes;

float UNIT_ANGLE = PI / 180;

AudioPlayer fall_sound;
AudioPlayer clear_sound;
AudioPlayer fail_sound;

int MAX_STAGE = 3;
int stage = 0;
int life = 5;

void setup(){
  size(800, 600);
  smooth();
  
  initWorld();
  initSound();
  initStage();
  initBall();
}

void draw(){
  background(color(0, 0, 0));
  world.draw();
  world.step();
  
  textSize(20);
  text("Stage: " + (stage+1), width-120, 50);
  text("Life: " + life, width-120, 80);
  
  if(isFail()){
    initBall();
  }
}

void initWorld(){
  Fisica.init(this);
  world = new FWorld();
  world.setGravity(0, 1000);
  world.setEdges(0, -100, width, height+100, color(105,105,105));
}

void initBall(){
  ball = new Ball(30, 100, 0);
  world.add(ball);
  
  fall_sound.rewind();
  fall_sound.play();
}

void contactStarted(FContact contact){

  if(contact.contains(ball, goal)){
    println("clear stage" + stage);
    clear_sound.rewind();
    clear_sound.play();
    world.remove(ball);
    
    stage = ((stage + 1) % MAX_STAGE);
    
    initStage();
    initBall();
  }
  
}

void initSound(){
  Minim minim = new Minim(this);
  
  fall_sound = minim.loadFile("sound/fall.mp3");
  clear_sound = minim.loadFile("sound/clear.mp3");
  fail_sound = minim.loadFile("sound/fail.mp3");
}

void initStage(){
 
  slopes = new ArrayList<Slope>();
  world.clear();
  
  if(stage == 0){
   
    Slope slope1 = new Slope(400, 10);
    slope1.setPosition(250, 200);
    slope1.rotate(5*UNIT_ANGLE);
    slopes.add(slope1);
   
    Slope slope2 = new Slope(400, 10);
    slope2.setPosition(550, 400);
    slope2.rotate(5*UNIT_ANGLE);
    slopes.add(slope2);
    
    goal = new Goal(50, 250, 550);
  }
  else if(stage == 1){
    
    Slope slope1 = new Slope(200, 10);
    slope1.setPosition(150, 100);
    slope1.rotate(5*UNIT_ANGLE);
    slopes.add(slope1);
    
    Slope slope2 = new Slope(100, 10);
    slope2.setPosition(300, 200);
    slope2.rotate(25*UNIT_ANGLE);
    slopes.add(slope2);
    
    Slope slope3 = new Slope(200, 10);
    slope3.setPosition(450, 300);
    slope3.rotate(45*UNIT_ANGLE);
    slopes.add(slope3);
    
    Slope slope4 = new Slope(100, 10);
    slope4.setPosition(600, 400);
    slope4.rotate(65*UNIT_ANGLE);
    slopes.add(slope4);
    
    goal = new Goal(50, 700, 550);
  }
  else if(stage == 2){
    
    Slope slope1 = new Slope(350, 10);
    slope1.setPosition(200, 100);
    slope1.rotate(5*UNIT_ANGLE);
    slopes.add(slope1);
   
    Slope slope2 = new Slope(350, 10);
    slope2.setPosition(600, 250);
    slope2.rotate(5*UNIT_ANGLE);
    slopes.add(slope2);
    
    Slope slope3 = new Slope(350, 10);
    slope3.setPosition(200, 400);
    slope3.rotate(5*UNIT_ANGLE);
    slopes.add(slope3);
    
    goal = new Goal(50, 375, 550);
    
  }
  
  for(Slope slope: slopes){
    world.add(slope);
  }
  world.add(goal);
  
}

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

void mouseDragged(){
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

class Ball extends FCircle{
  
  Ball(float radius, float circle_x, float circle_y){
    super(radius);
    this.setPosition(circle_x, circle_y);
    this.setFillColor(color(255, 255, 0));
    this.setStrokeColor(color(255, 255, 0));
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

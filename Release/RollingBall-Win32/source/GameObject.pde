// ボール
class Ball extends FCircle{
  
  static final int radius = 30;
  float init_x;
  float init_y = 0;
  
  Ball(float init_x){
    super(radius);
    this.init_x = init_x;
    this.setGrabbable(false);
    this.setRestitution(0.5);
    this.setFriction(0);
    this.setPosition(init_x, init_y);
    this.setFillColor(color(255, 255, 0));
    this.setStrokeColor(color(255, 255, 0));
  }
  
  void reset(){
    this.setPosition(init_x, init_y);
  }
  
  void move(float x, float y){
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
    this.setRestitution(0.5);
    this.setFillColor(color(255));
    this.setStrokeColor(color(255));
  }
  
  void rotate(float angle){
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
    this.setRestitution(0.5);
    this.setRotation(angle);
    this.setFriction(0);
    this.setFillColor(color(0, 0, 255));
    this.setStrokeColor(color(0, 0, 255));
  }
  
  void update(){
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

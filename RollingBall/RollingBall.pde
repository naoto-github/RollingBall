import fisica.*;

FWorld world;
FCircle circle;
FPoly poly;

void setup(){
  size(800, 600); //ウィンドウサイズ
  smooth(); //アンチエイリアス
  
  Fisica.init(this);
  
  world = new FWorld();
  world.setGravity(0, 1000);
  //world.setEdges(color(255, 255, 0));
  
  circle = new FCircle(30);
  circle.setFillColor(color(255, 255, 0));
  circle.setStrokeColor(color(255, 255, 0));
  circle.setPosition((width / 2), 0);
  world.add(circle);
  
  poly = new FPoly();
  poly.setStatic(true);
  poly.vertex(0, 200);
  poly.vertex(700, 250);
  poly.vertex(700, 260);
  poly.vertex(0, 210);
  world.add(poly);
  
}

void draw(){
  background(color(0, 0, 0));
  world.draw();
  world.step();
}

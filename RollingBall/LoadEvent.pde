// JSONのロード
void loadStage(String filename){
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

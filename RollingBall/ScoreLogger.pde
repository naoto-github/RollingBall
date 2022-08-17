class ScoreLog implements Comparable{
  
  public String uuid;
  public int stage;
  public int time;
  public int gravity;
  
  public ScoreLog(int stage, int time, int gravity){
    this.uuid = UUID.randomUUID().toString();
    this.stage = stage;
    this.time = time;
    this.gravity = gravity;
  }
  
  public ScoreLog(String uuid, int stage, int time, int gravity){
    this.uuid = uuid;
    this.stage = stage;
    this.time = time;
    this.gravity = gravity;
  }
  
  public int compareTo(Object obj){
    ScoreLog s2 = (ScoreLog)obj;
    int value = s2.stage - this.stage;
    println(s2.stage + " " + this.stage + " " + value);
    return value;
    
    /*
    if(this.gravity < s2.gravity){
          return 1;
    }
    else{
      if(this.stage < s2.stage){
        return 1;
      }
      else{
        if(this.time > s2.time){
          return 1;
        }
      }
    }
    
    return -1;
    */
    
  }
  
}

class ScoreList extends ArrayList<ScoreLog>{
  
  public String log_file = "./log/score_log.json";
  
  public ScoreList(){
    super();
  }
  
  public boolean add(ScoreLog score_log){
    return super.add(score_log);
  }
  
  public void save(){
    
    JSONArray json_array = new JSONArray();
    
    for(ScoreLog score_log: this){
      JSONObject json_object = new JSONObject();
      json_object.setString("uuid", score_log.uuid);
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
        int stage = json_object.getInt("stage");
        int time = json_object.getInt("time");
        int gravity = json_object.getInt("gravity");
        
        ScoreLog score_log = new ScoreLog(uuid, stage, time, gravity);
        add(score_log);
      }
      
    }
    catch(NullPointerException e){
      println("Initialize log file");
    }
  }
  
  public String toString(){
    StringBuffer sb = new StringBuffer();
    for(ScoreLog s: this){
      sb.append(s.uuid + " Gravity:" + s.gravity + " Stage:" + s.stage + " Time:" + s.time + "\n");
    }
    return sb.toString();
  }
}

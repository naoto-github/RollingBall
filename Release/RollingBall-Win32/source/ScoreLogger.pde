class ScoreLog implements Comparable{
  
  public String uuid;
  public int score;
  public int stage;
  public int time;
  public int gravity;
  
  public ScoreLog(int stage, int time, int gravity){
    this.uuid = UUID.randomUUID().toString();
    this.score = stage * gravity - int(time / 100);
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

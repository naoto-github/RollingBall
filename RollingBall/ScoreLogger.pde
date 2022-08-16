JSONArray score_array = new JSONArray();
String LOG_FILE = "./log/score_log.json";

void loadScoreLog(){
  try{
    score_array = loadJSONArray(LOG_FILE);
    println(score_array);
    score_array = sortScoreLog(score_array);
    println(score_array);
    saveJSONArray(score_array,  LOG_FILE);
  }
  catch(NullPointerException e){
    println("Init score_log.json");
  }
}

String saveScoreLog(int stage, float total_time, int gravity){
    JSONObject score_object = new JSONObject();
    String uuid = UUID.randomUUID().toString();
    score_object.setString("uuid", uuid);
    score_object.setInt("stage", stage);
    score_object.setInt("time", (int)total_time);
    score_object.setInt("gravity", gravity);
    score_array.append(score_object);
    score_array = sortScoreLog(score_array);
    saveJSONArray(score_array,  LOG_FILE);
    return uuid;
}

void exchangeScore(JSONObject score_object1, JSONObject score_object2){
  String uuid1 = score_object1.getString("uuid");
  String uuid2 = score_object2.getString("uuid");
  
  int stage1 = score_object1.getInt("stage");
  int stage2 = score_object2.getInt("stage");
  
  int time1 = score_object1.getInt("time");
  int time2 = score_object2.getInt("time");
  
  int gravity1 = score_object1.getInt("gravity");
  int gravity2 = score_object2.getInt("gravity");   
  
  score_object1.setString("uuid", uuid2);
  score_object2.setString("uuid", uuid1);
  
  score_object1.setInt("stage", stage2);
  score_object2.setInt("stage", stage1);
  
  score_object1.setInt("time", time2);
  score_object2.setInt("time", time1);
  
  score_object1.setInt("gravity", gravity2);
  score_object2.setInt("gravity", gravity1);
  
}

JSONArray sortScoreLog(JSONArray score_array){
  if(score_array.size() >= 2){
    // バブルソート
    for(int i=0; i<score_array.size()-1; i++){
      for(int j=0; j<score_array.size()-1; j++){
        JSONObject score_object1 = score_array.getJSONObject(j);
        JSONObject score_object2 = score_array.getJSONObject(j+1);
        
        int stage1 = score_object1.getInt("stage");
        int stage2 = score_object2.getInt("stage");
        
        int time1 = score_object1.getInt("time");
        int time2 = score_object2.getInt("time");
        
        int gravity1 = score_object1.getInt("gravity");
        int gravity2 = score_object2.getInt("gravity");           
 
       if(gravity1 < gravity2){
         exchangeScore(score_object1, score_object2);
       }
       else{
         if(stage1 < stage2){
           exchangeScore(score_object1, score_object2);
         }
         else{
           if(time1 > time2){
             exchangeScore(score_object1, score_object2);
           }
         }
       }        
      }
    }
  }
  
  return score_array;
}

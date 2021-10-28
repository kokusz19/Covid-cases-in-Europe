class Date{
  int representation, day, month, year;
  Date(){}
  Date(int locDay, int locMonth, int locYear){
    day = locDay;
    month = locMonth;
    year = locYear;
    representation = year*365+month*31+day;
  }
  
  int getRepresentation(){
    return year*365+month*31+day;
  }
  int getRepresentationFromValue(int locDay, int locMonth, int locYear){
    return locYear*365+locMonth*31+locDay;
  }
  
  Date getValueFromRepresentation(int representation){
    int tmpYear = floor((float)representation/365);
    int tmpMonth = floor((float)(representation-tmpYear*365)/31);
    int tmpDay = representation-tmpYear*365-tmpMonth*31+1;
    convert(tmpDay, tmpMonth, tmpYear);
    Date tmpDate = new Date(tmpDay, tmpMonth, tmpYear);    
    return tmpDate;
  }
  
  String toString(){
    convert(day, month, year);
    return year+"."+month+"."+day;
  }
  
  void convert(int locDay, int locMonth, int locYear){
    if(locMonth == 2 || locMonth == 4 || locMonth == 6 || locMonth == 9 || locMonth == 11){
      if(locDay == 31){
        locDay = 1;
        locMonth += 1;
      }
      if(locMonth == 2){
        if(locDay == 30){
          locDay = 1;
          locMonth += 1;
        }
        if(locDay == 29 && locYear%4!=0){
           locDay = 1;
           locMonth += 1;
        }
      }
    }
  }
}

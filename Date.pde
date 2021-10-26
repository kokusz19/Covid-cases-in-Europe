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
    Date tmpDate = new Date(tmpDay, tmpMonth, tmpYear);    
    return tmpDate;
  }
  
  String toString(){
    return year+"."+month+"."+day;
  }
  
  // TODO: update
  // https://forum.processing.org/one/topic/converting-day-month-year-to-the-day-of-year.html
}

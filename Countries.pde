class Countries{
 int number;
 String shortName;
 String longName;
 
 Countries(int tmpNumber, String tmpShortName, String tmpLongName){
  number = tmpNumber;
  shortName = tmpShortName;
  longName = tmpLongName;
 }
 
 String toString(){
   return number + " " + shortName + " " + longName; 
 }
}

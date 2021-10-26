PShape europe;
Table table;
int minDay = 31, minMonth = 12, minYear = 3000;
int maxDay = 0, maxMonth = 0, maxYear = 0;
Date minDate, maxDate;
HScrollbar scrollbar;


void setup(){
  size(1050, 750);
  europe = loadShape("europe.svg");
  table = loadTable("data.csv", "header");
  
  getMinMaxDates();
  //getMinMaxDates(true);
  minDate = new Date(minDay, minMonth, minYear);
  maxDate = new Date(maxDay, maxMonth, maxYear);
  Date tmpDate = new Date();
  //println(minDate.toString() + "\t" + minDate.getRepresentationFromValue() + "\t" + tmpDate.getValueFromRepresentation(minDate.getRepresentationFromValue()));
  //println(maxDate.toString() + "\t" + maxDate.getRepresentationFromValue() + "\t" + tmpDate.getValueFromRepresentation(maxDate.getRepresentationFromValue()));

  scrollbar = new HScrollbar(25, height-50, width-50, 16,  1);
}

void draw(){
  background(230);
  for(int i = 0; i < europe.getChildCount(); i++){
    europe.getChild(i).setFill(color(5*i, 5*i, 5*i));   
    shape(europe.getChild(i));  
  }
  text(minDate.toString(), 25, height-25);
  text(maxDate.toString(), width-95, height-25);
  
  Date tmpDate = new Date();
  int diff = floor((maxDate.getRepresentation()-minDate.getRepresentation())*floor(scrollbar.getPos())/1000)-7;
  Date chosenDate = tmpDate.getValueFromRepresentation(minDate.getRepresentation() + diff);
  text(chosenDate.toString(), width/2, height-25);
  
  scrollbar.update();
  scrollbar.display();
  }


void getMinMaxDates(){
  getMinMaxDates(false);
}
void getMinMaxDates(boolean showDetails){
  // Get Min and Max Year
  for(int i = 0; i < table.getRowCount(); i++){
    if(table.getRow(i).getColumnTitle(3).equals("year")){
      if(table.getRow(i).getInt(3) < minYear)
        minYear = table.getRow(i).getInt(3);
      if(table.getRow(i).getInt(3) > maxYear)
        maxYear = table.getRow(i).getInt(3);
    }
  }
  // Get Min and Max Month
  for(int i = 0; i < table.getRowCount(); i++){
    if(table.getRow(i).getColumnTitle(2).equals("month")){
      if(table.getRow(i).getInt(3) == minYear && table.getRow(i).getInt(2) < minMonth)
        minMonth = table.getRow(i).getInt(2);
      if(table.getRow(i).getInt(3) == maxYear && table.getRow(i).getInt(2) > maxMonth)
        maxMonth = table.getRow(i).getInt(2);
    }
  }
  // Get Min and Max Day
  for(int i = 0; i < table.getRowCount(); i++){
    if(table.getRow(i).getColumnTitle(1).equals("day")){
      if(table.getRow(i).getInt(3) == minYear && table.getRow(i).getInt(2) == minMonth && table.getRow(i).getInt(1) < minDay)
        minDay = table.getRow(i).getInt(1);
      if(table.getRow(i).getInt(3) == maxYear && table.getRow(i).getInt(2) == maxMonth && table.getRow(i).getInt(1) > maxDay)
        maxDay = table.getRow(i).getInt(1);
    }
  }
  if(showDetails){
      print("Minimum Date: " + minYear + "." + minMonth + "." + minDay + ".\nMaximum Date: " + maxYear + "." + maxMonth + "." + maxDay + ".");
  }
}

PShape europe;
Table table;
Table sortedTable;
int minDay = 31, minMonth = 12, minYear = 3000;
int maxDay = 0, maxMonth = 0, maxYear = 0;
Date minDate, maxDate;
HScrollbar scrollbar;
int maxCases = 0;
TableRow maxCase;

boolean test = true;

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
    
  scrollbar.update();
  scrollbar.display();

  text(minDate.toString(), 25, height-25);
  text(maxDate.toString(), width-95, height-25);
  
  Date tmpDate = new Date();
  int diff = floor((maxDate.getRepresentation()-minDate.getRepresentation())*floor(scrollbar.getPos())/1000)-7;
  
  Date chosenDate = new Date();
  try{
    chosenDate = tmpDate.getValueFromRepresentation(minDate.getRepresentation() + diff);
    text(chosenDate.toString(), width/2, height-25);
  
    sortedTable = loadTable("data.csv", "header");
    for(int i = sortedTable.getRowCount()-1 ; i >= 0; i--){
      if(sortedTable.getRow(i).getInt(1) != chosenDate.day || sortedTable.getRow(i).getInt(2) != chosenDate.month || sortedTable.getRow(i).getInt(3) != chosenDate.year){
        sortedTable.removeRow(i); 
      }
    }    
  } catch(ArrayIndexOutOfBoundsException e){
    chosenDate = tmpDate.getValueFromRepresentation(chosenDate.getRepresentation()-1);
  }


  maxCase = sortedTable.getRow(0);
  
  for(int i = sortedTable.getRowCount()-1 ; i >= 0; i--){
    if(maxCase.getInt(4) < sortedTable.getRow(i).getInt(4)){
       maxCase = sortedTable.getRow(i);
    }
  }
  println(maxCase.getString(6) + " had the max case of " + maxCase.getInt(4) + " at " + maxCase.getString(0));

  for(int i = 0; i < europe.getChildCount(); i++){
    europe.getChild(i).setFill(color(5*i, 5*i, 5*i));   
    shape(europe.getChild(i));  
  }

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

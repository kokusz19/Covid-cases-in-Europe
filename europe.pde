PShape europe;
Table table;
Table sortedTable;
Date minDate, maxDate;
HScrollbar scrollbar;
TableRow maxCase;
TableRow chosenCountry;
Countries[] countries;
int countriesCount = 0;

boolean test = true;

void setup(){
  size(1050, 750);
  // Load in Europe SVG and Data CSV
  europe = loadShape("europe.svg");
  table = loadTable("data.csv", "header");
  
  // Find minimum and maximum dates in the CSV
  getMinMaxDates();
  
  // Create scrollbar
  scrollbar = new HScrollbar(25, height-50, width-50, 16,  1);
  
  countries = new Countries[europe.getChildCount()];
  populateCountries();
  
  //for(int i = 0; i < countriesCount; i++){
  //  println(countries[i].toString()); 
  //}
  
}

void draw(){
  background(230);
    
  // Scrollbar + text
  scrollbar.update();
  scrollbar.display();
  text(minDate.toString(), 25, height-25);
  text(maxDate.toString(), width-95, height-25);
  
  // Get the chosen date from the scrollbar
  updateChosenDate();
  // Get the country with the max case for the chosen date
  getMaxCase();
    
  //println(maxCase.getString(6) + " had the max case of " + maxCase.getInt(4) + " at " + maxCase.getString(0));
  for(int i = 0; i < countriesCount; i++){
    float fillValue = 0;
    for(int j = 0; j < sortedTable.getRowCount(); j++){
      if(sortedTable.getRow(j).getString(7).equals(countries[i].shortName)){
        float divide = (float)sortedTable.getRow(j).getInt(4)/ (float)maxCase.getInt(4);
          fillValue = divide*255;
        //Fill value test
        println(sortedTable.getRow(j).getString(7) + " " + sortedTable.getRow(j).getInt(4) + "/" +maxCase.getInt(4) + " is " + divide + " " + fillValue);
      }
    }
    // TODO update
    // countries (only Europe SVG) vs sortedTable (only Covid "EU" dates)
    europe.getChild(i).setFill(color((int)(1/fillValue), 230, 30, 30));  
    shape(europe.getChild(i));  
  }
  findChosenCountry();
}

void updateChosenDate(){
   // Chosen date update
  Date tmpDate = new Date();
  int diff = floor((maxDate.getRepresentation()-minDate.getRepresentation())*floor(scrollbar.getPos())/1000)-7;
  Date chosenDate = new Date();
  try{
    chosenDate = tmpDate.getValueFromRepresentation(minDate.getRepresentation() + diff);
    text(chosenDate.toString(), width/2, height-25);
    sortedTable = loadTable("data.csv", "header");
    for(int i = sortedTable.getRowCount()-1 ; i >= 0; i--)
      if(sortedTable.getRow(i).getInt(1) != chosenDate.day || sortedTable.getRow(i).getInt(2) != chosenDate.month || sortedTable.getRow(i).getInt(3) != chosenDate.year)
        sortedTable.removeRow(i);
  } catch(ArrayIndexOutOfBoundsException e){
    chosenDate = tmpDate.getValueFromRepresentation(chosenDate.getRepresentation()-1);
  }
}

void getMaxCase(){
  maxCase = sortedTable.getRow(0);
  for(int i = sortedTable.getRowCount()-1 ; i >= 0; i--)
    if(maxCase.getInt(4) < sortedTable.getRow(i).getInt(4))
       maxCase = sortedTable.getRow(i);

  // Print country with info with the max cases
  text("Country: " + maxCase.getString(6) + "\nCases: " + maxCase.getInt(4) + "\nDeaths: " + maxCase.getInt(5), 0, 10);
}

void findChosenCountry(){
  fill(255, 0, 0);
  // last 3 children was a circle
  for(int i = 0; i < europe.getChildCount()-3; i++)
     if(europe.getChild(i).contains(mouseX, mouseY)){
       //text("asd", mouseX, mouseY);
       for(int j = 0; j < sortedTable.getRowCount(); j++)
         // Europe SVG Country = chosen country
         if(sortedTable.getRow(j).getString(7).equals(countries[i].shortName))
           // Show the name, cases and deaths of the chosen country
           text(sortedTable.getRow(j).getString(6) + "\nCases: " + sortedTable.getRow(j).getInt(4) + "\nDeaths: " + sortedTable.getRow(j).getInt(5), mouseX, mouseY-30);  
     }
}

void populateCountries(){
  // Get all the lines from the Europe SVG
  String[] lines = loadStrings("europe.svg");
  for(int i = 0 ; i < lines.length; i++){
    if(lines[i].startsWith(" <path")){
      // Check all the pathes (countries)
      String[] elements = lines[i].split(" ");
      String tmpShortName = "", tmpLongName = "";
      for(int j = 0; j < elements.length; j++){
          // Get the short name of each country
          if(elements[j].startsWith("id")){
            String[] tmp = elements[j].split("=");
            tmpShortName = tmp[1].replace('"', ' ').trim();
          }
          // Get the long name of each country
          if(elements[j].startsWith("name")){
            String[] tmp = elements[j].split("=");
            tmpLongName = tmp[1].replace('"', ' ').replace(">", " ").trim();
          }
      }
      // Save all the countries present in the Europe SVG
      countries[countriesCount] = new Countries(countriesCount, tmpShortName, tmpLongName);
      countriesCount++;
    }
  }
  //for(int i = 0; i < countriesCount; i++)
  //  println(countries[i].toString());
}

void getMinMaxDates(){
  getMinMaxDates(false);
}
void getMinMaxDates(boolean showDetails){
  int minDay = 31, minMonth = 12, minYear = 3000;
  int maxDay = 0, maxMonth = 0, maxYear = 0;

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
  
  minDate = new Date(minDay, minMonth, minYear);
  maxDate = new Date(maxDay, maxMonth, maxYear);
  
  
  if(showDetails){
      print("Minimum Date: " + minYear + "." + minMonth + "." + minDay + ".\nMaximum Date: " + maxYear + "." + maxMonth + "." + maxDay + ".");
  }
}

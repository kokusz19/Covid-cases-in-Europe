// Showing the COVID-19 cases by countries for each day
// data.csv  (if you want to use an updated one)
//    https://www.ecdc.europa.eu/en/publications-data/data-daily-new-cases-covid-19-eueea-country
// europe.svg
//    https://simplemaps.com/resources/svg-europe
// There are countries, which there are no COVID cases or in the data.csv (e.g. not EU countries anymore, etc)
// These countries are coloured with grey

PShape europe;
Table table;
Table sortedTable;
Date minDate, maxDate;
HScrollbar scrollbar;
TableRow maxCase;
TableRow chosenCountry;
Countries[] countries;
int countriesCount = 0;
boolean firstPanelSelected = true;
Button panel1, panel2, panel3;

void setup(){
  size(1050, 800);
  // Load in Europe SVG and Data CSV
  europe = loadShape("europe.svg");
  table = loadTable("data.csv", "header");
  
  panel1 = new Button(0, 0, 115, 45);
  panel2 = new Button(115, 0, 205, 45);
  panel3 = new Button(200, 0, width, 45);
  
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
  // Create Buttons with upper panel
  createUpperPanel();
  panel1.update();
  panel2.update();
  
  // Show world map
  if(firstPanelSelected){
    // Scrollbar + text
    scrollbar.update();
    scrollbar.display();
    text(minDate.toString(), 25, height-25);
    text(maxDate.toString(), width-95, height-25);
    
    // Get the chosen date from the scrollbar
    updateChosenDate();
    // Get the country with the max case for the chosen date
    getMaxCase();
    // Give a basic colour to all countries
    basicColourCountries();
    // Give a colour to all countries based on their covid cases
    colourCountries();
    findChosenCountry();
  }
  // Show graph
  else{
    // Scrollbar + text
    scrollbar.update();
    scrollbar.display();
    text(minDate.toString(), 25, height-25);
    text(maxDate.toString(), width-95, height-25);
    
    // Get the chosen date from the scrollbar
    updateChosenDate();

  }
}
void mousePressed() {
  if (panel1.rectOver) {
    panel1.currentColor = panel1.selectedColor;
  firstPanelSelected = true;
  }
  if (panel2.rectOver) {
    panel2.currentColor = panel2.selectedColor;
  firstPanelSelected = false;
  }
}
void createUpperPanel(){
  if(firstPanelSelected){
    createButton(panel1, true);
    createButton(panel2, false);
    createButton(panel3, false);
  } else{
    createButton(panel1, false);
    createButton(panel2, true);
    createButton(panel3, false);
  }
  fill(0);
  text("Show world map", 10, 25);
  fill(0);
  text("Show graph", 125, 25);
}
void createButton(Button button, boolean selected){
    if(selected)
      button.currentColor = button.selectedColor;
    else
      button.currentColor = button.currentColor;
    fill(button.currentColor);
    noStroke();
    rect(button.rectX, button.rectY, button.rectXSize, button.rectYSize);
}

void updateChosenDate(){
   // Chosen date update
  Date tmpDate = new Date();
  int diff = floor((maxDate.getRepresentation()-minDate.getRepresentation())*floor(scrollbar.getPos())/1000)-7;
  Date chosenDate = new Date();
  try{
    chosenDate = tmpDate.getValueFromRepresentation(minDate.getRepresentation() + diff);
  } catch(ArrayIndexOutOfBoundsException e){
    chosenDate = tmpDate.getValueFromRepresentation(chosenDate.getRepresentation()-3);
    scrollbar.setPos(scrollbar.getPos()-3);
  }
  sortedTable = loadTable("data.csv", "header");
  for(int i = sortedTable.getRowCount()-1 ; i >= 0; i--){
    if(chosenDate.month == 2 || chosenDate.month == 4 || chosenDate.month == 6 || chosenDate.month == 9 || chosenDate.month == 11){
      if(chosenDate.day == 31)
          reduceChosenDate(chosenDate);
      if(chosenDate.month == 2){
        if(chosenDate.day == 30)
          reduceChosenDate(chosenDate);
        if(chosenDate.day == 29 && chosenDate.year%4!=0)
          reduceChosenDate(chosenDate);
      }
    }
    text(chosenDate.toString(), width/2, height-25);
    if(sortedTable.getRow(i).getInt(1) != chosenDate.day || sortedTable.getRow(i).getInt(2) != chosenDate.month || sortedTable.getRow(i).getInt(3) != chosenDate.year)
      sortedTable.removeRow(i);
  }
}

void reduceChosenDate(Date chosenDate){
  chosenDate.day = 1;
  chosenDate.month += 1;
}

void getMaxCase(){
  maxCase = sortedTable.getRow(0);
  for(int i = sortedTable.getRowCount()-1 ; i >= 0; i--)
    if(maxCase.getInt(4) < sortedTable.getRow(i).getInt(4))
       maxCase = sortedTable.getRow(i);
  // Print country with info with the max cases
  text("Country: " + maxCase.getString(6) + "\nCases: " + maxCase.getInt(4) + "\nDeaths: " + maxCase.getInt(5), 0, 60);
}

void basicColourCountries(){
  for(int i = 0; i < countriesCount; i++){
    for(int j = 0; j < sortedTable.getRowCount(); j++){
      if(sortedTable.getRow(j).getString(7).equals(countries[i].shortName)){
        europe.getChild(i).setFill(color(0, 230, 0, 25));  
        shape(europe.getChild(i), 0, 50);
      }
    }
  }
}

void colourCountries(){
   for(int i = 0; i < countriesCount; i++){
    float fillValue = 0;
    boolean found = false;
    for(int j = 0; j < sortedTable.getRowCount(); j++){
      if(sortedTable.getRow(j).getString(7).equals(countries[i].shortName)){
        found = true;
        float divide = (float)sortedTable.getRow(j).getInt(4)/ (float)maxCase.getInt(4);
          fillValue = divide*255;
        //Fill value test
        //println(sortedTable.getRow(j).getString(7) + " " + sortedTable.getRow(j).getInt(4) + "/" +maxCase.getInt(4) + " is " + divide + " " + fillValue);
        europe.getChild(i).setFill(color(230, 30, 30, (int)fillValue));  
        shape(europe.getChild(i), 0, 50);
      }
    }
    if(!found){
      europe.getChild(i).setFill(color(15, 15, 15, 180));  
      shape(europe.getChild(i), 0, 50);
    }
  }
}

void findChosenCountry(){
  fill(0);
  // last 3 children was a circle
  for(int i = 0; i < europe.getChildCount()-3; i++)
     if(europe.getChild(i).contains(mouseX, mouseY-50)){
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

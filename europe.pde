// Showing the COVID-19 cases by countries for each day
// data.csv  (if you want to use an updated one)
//    https://www.ecdc.europa.eu/en/publications-data/data-daily-new-cases-covid-19-eueea-country
// europe.svg
//    https://simplemaps.com/resources/svg-europe
// There are countries, which there are no COVID cases or in the data.csv (e.g. not EU countries anymore, etc)
// These countries are coloured with grey

// To use the barchart tab, you have to get the GiCentre library
//    http://gicentre.org/utils/gicentreUtils.zip
// To install this library
//  1) Locate your Processing folder's "libraries" folder (e.g. "C:\Users\Kokusz\Documents\Processing\libraries")
//  2) Create a "gicentreUtils" folder inside of it and a "library" folder inside of this one (e.g. "C:\Users\Kokusz\Documents\Processing\libraries\gicentreUtils\library")
//  3) Move the "gicentreUtils.jar" from the previously downloaded "gicentreUtils.zip" to this folder
//  4) Restart Processing

// To use ControlP5 library, download it from the below link and use the previously mentioned method to install it
//    http://www.sojamo.de/libraries/controlP5/

import org.gicentre.utils.stat.*;
import controlP5.*;

PShape europe;
Table table;
Table sortedTable, countryTable, countryTable2;
Date minDate, maxDate, chosenDate;
HScrollbar scrollbar;
TableRow maxCase;
TableRow chosenCountry;
Countries[] countries;
Countries[] finalCountries;
int countriesCount = 0;
int panelSelected = 1;
Button panel1, panel2, panel3, panel4;
BarChart barchart;
XYChart linechart, linechart2;
ControlP5 cp5;
ControlP5 cp6;
DropdownList dl;
DropdownList dl2;
RadioButton rb;

void setup(){
  size(1050, 800);
  // Load in Europe SVG and Data CSV
  europe = loadShape("europe.svg");
  table = loadTable("data.csv", "header");
    
  // Create the upper panels of the window
  panel1 = new Button(0, 0, 115, 45);
  panel2 = new Button(115, 0, 250, 45);
  panel3 = new Button(250, 0, 375, 45);
  panel4 = new Button(375, 0, width, 45);
  
  chosenDate = new Date();

  // Create a barchart
  barchart = new BarChart(this);
  cp5 = new ControlP5(this);
  cp6 = new ControlP5(this);
  linechart = new XYChart(this);
  linechart2 = new XYChart(this);

  // Find minimum and maximum dates in the CSV
  getMinMaxDates();
  
  // Create scrollbar
  scrollbar = new HScrollbar(25, height-50, width-50, 16,  1);
  
  countries = new Countries[europe.getChildCount()];
  populateCountries();
}

void draw(){
  background(230);
  // Create Buttons with upper panel
  createUpperPanel();
  // Update the 2 upper panel
  panel1.update();
  panel2.update();
  panel3.update();
  
  // Show world map
  if(panelSelected == 1){
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
    // Show info for the country, which contains the mouse coordinates
    findChosenCountry();
    // Sshow colour scale
    colourScale(15,150,40,100);

    // Don't show a barchart or radiobutton on this page
    if(dl != null){
      dl.remove();
      dl = null;
      dl2.remove();
      dl2 = null;
    } if(rb != null){
      rb.remove();
      rb = null;
    }
  }
  // Show graph
  else if(panelSelected == 2){
    // Get max cases for the day
    getMaxCase(false);

    // Scrollbar + text
    scrollbar.update();
    scrollbar.display();
    text(minDate.toString(), 25, height-25);
    text(maxDate.toString(), width-95, height-25);
    
    // Get the chosen date from the scrollbar
    updateChosenDate();

    // Don't show a barchart on this page
    if(dl != null){
      dl.remove();
      dl = null;
      dl2.remove();
      dl2 = null;
    }
    if(rb == null)
      createRadioButton();
    
    boolean showCases = rb.getState(0);
    
    // Create the barchart for this panel
    showBarChart(showCases);

  }
  // Show linechart for country
  else if(panelSelected == 3){
    // Show a barchart on this page (customized)
    // Create a dropdownlist with it's elements
    if(dl == null){
      dl = cp5.addDropdownList("Please select a country").setPosition(15, 60);
      dl2 = cp6.addDropdownList("Please select a country").setPosition(150, 60);
      customizeDL(dl, color(1, 150, 32));
      customizeDL(dl2, color(0, 51, 102));
    } if(rb != null){
      rb.remove();
      rb = null;
    }
    if((dl.getValue() != 0.0 || dl.getLabel().equals(" ("+finalCountries[0].shortName+") " + finalCountries[0].longName)) && (dl2.getValue() != 0.0 || dl2.getLabel().equals(" ("+finalCountries[0].shortName+") " + finalCountries[0].longName))){
      Countries chosenCountry = finalCountries[(int)dl.getValue()];
      Countries chosenCountry2 = finalCountries[(int)dl2.getValue()];
      
      countryTable = loadTable("data.csv", "header");
      countryTable2 = loadTable("data.csv", "header");
      // Remove not chosen countries from countryTable
      for(int i = countryTable.getRowCount()-1 ; i >= 0; i--)
        if(!countryTable.getRow(i).getString(7).equals(chosenCountry.shortName))
          countryTable.removeRow(i);
      for(int i = countryTable2.getRowCount()-1 ; i >= 0; i--)
        if(!countryTable2.getRow(i).getString(7).equals(chosenCountry2.shortName))
          countryTable2.removeRow(i);

      float globalMax = 0;
      for(int i = 0; i < countryTable.getRowCount()-2; i++)
        if(globalMax < Float.parseFloat(countryTable.getRow(i).getString(4)))
          globalMax = Float.parseFloat(countryTable.getRow(i).getString(4));
      for(int i = 0; i < countryTable2.getRowCount()-2; i++)
        if(globalMax < Float.parseFloat(countryTable2.getRow(i).getString(4)))
          globalMax = Float.parseFloat(countryTable2.getRow(i).getString(4));
      showLineChart(countryTable, linechart, color(1, 150, 32), globalMax);
      showLineChart(countryTable2, linechart2, color(0, 51, 102), globalMax);
      //fill(color(1, 150, 32));
      //text(chosenCountry.longName, 285, 75);
      //fill(color(0, 51, 102));
      //text(chosenCountry2.longName, 285, 90);
    }
  }
}

void colourScale(int fromX, int fromY, int width, int height){
  color maxColour = color(0, 230, 0, 25);
  color minColour = color(230, 30, 30);

  for (int i = fromY; i <= fromY+height; i++) {
    float inter = map(i, fromY, fromY+height, 0, 1);
    color c = lerpColor(minColour, maxColour, inter);
    stroke(c);
    line(fromX, i, fromX+width, i);
  }
  fill(0);
  text(maxCase.getInt(4), fromX, fromY-10);
  text("0", fromX, fromY+height+15);
}

void customizeDL(DropdownList ddl, color labelColor) {
  // a convenience function to customize a DropdownList
  ddl.setHeight(200);
  ddl.setWidth(ddl.getWidth()+25);
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(25);
  ddl.setBarHeight(25);

  // Get all countries
  getCountriesFromData();

  // Adding countries to the dropdown list
  for (int i=0;i<finalCountries.length;i++) {
    if(finalCountries[i] != null)
      ddl.addItem(" (" + finalCountries[i].shortName + ") " + finalCountries[i].longName, i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(185));
  ddl.setColorActive(color(255, 128));
  ddl.setColorLabel(labelColor);
  ddl.setColorValue(color(0));
}

void getCountriesFromData(){
  // Loop through the data.csv and save all of the countries, which have data in it
  int count = 0;
  finalCountries = new Countries[table.getRowCount()];
  //finalCountries[0] = new Countries(0, table.getRow(0).getString(7), table.getRow(0).getString(6));
  for(int i = 1; i < table.getRowCount(); i++){
    boolean found = false;
    for(int j = 0; j < count; j++){
      if(table.getRow(i).getString(7).equals(finalCountries[j].shortName))
        found = true;
    }
    if(!found){
      Countries tmpCountry = new Countries(count, table.getRow(i).getString(7), table.getRow(i).getString(6));
      finalCountries[count] = tmpCountry;
      count += 1;
    }
  }
}

void mousePressed() {
  // Check if the mouse has been clicked inside of a panel
  if (panel1.rectOver) {
    panel1.currentColor = panel1.selectedColor;
  panelSelected = 1;
  }
  if (panel2.rectOver) {
    panel2.currentColor = panel2.selectedColor;
  panelSelected = 2;
  }
  if (panel3.rectOver) {
    panel3.currentColor = panel3.selectedColor;
  panelSelected = 3;
  }
}
void createUpperPanel(){
  // Creating upper panel
  // First panel is selected by default, can be chosen by clicking on the second panel
  if(panelSelected == 1){
    createButton(panel1, true);
    createButton(panel2, false);
    createButton(panel3, false);
    createButton(panel4, false);
  } else if(panelSelected == 2){
    createButton(panel1, false);
    createButton(panel2, true);
    createButton(panel3, false);
    createButton(panel4, false);
  } else if(panelSelected == 3){
    createButton(panel1, false);
    createButton(panel2, false);
    createButton(panel3, true);
    createButton(panel4, false);
  }
  // Text placed in the panels
  fill(0);
  text("Show world map", 10, 25);
  fill(0);
  text("Show graph per day", 125, 25);
  fill(0);
  text("History of country", 260, 25);
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
  Date tmpDate = new Date();
  // diff = 0-1000 representation between the min and max dates
  int diff = floor((maxDate.getRepresentation()-minDate.getRepresentation())*floor(scrollbar.getPos())/1000)-7;
  try{
    chosenDate = tmpDate.getValueFromRepresentation(minDate.getRepresentation() + diff);
  } catch(ArrayIndexOutOfBoundsException e){
    chosenDate = tmpDate.getValueFromRepresentation(chosenDate.getRepresentation()-3);
    scrollbar.setPos(scrollbar.getPos()-3);
  }
  sortedTable = loadTable("data.csv", "header");
  // If the date is not a valid date, set it to the next valid date
  for(int i = sortedTable.getRowCount()-1 ; i >= 0; i--){
    if(chosenDate.month == 2 || chosenDate.month == 4 || chosenDate.month == 6 || chosenDate.month == 9 || chosenDate.month == 11){
      if(chosenDate.day == 31)
          updateChosenDate(chosenDate);
      if(chosenDate.month == 2){
        if(chosenDate.day == 30)
          updateChosenDate(chosenDate);
        if(chosenDate.day == 29 && chosenDate.year%4!=0)
          updateChosenDate(chosenDate);
      }
    }
    // Showing of chosen date
    text(chosenDate.toString(), width/2, height-25);
    // Remove not chosen dates from sortedTable
    if(sortedTable.getRow(i).getInt(1) != chosenDate.day || sortedTable.getRow(i).getInt(2) != chosenDate.month || sortedTable.getRow(i).getInt(3) != chosenDate.year)
      sortedTable.removeRow(i);
  }
}

void updateChosenDate(Date chosenDate){
  // Setting next valid date
  chosenDate.day = 1;
  chosenDate.month += 1;
}

void getMaxCase(){
  getMaxCase(true);
}
void getMaxCase(boolean show){
  maxCase = sortedTable.getRow(0);
  for(int i = sortedTable.getRowCount()-1 ; i >= 0; i--)
    if(maxCase.getInt(4) < sortedTable.getRow(i).getInt(4))
       maxCase = sortedTable.getRow(i);
  // Print country with info with the max cases
  if(show)
  text("Country: " + maxCase.getString(6) + "\nCases: " + maxCase.getInt(4) + "\nDeaths: " + maxCase.getInt(5), 0, 60);
}

void createRadioButton(){
  // Create radiobuttons with the first element being active
  rb = cp5.addRadioButton("radioButton")
                   .setPosition(150, 60)
                   .setSize(40,20)
                   .setColorForeground(color(120))
                   .setColorActive(color(255))
                   .setColorLabel(color(0))
                   .setItemsPerRow(2)
                   .setSpacingColumn(50)
                   .addItem("Cases",0)
                   .addItem("Deaths",1)
                   ;
  rb.activate(0);
       
  for(Toggle t:rb.getItems()) {
    t.getCaptionLabel().setColorBackground(color(255,80));
    t.getCaptionLabel().getStyle().moveMargin(-7,0,0,-3);
    t.getCaptionLabel().getStyle().movePadding(7,0,0,3);
    t.getCaptionLabel().getStyle().backgroundWidth = 45;
    t.getCaptionLabel().getStyle().backgroundHeight = 13;
  }
}
void showBarChart(boolean showCases){
  float maxDeath = 0;   
  
  // Getting the values from the sortedTable in float to be used in the barchart
  float[] cases = new float[sortedTable.getRowCount()];
  float[] deaths = new float[sortedTable.getRowCount()];
  for(int i = 0; i < cases.length; i++){
    cases[i] = Float.parseFloat(sortedTable.getRow(i).getString(4));
    deaths[i] = Float.parseFloat(sortedTable.getRow(i).getString(5));
    if(maxDeath < deaths[i])  maxDeath = deaths[i];
  }

  // Setting the min and max values of cases
  barchart.setMinValue(0);
  if(showCases)
    barchart.setMaxValue(maxCase.getInt(4)*1.1);
  else
    barchart.setMaxValue(maxDeath);
  // Showing axis labels (country names - X, number of cases - Y)
  barchart.showValueAxis(true);
  barchart.setValueFormat("###,###");
  barchart.showCategoryAxis(true);
  
  if(showCases)
    barchart.setData(cases);
  else
    barchart.setData(deaths);
  // Setting the labels for each column
  barchart.setBarLabels(sortedTable.getStringColumn(7));

  // Drawing the barchart
  barchart.draw(25, 50, width-50, height-140);
  barchart.updateLayout();

}
void showLineChart(Table tmpTable, XYChart tmpLineChart, color lineColor, float globalMax){
  // Save and show cases with linechart (saving deaths as well for future usages)
  float[] number = new float[tmpTable.getRowCount()];
  float[] cases = new float[tmpTable.getRowCount()];
  float[] deaths = new float[tmpTable.getRowCount()];
  for(int i = cases.length-1; i >= 0 ; i--){
    number[cases.length-i-1] = cases.length-i-1;
    cases[cases.length-i-1] = Float.parseFloat(tmpTable.getRow(i).getString(4));
    deaths[cases.length-i-1] = Float.parseFloat(tmpTable.getRow(i).getString(5));
  }
  cases[0] = 0;
  cases[1] = 0;
  deaths[0] = 0;
  deaths[1] = 1;
  tmpLineChart.setData(number, cases);
  // Customize linechart
  tmpLineChart.showXAxis(true); 
  tmpLineChart.showYAxis(true); 
  //fill(color(180,50,50,100));
  tmpLineChart.setMinY(0);
  tmpLineChart.setMaxY(globalMax);
  // Symbol colours
  //linechart.setPointColour(color(180,50,50,100));
  tmpLineChart.setPointSize(0);
  tmpLineChart.setLineColour(lineColor);
  tmpLineChart.setLineWidth(2);
  tmpLineChart.draw(70,100,width-110,height-150);
  tmpLineChart.updateLayout();
  textAlign(LEFT);
  text(minDate.toString(), 95, height-25);
  text(maxDate.toString(), width-95, height-25);
  textAlign(CENTER);
  text("Cases for each day\n(i^th day * cases)", 525, height-25);
  textAlign(LEFT);
}

void basicColourCountries(){
  // Set basic light green colouring for each found country
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
  // Loop through all the countries
  for(int i = 0; i < countriesCount; i++){
    float fillValue = 0;
    boolean found = false;
    for(int j = 0; j < sortedTable.getRowCount(); j++){
      // Get the data from data.csv for each country
      // If found, the fill value of the country will be based on it's case value compared to the max cases found for that day
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
    // If not found, will be coloured with gray
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
  // get Min and Max dates without the info (default showDetails=false)
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

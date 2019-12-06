import de.bezier.data.sql.*; //BezierSQLib //<>//
import java.awt.*; //til fonte
import g4p_controls.*; //G4P GUI

SQLite bit; //databasen kaldes bit

ArrayList<Task> tasks = new ArrayList<Task>();
ArrayList<Break> breaks = new ArrayList<Break>();

ArrayList<GButton> removeButtons = new ArrayList<GButton>();
ArrayList<GButton> checkButtons = new ArrayList<GButton>();

int topScreen, buttonScreen;
int timerHour, timerMin;

//kan ændres (anbefales 5 min pause hvert 25. min)
int breakLength = 5;
int breakEvery = 25;

float breakLen;
float breakDist;

void setup() {
  size(600, 900);
  rectMode(CORNERS);
  textSize(15);

  createGUI();
  customGUI();

  bit = new SQLite(this, "POOP.sqlite" );

  stroke(255);
  topScreen = round(height*0.08);
  buttonScreen = round(height*0.89);

  breakLen = (buttonScreen-topScreen)/(540.0/breakLength); //antal min i skærmstørrelse. 9t*60min/t = 540
  breakDist = breakEvery/float(breakLength);


  getTasks();
}



void draw() {
  background(35);

  clock();
  labelText();

  textAlign(CORNER);
  strokeWeight(1);
  for (int i = 0; i < tasks.size(); i++) tasks.get(i).display();
  for (int i = 0; i < breaks.size(); i++) breaks.get(i).display();
}



void customGUI() {
  window1.setLocation(710, 300);
  window1.setVisible(false);

  button1.setFont(new Font("Ariel", Font.PLAIN, 60));
  button2.setFont(new Font("Ariel", Font.PLAIN, 30));
  button3.setFont(new Font("Ariel", Font.PLAIN, 30));
  button4.setFont(new Font("Ariel", Font.PLAIN, 15));
  label1.setFont(new Font("Ariel", Font.PLAIN, 25));
  label2.setFont(new Font("Ariel", Font.PLAIN, 20));
  label3.setFont(new Font("Ariel", Font.PLAIN, 25));
  label4.setFont(new Font("Ariel", Font.PLAIN, 14));
  textfield1.setFont(new Font("Ariel", Font.PLAIN, 20));
  textarea1.setFont(new Font("Ariel", Font.PLAIN, 15));
  dropList1.setFont(new Font("Ariel", Font.PLAIN, 15));
  dropList2.setFont(new Font("Ariel", Font.PLAIN, 15));
}


void labelText() {
  label1.setText("Pause om: "+timerHour+":"+timerMin);
  label2.setText(day()+"/"+month()+"/"+year());
  label3.setText(hour()+":"+minute()+":"+second());
}

void clock() {
  //linje i bund og i top
  stroke(255);
  line(0, topScreen*0.9, width, topScreen*0.9);
  line(0, buttonScreen, width, buttonScreen);

  //afstanden mellem hvert tal
  int d = round((buttonScreen - topScreen)/9);

  textAlign(RIGHT, CENTER);
  fill(255);

  //tal i siden
  for (int i = 8; i < 17; i++) {
    text(i, width*0.99, (i-8)*d+topScreen);
  }

  float y = mapYVal(hour(), minute());

  stroke(255, 0, 10);
  strokeWeight(5);
  //linje der markerer hvornår på dagen det er
  if (hour() >= 8 && hour() <= 16) line(0, y, width, y);

  //timer til pause
  timerHour = 0;
  timerMin = 0;
  if (breaks.size() > 0) {
    Break nextBreak = null;
    for (int i = 0; i < breaks.size(); i++) {
      //om pausen er efter klokkeslet
      if (breaks.get(i).startHour > hour() || breaks.get(i).startHour == hour() && breaks.get(i).startMin > minute()) {
        if (nextBreak == null) {
          nextBreak = breaks.get(i);
        }
        //om nuværende pause er tættere på klokkeslet end tidligere tætteste
        else if (breaks.get(i).startHour < nextBreak.startHour || breaks.get(i).startHour == nextBreak.startHour && breaks.get(i).startMin < nextBreak.startMin) {
          nextBreak = breaks.get(i);
        }
      }
    }
    if (nextBreak != null) {
      timerHour = nextBreak.startHour - hour();
      timerMin = nextBreak.startMin - minute();
      if (timerMin < 0) {
        timerMin = timerMin + 60;
        timerHour--;
      }
    }
  }
}





float mapYVal(int hour, int min) {
  float yVal = hour * 60 + min;
  //map fra kl. 8-17 til skærmstørrelsen
  yVal = map(yVal, 480, 1020, topScreen, buttonScreen);
  return yVal;
}


void closeWindow() {
  textfield1.setText("");
  textarea1.setText("");
  label4.setText("");
  dropList1.setSelected(0);
  dropList2.setSelected(0);

  window1.setVisible(false);
}


boolean createTask() {

  //kun hvis der er valgt et tidspunkt og navn
  if (dropList1.getSelectedIndex() != 0 && dropList2.getSelectedIndex() != 0 && textfield1.getText() != "") {


    int sHour = (dropList1.getSelectedIndex()-1)/4 + 8; //deles med 4 fordi der er 4 værdier med samme time efter hinanden
    int eHour = (dropList2.getSelectedIndex()-1)/4 + 8;

    int sMin = (dropList1.getSelectedIndex()-1)%4 * 15; //modulu 4 fordi hver 4. minuttal er ens
    int eMin = (dropList2.getSelectedIndex()-1)%4 * 15;

    //kun hvis starttidspunktet er før sluttidspunktet
    if (eHour > sHour || eHour == sHour && eMin > sMin) {

      if (bit.connect()) {

        //indsæt valgte data i database
        bit.execute("Insert Into Tasks (Name, Description, StartHour, StartMin, EndHour, EndMin, Checked) Values ('"+textfield1.getText()+"', '"+textarea1.getText()+"', '"+sHour+"', '"+sMin+"', '"+eHour+"', '"+eMin+"', '"+false+"');");

        bit.close();
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}



void customButton(GButton source, GEvent event) {
  if (bit.connect()) {
    for (int i = removeButtons.size()-1; i >= 0; i--) {
      if (source.equals(removeButtons.get(i))) {

        bit.execute("DELETE FROM Tasks WHERE ID='"+tasks.get(i).ID+"';");

        for (int j = breaks.size()-1; j >= 0; j--) {
          if (breaks.get(j).task_ID == tasks.get(i).ID) {
            breaks.remove(breaks.get(j));
          }
        }

        removeButtons.get(i).dispose();
        checkButtons.get(i).dispose();

        removeButtons.remove(removeButtons.get(i));
        checkButtons.remove(checkButtons.get(i));

        tasks.remove(tasks.get(i));
      }
    }
    for (int i = checkButtons.size()-1; i >= 0; i--) {
      if (source.equals(checkButtons.get(i))) {
        tasks.get(i).checked = true;
        bit.execute("UPDATE Tasks SET Checked = 1 WHERE ID = "+tasks.get(i).ID+";");
      }
    }
  }
  bit.close();
}


void getTasks() {
  if (bit.connect()) {

    //slet og opdatér tasks, knapper og pauser
    for (int i = tasks.size()-1; i >= 0; i--) {
      tasks.remove(tasks.get(i));
      removeButtons.get(i).dispose();
      removeButtons.remove(removeButtons.get(i));
      checkButtons.get(i).dispose();
      checkButtons.remove(checkButtons.get(i));
    }


    bit.query("SELECT ID, Name, Description, StartHour, StartMin, EndHour, EndMin, Checked FROM Tasks;");


    while (bit.next()) {
      float startY = mapYVal(bit.getInt("StartHour"), bit.getInt("StartMin"));
      float endY = mapYVal(bit.getInt("EndHour"), bit.getInt("EndMin"));

      tasks.add(new Task(bit.getInt("ID"), bit.getString("Name"), bit.getString("Description"), startY, endY, bit.getBoolean("Checked")));

      removeButtons.add(new GButton(this, width*0.85, startY+height*0.005, 50, 50));
      removeButtons.get(removeButtons.size()-1).setLocalColorScheme(GCScheme.RED_SCHEME);
      removeButtons.get(removeButtons.size()-1).setText("X");
      removeButtons.get(removeButtons.size()-1).setFont(new Font("Ariel", Font.BOLD, 25));
      removeButtons.get(removeButtons.size()-1).addEventHandler(this, "customButton");

      checkButtons.add(new GButton(this, width*0.85-60, startY+height*0.005, 50, 50));
      checkButtons.get(checkButtons.size()-1).setLocalColorScheme(GCScheme.GREEN_SCHEME);
      checkButtons.get(checkButtons.size()-1).setText("✓");
      checkButtons.get(checkButtons.size()-1).setFont(new Font("Ariel", Font.BOLD, 25));
      checkButtons.get(checkButtons.size()-1).addEventHandler(this, "customButton");


      //pauser
      boolean b = true;
      float mult = 0;

      while (b) { //<>//
        //hvor mange pauser der skal være
        float g = breakLen * (mult+breakDist);
        float e = endY-startY;
        if (e > g) mult += breakDist;
        else b = false;
      }

      for (float i = breakDist; i <= mult; i += breakDist) {
        float sY = startY + breakLen*(i-1);
        float eY = startY + breakLen*i;

        //modsat mapYVal()
        float sHour = map(sY, topScreen, buttonScreen, 480, 1020)/60;
        int sMin = round((sHour - floor(sHour)) * 60);
        sHour = floor(sHour);

        float eHour = map(eY, topScreen, buttonScreen, 480, 1020)/60;
        int eMin = round((eHour - floor(eHour)) * 60);
        eHour = floor(eHour);


        breaks.add(new Break(bit.getInt("ID"), sY, eY, int(sHour), sMin, int(eHour), eMin));
      }
    }
  }
  bit.close();
}

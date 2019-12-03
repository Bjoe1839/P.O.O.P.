import de.bezier.data.sql.*; //BezierSQLib //<>// //<>//
import java.awt.*; //til fonte
import g4p_controls.*; //G4P GUI

SQLite bit; //databasen kaldes bit

ArrayList<Task> tasks = new ArrayList<Task>();

//samme længde som 'tasks'. Lavet pga at GButton klassen ikke kan tilpasses med egne variable
ArrayList<GButton> buttons = new ArrayList<GButton>();

ArrayList<Break> breaks = new ArrayList<Break>();

int topScreen, buttonScreen;

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

  button1.setFont(new Font("Ariel", Font.PLAIN, 70));
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
  label1.setText("Pause om: ");
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
        bit.execute("Insert Into Tasks (Name, Description, StartHour, StartMin, EndHour, EndMin) Values ('"+textfield1.getText()+"', '"+textarea1.getText()+"', '"+sHour+"', '"+sMin+"', '"+eHour+"', '"+eMin+"');");

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
    for (int i = buttons.size()-1; i >= 0; i--) {
      if (source.equals(buttons.get(i))) {

        bit.execute("DELETE FROM Tasks WHERE ID='"+tasks.get(i).ID+"';");
        bit.execute("DELETE FROM Breaks WHERE Task_ID='"+tasks.get(i).ID+"';");

        for (int j = breaks.size()-1; j >= 0; j--) {
          if (breaks.get(j).task_ID == tasks.get(i).ID) {
            breaks.remove(breaks.get(j));
          }
        }

        bit.query("SELECT Task_ID FROM Breaks");

        buttons.remove(buttons.get(i));
        tasks.remove(tasks.get(i));
      }
    }
  }
  source.dispose();
  bit.close();
}


void getTasks() {
  if (bit.connect()) {

    //slet og opdatér tasks, knapper og pauser
    for (int i = tasks.size()-1; i >= 0; i--) {
      tasks.remove(tasks.get(i));
      buttons.get(i).dispose();
      buttons.remove(buttons.get(i));
    }


    bit.query("SELECT ID, Name, Description, StartHour, StartMin, EndHour, EndMin FROM Tasks;");

    StringList toBeExecuted = new StringList();

    while (bit.next()) {
      float startY = mapYVal(bit.getInt("StartHour"), bit.getInt("StartMin"));
      float endY = mapYVal(bit.getInt("EndHour"), bit.getInt("EndMin"));

      tasks.add(new Task(bit.getInt("ID"), bit.getString("Name"), bit.getString("Description"), startY, endY));

      buttons.add(new GButton(this, width*0.85, startY+height*0.005, 50, 50));
      buttons.get(buttons.size()-1).setLocalColorScheme(GCScheme.RED_SCHEME);
      buttons.get(buttons.size()-1).setText("X");
      buttons.get(buttons.size()-1).addEventHandler(this, "customButton");

      //pauser
      float t = (buttonScreen-topScreen)/108.0; //5 min i skærmstørrelse

      boolean b = true;
      int mult = 0;

      while (b) {
        //hvor mange pauser der skal være
        if (endY-startY > t * (mult+6)) mult += 6;
        else b = false;
      }

      for (int i = 6; i <= mult; i += 6) {
        //kan ikke execute inde i bit.next()
        toBeExecuted.append("INSERT INTO Breaks (Task_ID, StartY, EndY) Values ('"+bit.getInt("ID")+"','"+(startY + t*(i-1))+"','"+(startY + t*i)+"');");
        breaks.add(new Break(bit.getInt("ID"), startY + t*(i-1), startY + t*i));
      }
    }
    //indsæt pauser
    for (String s : toBeExecuted) {
      bit.execute(s);
    }
  }
  bit.close();
}

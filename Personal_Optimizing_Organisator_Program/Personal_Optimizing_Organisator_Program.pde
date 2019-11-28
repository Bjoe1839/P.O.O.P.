import de.bezier.data.sql.*; //BezierSQLib //<>//
import java.awt.*; //til fonte
import g4p_controls.*; //G4P

SQLite bit;
ArrayList<GButton> buttons = new ArrayList<GButton>();
IntList buttonBelongs = new IntList();

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

  buttonSetup();
}

void draw() {
  background(35);
  labelText();

  tasks();
  clock();
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
  line(0, topScreen*0.9, width, topScreen*0.9);
  line(0, buttonScreen, width, buttonScreen);

  //afstanden mellem hvert tal
  int d = round((buttonScreen - topScreen)/9);

  textAlign(RIGHT, CENTER);

  fill(0, 200, 255);
  for (int i = 8; i < 17; i++) {
    text(i, width*0.99, (i-8)*d+topScreen);
  }

  int y = round(map(hour(), 8, 17, topScreen, buttonScreen)); //timer
  y += round(map(minute(), 0, 60, 0, d)); //minutter

  stroke(255, 0, 10);
  strokeWeight(2);
  //linje der markerer hvornår på dagen det er
  line(0, y, width, y);
}



void tasks() {
  if (bit.connect()) {
    bit.query("SELECT Name, Description, StartHour, StartMin, EndHour, EndMin FROM Tasks ORDER BY StartHour, StartMin;");

    stroke(255);
    strokeWeight(1);
    textAlign(CORNER);

    while (bit.next()) {
      int startY = mapYVal(bit.getInt("StartHour"), bit.getInt("StartMin"));
      int endY = mapYVal(bit.getInt("EndHour"), bit.getInt("EndMin"));

      println(startY+"   "+endY+"           "+bit.getInt("StartHour"));

      fill(170);
      rect(width*0.02, startY, width*0.94, endY, 5);

      fill(255);
      //text(bit.getString("Name"), width*0.04, startY+height*0.018); //her
    }
  }
  bit.close();
}

int mapYVal(int hour, int min) {
  int yVal = hour * 60 + min;
  //map fra kl. 8-17 til skærmstørrelsen
  yVal = round(map(yVal, 480, 1020, topScreen, buttonScreen));
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

        //hent id fra lavede task
        bit.query("SELECT ID FROM Tasks;");

        int id = 0;

        while (bit.next()) {
          id = bit.getInt("ID");
        }
        buttonBelongs.append(id);


        createButton(sHour, sMin, eHour, eMin);
        
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


void buttonSetup() {
  if (bit.connect()) {
    bit.query("SELECT StartHour, StartMin, EndHour, EndMin FROM Tasks;");

    while (bit.next()) {
      createButton(bit.getInt("StartHour"), bit.getInt("StartMin"), bit.getInt("EndHour"), bit.getInt("EndMin"));
    }
  }
  bit.close();
}

void createButton(int sHour, int sMin, int eHour, int eMin) {
  //knapper
  //e??
  buttons.add(new GButton(this, width*0.85, mapYVal(sHour, sMin)+height*0.005, 50, 50));

  buttons.get(buttons.size()-1).addEventHandler(this, "custom_button");
}

public void custom_button(GButton source, GEvent event) {
  if (bit.connect()) {

    for (int i = buttons.size()-1; i >= 0; i--) {
      if (source == buttons.get(i)) {

        bit.execute("DELETE FROM Tasks WHERE ID='"+buttonBelongs.get(i)+"';");

        buttons.get(i).dispose();
        buttons.remove(buttons.get(i));
        buttonBelongs.remove(buttonBelongs.get(i));
        //source.dispose();
      }
    }
  }
  bit.close();
}

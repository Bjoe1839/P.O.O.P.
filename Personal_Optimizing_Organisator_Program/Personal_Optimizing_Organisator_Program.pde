import de.bezier.data.sql.*; //BezierSQLib
import java.awt.*; //til fonte
import g4p_controls.*; //G4P

SQLite db;

int topScreen, buttonScreen;

void setup() {
  size(600, 900);

  createGUI();
  customGUI();

  db = new SQLite(this, "POOP.sqlite" ); //åben database filen

  stroke(255);
  topScreen = round(height*0.08);
  buttonScreen = round(height*0.89);
}

void draw() {
  background(35);
  labelText();

  clock();
}


void customGUI() {
  window1.setLocation(710, 300);
  window1.setVisible(false);

  button1.setFont(new Font("Ariel", Font.PLAIN, 70));
  button2.setFont(new Font("Ariel", Font.PLAIN, 30));
  button3.setFont(new Font("Ariel", Font.PLAIN, 30));
  label1.setFont(new Font("Ariel", Font.PLAIN, 25));
  label2.setFont(new Font("Ariel", Font.PLAIN, 20));
  label3.setFont(new Font("Ariel", Font.PLAIN, 25));
  textfield1.setFont(new Font("Ariel", Font.PLAIN, 20));
  textarea1.setFont(new Font("Ariel", Font.PLAIN, 15));
  dropList1.setFont(new Font("Ariel", Font.PLAIN, 15));
  dropList2.setFont(new Font("Ariel", Font.PLAIN, 15));

  //GDropList(window1, 200, 80, 100, 200, 5, 25);
}


void labelText() {
  label1.setText("Pause om: ");
  label2.setText(day()+"/"+month()+"/"+year());
  label3.setText(hour()+":"+minute()+":"+second());
}

void clock() {
  //linje i bund og i top
  line(0, topScreen, width, topScreen);
  line(0, buttonScreen, width, buttonScreen);

  //afstanden mellem hvert tal
  int d = round((buttonScreen - topScreen)/9);

  textAlign(RIGHT, CENTER);

  for (int i = 8; i < 17; i++) {
    text(i, width*0.98, (i-8)*d+topScreen);
  }

  int y = round(map(hour(), 8, 17, topScreen, buttonScreen)); //timer
  y += round(map(minute(), 0, 60, 0, d)); //minutter

  stroke(255, 0, 0);
  strokeWeight(2);
  //linje der markerer hvornår på dagen det er
  line(0, y, width, y);

  //set alt tilbage igen
  textAlign(CENTER, CENTER);
  stroke(255);
  strokeWeight(1);
}


void createTask() {
  if (db.connect()) {

    println(dropList1.getSelectedIndex());
    
    
    int sHour = (dropList1.getSelectedIndex()-1)/4 + 8; //deles med 4 fordi der er 4 værdier med samme time
    int eHour = (dropList2.getSelectedIndex()-1)/4 + 8;
    
    int sMin = (dropList1.getSelectedIndex()-1)%4 * 15; //modulu 4 fordi hver 4 minuttal er ens
    int eMin = (dropList2.getSelectedIndex()-1)%4 * 15;
    


    db.execute("Insert Into Tasks (Name, Description, StartHour, StartMin, EndHour, EndMin) Values ('"+textfield1.getText()+"', '"+textarea1.getText()+"', '"+sHour+"', '"+sMin+"', '"+eHour+"', '"+eMin+"');");
  }
  db.close();
}

import de.bezier.data.sql.*; //BezierSQLib
import java.awt.*; //til fonte
import g4p_controls.*; //G4P

void setup() {
  size(600, 900);
  
  createGUI();
  customGUI();
}

void draw() {
  background(0);
  labelText();
}

void customGUI() {
  button1.setFont(new Font("Ariel", Font.PLAIN, 60));
  label1.setFont(new Font("Ariel", Font.PLAIN, 25));
  label2.setFont(new Font("Ariel", Font.PLAIN, 20));
  label3.setFont(new Font("Ariel", Font.PLAIN,25));
}

void labelText() {
  label1.setText("Pause om: ");
  label2.setText(day()+"/"+month()+" "+year());
  label3.setText(hour()+":"+minute()+":"+second());
}

class Task {
  int ID;
  float startY, endY;
  String name;
  boolean checked;

  Task(int ID_, String name_, float startY_, float endY_, boolean checked_) {
    ID = ID_;
    name = name_;
    startY = startY_;
    endY = endY_;
    checked = checked_;
  }


  void display() {
    stroke(255);
    if (checked) fill(130, 230, 130);
    else fill(170);
    
    rect(width*0.02, startY, width*0.94, endY, 5);

    fill(255);
    text(name, width*0.04, startY+height*0.024);
  }
}

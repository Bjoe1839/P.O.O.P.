class Break {
  int task_ID;
  float startY, endY;
  int startHour, startMin, endHour, endMin;
  
  Break(int task_ID_, float startY_, float endY_, int startHour_, int startMin_, int endHour_, int endMin_) {
    task_ID = task_ID_;
    startY = startY_;
    endY = endY_;
    startHour = startHour_;
    startMin = startMin_;
    endHour = endHour_;
    endMin = endMin_;
  }

  void display() {
    noStroke();
    fill(0, 0, 255);
    rect(width*0.02, startY, width*0.94, endY);
  }
}

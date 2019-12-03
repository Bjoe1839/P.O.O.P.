class Break {
  int task_ID;
  float startY, endY;
  
  Break(int task_ID_, float startY_, float endY_) {
    task_ID = task_ID_;
    startY = startY_;
    endY = endY_;
  }

  void display() {
    noStroke();
    fill(0, 0, 255);
    rect(width*0.02, startY, width*0.94, endY);
  }
}

class Spark {
  PVector location, velocity, acceleration;
  int lifespan = 255, lifespeed;
  color c;

  Spark(float x, float y, PVector v, color c_, int ls) {
    acceleration = new PVector(0, 0);
    velocity = v;
    location =  new PVector(x, y);
    c = c_;
    lifespeed = ls;
  }

  void move() {
    acceleration.add(new PVector(0, 0.2));
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
    
    lifespan -= lifespeed;
  }

  void display() {
    strokeWeight(8);
    stroke(c, lifespan);
    point(location.x, location.y);
    strokeWeight(2);
  }
}

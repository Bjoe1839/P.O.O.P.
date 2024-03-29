class Firework {
  ArrayList<Spark> sparks = new ArrayList<Spark>();
  Spark startSpark;
  color c;

  boolean exploded;

  Firework() {
    colorMode(HSB);
    c = color(random(255), 255, 255);
    colorMode(RGB);
    startSpark = new Spark(random(100, width-100), buttonScreen, new PVector(0, random(-17, -13)), c, 0);
  }

  void run() {
    if (!exploded) {
      if (startSpark.velocity.y >= 0) {
        for (int i = 0; i < 500; i++) {
          PVector p = PVector.random2D();
          p.mult(random(0.5, 8));
          sparks.add(new Spark(startSpark.location.x, startSpark.location.y, p, c, round(random(3, 12))));
        }
        exploded = true;
      }
      startSpark.move();
      startSpark.display();
    } else {
      for (int i = sparks.size()-1; i >= 0; i--) {
        sparks.get(i).move();
        sparks.get(i).velocity.mult(0.97);
        if (sparks.get(i).lifespan <= 0) sparks.remove(sparks.get(i));
        else sparks.get(i).display();
      }
    }
  }
}

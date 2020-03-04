class Map2 { //<>// //<>// //<>// //<>// //<>//
  PShape shape;
  float scale;
  PVector pos;
  Table table;
  JSONObject isoList;
  int[] toll;
  Geometry geo;
  // ANIMATION
  char displayMode; // R or L
  int currentCountryIDonMap;
  //
  float bboxX;
  float bboxXT;

  float bboxY;
  float bboxYT;

  Ani bboxXAni;  
  Ani bboxYAni;
  // FONT
  PFont H2;
  // global rectmode must be CORNERS
  Map2 () {
    bboxX = 0;
    geo = new Geometry();
    // animate the variables x and y in 1.5 sec to mouse click position
  }
  // 1. Attach map
  void attachMap (String L) {
    shape = loadShape (L);
    shape.disableStyle();
    scale = width / shape.width;
    //print ("width : ", shape.getWidth());
    print (" / scale : ", scale);
    //println(" / width (scaled) : ", shape.getWidth());
    pos = new PVector ((width-shape.getWidth())/2, (height - shape.getHeight())/8);
    //translate(pos.x, pos.y);
    //
    isoList = loadISOList ("data/iso3166-1.json");
  }
  // 2. Attach table
  void attachTable(Table T, int[] Toll) {
    table = T;
    toll = Toll;
  }
  // 3. Render
  void render (int _now) {
    colorMode (HSB, 360, 100, 100, 100);
    H2 = loadFont("R-CB.vlw");
    int c = 0;
    int d = 0;
    int r = 0;
    // render the world map first
    for (int i = 0; i < shape.getChildCount(); i++) {
      PShape ps = shape.getChild(i);
      String currentISO = ps.getName();
      //println("currentISO : ",currentISO);
      String currentName = getNameFromISO(currentISO);
      Boolean hasCase = false;
      //get currunt shape info
      for (int k = 0; k < table.getRowCount(); k++) {
        //println(currentName," ",T.getRow(k).getString(1));
        if (table.getRow(k).getString(8).equals(currentISO)) {
          hasCase = true;
          //println(table.getRow(k).getString(8), " marked");
          c = table.getRow(k).getInt(1);
          d = table.getRow(k).getInt(3);
          r = table.getRow(k).getInt(5);
        }
      }
      if (table.getRow(_now).getString(8).equals(currentISO)) {
        currentCountryIDonMap = i;
      }
      // Disable the colors found in the SVG file
      ps.disableStyle();
      strokeWeight(0.5);
      stroke(0);
      fill(42);
      if (hasCase) {
        fill(0, // Hue 0 is red
          map(log(c)/log(2), 0, log(toll[1])/log(2), 80, 100), // Saturation
          map(log(c)/log(2), 0, log(toll[3])/log(2), 20, 80), // Brightness
          map(log(c)/log(2), 0, log(toll[5])/log(2), 80, 100) // Alpha
          );
      } else {
        strokeWeight(0.5);
        stroke(0);
        fill(42);
      } 
      // Draw a single state
      shape(ps, 0, 0);
    }
    //shape(shape);
    drawCurrentCountry(shape.getChild(currentCountryIDonMap), _now);
  }
  void drawCurrentCountry(PShape cc, int _now) {
    println("---- ", cc.getParent().width);
    float left = geo.getLeft(cc);
    float right = geo.getRight(cc);
    float top = geo.getTop(cc);
    float bottom = geo.getBottom(cc);
    float w = geo.getW(cc);
    float h = geo.getH(cc);
    float wh = (w > h) ? w : h;
    PVector cent; // cent works fine
    cent = geo.getCentroid(cc);
    //println (cc.getName(), " x : ", cc.width, " / y : ", cc.height);
    //println ("cc.width : ", geo.getWidth(cc), " / ", geo.getHeight(cc));
    //println ("cc.width : ", geo.getW(cc), " / ", geo.getH(cc));
    //println ("cent : ", cent.x, " / ", cent.y);
    //println ("w : ", w, " / h : ", h, " / wh : ", wh);
    if (cent.x > width/2) {
      displayMode = 'R';
    } else {
      displayMode = 'L';
    }
    if (displayMode == 'R') {
      rectMode(CORNER);
      noStroke();
      fill(0, 100, 100, 10);
      rect(0, 0, width/2, height);
    } else {
      rectMode(CORNER);
      noStroke();
      fill(0, 100, 100, 10);
      rect(width/2, 0, width/2, height);
    }
    if (wh < 142) {
      println("wh : ", wh);
      // rectangle 
      rectMode (CENTER);
      noFill();
      strokeWeight(2);
      stroke(255);
      rect(bboxX, bboxY, 142, 142);
      // county name
      fill(255, 100);
      textAlign(CENTER, BOTTOM);
      textFont(H2, 38);
      text(table.getRow(_now).getString(0), cent.x, cent.y-81);
    } else {
    }
    //rect(worldTollPos.x, worldTollPos.y, 284, 284);
    pushMatrix();
    translate(bboxX, bboxY);
    if (wh < 10) {
      //noStroke();
      strokeWeight(3);
      stroke(0, 0, 100, 40);
      noFill();
      ellipse(0, 0, 30, 30);
    }
    popMatrix();
    //
    // shaping the territory
    strokeWeight (1);
    stroke (255);
    fill(255, 255);
    shape(cc, 0, 0);
    //draw the total dashboard

  }
  void updateView(int _cut) {
    println("udate the map with current country");
    //list of any.to
    //Ani(Object Target, float Duration, String FieldName, float End)
    bboxXAni = Ani.to (this, 0.5, "bboxX", getCountryShapeFromDatarowNO(_cut).x);
    bboxYAni = Ani.to (this, 0.5, "bboxY", getCountryShapeFromDatarowNO(_cut).y);

    //bboxYAni = Ani.to (this, 0.5, "bboxY", bboxYT);
  }
  // end of 3. Render
  PVector getCountryShapeFromDatarowNO (int _rowNo) {
    PVector pos = new PVector ();
    String iso = table.getRow(_rowNo).getString("iso");
    //println("iso ", iso);
    for (int m = 0; m < shape.getChildCount(); m++) {
      if (iso.equals(shape.getChild(m).getName())) {
        pos = geo.getCentroid(shape.getChild(m));
      }
    }
    return pos;
  }
  JSONObject loadISOList (String url) {
    JSONObject _job;
    _job = loadJSONObject (url);
    return _job;
  }
  String getISOFromName (JSONObject list, String name) {
    String code;
    String m = list.toString();
    String q = "([A-Z]{2})\\W+\""+name;
    String[] r = match(m, q);
    if (r == null) {
      code = "";
    } else {
      //for (int k = 0; k < r.length; k++) {
      //  println(r[k]);
      //}
      code = r[1];
    }
    //code = isoList.getString(name);
    return code;
  }
  String getNameFromISO (String isocode) {
    String name;
    name = isoList.getString(isocode);
    return name;
  }
}

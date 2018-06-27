import controlP5.*;
import java.util.*;

ControlP5 cp5;

PImage webImg;
XML mapabicing; //XML complet
XML[] estacions_data; //XML segmentat per estacions

String urlbicing = "http://wservice.viabicing.cat/v1/getstations.php?v=2";
String urlmapa = "http://w133.bcn.cat/WMSPLANOLBCN/service.svc/get?service=WMS&version=1.3.0&layers=Planol_BCN&request=GetMap&styles=&bbox=225145.2668,5056959.1358,250980.9824,5082030.4811&width=1800&height=990&crs=EPSG:3857&format=image/png"; //&transparent=true

//colors
color textColor;
color bgColor;

IntDict rankingbuides = new IntDict();
IntDict rankingplenes = new IntDict();
IntDict rankingtancades = new IntDict();

//límits en EPSG4236
float minx = 41.301797;
float miny = 2.022514;
float maxx = 41.470773;
float maxy = 2.254601;

//límits en 3857
float minx3857 = 225145.2668;
float miny3857 = 5056959.1358;
float maxx3857 = 250980.9824;
float maxy3857 = 5082030.4811;

boolean primeresDades = false;
int frame;
int minuteTime;
int secondTime;

int mapposx = 400;
int mapposy = -10;
int infoboxposx = 1360;
int infoboxposy = 40;

ArrayList<Boto> botons = new ArrayList<Boto>();
IntList llistaIDs = new IntList();
Estacio[] estacions = new Estacio[1000];

String est_seleccionada;
String est_;
boolean isHovering;
int distid = 1;
PImage minimapaCarrers;
PImage minimapa;
String urlminimapa;

boolean bicingcarregat = false;
boolean minimapacarregat = false;

class Boto {
  int x, y, ample, alt;
  boolean activat;
  String text1, text2;
  Boto(int x_, int y_, int alt_, String text1_, String text2_) {
    text1 = text1_;
    text2 = text2_;
    x = x_;
    y = y_;
    alt = alt_;
    activat = false;
  }

  void display() {
    textSize(15);
    textAlign(LEFT, TOP);
    ample = round(textWidth(text1)+20);
    if (activat == true) {
      if (mouseX>x && mouseX<x+ample && mouseY>y && mouseY<y+alt) { 
        stroke(#000000);
        fill(#212121);
        rect(x, y, ample, alt);
        fill(#FFFFFF);
        text(text1, x+10, y);
      } else {
        stroke(#303030);
        fill(#efefef);
        rect(x, y, ample, alt);
        fill(#303030);
        text(text1, x+10, y);
      }
    }
    if (activat == false) {
      if (mouseX>x && mouseX<x+ample && mouseY>y && mouseY<y+alt) { 
        stroke(#000000);
        fill(#212121);
        rect(x, y, ample, alt);
        fill(#FFFFFF);
        text(text2, x+10, y);
      } else {
        stroke(#303030);
        fill(#efefef);
        rect(x, y, ample, alt);
        fill(#303030);
        text(text2, x+10, y);
      }
    }
  }

  void check() {
    if (mouseX>x && mouseX<x+ample && mouseY>y && mouseY<y+alt) {
      activat = !activat;
    }
  }
}

class Estacio {
  float latitud, longitud; //en 4236
  int x, y; //en píxels
  float realx, realy;
  int slots; 
  int bicis; //slots+bicis=espais totals
  int oldbicis;
  int capacity; //0 a 100, treballem en HSB per tant de vermell a verd passant per groc
  boolean oberta;
  String tipus;
  String direccio;
  int life; //número aleatori entre 0-60000 per decidir quan es mostra el canvi de bici
  int birth;
  int brillo; //animació text
  int radi;
  boolean draw;
  boolean buida;
  boolean plena;
  boolean seleccionada;
  boolean hovering;
  String[] properes;
  int tempsbuida;
  int tempsplena;
  int tempstancada;
  int ID;
  color c;


  Estacio(XML estacions_data) {
    ID = estacions_data.getChild("id").getIntContent();
    latitud = estacions_data.getChild("lat").getFloatContent();
    longitud = estacions_data.getChild("long").getFloatContent();
    direccio =  estacions_data.getChild("street").getContent() + ", " + estacions_data.getChild("height").getContent();
    direccio = direccio.replaceAll("&#039;", "'");
    direccio = direccio.replaceAll("&Agrave;", "À");
    direccio = direccio.replaceAll("&Egrave;", "È");
    direccio = direccio.replaceAll("&Igrave;", "Ì");
    direccio = direccio.replaceAll("&Ograve;", "Ò");
    direccio = direccio.replaceAll("&Ugrave;", "Ù");
    direccio = direccio.replaceAll("&Aacute;", "Á");
    direccio = direccio.replaceAll("&Eacute;", "É");
    direccio = direccio.replaceAll("&Iacute;", "Í");
    direccio = direccio.replaceAll("&Oacute;", "Ó");
    direccio = direccio.replaceAll("&Uacute;", "Ú");
    direccio = direccio.replaceAll("&Auml;", "Ä");
    direccio = direccio.replaceAll("&Euml;", "Ë");
    direccio = direccio.replaceAll("&Iuml;", "Ï");
    direccio = direccio.replaceAll("&Ouml;", "Ö");
    direccio = direccio.replaceAll("&Uuml;", "Ü");
    direccio = direccio.replaceAll("&Ccedil;", "Ç");
    direccio = direccio.replaceAll("&middot;", "·");
    direccio = direccio.replaceAll("&agrave;", "à");
    direccio = direccio.replaceAll("&egrave;", "è");
    direccio = direccio.replaceAll("&igrave;", "ì");
    direccio = direccio.replaceAll("&ograve;", "ò");
    direccio = direccio.replaceAll("&ugrave;", "ù");
    direccio = direccio.replaceAll("&aacute;", "á");
    direccio = direccio.replaceAll("&eacute;", "é");
    direccio = direccio.replaceAll("&iacute;", "í");
    direccio = direccio.replaceAll("&oacute;", "ó");
    direccio = direccio.replaceAll("&uacute;", "ú");
    direccio = direccio.replaceAll("&auml;", "ä");
    direccio = direccio.replaceAll("&euml;", "ë");
    direccio = direccio.replaceAll("&iuml;", "ï");
    direccio = direccio.replaceAll("&ouml;", "ö");
    direccio = direccio.replaceAll("&uuml;", "ü");
    direccio = direccio.replaceAll("&ccedil;", "ç");
    
    pushMatrix();
    translate(0, 1000);
    rotate(-PI/2);
    realx = map(latitud, minx, maxx, 0, 1000);
    realy = map(longitud, miny, maxy, 0, 1000);
    x = round(screenX(realx, realy));
    y = round(screenY(realx, realy));
    popMatrix();

    slots = estacions_data.getChild("slots").getIntContent();
    bicis = estacions_data.getChild("bikes").getIntContent();
    oldbicis = bicis;
    properes = split(estacions_data.getChild("nearbyStationList").getContent(), ", ");
    capacity = round(map(bicis, 0, bicis+slots, 0, 100));
    if (estacions_data.getChild("status").getContent().equals("OPN")) {
      oberta = true;
    } else if (estacions_data.getChild("status").getContent().equals("CLS")) {
      oberta = false;
    }
    tipus = estacions_data.getChild("type").getContent();
    radi = 5;
    birth = millis();
    life = round(random(60000));
    brillo = 255;

    if (bicis == 0) {
      buida = true;
    }
    if (slots == 0) {
      plena = true;
    }
    if (bicis>0) {
      buida = false;
    }
    if (slots>0) {
      plena = false;
    }
    if (tipus.equals("BIKE")) {
      c = color(100-capacity, 100, 100);
    }
    if (tipus.equals("BIKE-ELECTRIC")) {
      c = color(180+capacity/1.66, 100, 100);
    }
    if (!oberta) {
      c = color(0, 0, 0);
    }
  }

  void update(XML estacions_data) {
    oldbicis = bicis;
    latitud = estacions_data.getChild("lat").getFloatContent();
    longitud = estacions_data.getChild("long").getFloatContent();

    pushMatrix();
    translate(0, 1000);
    rotate(-PI/2);
    realx = map(latitud, minx, maxx, 0, 1000);
    realy = map(longitud, miny, maxy, 0, 1000);
    x = round(screenX(realx, realy));
    y = round(screenY(realx, realy));
    popMatrix();

    slots = estacions_data.getChild("slots").getIntContent();
    bicis = estacions_data.getChild("bikes").getIntContent();
    capacity = round(map(bicis, 0, bicis+slots, 0, 100));
    if (estacions_data.getChild("status").getContent().equals("OPN")) {
      oberta = true;
    } else if (estacions_data.getChild("status").getContent().equals("CLS")) {
      oberta = false;
    }
    tipus = estacions_data.getChild("type").getContent();

    if ((buida || plena) && oberta) {
      radi = 10;
    } else if (!buida && !plena) {
      radi = 5;
    };

    birth = millis();
    life = round(random(60000));
    brillo = 360;
  }

  void updateCounters() {    
    if (bicis == 0 && !buida) {
      primeresDades = true;
      println("NOVA BUIDA");
      buida = true;
    }
    if (slots == 0 && !plena) {
      primeresDades = true;
      println("NOVA PLENA");
      plena = true;
    }
    if (!oberta) {
      tempstancada++;
    }
    if (buida) {
      if (bicis>0) {
        buida = false;
        println("MENYS BUIDA");
      }
      tempsbuida++;
    }
    if (plena) {
      if (slots>0) {
        plena = false;
        println("MENYS PLENA");
      }
      tempsplena++;
    }
  }

  void display() {
    stroke(#000000);
    //noStroke();
    fill(c);

    if (tipus.equals("BIKE") && botons.get(0).activat == false) {
      if (millis() - birth > life || !primeresDades) {
        stroke(#000000);  
        //noStroke();
        c = color(100-capacity, 100, 100);

        if ((buida || plena) && oberta) {
          radi = 10;
        } else if (!buida && !plena) {
          radi = 5;
        };

        if (!oberta) {
          c = color(0, 0, 0);
        }
      }

      ellipse(x, y, radi, radi);
    }

    if (tipus.equals("BIKE-ELECTRIC") && botons.get(1).activat == false) {
      if (millis() - birth > life || !primeresDades) {
        stroke(#000000); 
        // noStroke();
        c = color(180+capacity/1.66, 100, 100);

        if ((buida || plena) && oberta) {
          radi = 10;
        } else if (!buida && !plena) {
          radi = 5;
        };

        if (!oberta) {
          c = color(0, 0, 0);
        }
      }
      ellipse(x, y, radi, radi);
    }

    if (seleccionada) {
      noFill();
      stroke(0);
      strokeWeight(4);
      ellipse(x, y, 40, 40);
      strokeWeight(1);
    }

    if (hovering) {
      noFill();
      stroke(0);
      strokeWeight(4);
      ellipse(x, y, 30, 30);
      strokeWeight(1);
    }
  }

  void displayEtiqueta() {
    pushMatrix();
    translate(x, y);
    textAlign(LEFT, BOTTOM);
    textSize(20);
    //ellipse(0, 0, 20, 20);

    if (millis() - birth > life && ((tipus.equals("BIKE") && botons.get(0).activat == false) || (tipus.equals("BIKE-ELECTRIC") && botons.get(1).activat == false))) {
      if (oldbicis > bicis) {
        fill(#FFFFFF, brillo);
        stroke(#000000, brillo);
        line(0, 0, 10, -10);
        rect(10, -10, textWidth("-"+(oldbicis-bicis))+5, -20);
        fill(#000000, brillo);
        text("-"+(oldbicis-bicis), 12, -8);
        brillo-=2;
      }
      if (oldbicis < bicis) {
        fill(#FFFFFF, brillo);
        stroke(#000000, brillo);
        line(0, 0, 10, -10);
        rect(10, -10, textWidth("-"+(oldbicis-bicis))+5, -20);
        fill(#000000, brillo);
        text("+"+(bicis-oldbicis), 12, -8);
        brillo-=2;
      }
    } 
    popMatrix();
  }
}

void carregaBicing() {
  try {
    mapabicing = loadXML(urlbicing);
  } 
  catch(NullPointerException e) {
    println("error connexio");
  }
  bicingcarregat = true;
}

void actualitzarEstacions() {
  estacions_data = mapabicing.getChildren("station");

  for (int i = 0; i < estacions_data.length; i++) {
    if (!llistaIDs.hasValue(estacions_data[i].getChild("id").getIntContent())) {
      llistaIDs.append(estacions_data[i].getChildren("id")[i].getIntContent());
      estacions[estacions_data[i].getChild("id").getIntContent()] = new Estacio(estacions_data[i]);
    };
  }
  try {
    for (int i = 0; i < llistaIDs.size(); i++) {
      estacions[llistaIDs.get(i)].update(estacions_data[i]);
    }
  } 
  catch (ArrayIndexOutOfBoundsException e) {
    println("felicitats");
  }
}

void updateRankings() {
  for (int i = 0; i < llistaIDs.size(); i++) {
    estacions[llistaIDs.get(i)].updateCounters();
    if (estacions[llistaIDs.get(i)].oberta) {
      rankingbuides.set(str(estacions[llistaIDs.get(i)].ID), estacions[llistaIDs.get(i)].tempsbuida);
      rankingplenes.set(str(estacions[llistaIDs.get(i)].ID), estacions[llistaIDs.get(i)].tempsplena);
    } else {
      rankingtancades.set(str(estacions[llistaIDs.get(i)].ID), estacions[llistaIDs.get(i)].tempstancada);
    }
  }
  rankingbuides.sortValuesReverse();
  rankingplenes.sortValuesReverse();
  rankingtancades.sortValuesReverse();
  //printArray(rankingbuides);
}

double[] dhm(double ms) { //pillada d'un forum
  double days = Math.floor(ms / (24*60*60*1000));
  double daysms=ms % (24*60*60*1000);
  double hours = Math.floor((daysms)/(60*60*1000));
  double hoursms=ms % (60*60*1000);
  double minutes = Math.floor((hoursms)/(60*1000));
  double minutesms=ms % (60*1000);
  double sec = Math.floor((minutesms)/(1000));
  double[] array = {
    days, hours, minutes, sec
  };
  return array;
}


void setup() {
  size(1800, 900);
  colorMode(HSB, 360, 100, 100);
  textColor = color(0, 0, 0);
  bgColor = color(0, 0, 100);
  cp5 = new ControlP5(this);

  botons.add(0, new Boto(1500, 825, 20, "Mostrar mecàniques", "Ocultar mecàniques"));
  botons.add(1, new Boto(1500, 855, 20, "Mostrar elèctriques", "Ocultar elèctriques"));

  cp5.addScrollableList("buides")
    .setPosition(43, 260)
    .setSize(200, 100)
    .setBarHeight(25)
    .setItemHeight(15)
    .setHeight(180)
    .setWidth(320)
    .setCaptionLabel("buides")
    .addItems(Arrays.asList("Esperant dades..."))
    .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;
  cp5.addScrollableList("buidestemps")
    .lock()
    .setPosition(163, 260)
    .setSize(200, 100)
    .setBarHeight(25)
    .setItemHeight(15)
    .setHeight(180)
    .setCaptionLabel("temps")
    .addItems(Arrays.asList("Esperant dades..."))
    .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;
  cp5.addScrollableList("plenes")
    .setPosition(43, 470)
    .setSize(200, 100)
    .setBarHeight(25)
    .setItemHeight(15)
    .setHeight(180)
    .setWidth(320)
    .setCaptionLabel("plenes")
    .addItems(Arrays.asList("Esperant dades..."))
    .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;
  cp5.addScrollableList("plenestemps")
    .lock()
    .setPosition(163, 470)
    .setSize(200, 100)
    .setBarHeight(25)
    .setItemHeight(15)
    .setHeight(180)
    .setCaptionLabel("temps")
    .addItems(Arrays.asList("Esperant dades..."))
    .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;
  cp5.addScrollableList("tancades")
    .setPosition(43, 680)
    .setSize(200, 100)
    .setBarHeight(25)
    .setItemHeight(15)
    .setHeight(180)
    .setWidth(320)
    .setCaptionLabel("tancades")
    .addItems(Arrays.asList("Esperant dades..."))
    .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;
  cp5.addScrollableList("tancadestemps")
    .lock()
    .setPosition(163, 680)
    .setSize(200, 100)
    .setBarHeight(25)
    .setItemHeight(15)
    .setHeight(180)
    .setCaptionLabel("temps")
    .addItems(Arrays.asList("Esperant dades..."))
    .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;
  cp5.addButtonBar("properes")
    .setPosition(0, 0)
    .setSize(360, 30)
    ;


  mapabicing = loadXML(urlbicing);
  estacions_data = mapabicing.getChildren("station");

  for (int i = 0; i < estacions_data.length; i++) {
    llistaIDs.append(estacions_data[i].getChild("id").getIntContent());
    estacions[estacions_data[i].getChild("id").getIntContent()] = new Estacio(estacions_data[i]);
  }

  webImg = loadImage(urlmapa, "png");
  //webImg.filter(POSTERIZE, 2);
  //webImg.filter(INVERT);
  minuteTime = millis();
  secondTime = millis();
  frame = 0;
  est_seleccionada = "378";
  canvi("378");
}

void mouseClicked() {
  for (int i = 0; i < botons.size(); i++) {
    botons.get(i).check();
  }

  if (isHovering) {
    canvi(str(distid));
  }
}

void buides(int i) {
  canvi(cp5.get(ScrollableList.class, "buides").getItem(i).get("name").toString());
}

void plenes(int i) {
  canvi(cp5.get(ScrollableList.class, "plenes").getItem(i).get("name").toString());
}

void tancades(int i) {
  canvi(cp5.get(ScrollableList.class, "tancades").getItem(i).get("name").toString());
}

void properes(int i) {
  canvi(estacions[int(est_seleccionada)].properes[i]);
}

void canvi(String est) {
  est_ = est;
  minimapacarregat = false;
  thread("carrega");
}

void carrega() {
  estacions[int(est_seleccionada)].seleccionada = false;
  est_seleccionada = est_;
  estacions[int(est_seleccionada)].seleccionada = true;
  println(estacions[int(est_seleccionada)].x+" "+estacions[int(est_seleccionada)].y);
  float minx_ = map(estacions[int(est_seleccionada)].x-20, 0, 1000, minx3857, maxx3857);
  float miny_ = map(estacions[int(est_seleccionada)].y+20, 0, 1000, maxy3857, miny3857);
  float maxx_ = map(estacions[int(est_seleccionada)].x+20, 0, 1000, minx3857, maxx3857);
  float maxy_ = map(estacions[int(est_seleccionada)].y-20, 0, 1000, maxy3857, miny3857);
  urlminimapa = "http://w133.bcn.cat/WMSPLANOLBCN/service.svc/get?service=WMS&version=1.3.0&layers=Planol_BCN&request=GetMap&styles=&bbox="+minx_+","+miny_+","+maxx_+","+maxy_+"&width=360&height=360&crs=EPSG:3857&format=image/png";
  minimapa = loadImage(urlminimapa, "png");
  minimapacarregat = true;
}

void draw() {
  background(bgColor);

  cp5.get(ScrollableList.class, "buides").open();
  cp5.get(ScrollableList.class, "plenes").open();
  cp5.get(ScrollableList.class, "tancades").open();

  pushMatrix();
  image(webImg, 0, 0);
  translate(mapposx, mapposy);

  //http://w133.bcn.cat/WMSCARRERER/service.svc/get?service=WMS&version=1.3.0&layers=Retolaci%C3%B3_de_carrers&request=GetMap&styles=&bbox=239871.3380,5068909.5874,241486.0703,5070041.8109&width=1000&height=1000&crs=EPSG:3857&format=image/png&transparent=true

  float dist;
  float lastdist = 100;
  isHovering = false;
  for (int i = 0; i < llistaIDs.size(); i++) {
    estacions[llistaIDs.get(i)].display();

    //agafa la estacio mes proxima per evitar conflictes
    estacions[llistaIDs.get(i)].hovering = false;
    dist = dist(estacions[llistaIDs.get(i)].x+mapposx, estacions[llistaIDs.get(i)].y+mapposy, mouseX, mouseY);
    if (dist<=lastdist) {
      distid = llistaIDs.get(i);
      lastdist = dist;
    }
  }

  if (lastdist<20) {
    isHovering = true;
    estacions[distid].hovering = true;
  }

  for (int i = 0; i < llistaIDs.size(); i++) {
    estacions[llistaIDs.get(i)].displayEtiqueta();
  } 
  popMatrix();

  for (int i = 0; i < botons.size(); i++) {
    botons.get(i).display();
  }

  if (!primeresDades && millis()-minuteTime>1000) {
    if (!bicingcarregat) {
      thread("carregaBicing");
    } else if (bicingcarregat) {
      actualitzarEstacions();
      minuteTime = millis();
      println("UPDATE");
      bicingcarregat = false;
    }
  }

  if (millis()-secondTime>1000) {
    secondTime = millis();
    updateRankings();

    String[] arrayclaus = rankingbuides.keyArray();
    String[] arrayfinal = {};
    String[] arrayfinaltemps = {};
    for (int i = 0; i < arrayclaus.length; i++) {
      if (i > 9) {
        break;
      }
      String id = arrayclaus[i];
      if (rankingbuides.get(id)>0) {
        String linia;
        double[] temps = dhm(int(rankingbuides.get(id))*1000);
        linia = temps[0] + "d " + temps[1] + "h " + temps[2] + "m " + temps[3] + "s";
        arrayfinal = append(arrayfinal, id);
        arrayfinaltemps = append(arrayfinaltemps, linia);
      }
    }
    String[] arrayclausplenes = rankingplenes.keyArray();
    String[] arrayfinalplenes = {};
    String[] arrayfinaltempsplenes = {};
    for (int i = 0; i < arrayclausplenes.length; i++) {
      if (i > 9) {
        break;
      }
      String id = arrayclausplenes[i];
      if (rankingplenes.get(id)>0) {
        String linia;
        double[] temps = dhm(int(rankingplenes.get(id))*1000);
        linia = temps[0] + "d " + temps[1] + "h " + temps[2] + "m " + temps[3] + "s";
        arrayfinalplenes = append(arrayfinalplenes, id);
        arrayfinaltempsplenes = append(arrayfinaltempsplenes, linia);
      }
    }
    String[] arrayclaustancades = rankingtancades.keyArray();
    String[] arrayfinaltancades = {};
    String[] arrayfinaltempstancades = {};
    for (int i = 0; i < arrayclaustancades.length; i++) {
      if (i > 9) {
        break;
      }
      String id = arrayclaustancades[i];
      if (rankingtancades.get(id)>0) {
        String linia;
        double[] temps = dhm(int(rankingtancades.get(id))*1000);
        linia = temps[0] + "d " + temps[1] + "h " + temps[2] + "m " + temps[3] + "s";
        arrayfinaltancades = append(arrayfinaltancades, id);
        arrayfinaltempstancades = append(arrayfinaltempstancades, linia);
      }
    }
    cp5.get(ScrollableList.class, "buides").setItems(arrayfinal);
    cp5.get(ScrollableList.class, "buidestemps").setItems(arrayfinaltemps);
    cp5.get(ScrollableList.class, "plenes").setItems(arrayfinalplenes);
    cp5.get(ScrollableList.class, "plenestemps").setItems(arrayfinaltempsplenes);
    cp5.get(ScrollableList.class, "tancades").setItems(arrayfinaltancades);
    cp5.get(ScrollableList.class, "tancadestemps").setItems(arrayfinaltempstancades);
  }

  if (primeresDades && millis()-minuteTime>60000) {
    if (!bicingcarregat) {
      thread("carregaBicing");
    } else if (bicingcarregat) {
      actualitzarEstacions();
      minuteTime = millis();
      println("UPDATE");
      bicingcarregat = false;
    }
  }

  //infobox
  pushMatrix();
  translate(infoboxposx, infoboxposy);
  stroke(textColor);
  noFill();
  rect(0, 0, 400, 630);
  fill(textColor);
  textSize(30);
  text("ESTACIÓ " + est_seleccionada, 20, 20);
  textSize(20);
  if (!estacions[int(est_seleccionada)].oberta) {
    fill(0);
    rect(20, 93, 360, 30);
    fill(0, 0, 100);
    text("TANCADA", 150, 96);
  } else {
    int midpoint = round(map(estacions[int(est_seleccionada)].bicis, 0, estacions[int(est_seleccionada)].bicis+estacions[int(est_seleccionada)].slots, 20, 380));
    fill(0, 100, 100);
    rect(20, 93, midpoint-20, 30);
    fill(110, 100, 100);
    rect(midpoint, 93, 380-midpoint, 30);
  }
  fill(textColor);
  text(estacions[int(est_seleccionada)].bicis, 24, 96);
  text(estacions[int(est_seleccionada)].slots, 376-textWidth(str(estacions[int(est_seleccionada)].slots)), 96);
  if (estacions[int(est_seleccionada)].bicis == 1) {
    text("bicis", 22, 125);
  } else {
    text("bicis", 22, 125);
  }
  if (estacions[int(est_seleccionada)].bicis == 1) {
    text("espai", 317, 125);
  } else {
    text("espais", 317, 125);
  }
  text(estacions[int(est_seleccionada)].direccio, 20, 60);
  text("Estacions properes", 20, 170);
  cp5.get(ButtonBar.class, "properes").setPosition(20+infoboxposx, 200+infoboxposy);
  cp5.get(ButtonBar.class, "properes").setItems(estacions[int(est_seleccionada)].properes);
  if (minimapacarregat) {
    image(minimapa, 20, 250);
    ellipse(180+20, 180+250, 10, 10);
  text(estacions[int(est_seleccionada)].ID, 180+25, 180+227);
  for (int i = 0; i < estacions[int(est_seleccionada)].properes.length; i++) {
    float x, y;
    x = map(estacions[int(estacions[int(est_seleccionada)].properes[i])].x, estacions[int(est_seleccionada)].x-20, estacions[int(est_seleccionada)].x+20, 0, 360);
    y = map(estacions[int(estacions[int(est_seleccionada)].properes[i])].y, estacions[int(est_seleccionada)].y-20, estacions[int(est_seleccionada)].y+20, 0, 360);
    println(x+" "+y);
    if (abs(x-180)<180 && abs(y-180)<180) {
      ellipse(x+20, y+250, 5, 5);
      text(estacions[int(estacions[int(est_seleccionada)].properes[i])].ID, x+25, y+227);
    }
  }
  } else if (!minimapacarregat) {
    text("Carregant...", 20, 250);
  }
  popMatrix();
  //estatics
  textSize(50);
  textAlign(LEFT, TOP);
  fill(textColor);
  textLeading(55);
  text("Live Bicing Data", 40, 30);
  textSize(20);
  text("Updated every ~1 minute", 43, 100);
  text("Rànquings", 43, 230);
  pushMatrix();
  translate(1500, 700);
  text("Llegenda", 0, -20);
  stroke(textColor);
  //mecàniques
  fill(100, 100, 100);
  ellipse(5, 37, 5, 5);
  fill(0, 100, 100);
  ellipse(5, 57, 5, 5);
  fill(100, 100, 100);
  ellipse(5, 77, 10, 10);
  fill(0, 100, 100);
  ellipse(5, 97, 10, 10);
  fill(textColor);
  textAlign(LEFT, CENTER);
  textSize(14);
  text("Mecàniques", 0, 17);
  textSize(12);
  text("Més buida", 15, 35);
  text("Més plena", 15, 55);
  text("Totalment buida", 15, 75);
  text("Totalment plena", 15, 95);
  //elèctriques
  translate(130, 0);
  fill(180, 100, 100);
  ellipse(5, 37, 5, 5);
  fill(240, 100, 100);
  ellipse(5, 57, 5, 5);
  fill(180, 100, 100);
  ellipse(5, 77, 10, 10);
  fill(240, 100, 100);
  ellipse(5, 97, 10, 10);
  fill(textColor);
  textAlign(LEFT, CENTER);
  textSize(14);
  text("Elèctriques", 0, 17);
  textSize(12);
  text("Més buida", 15, 35);
  text("Més plena", 15, 55);
  text("Totalment buida", 15, 75);
  text("Totalment plena", 15, 95);
  popMatrix();
}

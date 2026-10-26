//****************************************************************************//
//                                                                            //
//                SIEGE: BY OLEG YUSCHUK                                      //
//                        IDEA: FALLEN ANGEL INDUSTRIES                       //
//****************************************************************************//

/*
FIELD:
 1-WOOD
 2-METAL
 3-FIRE
 4-MAGIC
*/






PROGRAM Siege;

CONST
  TIM_BUILD=0;           //Zeit zum Aktivieren der gebauten Einheiten
  TIM_RESET=30;          //Zeit zum Reseten des Feldes

  LP_KRIEGER=6;          //Krieger Leben
  SPD_KRIEGER=4;         //Kleiner -> Schneller

  DAM_PFEIL=7;           //Bogenschuetze Pfeil schaden
  EXP_PFEIL=12;          //Bogenschuetze Pfeil Sprengradius

  LP_RAMME=25;           //Ramme Leben
  SPD_RAMME=8;           //Kleiner -> Schneller

  DAM_BOMBER=10;         //Bomber Explosion Schaden
  EXP_BOMBER=18;         //Bomber Explosion Radius
  SPD_BOMBER=3;          //Kleiner -> Schneller

  DAM_KATAPULT=5;        //Schaden PRO Explosionsteil
  PAR_KATAPULT=4;        //Anzahl der Explosionen
  EXP_KATAPULT=12;       //Katapult Spreng- und Streuradius

  DAM_BALLISTE=12;       //Schaden Des Bolzen 2 Explosionen!!
  EXP_BALLISTE=12;       //Balliste Sprengradius

  LP_RANKEN=30;          //Lebenspunkte der Ranken

  LP_RITTER=15;          //Lebenspunkte der Ritter
  SPD_RITTER=5;          //ANDERES SPEEDING! MINDESTENS 2!!

  LP_WOLKE=25;           //Lebenspunkte der Ritter

  DAM_MAGIER=12;         //Schaden des Magierlaser

  LP_ARBEITER=16;        //Vom Arbeiter Reparierte Burg-leben
  TIM_ARBEITER=25;       //Vom Arbeiter benoetigte Zeit (ca. in Sek)

  LP_ELEFANT=35;         //Elefant Leben (Er ist gross aufgepasst!)
  SPD_ELEFANT=4;         //Kleiner -> Schneller

  LP_TURM=14;            //Turm Lebenspunkte (da "fliegend", nur durch Geschosse treffbar). Stirbt wenn geg. Einheit in der Naehe!!
  DAM_TURM=4;            //Turm Pfeil schaden
  EXP_TURM=12;           //Turm Pfeil Sprengradius
  TIM_TURM=30;           //Zeit zwischen Schuessen (In Frames)

  PAR_METEOR=3;          //Anzahl der Meteorteile
  DAM_METEOR=6;          //Schaden durch einen Meteor
  EXP_METEOR=12;         //Explosionsradius der Meteore

  DAM_PEST=10;           //Durch Pest verursachter Schaden
  EXP_PEST=20;           //Pest - Schadensradius

  LP_LUFTSCHIFF=20;      //Leben des Luftschiffes
  EXP_LUFTSCHIFF=12;     //Explosionsradius der Geschosse
  DAM_LUFTSCHIFF=7;      //Schaden der Geschosse
  TIM_LUFTSCHIFF=27;     //Wurfintervall (In Frames)
  SPD_LUFTSCHIFF=2;      //Kleiner -> Schneller

  LP_GOLEM=80;           //Golem Leben (Er ist gross aufgepasst!)
  SPD_GOLEM=4;           //Kleiner -> Schneller, hier besonders langsam!

  LP_DRACHE=30;          //Leben des Drachens
  EXP_DRACHE=15;         //Explosionsradius der Geschosse
  DAM_DRACHE=3;          //Schaden der Geschosse
  PAR_DRACHE=6;          //Anzahl der Sprengungen vom Geschoss
  TIM_DRACHE=50;         //Wurfintervall (In Frames)
  SPD_DRACHE=4;          //Kleiner -> Schneller (Hier durch 2 geteilt denken!!)

  LP_TOTENBESCHWOERER=1; //Leben des Beschwoerers
  SPD_TOTENBESCHWOERER=2;//Er muss erst Laufen
  PAR_TOTENBESCHWOERER=3;//Maximale Skelettzahl

  LP_SKELETT=3;          //Leben
  SPD_SKELETT=5;         //Speed Kleiner-schneller

GLOBAL
  tech[1]=6,6;
  life[1]=100,100;


  STRUCT field[1];
    STRUCT x[5]
      y[4];
    END
  END


LOCAL
  xpos;
  ypos;
  art;
  player;
  fly;
    //fly: 0=no 1=yes; fliegende Einheiten kaempfen nicht.
  big;
    //big: 0=no 1=yes; Diese Einheiten koennen von Pfeilen getrioffen werden
  hitsize;
    //Groesse des Pfeil-trifft_mich Radiusses

  LP;             //Leben der Einheiten werden Lokal gespeichert


BEGIN
  // Bildschirm starten
  load_fpg("olegs\siege.fpg");
  set_mode(m320x240);

  x=160;
  y=120;
  FOR(graph=80; graph<=85; graph++)
    WHILE(NOT (key(_enter) OR key(_space)))
      FRAME;
    END
    WHILE((key(_enter) OR key(_space)))
      FRAME;
    END
  END
  x=0;
  y=0;
  graph=0;


  put_screen(0,1);

  // Felder zufaellig fuellen
  FOR(x=0; x<=5; x++)
    FOR(y=0; y<=4; y++)
      field[0].x[x].y[y]=rand(1,4);
      field[1].x[x].y[y]=rand(1,4);
    END
  END

  // Felder anmalen
  Draw_field(0);
  Draw_field(1);

  // Spieler starten
  Cursor(0,_up,_down,_left,_right,_o,_p,_l);
  Cursor(1,_w,_s,_a,_d,_1,_2,_q);

  // Lebensleisten starten
  Life_Gauge(0);
  Life_Gauge(1);

  //KI(1);

  //Unit-Anzeiger starten
  Unit_Locator();

  // Hintergrund zeichner
  Painter();


  // Irgendein LOOP
  LOOP
    FRAME;
  END


END








PROCESS Cursor(player,cup,cdown,cleft,cright,cclick,cactiv,cnew)

PRIVATE
  choosen;
  temp;
  afch;             //Horizontal
  afcv;             //Vertikal
  afc;              //Restknoepfe
  tim;

BEGIN
  graph=2;
  x=player*188;
  y=0;
  LOOP

    // Movement
    IF(key(cup) AND ypos>0 AND afcv==0)
      ypos--;
      afcv=1;
    END
    IF(key(cdown) AND ypos<4 AND afcv==0)
      ypos++;
      afcv=1;
    END
    IF(key(cleft) AND xpos>0 AND afch==0)
      xpos--;
      afch=1;
    END
    IF(key(cright) AND xpos<5 AND afch==0)
      xpos++;
      afch=1;
    END


    // Graphisch in Position bringen
    x=xpos*22+player*188;
    y=ypos*22;

    // AntiFastClick wieder rueckstellen
    IF(NOT (key(cup) OR key(cdown))) afcv=0; END
    IF(NOT (key(cleft) OR key(cright))) afch=0; END
    IF(NOT (key(cclick) OR key(cactiv) OR key(cnew))) afc=0; END


    // Feld neumachen
    IF(key(cnew) AND afc==0)
      FOR(x=0; x<=5; x++)
        FOR(y=0; y<=4; y++)
          field[player].x[x].y[y]=rand(1,4);
        END
      END
      x=xpos*22+player*188;
      y=ypos*22;
      afc=1;
      FOR(angle=TIM_RESET*12000; angle>0; angle-=12000)
        FRAME;
      END
      angle=0;
      Draw_field(player);
    END


    // Hiermit tauscht man
    IF(key(cclick) AND afc==0)
      IF(choosen==0)
        // Ein Feld waehlen
        choosen=Choosen_cursor(player);
      ELSE
        // Mit einem Feld tauschen
        temp=field[player].x[choosen.xpos].y[choosen.ypos];
        field[player].x[choosen.xpos].y[choosen.ypos]=field[player].x[xpos].y[ypos];
        field[player].x[xpos].y[ypos]=temp;
        signal(choosen,s_kill);
        choosen=0;
        Draw_field(player);
      END
      afc=1;
    END


    //Oho, du willst Einheiten bauen
    IF(key(cactiv) AND afc==0)
      IF(Search_Units(player,2)==1)

        FOR(x=0; x<=5; x++)
          FOR(y=4; y>=2; y--)
            field[player].x[x].y[y]=field[player].x[x].y[y-2];
          END
        END
        FOR(x=0; x<=5; x++)
          FOR(y=1; y>=0; y--)
            field[player].x[x].y[y]=rand(1,4);
          END
        END
        x=xpos*22+player*188;
        y=ypos*22;
        afc=1;
        Draw_field(player);
        FOR(angle=TIM_BUILD*12000; angle>0; angle-=12000)
          FRAME;
        END
        angle=0;


      END
    END

    FRAME;
  END
END


PROCESS Choosen_cursor(player)

BEGIN
  graph=3;
  z=-5;
  x=father.x;
  y=father.y;
  xpos=father.xpos;
  ypos=father.ypos;
  LOOP
    FRAME;
  END
END


PROCESS Draw_field(player)

BEGIN
  FOR (x=0; x<=5; x++)
    FOR (y=0; y<=4; y++)
      put(0,field[player].x[x].y[y]+9,x*22+player*188,y*22);
    END
  END
  Search_Units(player,1);
END


PROCESS Life_gauge(player)

BEGIN
  IF(player==0)
    x=137;
    y=86;
  ELSE
    x=140;
    y=49;
  END

  LOOP
    graph=25-(life[player]*6)/100;
    IF(life[player]<=0) graph=26; END
    IF(graph>26) graph=26; END
    IF(graph<20) graph=20; END
    FRAME;
  END
END


PROCESS Unit_Locator();

BEGIN
  x=0;
  y=66;
  graph=29;
  //flags=4;
  z=10;
  LOOP
    FRAME;
  END
END

PROCESS Painter()

PRIVATE
  STRUCT Vogel[2]
    x;
    y;
    graph;
    dir;
  END

  STRUCT Wolke[5]
    x;
    y;
    graph;
  END

  i;
  winddir;
  windi;

BEGIN
  FOR(i=0; i<6; i++)
    wolke[i].x=64*i*2;
    wolke[i].y=rand(122,170);
    wolke[i].graph=58;
  END

  LOOP
    //Hintergrund
    put(0,40,0,110);

    //Vogel
    FOR(i=0; i<3; i++)
      //Vogel machen
      IF(vogel[i].x>340 OR vogel[i].x<-20 OR vogel[i].y<122)
        IF(rand(0,70)==0)
          vogel[i].dir=2*rand(0,1)-1;
          vogel[i].x=160-170*vogel[i].dir;
          vogel[i].y=rand(122,200);
          vogel[i].graph=50;
        END
      ELSE
        vogel[i].graph++;
        IF(vogel[i].graph>57 OR vogel[i].graph<50) vogel[i].graph=50; END
        vogel[i].x+=vogel[i].dir*(2+rand(0,1));
        xput(0,vogel[i].graph,vogel[i].x,vogel[i].y,0,100,-(vogel[i].dir-1)/2,0);

      END
    END

    //Wolke
    FOR(i=0; i<6; i++)
      //Wolke machen
      IF(wolke[i].x>360*2 OR wolke[i].x<-40*2 OR wolke[i].y<122)
        IF(rand(0,40)==0)
          IF(winddir>0)
            wolke[i].x=-30*2;
            wolke[i].y=rand(122,170);
            wolke[i].graph=58;
          END
          IF(winddir<0)
            wolke[i].x=350*2;
            wolke[i].y=rand(122,170);
            wolke[i].graph=58;
          END
          IF(winddir==0)
            wolke[i].x=0;
            wolke[i].y=0;
            wolke[i].graph=0;
          END

        END
      ELSE
        wolke[i].x+=winddir*(1+rand(-2,2)/2);
        put(0,wolke[i].graph,wolke[i].x/2,wolke[i].y);
      END
    END

    //Wolke Bewegrichtung
    windi++;
    IF(windi>130)
      windi=0;
      winddir+=rand(-1,1);
      IF(winddir>1) winddir=1; END
      IF(winddir<-1) winddir=-1; END

    END




    //Burgen
    xput(0,41,29,221,0,100,0,0);
    xput(0,41,290,221,0,100,1,0);

    FRAME;
  END
END




// *************************************************************************************
// *************************************************************************************
// ***************** DAS ZAUBERBUCH! ***************************************************
// *************************************************************************************
// *************************************************************************************




PROCESS Search_Units(player,art)    //art: 1=Markieren 2=Erstellen

PRIVATE
  used[2];     //Falls schon ein Teil besetzt ist, muss es nicht gecheckt werden.
  F[11];       //Hier wird das "Rezept" eingegeben. Dabei wird nummeriert,
               //wie man liest und 0 steht fuer beliebig
               //Holz=1;
               //Eisen=2;
               //Feuer=3;
               //Magie=4;
  T;           //Das ist die Techstufe der Einheit

  passed;
  chpos;
  pos;
  created;     // Nur wenn eine Einheit erstellt wurde, bewegen sich die Kloetze weiter
  hit;


BEGIN

  //Jetzige Aufstellung loeschen
  FOR(x=0+player*188; x<132+player*188; x++)
    FOR(y=0; y<44; y++)
      map_put_pixel(0,29,x,y,0);
    END
  END

  // Zuerst 6*2er suchen.
    //Magier --------------------------------------------------------------------

      //Vorarbeit
      passed=1;

      //Formel eingeben
      F[00]=0; F[01]=0; F[02]=0; F[03]=0; F[04]=0; F[05]=0;
      F[06]=1; F[07]=1; F[08]=4; F[09]=4; F[10]=4; F[11]=4;
      T=3;

      //Formel checken
      FOR(chpos=0; chpos<12; chpos++)
        IF(tech[player]<T)
          passed=0;
          BREAK;
        END

        IF(used[0]==1 OR used[1]==1 OR used[2]==1)
          passed=0;
          BREAK;
        END

        IF(F[chpos]!=0)
          IF(F[chpos]!=field[player].x[chpos%6].y[chpos/6+3])
            passed=0;
            BREAK;
          END
        END
      END

      //Erstellen
      IF(passed==1)
        IF(art==1)
          // Nur markieren
          map_put(0,29,200,player*188,0);
          used[0]=1; used[1]=1; used[2]=1;
        ELSE
          // Erstellen!
          created=1;
          Animation(4,player);
          used[0]=1; used[1]=1; used[2]=1;
        END
      END


    //Turm --------------------------------------------------------------------

      //Vorarbeit
      passed=1;

      //Formel eingeben
      F[00]=3; F[01]=1; F[02]=1; F[03]=1; F[04]=1; F[05]=3;
      F[06]=1; F[07]=2; F[08]=1; F[09]=1; F[10]=2; F[11]=1;
      T=4;

      //Formel checken
      FOR(chpos=0; chpos<12; chpos++)
        IF(tech[player]<T)
          passed=0;
          BREAK;
        END

        //Div-get_id-Speicher loeschen
        get_id(TYPE cursor);

        //Einzigartige Einheit!!
        WHILE(hit=get_id(TYPE unit))
          IF(hit.art==8 AND player==hit.player)
            passed=0;
            BREAK;
          END
        END
        IF(passed==0) BREAK; END

        IF(used[0]==1 OR used[1]==1 OR used[2]==1)
          passed=0;
          BREAK;
        END

        IF(F[chpos]!=0)
          IF(F[chpos]!=field[player].x[chpos%6].y[chpos/6+3])
            passed=0;
            BREAK;
          END
        END
      END

      //Erstellen
      IF(passed==1)
        IF(art==1)
          // Nur markieren
          map_put(0,29,230,player*188,0);
          used[0]=1; used[1]=1; used[2]=1;
        ELSE
          // Erstellen!
          created=1;
          Unit(8,player);
          used[0]=1; used[1]=1; used[2]=1;
        END
      END



    //Pest --------------------------------------------------------------------

      //Vorarbeit
      passed=1;

      //Formel eingeben
      F[00]=0; F[01]=0; F[02]=1; F[03]=1; F[04]=0; F[05]=0;
      F[06]=4; F[07]=4; F[08]=4; F[09]=4; F[10]=4; F[11]=4;
      T=5;

      //Formel checken
      FOR(chpos=0; chpos<12; chpos++)
        IF(tech[player]<T)
          passed=0;
          BREAK;
        END

        IF(used[0]==1 OR used[1]==1 OR used[2]==1)
          passed=0;
          BREAK;
        END

        IF(F[chpos]!=0)
          IF(F[chpos]!=field[player].x[chpos%6].y[chpos/6+3])
            passed=0;
            BREAK;
          END
        END
      END

      //Erstellen
      IF(passed==1)
        IF(art==1)
          // Nur markieren
          map_put(0,29,250,player*188,0);
          used[0]=1; used[1]=1; used[2]=1;
        ELSE
          // Erstellen!
          created=1;
          Animation(6,player);
          used[0]=1; used[1]=1; used[2]=1;
        END
      END

    //Luftschiff --------------------------------------------------------------------

      //Vorarbeit
      passed=1;

      //Formel eingeben
      F[00]=1; F[01]=1; F[02]=1; F[03]=1; F[04]=1; F[05]=1;
      F[06]=3; F[07]=2; F[08]=3; F[09]=1; F[10]=3; F[11]=1;
      T=5;

      //Formel checken
      FOR(chpos=0; chpos<12; chpos++)
        IF(tech[player]<T)
          passed=0;
          BREAK;
        END

        IF(used[0]==1 OR used[1]==1 OR used[2]==1)
          passed=0;
          BREAK;
        END

        IF(F[chpos]!=0)
          IF(F[chpos]!=field[player].x[chpos%6].y[chpos/6+3])
            passed=0;
            BREAK;
          END
        END
      END

      //Erstellen
      IF(passed==1)
        IF(art==1)
          // Nur markieren
          map_put(0,29,270,player*188,0);
          used[0]=1; used[1]=1; used[2]=1;
        ELSE
          // Erstellen!
          created=1;
          Unit(9,player);
          used[0]=1; used[1]=1; used[2]=1;
        END
      END


    //GOLEM --------------------------------------------------------------------

      //Vorarbeit
      passed=1;

      //Formel eingeben
      F[00]=2; F[01]=2; F[02]=2; F[03]=2; F[04]=2; F[05]=2;
      F[06]=2; F[07]=4; F[08]=4; F[09]=4; F[10]=4; F[11]=2;
      T=6;

      //Formel checken
      FOR(chpos=0; chpos<12; chpos++)
        IF(tech[player]<T)
          passed=0;
          BREAK;
        END

        IF(used[0]==1 OR used[1]==1 OR used[2]==1)
          passed=0;
          BREAK;
        END

        IF(F[chpos]!=0)
          IF(F[chpos]!=field[player].x[chpos%6].y[chpos/6+3])
            passed=0;
            BREAK;
          END
        END
      END

      //Erstellen
      IF(passed==1)
        IF(art==1)
          // Nur markieren
          map_put(0,29,280,player*188,0);
          used[0]=1; used[1]=1; used[2]=1;
        ELSE
          // Erstellen!
          created=1;
          Unit(10,player);
          used[0]=1; used[1]=1; used[2]=1;
        END
      END



    //DRACHE --------------------------------------------------------------------

      //Vorarbeit
      passed=1;

      //Formel eingeben
      F[00]=4; F[01]=3; F[02]=4; F[03]=3; F[04]=4; F[05]=3;
      F[06]=3; F[07]=4; F[08]=3; F[09]=4; F[10]=3; F[11]=4;
      T=6;

      //Formel checken
      FOR(chpos=0; chpos<12; chpos++)
        IF(tech[player]<T)
          passed=0;
          BREAK;
        END

        IF(used[0]==1 OR used[1]==1 OR used[2]==1)
          passed=0;
          BREAK;
        END

        IF(F[chpos]!=0)
          IF(F[chpos]!=field[player].x[chpos%6].y[chpos/6+3])
            passed=0;
            BREAK;
          END
        END
      END

      //Erstellen
      IF(passed==1)
        IF(art==1)
          // Nur markieren
          map_put(0,29,290,player*188,0);
          used[0]=1; used[1]=1; used[2]=1;
        ELSE
          // Erstellen!
          created=1;
          Unit(11,player);
          used[0]=1; used[1]=1; used[2]=1;
        END
      END


    //Totenbeschwoerer --------------------------------------------------------------------

      //Vorarbeit
      passed=1;

      //Formel eingeben
      F[00]=4; F[01]=3; F[02]=4; F[03]=1; F[04]=4; F[05]=2;
      F[06]=4; F[07]=4; F[08]=4; F[09]=4; F[10]=4; F[11]=4;
      T=6;

      //Formel checken
      FOR(chpos=0; chpos<12; chpos++)
        IF(tech[player]<T)
          passed=0;
          BREAK;
        END

        //Div-get_id-Speicher loeschen
        get_id(TYPE cursor);

        //Einzigartige Einheit!!
        WHILE(hit=get_id(TYPE unit))
          IF(hit.art==12 AND player==hit.player)
            passed=0;
            BREAK;
          END
        END
        IF(passed==0) BREAK; END

        IF(used[0]==1 OR used[1]==1 OR used[2]==1)
          passed=0;
          BREAK;
        END

        IF(F[chpos]!=0)
          IF(F[chpos]!=field[player].x[chpos%6].y[chpos/6+3])
            passed=0;
            BREAK;
          END
        END
      END

      //Erstellen
      IF(passed==1)
        IF(art==1)
          // Nur markieren
          map_put(0,29,300,player*188,0);
          used[0]=1; used[1]=1; used[2]=1;
        ELSE
          // Erstellen!
          created=1;
          Unit(12,player);
          used[0]=1; used[1]=1; used[2]=1;
        END
      END



  // Jetzt 4*2er suchen.
    //Katapult --------------------------------------------------------------------

      //Formel eingeben
      F[00]=3; F[01]=3; F[02]=3; F[03]=3;
      F[04]=1; F[05]=2; F[06]=2; F[07]=1;
      T=2;

      //Beide moeglichen Positionen durchgehen
      FOR(pos=0; pos<=1; pos++)

        //Vorarbeit
        passed=1;

        //Formel checken
        FOR(chpos=0; chpos<8; chpos++)
          IF(tech[player]<T)
            passed=0;
            BREAK;
          END

          IF(used[pos]==1 OR used[pos+1]==1)
            passed=0;
            BREAK;
          END

          IF(F[chpos]!=0)
            IF(F[chpos]!=field[player].x[chpos%4+pos*2].y[chpos/4+3])
              passed=0;
              BREAK;
            END
          END
        END

        //Erstellen
        IF(passed==1)
          IF(art==1)
            // Nur markieren
            map_put(0,29,150,player*188+pos*44,0);
            used[pos]=1; used[pos+1]=1;
          ELSE
            // Erstellen!
            created=1;
            Animation(2,player);
            used[pos]=1; used[pos+1]=1;
          END
        END
      END



    //Balliste --------------------------------------------------------------------

      //Formel eingeben
      F[00]=1; F[01]=1; F[02]=1; F[03]=1;
      F[04]=2; F[05]=3; F[06]=3; F[07]=2;
      T=2;

      //Beide moeglichen Positionen durchgehen
      FOR(pos=0; pos<=1; pos++)

        //Vorarbeit
        passed=1;

        //Formel checken
        FOR(chpos=0; chpos<8; chpos++)
          IF(tech[player]<T)
            passed=0;
            BREAK;
          END

          IF(used[pos]==1 OR used[pos+1]==1)
            passed=0;
            BREAK;
          END

          IF(F[chpos]!=0)
            IF(F[chpos]!=field[player].x[chpos%4+pos*2].y[chpos/4+3])
              passed=0;
              BREAK;
            END
          END
        END

        //Erstellen
        IF(passed==1)
          IF(art==1)
            // Nur markieren
            map_put(0,29,160,player*188+pos*44,0);
            used[pos]=1; used[pos+1]=1;
          ELSE
            // Erstellen!
            created=1;
            Animation(3,player);
            used[pos]=1; used[pos+1]=1;
          END
        END
      END

    //Ramme --------------------------------------------------------------------

      //Formel eingeben
      F[00]=0; F[01]=0; F[02]=0; F[03]=0;
      F[04]=1; F[05]=1; F[06]=1; F[07]=2;
      T=1;

      //Beide moeglichen Positionen durchgehen
      FOR(pos=0; pos<=1; pos++)

        //Vorarbeit
        passed=1;

        //Formel checken
        FOR(chpos=0; chpos<8; chpos++)
          IF(tech[player]<T)
            passed=0;
            BREAK;
          END

          IF(used[pos]==1 OR used[pos+1]==1)
            passed=0;
            BREAK;
          END

          IF(F[chpos]!=0)
            IF(F[chpos]!=field[player].x[chpos%4+pos*2].y[chpos/4+3])
              passed=0;
              BREAK;
            END
          END
        END

        //Erstellen
        IF(passed==1)
          IF(art==1)
            // Nur markieren
            map_put(0,29,130,player*188+pos*44,0);
            used[pos]=1; used[pos+1]=1;
          ELSE
            // Erstellen!
            unit(2,player);
            created=1;
            used[pos]=1; used[pos+1]=1;
          END
        END
      END


    //Arbeiter --------------------------------------------------------------------

      //Formel eingeben
      F[00]=2; F[01]=1; F[02]=2; F[03]=1;
      F[04]=1; F[05]=2; F[06]=1; F[07]=2;
      T=4;

      //Beide moeglichen Positionen durchgehen
      FOR(pos=0; pos<=1; pos++)

        //Vorarbeit
        passed=1;

        //Formel checken
        FOR(chpos=0; chpos<8; chpos++)
          IF(tech[player]<T)
            passed=0;
            BREAK;
          END

          //Div-get_id-Speicher loeschen
          get_id(TYPE cursor);

          //Einzigartige Einheit!!
          WHILE(hit=get_id(TYPE Animation))
            IF(hit.art==5 AND player==hit.player)
              passed=0;
              BREAK;
            END
          END
          IF(passed==0) BREAK; END

          IF(used[pos]==1 OR used[pos+1]==1)
            passed=0;
            BREAK;
          END

          IF(F[chpos]!=0)
            IF(F[chpos]!=field[player].x[chpos%4+pos*2].y[chpos/4+3])
              passed=0;
              BREAK;
            END
          END
        END

        //Erstellen
        IF(passed==1)
          IF(art==1)
            // Nur markieren
            map_put(0,29,210,player*188+pos*44,0);
            used[pos]=1; used[pos+1]=1;
          ELSE
            // Erstellen!
            created=1;
            Animation(5,player);
            used[pos]=1; used[pos+1]=1;
          END
        END
      END

    //Elefant --------------------------------------------------------------------

      //Formel eingeben
      F[00]=4; F[01]=1; F[02]=1; F[03]=4;
      F[04]=4; F[05]=2; F[06]=2; F[07]=4;
      T=4;

      //Beide moeglichen Positionen durchgehen
      FOR(pos=0; pos<=1; pos++)

        //Vorarbeit
        passed=1;

        //Formel checken
        FOR(chpos=0; chpos<8; chpos++)
          IF(tech[player]<T)
            passed=0;
            BREAK;
          END

          IF(used[pos]==1 OR used[pos+1]==1)
            passed=0;
            BREAK;
          END

          IF(F[chpos]!=0)
            IF(F[chpos]!=field[player].x[chpos%4+pos*2].y[chpos/4+3])
              passed=0;
              BREAK;
            END
          END
        END

        //Erstellen
        IF(passed==1)
          IF(art==1)
            // Nur markieren
            map_put(0,29,220,player*188+pos*44,0);
            used[pos]=1; used[pos+1]=1;
          ELSE
            // Erstellen!
            unit(7,player);
            created=1;
            used[pos]=1; used[pos+1]=1;
          END
        END
      END


  // Jetzt 2*2er suchen.
    //Ritter --------------------------------------------------------------------

      //Formel eingeben
      F[00]=2; F[01]=3;
      F[02]=2; F[03]=3;
      T=3;

      //Drei moeglichen Positionen durchgehen
      FOR(pos=0; pos<=2; pos++)

        //Vorarbeit
        passed=1;

        //Formel checken
        FOR(chpos=0; chpos<4; chpos++)
          IF(tech[player]<T)
            passed=0;
            BREAK;
          END

          IF(used[pos]==1)
            passed=0;
            BREAK;
          END

          IF(F[chpos]!=0)
            IF(F[chpos]!=field[player].x[chpos%2+pos*2].y[chpos/2+3])
              passed=0;
              BREAK;
            END
          END
        END

        //Erstellen
        IF(passed==1)
          IF(art==1)
            // Nur markieren
            map_put(0,29,180,player*188+pos*44,0);
            used[pos]=1;
          ELSE
            // Erstellen!
            created=1;
            Unit(5,player);
            used[pos]=1;
          END
        END
      END


    //Krieger --------------------------------------------------------------------

      //Formel eingeben
      F[00]=0; F[01]=0;
      F[02]=2; F[03]=2;
      T=1;

      //Drei moeglichen Positionen durchgehen
      FOR(pos=0; pos<=2; pos++)

        //Vorarbeit
        passed=1;

        //Formel checken
        FOR(chpos=0; chpos<4; chpos++)
          IF(tech[player]<T)
            passed=0;
            BREAK;
          END

          IF(used[pos]==1)
            passed=0;
            BREAK;
          END

          IF(F[chpos]!=0)
            IF(F[chpos]!=field[player].x[chpos%2+pos*2].y[chpos/2+3])
              passed=0;
              BREAK;
            END
          END
        END

        //Erstellen
        IF(passed==1)
          IF(art==1)
            // Nur markieren
            map_put(0,29,100,player*188+pos*44,0);
            used[pos]=1;
          ELSE
            // Erstellen!
            created=1;
            used[pos]=1;
            unit(1,player);
          END
        END
      END

    //Bogenschuetze --------------------------------------------------------------------

      //Formel eingeben
      F[00]=0; F[01]=0;
      F[02]=1; F[03]=3;
      T=1;

      //Drei moeglichen Positionen durchgehen
      FOR(pos=0; pos<=2; pos++)

        //Vorarbeit
        passed=1;

        //Formel checken
        FOR(chpos=0; chpos<4; chpos++)
          IF(tech[player]<T)
            passed=0;
            BREAK;
          END

          IF(used[pos]==1)
            passed=0;
            BREAK;
          END

          IF(F[chpos]!=0)
            IF(F[chpos]!=field[player].x[chpos%2+pos*2].y[chpos/2+3])
              passed=0;
              BREAK;
            END
          END
        END

        //Erstellen
        IF(passed==1)
          IF(art==1)
            // Nur markieren
            map_put(0,29,110,player*188+pos*44,0);
            used[pos]=1;
          ELSE
            // Erstellen!
            created=1;
            used[pos]=1;
            Animation(1,player);
          END
        END
      END


    //Bomber --------------------------------------------------------------------

      //Formel eingeben
      F[00]=3; F[01]=3;
      F[02]=3; F[03]=3;
      T=2;

      //Drei moeglichen Positionen durchgehen
      FOR(pos=0; pos<=2; pos++)

        //Vorarbeit
        passed=1;

        //Formel checken
        FOR(chpos=0; chpos<4; chpos++)
          IF(tech[player]<T)
            passed=0;
            BREAK;
          END

          IF(used[pos]==1)
            passed=0;
            BREAK;
          END

          IF(F[chpos]!=0)
            IF(F[chpos]!=field[player].x[chpos%2+pos*2].y[chpos/2+3])
              passed=0;
              BREAK;
            END
          END
        END

        //Erstellen
        IF(passed==1)
          IF(art==1)
            // Nur markieren
            map_put(0,29,140,player*188+pos*44,0);
            used[pos]=1;
          ELSE
            // Erstellen!
            Unit(3,player);
            created=1;
            used[pos]=1;
          END
        END
      END


    //Ranken --------------------------------------------------------------------

      //Formel eingeben
      F[00]=4; F[01]=4;
      F[02]=1; F[03]=1;
      T=3;

      //Drei moeglichen Positionen durchgehen
      FOR(pos=0; pos<=2; pos++)


        //Vorarbeit
        passed=1;

        //Formel checken
        FOR(chpos=0; chpos<4; chpos++)
          IF(tech[player]<T)
            passed=0;
            BREAK;
          END

          //Div-get_id-Speicher loeschen
          get_id(TYPE cursor);

          //Einzigartige Einheit!!
          WHILE(hit=get_id(TYPE unit))
            IF(hit.art==4 AND player==hit.player)
              passed=0;
              BREAK;
            END
          END
          IF(passed==0) BREAK; END

          IF(used[pos]==1)
            passed=0;
            BREAK;
          END

          IF(F[chpos]!=0)
            IF(F[chpos]!=field[player].x[chpos%2+pos*2].y[chpos/2+3])
              passed=0;
              BREAK;
            END
          END
        END

        //Erstellen
        IF(passed==1)
          IF(art==1)
            // Nur markieren
            map_put(0,29,170,player*188+pos*44,0);
            used[pos]=1;
          ELSE
            // Erstellen!
            Unit(4,player);
            created=1;
            used[pos]=1;
          END
        END
      END


    //Wolke --------------------------------------------------------------------

      //Formel eingeben
      F[00]=4; F[01]=4;
      F[02]=4; F[03]=4;
      T=3;

      //Drei moeglichen Positionen durchgehen
      FOR(pos=0; pos<=2; pos++)


        //Vorarbeit
        passed=1;

        //Formel checken
        FOR(chpos=0; chpos<4; chpos++)
          IF(tech[player]<T)
            passed=0;
            BREAK;
          END

          //Div-get_id-Speicher loeschen
          get_id(TYPE cursor);

          //Einzigartige Einheit!!
          WHILE(hit=get_id(TYPE unit))
            IF(hit.art==6 AND player==hit.player)
              passed=0;
              BREAK;
            END
          END
          IF(passed==0) BREAK; END

          IF(used[pos]==1)
            passed=0;
            BREAK;
          END

          IF(F[chpos]!=0)
            IF(F[chpos]!=field[player].x[chpos%2+pos*2].y[chpos/2+3])
              passed=0;
              BREAK;
            END
          END
        END

        //Erstellen
        IF(passed==1)
          IF(art==1)
            // Nur markieren
            map_put(0,29,190,player*188+pos*44,0);
            used[pos]=1;
          ELSE
            // Erstellen!
            Unit(6,player);
            created=1;
            used[pos]=1;
          END
        END
      END


    //Meteor --------------------------------------------------------------------

      //Formel eingeben
      F[00]=4; F[01]=4;
      F[02]=3; F[03]=3;
      T=5;

      //Drei moeglichen Positionen durchgehen
      FOR(pos=0; pos<=2; pos++)

        //Vorarbeit
        passed=1;

        //Formel checken
        FOR(chpos=0; chpos<4; chpos++)
          IF(tech[player]<T)
            passed=0;
            BREAK;
          END

          IF(used[pos]==1)
            passed=0;
            BREAK;
          END

          IF(F[chpos]!=0)
            IF(F[chpos]!=field[player].x[chpos%2+pos*2].y[chpos/2+3])
              passed=0;
              BREAK;
            END
          END
        END

        //Erstellen
        IF(passed==1)
          IF(art==1)
            // Nur markieren
            map_put(0,29,240,player*188+pos*44,0);
            used[pos]=1;
          ELSE
            // Erstellen!
            x=160+rand(-10,10)+(1-player*2)*30;
            For(hit=0; hit<PAR_METEOR; hit++)
              shot(5,player);
            END
            created=1;
            used[pos]=1;
          END
        END
      END


  return(created);
END



// *************************************************************************************
// *************************************************************************************
// ***************** DIE KI! ***************************************************
// *************************************************************************************
// *************************************************************************************

PROCESS KI(player)

PRIVATE
  counter;
  Wait;

BEGIN
  LOOP
    counter=rand(0,20);

    IF(counter<20) Unit(1,player); ELSE counter-=20; END



    FOR (wait=24; wait>0; wait--)
      FRAME;
    END

  END
END

























// *************************************************************************************
// *************************************************************************************
// ***************** DAS SCHLACHTFELD! ***************************************************
// *************************************************************************************
// *************************************************************************************





PROCESS Unit(art,player) //Erstellt eine Einheit die Kaempfen kann

/* List of Units (art)
  art=1 : Krieger
  art=2 : Ramme
  art=3 : Bomber
  art=4 : Ranken
  art=5 : Ritter
  art=6 : Wolke
  art=7 : Elefant
  art=8 : Turm
  art=9 : Luftschiff
  art=11: Drache
  art=12: Totenbeschwoerer
  art=13: Skelett

*/

PRIVATE
  movefreq;
  hit;
  res;
  Mensch;                              //Zum Totebeschwoeren!!!

BEGIN
  //Standart Erstellung
  x=49+player*221;
  y=221;
  flags=player;
  movefreq=rand(0,4);


  //KRIEGER ********************************************************************
  IF(art==1)
    mensch=1;
    graph=101;
    LP=LP_KRIEGER;
    LOOP
      //Bewegung
      IF(Movefreq==0)
        x+=(1-player*2)*(1+rand(0,1));
      END


      //Kampf gegen andere UNITS!
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<8)
          IF(hit.LP>0 AND LP>0 AND fly!=1 AND hit.fly!=1 AND player!=hit.player)
            hit.LP--;
            LP--;
          END
        END
      END

      //Der obligatorische 'FRAME'!
      FRAME;

      //Bei erreichter Festung Leben abziehen
      IF((player==0 AND x>259) OR (player==1 AND x<60))
        life[1-player]-=sqrt(LP*4);
        LP=0;
      END

      //Wenn LP 0 erreicht
      IF(LP<=0)
        BREAK;
      END

      //Graphik aktualisieren
      movefreq++;
      IF(movefreq>SPD_KRIEGER)
        movefreq=0;
        graph++;
        IF(graph>104) graph=101; END
      END
    END
  END


  //RAMME ********************************************************************
  IF(art==2)
    mensch=1;
    graph=131;
    LP=LP_RAMME;
    LOOP
      //Bewegung
      IF(Movefreq==0)
        x+=(1-player*2)*(1+rand(0,1));
      END


      //Kampf gegen andere UNITS!
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<8)
          IF(hit.LP>0 AND LP>0 AND fly!=1 AND hit.fly!=1 AND player!=hit.player)
            hit.LP--;
            LP--;
          END
        END
      END

      //Der obligatorische 'FRAME'!
      FRAME;

      //Bei erreichter Festung Leben abziehen
      IF((player==0 AND x>259) OR (player==1 AND x<60))
        life[1-player]-=sqrt(LP*4);
        LP=0;
      END

      //Wenn LP 0 erreicht
      IF(LP<=0)
        BREAK;
      END

      //Graphik aktualisieren
      movefreq++;
      IF(movefreq>SPD_RAMME)
        movefreq=0;
        graph++;
        IF(graph>134) graph=131; END
      END
    END
  END


  //BOMBER ********************************************************************
  IF(art==3)
    mensch=1;
    graph=141;
    LP=1;
    LOOP
      //Bewegung
      IF(Movefreq==0)
        x+=(1-player*2)*(1+rand(0,1));
      END

      //Kampf gegen andere UNITS!
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<8)
          IF(hit.LP>0 AND LP>0 AND fly!=1 AND hit.fly!=1 AND player!=hit.player)
            hit.LP--;
            LP--;
          END
        END
      END

      //Der obligatorische 'FRAME'!
      FRAME;

      //Bei erreichter Festung Leben abziehen
      IF((player==0 AND x>259) OR (player==1 AND x<60))
        life[1-player]-=sqrt(LP*4);
        LP=0;
      END

      //Wenn LP 0 erreicht
      //Spezialfall Bomber: Wenn LP<=0 oder In der Mitte: SPRENGEN!
      IF(LP<=0 OR (player==0 AND x>160) OR (player==1 AND x<160))
        Explode(3,player);
        BREAK;
      END

      //Graphik aktualisieren
      movefreq++;
      IF(movefreq>SPD_BOMBER)
        movefreq=0;
        graph++;
        IF(graph>144) graph=141; END
      END
    END
  END

  //RANKEN ********************************************************************
  IF(art==4)
    z=5;
    graph=171;
    LP=LP_RANKEN;
    x=80+player*159;
    big=1;
    hitsize=24;

    LOOP
      //Kampf gegen andere UNITS!
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<8)
          IF(hit.LP>0 AND LP>0 AND fly!=1 AND hit.fly!=1 AND player!=hit.player)
            hit.LP--;
            LP--;
          END
        END
      END

      //Der obligatorische 'FRAME'!
      FRAME;

      //Wenn LP 0 erreicht
      IF(LP<=0)
        BREAK;
      END

      //Graphik aktualisieren
      movefreq++;
      IF(movefreq>1)
        movefreq=0;
        graph++;
        IF(graph>176) graph=176; END
      END
    END
  END

  //RITTER ********************************************************************
  IF(art==5)
    mensch=1;
    graph=181;
    LP=LP_RITTER;
    LOOP
      //Bewegung
      IF(Movefreq==0)
        x+=(1-player*2)*(1+(rand(0,SPD_RITTER)/(SPD_RITTER-1)));
      END


      //Kampf gegen andere UNITS!
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<8)
          IF(hit.LP>0 AND LP>0 AND fly!=1 AND hit.fly!=1 AND player!=hit.player)
            hit.LP--;
            LP--;
          END
        END
      END

      //Der obligatorische 'FRAME'!
      FRAME;

      //Bei erreichter Festung Leben abziehen
      IF((player==0 AND x>259) OR (player==1 AND x<60))
        life[1-player]-=sqrt(LP*4);
        LP=0;
      END

      //Wenn LP 0 erreicht
      IF(LP<=0)
        BREAK;
      END

      //Graphik aktualisieren
      movefreq++;
      IF(movefreq>0)
        movefreq=0;
        graph++;
        IF(graph>186) graph=181; END
      END
    END
  END


  //WOLKE ********************************************************************
  IF(art==6)
    z=-5;
    graph=191;
    LP=LP_WOLKE;
    x=126+player*67;
    y=165;
    Fly=1;       //Fliegt!! D.h. kaempft nicht!
    big=1;
    hitsize=30;
    size=0;

    LOOP
      //Der obligatorische 'FRAME'!
      FRAME;

      //Wenn LP 0 erreicht
      IF(LP<=0)
        BREAK;
      END

      //Graphik aktualisieren
      movefreq++;
      IF(size<100) size+=10; END
      IF(movefreq>2)
        movefreq=0;
        graph=rand(0,10);
        IF(graph<3)
          graph=graph+192;
        ELSE
          graph=191;
        END
      END
    END
  END

  //Elefant ********************************************************************
  IF(art==7)
    mensch=1;
    graph=221;
    LP=LP_ELEFANT;
    big=1;
    hitsize=24;
    LOOP
      //Bewegung
      IF(Movefreq==0)
        x+=(1-player*2)*(1+rand(0,1));
      END


      //Kampf gegen andere UNITS!
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<8)
          IF(hit.LP>0 AND LP>0 AND fly!=1 AND hit.fly!=1 AND player!=hit.player)
            hit.LP--;
            LP--;
          END
        END
      END

      //Der obligatorische 'FRAME'!
      FRAME;

      //Bei erreichter Festung Leben abziehen
      IF((player==0 AND x>259) OR (player==1 AND x<60))
        life[1-player]-=sqrt(LP*4);
        LP=0;
      END

      //Wenn LP 0 erreicht
      IF(LP<=0)
        BREAK;
      END

      //Graphik aktualisieren
      movefreq++;
      IF(movefreq>SPD_ELEFANT)
        movefreq=0;
        graph++;
        IF(graph>224) graph=221; END
      END
    END
  END


  //TURM ********************************************************************
  IF(art==8)
    mensch=1;
    z=5;
    graph=231;
    LP=LP_TURM;
    big=1;
    hitsize=24;
    x=110+player*99;

    LOOP
      //Kampf gegen andere UNITS!
      //In diesem Fall -> TOD
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<8)
          IF(hit.fly!=1 AND player!=hit.player)
            LP=0;
            BREAK;
          END
        END
      END

      //Der obligatorische 'FRAME'!
      FRAME;

      //Wenn LP 0 erreicht
      IF(LP<=0)
        BREAK;
      END

      //Schuss abwarten
      movefreq++;
      IF(movefreq>TIM_TURM)
        movefreq=0;
        shot(4,player);
      END
    END
  END


  //LUFTSCHIFF ********************************************************************
  IF(art==9)
    graph=271;
    LP=LP_LUFTSCHIFF;
    fly=1;
    big=1;
    hitsize=24;
    y=160;
    LOOP
      //Schuss abwarten
      res++;
      IF(res>TIM_LUFTSCHIFF AND ((player==0 AND x>120) OR (player==1 AND x<200)))
        res=0;
        shot(6,player);
      END

      //Der obligatorische 'FRAME'!
      FRAME;

      //Bei erreichter Festung Leben abziehen
      IF((player==0 AND x>259) OR (player==1 AND x<60))
        life[1-player]-=sqrt(LP*4);
        LP=0;
      END

      //Wenn LP 0 erreicht
      IF(LP<=0)
        BREAK;
      END

      //Graphik aktualisieren
      graph++;
      IF(graph>274) graph=271; END

      //Bewegung
      movefreq++;
      IF(movefreq>SPD_LUFTSCHIFF)
        movefreq=0;
        x+=1-player*2;
      END


    END
  END


  //GOLEM ********************************************************************
  IF(art==10)
    graph=281;
    LP=LP_GOLEM;
    big=1;
    hitsize=30;
    LOOP
      //Bewegung
      IF((graph==282 OR graph==284) AND Movefreq==0)
        x+=(1-player*2)*(1+rand(0,1));
      END


      //Kampf gegen andere UNITS!
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<8)
          IF(hit.LP>0 AND LP>0 AND fly!=1 AND hit.fly!=1 AND player!=hit.player)
            hit.LP--;
            LP--;
          END
        END
      END

      //Der obligatorische 'FRAME'!
      FRAME;

      //Bei erreichter Festung Leben abziehen
      IF((player==0 AND x>259) OR (player==1 AND x<60))
        life[1-player]-=sqrt(LP*4);
        LP=0;
      END

      //Wenn LP 0 erreicht
      IF(LP<=0)
        BREAK;
      END

      //Graphik aktualisieren
      movefreq++;
      IF(movefreq>SPD_GOLEM)
        movefreq=0;
        graph++;
        IF(graph>284) graph=281; END
      END
    END
  END

  //DRACHE ********************************************************************
  IF(art==11)
    graph=291;
    LP=LP_DRACHE;
    fly=1;
    big=1;
    hitsize=24;
    y=160;
    LOOP
      //Bewegung
      IF(Movefreq==0 OR Movefreq==SPD_DRACHE/2)
        x+=(1-player*2)*(1+rand(0,1));
      END

      //Der obligatorische 'FRAME'!
      FRAME;

      //Bei erreichter Festung Leben abziehen
      IF((player==0 AND x>259) OR (player==1 AND x<60))
        life[1-player]-=sqrt(LP*4);
        LP=0;
      END

      //Wenn LP 0 erreicht
      IF(LP<=0)
        BREAK;
      END

      //Schuss abwarten
      res++;
      IF(res>TIM_DRACHE AND ((player==0 AND x>100) OR (player==1 AND x<220)))
        res=0;
        shot(7,player);
      END

      //Graphik aktualisieren
      movefreq++;
      IF(movefreq>SPD_DRACHE)
        movefreq=0;
        graph++;
        IF(graph>294) graph=291; END
      END
    END
  END


  //TOTENBESCHWOERER ********************************************************************
  IF(art==12)
    graph=301;
    LP=LP_TOTENBESCHWOERER;
    LOOP
      //Bewegung
      IF(Movefreq==0 AND ((player==0 AND x<105) OR (player==1 AND x>214)))
        x+=(1-player*2)*(1+rand(0,1));
      END


      //Kampf gegen andere UNITS!
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<8)
          IF(hit.LP>0 AND LP>0 AND fly!=1 AND hit.fly!=1 AND player!=hit.player)
            hit.LP--;
            LP--;
          END
        END
      END

      //Der obligatorische 'FRAME'!
      FRAME;

      //Bei erreichter Festung Leben abziehen
      IF((player==0 AND x>259) OR (player==1 AND x<60))
        life[1-player]-=sqrt(LP*4);
        LP=0;
      END

      //Wenn LP 0 erreicht
      IF(LP<=0)
        BREAK;
      END

      //Graphik aktualisieren
      movefreq++;
      IF(movefreq>SPD_TOTENBESCHWOERER)
        IF(((player==0 AND x<105) OR (player==1 AND x>214)))
          movefreq=0;
          graph++;
          IF(graph>304) graph=301; END
        ELSE
          movefreq=0;
          graph++;
          IF(graph>308) graph=305; END
        END
      END
    END
  END

  //Skelett ********************************************************************
  IF(art==13)
    x=father.x;
    y=father.y;
    mensch=0;
    graph=311;
    LP=LP_SKELETT;
    LOOP
      //Bewegung
      IF(Movefreq==0)
        x+=(1-player*2)*(1+rand(0,1));
      END


      //Kampf gegen andere UNITS!
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<8)
          IF(hit.LP>0 AND LP>0 AND fly!=1 AND hit.fly!=1 AND player!=hit.player)
            hit.LP--;
            LP--;
          END
        END
      END

      //Der obligatorische 'FRAME'!
      FRAME;

      //Bei erreichter Festung Leben abziehen
      IF((player==0 AND x>259) OR (player==1 AND x<60))
        LP=0;
      END

      //Wenn LP 0 erreicht
      IF(LP<=0)
        BREAK;
      END

      //Graphik aktualisieren
      movefreq++;
      IF(movefreq>SPD_SKELETT)
        movefreq=0;
        graph++;
        IF(graph>314) graph=311; END
      END
    END
  END






  //Blut auf dem Schlachtfeld verteilen!!!
  Explode(0,player);

  //Wird ein Toter beschworen???
  IF(Mensch==1)
    //Div-get_id-Speicher loeschen
    get_id(TYPE cursor);

    //Suche den Beschwoerer!!
    WHILE(hit=get_id(TYPE unit))
      IF(hit.art==12 AND player==hit.player AND hit.graph>=305 AND hit.graph<=308)
        //JA! Beschwoerer gefunden!! Aber... Wie viele Skelettis gibts denn?
        get_id(TYPE cursor);
        mensch=0;
        WHILE(hit=get_id(TYPE unit))
          IF(art==13 AND player==hit.player)
            mensch++;
          END
        END
        IF(mensch<PAR_TOTENBESCHWOERER)
          Unit(13,player);
        END
      END
    END
  END



END






PROCESS Shot(art,player) //Erstellt einen Schuss

/* List of Shots (art)
  art=1 : Pfeil (Bogenschuetze)
  art=2 : Stein (Katapult)
  art=3 : Bolzen (Balliste)
  art=4 : Pfeil (Turm)
  art=5 : Meteor
  art=6 : Luftschiffschuss
  art=7 : Drachenschuss
*/
PRIVATE
  velx;
  vely;
  oldx;
  oldy;
  hit;
  counter;

BEGIN
  x=father.x;
  y=father.y-1;
  oldx=x;
  oldy=y;


  // Pfeil vom Bogenschuetzen **************************************************
  IF(art==1)
    graph=116;
    velx=6*(1-player*2)+rand(-1,1);
    vely=-13+rand(-1,1);
    LOOP

      //Bewegung
      oldx=x;
      oldy=y;
      x+=velx;
      y+=vely;
      vely+=1;

      //Winkel finden
      angle=fget_angle(oldx,oldy,x,y);

      //Trifft grosse Einheit
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<hit.hitsize AND hit.big==1)
          IF(hit.LP>0 AND player!=hit.player)
            hit.LP-=DAM_PFEIL;                 //Pfeilschaden!!!
            Explode(2,player);
            return();
          END
        END
      END

      //Trifft Boden
      IF(y>222)
        y=222;
        Explode(1,player);
        return();
      END

      //Der obligatorische 'FRAME'
      FRAME;
    END
  END


  // Stein vom Katapult **************************************************
  IF(art==2)
    graph=156;
    y-=13;
    velx=6*(1-player*2)+rand(-1,1);
    vely=-13+rand(-1,1);
    angle=0;
    size=125;
    LOOP
      //Bewegung
      oldx=x;
      oldy=y;
      x+=velx;
      y+=vely;
      vely+=1;

      //Winkel finden
      angle+=18345;

      //Trifft grosse Einheit
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<hit.hitsize AND hit.big==1)
          IF(hit.LP>0 AND player!=hit.player)
            hit.LP-=DAM_KATAPULT*PAR_KATAPULT;
            Explode(2,player);
            return();
          END
        END
      END

      //Trifft Boden
      IF(y>222)
        y=222;
        For(counter=0; counter<PAR_KATAPULT; counter++)
          FRAME;
          Explode(4,player);
        END
        return();
      END

      //Der obligatorische 'FRAME'
      FRAME;
    END
  END


  // Bolzen der Balliste **************************************************
  IF(art==3)
    graph=165;
    y-=5;
    velx=14*(1-player*2);
    vely=-3;
    angle=0;
    size=100;
    LOOP
      //Bewegung
      oldx=x;
      oldy=y;
      x+=velx;
      y+=vely;
      vely+=1;

      //Winkel finden
      angle=fget_angle(oldx,oldy,x,y);

      //Trifft Einheit
      WHILE(hit=get_id(TYPE unit))
        IF((get_dist(hit)<hit.hitsize AND hit.big==1) OR get_dist(hit)<12)
          IF(hit.LP>0 AND player!=hit.player)
            y=222;
            Explode(5,player);
            x+=EXP_BALLISTE;
            Explode(5,player);
            return();
          END
        END
      END

      //Trifft Boden
      IF(y>222)
        y=222;
        Explode(5,player);
        x+=EXP_BALLISTE;
        Explode(5,player);
        return();
      END

      //Der obligatorische 'FRAME'
      FRAME;
    END
  END

  // Pfeil vom Turm **************************************************
  IF(art==4)
    graph=116;
    velx=(4+rand(0,1))*(1-player*2);
    vely=0;
    y-=27;
    LOOP

      //Bewegung
      oldx=x;
      oldy=y;
      x+=velx;
      y+=vely;
      vely+=1;

      //Winkel finden
      angle=fget_angle(oldx,oldy,x,y);

      //Trifft grosse Einheit
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<hit.hitsize AND hit.big==1)
          IF(hit.LP>0 AND player!=hit.player)
            hit.LP-=DAM_TURM;                 //Pfeilschaden!!!
            Explode(2,player);
            return();
          END
        END
      END

      //Trifft Boden
      IF(y>222)
        y=222;
        Explode(6,player);
        return();
      END

      //Der obligatorische 'FRAME'
      FRAME;
    END
  END

  // Meteor **************************************************
  IF(art==5)
    graph=156;
    y=120;
    velx=rand(-3,3);
    vely=2;
    angle=0;
    size=125;
    LOOP
      //Bewegung
      oldx=x;
      oldy=y;
      x+=velx;
      y+=vely;
      vely+=1;

      //Winkel finden
      angle+=18345;

      //Trifft grosse Einheit
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<hit.hitsize AND hit.big==1)
          IF(hit.LP>0 AND player!=hit.player)
            hit.LP-=DAM_METEOR;
            Explode(2,player);
            return();
          END
        END
      END

      //Trifft Boden
      IF(y>222)
        y=222;
        Explode(7,player);
        return();
      END

      //Der obligatorische 'FRAME'
      FRAME;
    END
  END

  // Luftschiffbombe **************************************************
  IF(art==6)
    graph=275;
    y=father.y+5;
    x=father.x+6*(1-player*2);
    vely=-1;
    angle=0;
    size=100;
    LOOP
      //Bewegung
      oldx=x;
      oldy=y;
      x+=velx;
      y+=vely;
      vely+=1;

      //Trifft grosse Einheit
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<hit.hitsize AND hit.big==1)
          IF(hit.LP>0 AND player!=hit.player AND hit.fly!=1)
            hit.LP-=DAM_LUFTSCHIFF;
            Explode(2,player);
            return();
          END
        END
      END

      //Trifft Boden
      IF(y>222)
        y=222;
        Explode(8,player);
        return();
      END

      //Der obligatorische 'FRAME'
      FRAME;
    END
  END

  // DRACHENSCHUSS **************************************************
  IF(art==7)
    graph=156;
    y=father.y+5;
    x=father.x+8*(1-player*2);
    vely=-1;
    velx=2*(1-player*2);
    angle=0;
    size=150;
    LOOP
      //Bewegung
      oldx=x;
      oldy=y;
      x+=velx;
      y+=vely;
      vely+=1;

      //Trifft grosse Einheit
      WHILE(hit=get_id(TYPE unit))
        IF(get_dist(hit)<hit.hitsize AND hit.big==1)
          IF(hit.LP>0 AND player!=hit.player AND hit.fly!=1)
            hit.LP-=DAM_DRACHE*PAR_DRACHE;
            Explode(2,player);
            y+=3;
            x+=5;
            Explode(2,player);
            x-=9;
            y+=3;
            Explode(2,player);
            return();
          END
        END
      END

      //Trifft Boden
      IF(y>222)
        y=222;
        For(counter=0; counter<PAR_DRACHE; counter++)
          FRAME;
          Explode(9,player);
        END
        return();
      END

      //Der obligatorische 'FRAME'
      FRAME;
    END
  END




END




PROCESS Animation(art,player) //Erstellt eine Animation (z.b. Bogenschuetze)

/* List of Animations (Art)
  art=1 : Bogenschuetze
  art=2 : Katapult
  art=3 : Balliste
  art=4 : Magier
  art=5 : Arbeiter
  art=6 : Pest
*/
PRIVATE
  hit;
  time;

BEGIN
  x=39+player*241+rand(-6,6);
  y=221;
  flags=player;
  z=-5;

  // Bogenschuetze *************************************************************
  IF(art==1)
    graph=111;
    FRAME(700);
    graph=112;
    FRAME(200);
    graph=113;
    shot(1,player);
    FRAME(400);

  END


  // Katapult *************************************************************
  IF(art==2)
    graph=151;
    FRAME(1500);
    FOR(graph=152; graph<154; graph++)
      FRAME(200);
    END
    shot(2,player);
    FRAME(200);
    graph++;
    FRAME(700);

  END


  // Balliste *************************************************************
  IF(art==3)
    graph=161;
    FRAME(1500);
    FOR(graph=161; graph<164; graph++)
      FRAME(200);
    END
    shot(3,player);
    FRAME(700);

  END

  // Magier *************************************************************
  IF(art==4)
    x=60+player*199;
    graph=201;
    FRAME(1000);
    FOR(graph=201; graph<204; graph++)
      FRAME(200);
    END

    //Schaden
    WHILE(hit=get_id(TYPE unit))
      IF(fget_dist(x,0,hit.x,0)<115 AND hit.player!=player AND hit.fly!=1)
        hit.LP-=DAM_MAGIER;
      END
    END

    FRAME(200);
    FOR(graph=206; graph>202; graph--)
      FRAME(200);
    END


    FRAME(700);

  END

  // Arbeiter *************************************************************
  IF(art==5)
    graph=211;
    time=TIM_ARBEITER*15;
    life[player]+=LP_ARBEITER;
    IF(life[player]>100) life[player]=100; END

    FOR(time=time; time>0; time--)

      IF(time%15==0)
        graph=215;
        xpos=rand(10,50)+260*player;
        ypos=rand(142,221);
        WHILE(fget_dist(x,y,xpos,ypos)>10)
          angle=fget_angle(x,y,xpos,ypos);
          advance(15);
          FRAME;
        END
        x=xpos;
        y=ypos;
        graph=210;
        angle=0;
      END



      graph++;
      IF(graph>214) graph=211; END

      FRAME;
    END

  END

  // Pest *************************************************************
  IF(art==6)
    x=rand(120,200);
    FOR(graph=251; graph<256; graph++)
      FRAME(100);
    END

    //Schaden
    WHILE(hit=get_id(TYPE unit))
      IF(get_dist(hit)<EXP_PEST AND hit.fly!=1)
        hit.LP-=DAM_PEST;
        IF(hit.LP<1 AND hit.player!=player)
          Animation(6,player);
        END
      END
    END

    FRAME(100);
    FOR(graph=257; graph<261; graph++)
      FRAME(200);
    END


    FRAME(100);

  END





END





PROCESS Explode(art,player)

/* List of Explosions (Art)
  art=0 : Blut
  art=1 : Pfeil-Explosion schaedigt Gegner + Eigene
  art=2 : Pur graphische Explosion
  art=3 : Bomber-Explosion schaedigt Gegner + Eigene
  art=4 : Katapult-Explosion schaedigt Gegner + Eigene
  art=5 : Balliste Explosion schaedigt Gegner + Eigene und schlaegt bissele durch
  art=6 : Turm Explosion schaedigt nur Gegner
  art=7 : Meteor Explosion schaedigt Gegner + Eigene
  art=8 : Luftschiffbombe schaedigt Gegner + Eigene
  art=9 : Drachenschuss schaedigt Gegner + Eigene
*/
PRIVATE
  hit;



BEGIN
  x=father.x;
  y=father.y;

  // Blutspritzer******** ******************************************************
  IF(art==0)
    FOR(graph=90; graph<=97; graph++)
      FRAME;
    END
  END

  // Sprengpfeil ***************************************************************
  IF(art==1)
    FOR(graph=119; graph>=117; graph--)
      FRAME;
    END

    //Sprengung tut weh!!!
    WHILE(hit=get_id(TYPE unit))
      IF(get_dist(hit)<EXP_PFEIL)
        hit.LP-=DAM_PFEIL;
      END
    END

    FOR(graph=117; graph<=120; graph++)
      FRAME;
    END
  END


  // Graphische Explosion ******************************************************
  IF(art==2)
    FOR(graph=120; graph>=117; graph--)
      FRAME;
    END
    FOR(graph=117; graph>=120; graph++)
      FRAME;
    END
  END


  // BOMBER EXPLOSION ***************************************************************
  IF(art==3)
    Size=130;
    FOR(graph=119; graph>=117; graph--)
      FRAME;
    END

    //Sprengung tut weh!!!
    WHILE(hit=get_id(TYPE unit))
      IF(get_dist(hit)<EXP_BOMBER)
        hit.LP-=DAM_BOMBER;
      END
    END

    FOR(graph=117; graph<=120; graph++)
      FRAME;
    END
  END


  // Katapult Sprengung ***************************************************************
  IF(art==4)
    size=120;
    x+=rand(-(EXP_KATAPULT*3)/2,(EXP_KATAPULT*3)/2);

    FOR(graph=119; graph>=117; graph--)
      FRAME;
    END

    //Sprengung tut weh!!!
    WHILE(hit=get_id(TYPE unit))
      IF(get_dist(hit)<EXP_KATAPULT)
        hit.LP-=DAM_KATAPULT;
      END
    END

    FOR(graph=117; graph<=120; graph++)
      FRAME;
    END
  END

  // Balliste Sprengung ***************************************************************
  IF(art==5)
    size=120;

    FOR(graph=119; graph>=117; graph--)
      FRAME;
    END

    //Sprengung tut weh!!!
    WHILE(hit=get_id(TYPE unit))
      IF(get_dist(hit)<EXP_BALLISTE)
        hit.LP-=DAM_BALLISTE;
      END
    END

    FOR(graph=117; graph<=120; graph++)
      FRAME;
    END
  END

  // Turmpfeil ***************************************************************
  IF(art==6)
    FOR(graph=119; graph>=117; graph--)
      FRAME;
    END

    //Sprengung tut weh!!!
    WHILE(hit=get_id(TYPE unit))
      IF(get_dist(hit)<EXP_TURM AND player!=hit.player)
        hit.LP-=DAM_TURM;
      END
    END

    FOR(graph=117; graph<=120; graph++)
      FRAME;
    END
  END

  // Meteor ***************************************************************
  IF(art==7)
    FOR(graph=119; graph>=117; graph--)
      FRAME;
    END

    //Sprengung tut weh!!!
    WHILE(hit=get_id(TYPE unit))
      IF(get_dist(hit)<EXP_METEOR)
        hit.LP-=DAM_METEOR;
      END
    END

    FOR(graph=117; graph<=120; graph++)
      FRAME;
    END
  END

  // Luftschiff-bombe ***************************************************************
  IF(art==8)
    FOR(graph=119; graph>=117; graph--)
      FRAME;
    END

    //Sprengung tut weh!!!
    WHILE(hit=get_id(TYPE unit))
      IF(get_dist(hit)<EXP_LUFTSCHIFF)
        hit.LP-=DAM_LUFTSCHIFF;
      END
    END

    FOR(graph=117; graph<=120; graph++)
      FRAME;
    END
  END

  // Drache Sprengung ***************************************************************
  IF(art==9)
    size=140;
    x+=rand(-(EXP_DRACHE*3)/2,(EXP_DRACHE*3)/2);

    FOR(graph=119; graph>=117; graph--)
      FRAME;
    END

    //Sprengung tut weh!!!
    WHILE(hit=get_id(TYPE unit))
      IF(get_dist(hit)<EXP_DRACHE)
        hit.LP-=DAM_DRACHE;
      END
    END

    FOR(graph=117; graph<=120; graph++)
      FRAME;
    END
  END


END













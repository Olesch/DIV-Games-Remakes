

//Colors for Unit map:
//
//20=Red Building
//22=Red Vehicle
//24=One Red Infantry
//25=Two Red Infantrys
//26=Three Red Infantrys
//
//52=Blue Building
//54=Blue Vehicle
//56=One Blue Infantry
//57=Two Blue Infantrys
//58=Three Blue Infantrys
//
//
//-------------------------------------------------------------------
// TITLE:   Tutorial 1
// AUTHOR:  Antonio Marchal
// DATE:    10/10/97
//-------------------------------------------------------------------

PROGRAM Tutorial_1;

GLOBAL
    Kartenhoehe=39;
    Kartenbreite=39;
    KartenLandschaft=500;
    Kartenflaeche=501;
    KartenRadar=502;

    Point_x;
    Point_y;

    Click_x_1=-1;    // Wo die Maus klickt Spieler1
    Click_y_1=-1;    // Wo die Maus klickt
    Click_x_2=-1;    // Wo die Maus klickt Spieler2
    Click_y_2=-1;    // Wo die Maus klickt
    Move_x_1=-1;    // Wohin die Selectierten Einheiten Laufen sollen Spieler1
    Move_y_1=-1;    // Wohin die Selectierten Einheiten Laufen sollen
    Move_x_2=-1;    // Wohin die Selectierten Einheiten Laufen sollen Spieler2
    Move_y_2=-1;    // Wohin die Selectierten Einheiten Laufen sollen
    Attack_id_1;    // Wen die selectierten Einheiten angreifen sollen Spieler1
    Attack_id_2;    // Wen die selectierten Einheiten angreifen sollen Spieler2
    Attack_x_1;
    Attack_y_1;     // Die Einheit die Angegriffen werden soll
    Attack_x_2;     // wird ausgewaehlt
    Attack_y_2;
    Deselect_1;     // Alle Werden abgewaehlt.
    Deselect_2;     //
                     //                                I          K
                     //                                1          Q
    Mousedoing_1;    // Was macht die Maus? 1=Waehlen  2=Bewegen  3=Angreifen
    Mousedoing_2;    // Was macht die Maus? 1=Waehlen  2=Bewegen  3=Angreifen

    counter0;
    Farbenwandler[255]=     // Colour convertion table from red to blue
        0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
        48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,
        32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,
        48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,
        64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,
        80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,
        96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,
        112,113,114,115,116,117,118,119,120,121,122,123,123,125,126,127,
        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,
        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,
        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,
        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,
        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,
        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,
        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,
        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255;


    /*Farbenwandler[255]=     // no changes
        0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
        16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,
        32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,
        48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,
        64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,
        80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,
        96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,
        112,113,114,115,116,117,118,119,120,121,122,123,123,125,126,127,
        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,
        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,
        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,
        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,
        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,
        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,
        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,
        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255, */



LOCAL
    Selected;   // Schaut ob eine Einheit gewaehlt ist (1=gewaehlt,0=nicht gewaehlt)
    Life;       // Speichert die Leben Von Einheiten




BEGIN
    max_process_time=5000;
    load_fpg("Olegs\Ollwars.fpg");  // Loads graphics' file
    load_fpg("Olegs\OlwUnits.fpg");  // Loads graphics' file
    load_fpg("Olegs\OlwUnits.fpg");  // Loads graphics' file
    load_fnt("Olegs\Space.fnt");  // Loads font type

    //set_mode(m1024x768);               // Sets video mode to 640x480
    set_mode(m640x480);               // Sets video mode to 640x480

    set_fps(24,0);                    // Number of frames per second
    define_Region(1,1,1,319,479);
    define_Region(2,321,1,319,479);
    cursor(320,240,480);//,_up,_down,_left,_right);                 // Creates ship process
    cursor2(320,240,480);//,_w,_s,_a,_d);                 // Creates ship process
    Felder(KartenLandschaft);


    FROM counter0=1 TO 2;
        convert_palette(2,counter0,&Farbenwandler);
    END

    FROM counter0=201 TO 202;
        convert_palette(2,counter0,&Farbenwandler);
    END

    get_point(0,KartenLandschaft,1,offset Point_x,offset Point_y);
    Headquarter(Point_x*32-16,Point_y*32-16,201,1);

    get_point(0,KartenLandschaft,2,offset Point_x,offset Point_y);
    Headquarter(Point_x*32-16,Point_y*32-16,201,2);

    Karte(KartenLandschaft);
    Radar(Kartenradar);

    Unit(304,304,1,1);
    Unit(336,304,1,1);
    Unit(304,336,1,2);
    Unit(336,336,1,2);

END







PROCESS cursor(x,y,graph)
PRIVATE
  movspeed1;  //"mouse" moving speed
  Wait;       //After Clicking it waits until it kills all Variables

BEGIN
    cnumber=c_0;
    z=-100;
    start_scroll(0,0,501,0,1,0);
    scroll[0].camera=id;
    ctype=c_scroll;

    LOOP
        IF(key(_o))
          movspeed1+=16;

        END


        IF(key(_l))

          IF(key(_i))
            move_x_1=(x-(x MOD 32))/32;
            move_y_1=(y-(y MOD 32))/32;
            Wait=2;
          END

          IF(key(_k))
            Attack_x_1=(x-(x MOD 32))/32;
            Attack_y_1=(y-(y MOD 32))/32;
            Wait=2;
          END

          IF(NOT key(_i) AND NOT key(_k))
            click_x_1=(x-(x MOD 32))/32;
            click_y_1=(y-(y MOD 32))/32;
            Wait=2;
          END

        END


        IF(key(_j))
          Deselect_1=1;
          Wait=2;
        END


        IF(wait<1)
            move_x_1=-1;
            move_y_1=-1;
            Attack_x_1=-1;
            Attack_y_1=-1;
            click_x_1=-1;
            click_y_1=-1;
            Deselect_1=0;

         ELSE
         wait--;
        END

        IF(key(_up)) y-=movspeed1; END
        IF(key(_down)) y+=movspeed1; END
        IF(key(_left)) x-=movspeed1; END
        IF(key(_right)) x+=movspeed1; END
        movspeed1=8;




        new_coordinates();
        FRAME;

        //click_x_1=-1;
        //click_y_1=-1;

    END
END






PROCESS cursor2(x,y,graph)
PRIVATE
  movspeed2;  //"mouse" moving speed
  Wait;

BEGIN
    cnumber=c_1;
    z=-100;
    start_scroll(1,0,501,0,2,0);
    scroll[1].camera=id;
    ctype=c_scroll;

    LOOP
        IF(key(_2))

          movspeed2+=16;

        END

        IF(key(_w))

          IF(key(_1))
            move_x_2=(x-(x MOD 32))/32;
            move_y_2=(y-(y MOD 32))/32;
            Wait=2;
          END

          IF(key(_q))
            Attack_x_2=(x-(x MOD 32))/32;
            Attack_y_2=(y-(y MOD 32))/32;
            Wait=2;
          END

          IF(NOT key(_q) AND NOT key(_1))
            click_x_2=(x-(x MOD 32))/32;
            click_y_2=(y-(y MOD 32))/32;
            Wait=2;
          END

        END

        IF(key(_a))
          Deselect_2=1;
          Wait=2;
        END

        IF(wait<1)
            move_x_2=-1;
            move_y_2=-1;
            Attack_x_2=-1;
            Attack_y_2=-1;
            click_x_2=-1;
            click_y_2=-1;
            Deselect_2=0;

         ELSE
         wait--;
        END



        IF(key(_e)) y-=movspeed2; END
        IF(key(_d)) y+=movspeed2; END
        IF(key(_s)) x-=movspeed2; END
        IF(key(_f)) x+=movspeed2; END
        movspeed2=8;

        new_coordinates();
        FRAME;

        //click_x_2=-1;
        //click_y_2=-1;

    END
END






PROCESS Felder(Karten)
PRIVATE
 Xgetter=0;
 Ygetter=0;

BEGIN
  LOOP
    IF(map_get_pixel(0,Kartenlandschaft,Xgetter,Ygetter)==41)
      Grasfeld(Xgetter*32,Ygetter*32);
     ELSE
      IF(map_get_pixel(0,Kartenlandschaft,Xgetter,Ygetter)==120)
        Lehmfeld(Xgetter*32,Ygetter*32);

      END

    END
    Xgetter++;
    IF(Xgetter>Kartenbreite+2)
      Xgetter=0;
      Ygetter++;
    END
    IF(Ygetter>Kartenhoehe+2)
      Xgetter=0;
      Ygetter=0;
      RETURN;
    END

  END

END






PROCESS Grasfeld(x,y)
PRIVATE
 xplusses;
 yplusses;


BEGIN
  LOOP
    map_put_pixel(0,Kartenflaeche,x,y,rand(32,35));
    x++;
    xplusses++;
    IF(xplusses>32)
      x-=33;
      xplusses-=33;
      y++;
      yplusses++;
    END
    IF(yplusses>32)
      RETURN;
    END

  END
END






PROCESS Lehmfeld(x,y)
PRIVATE
 xplusses;
 yplusses;


BEGIN
  LOOP
    IF(rand(0,1))
      map_put_pixel(0,Kartenflaeche,x,y,rand(116,118));
     ELSE
     map_put_pixel(0,Kartenflaeche,x,y,rand(32,35));
    END
    x++;
    xplusses++;
    IF(xplusses>32)
      x-=33;
      xplusses-=33;
      y++;
      yplusses++;
    END
    IF(yplusses>32)
      RETURN;
    END

  END
END







PROCESS Unit(x,y,graph,file)
PRIVATE
 x_coord;     // Damit die Einheit anwaehlbar ist
 y_coord;     // Damit die Einheit anwaehlbar ist
 x_move;      // Koordinaten wo hinbewegt werden soll
 y_move;      // Koordinaten wo hinbewegt werden soll
 unit_target; // Einheit die Angegriffen werden soll
 gettoangle;  // Dreht sich zu dem Winkel




BEGIN



    ctype=c_scroll;
    Resolution=100;
    x=x*100;
    y=y*100;

    x_coord=(x-(x MOD 3200))/3200;
    y_coord=(y-(y MOD 3200))/3200;
    x_move=x_coord;
    y_move=y_coord;

    LOOP
        //Wo bin ich?
        x_coord=(x-(x MOD 3200))/3200;
        y_coord=(y-(y MOD 3200))/3200;


        //Bin ich angewaehlt worden?
        IF(file==1)
         IF(click_x_1==x_coord)
           IF(click_y_1==y_coord)
             selected=1;
           END
         END

         ELSE
         IF(click_x_2==x_coord)
           IF(click_y_2==y_coord)
             selected=1;
           END
         END

        END



        //Werde ich abgewaehlt?
        IF(file==1)
          IF(Deselect_1==1)
            Selected=0;

          END
         ELSE
          IF(Deselect_2==1)
            Selected=0;

          END
        END


        //Wohin soll ich gehen?
        IF(Selected==1)
          IF(file==1)
            IF(Move_x_1!=-1)
              IF(Move_y_1!=-1)
                x_move=Move_x_1;
                y_move=Move_y_1;

              END
            END

           ELSE

            IF(Move_x_2!=-1)
              IF(Move_y_2!=-1)
                x_move=Move_x_2;
                y_move=Move_y_2;


              END
            END
          END
        END


        //Wohin sollte ich schauen?
        IF(x_move!=x_coord OR y_move!=y_coord)

          IF(x_move>x_coord)
            IF(y_move>y_coord)
              gettoangle=-45000;

            END
            IF(y_move<y_coord)
              gettoangle=45000;

            END
            IF(y_move==y_coord)
              gettoangle=0;

            END
          END

          IF(x_move<x_coord)
            IF(y_move>y_coord)
              gettoangle=-135000;

            END
            IF(y_move<y_coord)
              gettoangle=135000;

            END
            IF(y_move==y_coord)
              gettoangle=180000;

            END
          END

          IF(x_move==x_coord)
            IF(y_move>y_coord)
              gettoangle=-90000;

            END
            IF(y_move<y_coord)
              gettoangle=90000;

            END
            IF(y_move==y_coord)
              //Tja, das wurd von vornherein ausgeschlossen!

            END
          END
         ELSE
         gettoangle=angle;
        END


        //Ich drehe mich!
        angle = near_angle(angle, gettoangle, 5000);


        /*IF(gettoangle!=angle)
          IF(gettoangle>angle)
            angle+=5000;

            IF(gettoangle<angle)
              angle=gettoangle;
            END

          END

          IF(gettoangle<angle)
            angle-=5000;

            IF(gettoangle>angle)
              angle=gettoangle;
            END

          END

        END      */











        //NOCH FALSCH!
        IF(gettoangle==angle)
            IF(fget_dist(x,y,x_move*3200+1600,y_move*3200+1600)<3200)
                advance(fget_dist(x_coord,y_coord,x_move,y_move));
              ELSE
               advance(3200);
            END

            /*IF(map_get_pixel(0,Kartenlandschaft,x_coord,y_coord)==120 OR
               map_get_pixel(0,KartenRadar,x_coord,y_coord)==20 OR
               map_get_pixel(0,KartenRadar,x_coord,y_coord)==22 OR
               map_get_pixel(0,KartenRadar,x_coord,y_coord)==52 OR
               map_get_pixel(0,KartenRadar,x_coord,y_coord)==54 )

              advance(-300);
            END*/


        END








        /*If something goes wrong//NOCH FALSCH!
        IF(fget_dist(x_coord,y_coord,x_move,y_move)<100)
         advance(fget_dist(x_coord,y_coord,x_move,y_move));
         ELSE
         advance(100);
        END
        IF(gettoangle==angle)
          IF(x_move!=x_coord OR y_move!=y_coord)

            advance(100);
            IF(map_get_pixel(0,Kartenlandschaft,x_coord,y_coord)==120 OR
               map_get_pixel(0,KartenRadar,x_coord,y_coord)==20 OR
               map_get_pixel(0,KartenRadar,x_coord,y_coord)==22 OR
               map_get_pixel(0,KartenRadar,x_coord,y_coord)==52 OR
               map_get_pixel(0,KartenRadar,x_coord,y_coord)==54 )

              advance(-300);
            END

          END
        END */


        //Radaraufbauung
        IF(file==1)
           map_put_pixel(0,KartenRadar,x_coord,y_coord,22);
         ELSE
          map_put_pixel(0,KartenRadar,x_coord,y_coord,54);
        END

        FRAME;

        //Radarabbauung
        map_put_pixel(0,KartenRadar,x_coord,y_coord,0);


    END
END








PROCESS Headquarter(x,y,graph,file)
BEGIN
    ctype=c_scroll;
        IF(file==1)
            map_put_pixel(0,KartenRadar,(x-16)/32,(y-16)/32,20);
            map_put_pixel(0,KartenRadar,(x-16)/32+1,(y-16)/32,20);
            map_put_pixel(0,KartenRadar,(x-16)/32-1,(y-16)/32,20);
            map_put_pixel(0,KartenRadar,(x-16)/32,(y-16)/32+1,20);
            map_put_pixel(0,KartenRadar,(x-16)/32+1,(y-16)/32+1,20);
            map_put_pixel(0,KartenRadar,(x-16)/32-1,(y-16)/32+1,20);
            map_put_pixel(0,KartenRadar,(x-16)/32,(y-16)/32-1,20);
            map_put_pixel(0,KartenRadar,(x-16)/32+1,(y-16)/32-1,20);
            map_put_pixel(0,KartenRadar,(x-16)/32-1,(y-16)/32-1,20);
          ELSE
           map_put_pixel(0,KartenRadar,(x-16)/32,(y-16)/32,52);
           map_put_pixel(0,KartenRadar,(x-16)/32+1,(y-16)/32,52);
           map_put_pixel(0,KartenRadar,(x-16)/32-1,(y-16)/32,52);
           map_put_pixel(0,KartenRadar,(x-16)/32,(y-16)/32+1,52);
           map_put_pixel(0,KartenRadar,(x-16)/32+1,(y-16)/32+1,52);
           map_put_pixel(0,KartenRadar,(x-16)/32-1,(y-16)/32+1,52);
           map_put_pixel(0,KartenRadar,(x-16)/32,(y-16)/32-1,52);
           map_put_pixel(0,KartenRadar,(x-16)/32+1,(y-16)/32-1,52);
           map_put_pixel(0,KartenRadar,(x-16)/32-1,(y-16)/32-1,52);
        END

    LOOP

        FRAME;

    END
END







PROCESS Karte(graph)

BEGIN
    x=320;
    y=21;
    z=-98;
    LOOP
        FRAME;
    END
END






PROCESS Radar(graph)

BEGIN
    x=320;
    y=21;
    z=-99;
    LOOP
        FRAME;
    END
END









PROCESS new_coordinates()
BEGIN
    // If it gets out by the left, forces it to appear by the right
    // subtracting screen's wide
    IF (father.x<0) father.x=0; END
    // If it gets out by the right, forces it to appear by the left
    IF (father.x>Kartenbreite*32+31) father.x=Kartenbreite*32+31; END
    // If it gets out by the top, forces it to appear by the bottom
    IF (father.y<-0) father.y=0; END
    // If it gets out by the bottom, forces it to appear by the top
    IF (father.y>Kartenhoehe*32+31) father.y=Kartenhoehe*32+31; END
END

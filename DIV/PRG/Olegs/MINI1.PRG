//
//-------------------------------------------------------------------
// TITLE:   Tutorial 1
// AUTHOR:  Oleg Yuschuk
// DATE:    17/07/2004
//-------------------------------------------------------------------

PROGRAM Tutorial_1;

GLOBAL
    ShotStop=10;             // Leben der Schiesser.
    MaxHits=5;             // Leben der Schiesser.
    Maxspeed=17000;           // Speed-Constant
    Beschleunigung=600;     // SpeedUp-Constant
    AutoBremse=75;     // AutoBrake-Constant
    Kugelexplode=40;
    Playerexplode=200;
    Karte=1;
    shotlife=8;
    Fastfire=0;
    Eigenkilla=1;       //Kugeln-Kugeln
    Eigenkillb=1;       //Kugeln-Player
    Playx=150;
    Playy=100;
    shieldmod=1;        //1=shield
    Pinselgr=1;         //Wie schnell die Einstellung geht

    //ManaAbteilung

    Manamax=500;
    exploshotrad=20;     //Explosionsschussradius

LOCAL
Whatdo;


PRIVATE
    contador0=0;
    zeigerpos=1;

BEGIN
    x=190;
    y=4;
    graph=7;
    load_fpg("Olegs\Mini1.fpg");  // Loads graphics' file
    load_fnt("Olegs\Mini1.fnt");  // Loads font type
    set_mode(m640x480);               // Sets video mode to 640x480
    set_fps(24,0);                    // Number of frames per second
    write(0,300,0,0,"Einstellzahl Knoepfe Q W A S Z X");
    write(0,300,15,0,"E=1 R=5 T=10 Y=50 U=100 I=1000");
    write(0,0,0,0,"Leben");
    write(0,0,15,0,"Max. Geschwingigkeit");
    write(0,0,30,0,"Beschleunigung");
    write(0,0,45,0,"Bremse");
    write(0,0,60,0,"Spielerexplosionsdurchmesser");
    write(0,0,75,0,"Kugelexplosionsdurchmesser");
    write(0,0,90,0,"Lebensdauer der Schuesse");
    write(0,0,105,0,"Dauer zwischen den Schuessen");
    write(0,0,120,0,"Schnellfeuer? 0=nein");
    write(0,0,135,0,"Eigenzerstoerung Schuesse? 0=nein");
    write(0,0,150,0,"Eigenzerstoerung Schiffe? 0=nein");
    write(0,0,165,0,"Entfernung vom Rand H");
    write(0,0,180,0,"Entfernung vom Rand V");
    write(0,0,195,0,"Schildmodus 0=kein Schild");

    write_int(0,600,0,0,OFFSET Pinselgr);
    write_int(0,200,0,0,OFFSET MaxHits);
    write_int(0,200,15,0,OFFSET Maxspeed);
    write_int(0,200,30,0,OFFSET Beschleunigung);
    write_int(0,200,45,0,OFFSET AutoBremse);
    write_int(0,200,60,0,OFFSET Playerexplode);
    write_int(0,200,75,0,OFFSET Kugelexplode);
    write_int(0,200,90,0,OFFSET shotlife);
    write_int(0,200,105,0,OFFSET Shotstop);
    write_int(0,200,120,0,OFFSET fastfire);
    write_int(0,200,135,0,OFFSET Eigenkilla);
    write_int(0,200,150,0,OFFSET Eigenkillb);
    write_int(0,200,165,0,OFFSET playx);
    write_int(0,200,180,0,OFFSET playy);
    write_int(0,200,195,0,OFFSET shieldmod);

    LOOP
        IF(Key(_down)) y+=15; zeigerpos+=1;END
        IF(Key(_up)) y-=15; zeigerpos-=1;END
        IF(Key(_Q)) Pinselgr-=1;END
        IF(Key(_W)) Pinselgr+=1;END
        IF(Key(_A)) Pinselgr-=10;END
        IF(Key(_S)) Pinselgr+=10;END
        IF(Key(_Z)) Pinselgr-=100;END
        IF(Key(_X)) Pinselgr+=100;END
        IF(Key(_E)) Pinselgr=1;END
        IF(Key(_R)) Pinselgr=5;END
        IF(Key(_T)) Pinselgr=10;END
        IF(Key(_Y)) Pinselgr=50;END
        IF(Key(_U)) Pinselgr=100;END
        IF(Key(_I)) Pinselgr=1000;END

        IF(Key(_left))
            IF(zeigerpos==1) MaxHits-=Pinselgr; END
            IF(zeigerpos==2) MaxSpeed-=Pinselgr; END
            IF(zeigerpos==3) Beschleunigung-=Pinselgr; END
            IF(zeigerpos==4) Autobremse-=Pinselgr; END
            IF(zeigerpos==5) Playerexplode-=Pinselgr; END
            IF(zeigerpos==6) Kugelexplode-=Pinselgr; END
            IF(zeigerpos==7) Shotlife-=Pinselgr; END
            IF(zeigerpos==8) shotstop-=Pinselgr; END
            IF(zeigerpos==9) fastfire-=Pinselgr; END
            IF(zeigerpos==10) eigenkilla-=Pinselgr; END
            IF(zeigerpos==11) eigenkillb-=Pinselgr; END
            IF(zeigerpos==12) playx-=Pinselgr; END
            IF(zeigerpos==13) playy-=Pinselgr; END
            IF(zeigerpos==14) shieldmod-=Pinselgr; END
        END

        IF(Key(_right))
            IF(zeigerpos==1) MaxHits+=Pinselgr; END
            IF(zeigerpos==2) MaxSpeed+=Pinselgr; END
            IF(zeigerpos==3) Beschleunigung+=Pinselgr; END
            IF(zeigerpos==4) Autobremse+=Pinselgr; END
            IF(zeigerpos==5) Playerexplode+=Pinselgr; END
            IF(zeigerpos==6) Kugelexplode+=Pinselgr; END
            IF(zeigerpos==7) Shotlife+=Pinselgr; END
            IF(zeigerpos==8) shotstop+=Pinselgr; END
            IF(zeigerpos==9) fastfire+=Pinselgr; END
            IF(zeigerpos==10) eigenkilla+=Pinselgr; END
            IF(zeigerpos==11) eigenkillb+=Pinselgr; END
            IF(zeigerpos==12) playx+=Pinselgr; END
            IF(zeigerpos==13) playy+=Pinselgr; END
            IF(zeigerpos==14) shieldmod+=Pinselgr; END

        END
        IF(Key(_esc) OR Key(_enter) OR Key(_space))
            delete_text(all_text);
            BREAK;
        END
        FRAME;
    END
    screen(320,240,Karte);
//    put_screen(0,1);                 // Puts background screen
    FROM contador0=0 TO 499;
        put_pixel(rand(21,618),rand(21,458),127);
    END
    player(playx,playy,2,-45000,_left,_right,_up,_end);
    player(640-playx,playy,3,-135000,_a,_d,_w,_q);
    player(640-playx,480-playy,4,-225000,_c_end,_c_pgdn,_c_center,_del);
    player(playx,480-playy,5,-315000,_j,_l,_i,_u);


//    write_int(1,320,0,1,OFFSET score);     // Shows the score
END

//-------------------------------------------------------------------
// Handles player's ship
// Entries: Coordinates and graphic's code number
//-------------------------------------------------------------------

PROCESS screen(x,y,graph)
BEGIN
    LOOP
        FRAME;
    END
END


PROCESS player(x,y,graph,angle,left,right,shoot,manashoot)

PRIVATE
Rotation=0;
Clicked=0;
Leben=0;
shotwait=0;
Mana=0;

shield;
shotkill;

BEGIN
    Mana=Manamax;
    Leben=MaxHits;
    IF(shieldmod==1)
        shield=playershield(x,y,angle,left,right);
    END
    LOOP
        IF (Eigenkilla==0)
            WHILE(shotkill=collision (TYPE shot))
                IF(shotkill.graph!=graph+5)
                    Leben-=1;
                    shotkill.Whatdo=1;
                END
                IF(shotkill.graph==graph+5)
                    shotkill.Whatdo=2;
                END
            END
          ELSE
          IF (shotkill=collision (TYPE shot))
              Leben-=1;
              shotkill.Whatdo=1;
          END

        END

        IF (Leben<0) explode(x,y,Playerexplode); BREAK;  END
        IF (key(left)) rotation+=Beschleunigung; END
        IF (key(right)) rotation-=Beschleunigung; END
        IF (rotation>=Maxspeed) rotation=Maxspeed; END
        IF (rotation<=-Maxspeed) rotation=-Maxspeed; END
        angle+=rotation;
        IF (rotation>=1) rotation-=AutoBremse; END
        IF (rotation<=-1) rotation+=AutoBremse; END

        IF (key(shoot))
            IF(shotwait<1)
                IF(Clicked==0)
                    shotwait=ShotStop;
                    IF(fastfire==0) Clicked=1; END
                    shot(x,y,angle,graph+5);
                END
            END
          ELSE
            Clicked=0;
        END


        IF (key(manashoot))
            IF(shotwait<1-shotstop*3-20)
                IF(Clicked==0)
                    Exploshot(x,y,angle,graph+5);
                    shotwait=ShotStop;
                    IF(fastfire==0) Clicked=1; END
                END
            END
          ELSE
            Clicked=0;
        END


        shotwait-=1;
        FRAME;
    END
    signal(shield,s_kill);
END

PROCESS playershield(x,y,angle,left,right)

PRIVATE
Rotation=0;

BEGIN
    graph=6;
    LOOP
    /*    IF (key(left)) rotation+=Beschleunigung; END
        IF (key(right)) rotation-=Beschleunigung; END
        IF (rotation>=Maxspeed) rotation=Maxspeed; END
        IF (rotation<=-Maxspeed) rotation=-Maxspeed; END
        angle+=rotation;
        IF (rotation>=1) rotation-=AutoBremse; END
        IF (rotation<=-1) rotation+=AutoBremse; END  */
        angle=father.angle;
        FRAME;
    END
END






//-------------------------------------------------------------------
// Process shot
// Creates ship's shots
// Entries: Shot's coordinates and angle
//-------------------------------------------------------------------

PROCESS shot(x,y,angle,graph)
PRIVATE
Treffer=0;
Rech=0;
Othershot=0;


BEGIN
    advance(36);
    WHILE (NOT out_region(id,0))
        advance(7);

            IF (collision (TYPE Playershield))
               angle=angle+180000;
               advance(6);
            END

            IF (collision (TYPE screen))
                Treffer++;
                Treffer++;
                IF(Treffer>shotlife) Break; END

                IF(map_get_pixel(0,Karte,x-18,y)==55)
                Rech=360000-angle;
                Rech=90000-Rech;
                angle=270000-Rech;
                x+=5;

                END

                IF(map_get_pixel(0,Karte,x+18,y)==55)
                Rech=360000-angle;
                Rech=90000-Rech;
                angle=270000-Rech;
                x-=5;
                END

                IF(map_get_pixel(0,Karte,x,y-18)==55)
                Rech=90000-angle;
                Rech=90000-Rech;
                angle=360000-Rech;
                y+=5;


                END

                IF(map_get_pixel(0,Karte,x,y+18)==55)
                Rech=90000-angle;
                Rech=90000-Rech;
                angle=360000-Rech;
                y-=5;


                END


            END
            IF(Eigenkillb==0)
                IF (Othershot=collision (TYPE shot))
                    IF(Othershot.graph!=graph)
                        Othershot.Whatdo=1;
                        BREAK;
                    END
                END
              ELSE
              IF (Othershot=collision (TYPE shot))
                Othershot.Whatdo=1;
                BREAK;
              END
            END
            IF (collision (TYPE explode)) Break; END
            IF (Whatdo==1) BREAK; END
            IF (Whatdo==2) shrink(x,y,graph,size,4); RETURN; END

        FRAME;  // Shows graphic on screen
    END
    explode(x,y,Kugelexplode);
END




PROCESS explode(x,y,size)

BEGIN
    FROM graph=11 TO 16; FRAME; END
END

PROCESS shrink(x,y,graph,size,sizeminus)

BEGIN
    LOOP
        size-=sizeminus;
        IF(size<1) BREAK; END
        FRAME;
    END
END



// Manaattacks

/*PROCESS Exploshot(x,y,angle,graph)
BEGIN
    advance(36);
    explode(x,y,(exploshotrad*3)/2);
    WHILE (NOT out_region(id,0))
        explode(x+rand(-100,100),y+rand(-100,100),exploshotrad);
        explode(x+rand(-100,100),y+rand(-100,100),exploshotrad);
        explode(x+rand(-100,100),y+rand(-100,100),exploshotrad);
        advance(exploshotrad/2);
        angle+=rand(-1,1)*1000;
        FRAME;  // Shows graphic on screen
    END
END*/

/*PROCESS Exploshot(x,y,angle,graph)
BEGIN
    advance(45);
    angle+=90000;
    explode(x,y,(exploshotrad*3)/2);
    WHILE (NOT out_region(id,0))
        explode(x,y,exploshotrad);
        advance(7);
        angle+=7600;
        FRAME;  // Shows graphic on screen
    END
END*/

PROCESS Exploshot(x,y,angle,graph)
BEGIN
    advance(45);
    explode(x,y,(exploshotrad*3)/2);
    WHILE (NOT out_region(id,0))
        explode(x+rand(-40,40),y+rand(-40,40),exploshotrad);
        explode(x+rand(-40,40),y+rand(-40,40),exploshotrad);
        explode(x+rand(-40,40),y+rand(-40,40),exploshotrad);
        advance(7);
        angle+=rand(-10000,10000);
        FRAME;  // Shows graphic on screen
    END
END







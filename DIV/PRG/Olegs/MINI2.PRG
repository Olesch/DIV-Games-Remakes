//
//-------------------------------------------------------------------
// TITLE:   Canonball Riding
// AUTHOR:  Oleg Yuschuk
// DATE:    23/07/2004
//-------------------------------------------------------------------

PROGRAM Canonball_Riding;

GLOBAL
  Wind=0;             // The Wind in the Game
  Windnew;            // Damit Wind nicht ruckartig aendert
  WindChange=0;       // Time until Wind changes direction
  Cannonshot=0;       // Time until Cannon shots
  frames;
  Player1ID;
  Player2ID;
  KanShotRate=4800;   // How fast kannons shot smaller=faster
  score=0;            // Your points
  Playercount=0;      // One or two players
  Hiscore1=0;         // Your best points by one player
  Hiscore2=0;         // Your best points by two players

LOCAL
  SpeedChange;        // Wenn die Spieler kollidieren
  x_inc;              // x Speed increasing
  Life=3;             // Lebenspunkte der Spieler

BEGIN

    load("saves\CbScore1.sav",Offset Hiscore1);
    load("saves\CbScore2.sav",Offset Hiscore2);

    load_fpg("Olegs\Mini2.fpg");  // Loads graphics' file
    load_fnt("Olegs\Mini2.fnt");  // Loads font type

    set_mode(m640x480);               // Sets video mode to 640x480
    set_fps(frames=24,0);                    // Number of frames per second
    put_screen(0,9);                  // Puts background screen
    FROM x=1 TO 15;                    // Creates clouds
        cloud(rand(0,640),rand(0,480),rand(10,11),rand(50,200));
    END
    Windnew=rand(-25,25);
    WindRegulator();

    write(1,320,170,4,"Canonball Riding");
    write(1,640,480,8,"Programmed by Oleg Yuschuk");
    write(1,320,220,4,"1 - Ein Spieler");
    write(1,320,260,4,"2 - Zwei Spieler");
    write(1,0,0,0,"1 Spieler Hi-Score");
    write(1,0,40,0,"2 Spieler Hi-Score");
    write_int(1,640,0,2,OFFSET Hiscore1);
    write_int(1,640,40,2,OFFSET Hiscore2);
    LOOP
        IF(key(_1))
          Player1ID=player(320,400,1,_left,_right,1);   // Creates ship process
          Playercount=1;
          Delete_Text(all_text);
          write_int(1,320,0,1,OFFSET score);     // Shows the score
          escproc();
          BREAK;
        END
        IF(key(_2))
          Player1ID=player(427,400,1,_left,_right,1);   // Creates ship process
          Player2ID=player(213,400,2,_a,_d,2);          // Creates ship process
          Playercount=11;
          Delete_Text(all_text);
          write_int(1,320,0,1,OFFSET score);     // Shows the score
          escproc();
          BREAK;
        END
        IF(key(_3))
          Player1ID=player(320,400,1,_left,_right,1);   // Creates ship process
          Player2ID=player(160,400,2,_a,_d,2);          // Creates ship process
          Player2ID=player(480,400,2,_a,_d,2);          // Creates ship process
          Playercount=11;
          Delete_Text(all_text);
          write_int(1,320,0,1,OFFSET score);     // Shows the score
          escproc();
          BREAK;
        END
        IF(key(_esc))
            fade_off();
            exit("Ride Canonballs again soon!",Score);
        END
        FRAME;
    END




    LOOP
        Cannonshot++;
        IF(Cannonshot>KanShotRate/100)
            cannonball(rand(0,640),rand(-5,5),rand(-25,-35),rand(5,15));

            IF(Playercount==1 OR Playercount==11)
                score+=1;
              ELSE
              delete_text(all_text);
              write_int(1,320,240,1,OFFSET score);     // Shows the score

              IF(Playercount==0)
                IF(score>Hiscore1)
                  Hiscore1=score;
//                  save("saves\CbScore1.sav",Offset Hiscore1,sizeof(Hiscore1));
                  Playercount=-1;
                END
              END

              IF(Playercount==10)
                IF(score>Hiscore2)
                  Hiscore2=score;
//                  save("saves\CbScore2.sav",Offset Hiscore2,sizeof(Hiscore2));
                  Playercount=-1;
                END
              END

            END

            cannonshot=0;
        END
        IF(KanShotRate>1200) KanShotRate-=rand(1,2);
          ELSE
            IF(KanShotRate>600) KanShotRate-=1;
              ELSE
                IF(KanShotRate>300) KanShotRate-=rand(0,1);
                END
            END
        END
        FRAME;
    END
END

//-------------------------------------------------------------------
// Handles player's ship
// Entries: Coordinates and graphic's code number
//-------------------------------------------------------------------

PROCESS player(x,y,graph,left,right,playerNr)

PRIVATE
 x_inc_work;            // to work with x_inc without damaging it
 negpos;                // a negativ or positiv number
 Windzaehlung;          // Wann wirkt sich Wind aus
 wait;                  // keine 2 SpielerZusammenstoesse gleich nacheinander
 wait2;                 // keine 2 KanonenZusammenstoesse gleich nacheinander
 Kanonkughit;           // Welche Kanonenkugel traff?

BEGIN
    LOOP

      //WINDEINFLUSS
      Windzaehlung++;
      IF(Wind<>0)
        IF(Windzaehlung>(23-abs(Wind))/2)
          IF(Wind<0)
            x_inc-=1;
            Windzaehlung=0;
          END
          IF(Wind>0)
            x_inc+=1;
            Windzaehlung=0;
          END
        END
      END


      //GEGNERBERUEHRUNG
      IF(playerNr==1)
        x_inc_work=x_inc;
        IF(wait<0)
          IF(collision(Type player))
            x_inc=Player2ID.x_inc;
            Player2ID.speedchange=x_inc_work;
            x_inc_work=x_inc;
            IF(x_inc_work>0) x_inc_work+=15; END
            IF(x_inc_work<0) x_inc_work-=15; END
            wait=2;
          END
        END
        IF(wait>-2) wait--; END
      END

      IF(playerNr==2)
        x_inc_work=x_inc;
        IF(speedchange<>0)
          x_inc=speedchange;
          speedchange=0;
          x_inc_work=x_inc;
          IF(x_inc_work>0) x_inc_work+=15; END
          IF(x_inc_work<0) x_inc_work-=15; END
        END
      END


      //BEWEGUNG
      IF(key(left)) x_inc-=1;   END
      IF(key(right)) x_inc+=1;   END
      IF(x_inc<-25) x_inc=-25;   END
      IF(x_inc>25) x_inc=25;   END


      //KANONENKUGELTREFFER
      IF(wait2<0)
        IF(Kanonkughit=collision(Type Cannonball))
          IF(Kanonkughit.size>50)
            wait2=24;
            explode(x,y,500);
            Life--;
            IF(Life<0) BREAK; END
          END
        END
      END
      IF(wait2>-2) wait2--; END




      //BEWEGUNGSANZEIGE
      IF(x_inc_work<>0)
        //x_inc_work=x_inc;
        negpos=x_inc_work/abs(x_inc_work);
        x_inc_work=abs(x_inc_work);
        LOOP // ScreenEnd?
          x+=negpos;
          x_inc_work--;
          IF(x<1)
            negpos=-negpos;
            x=2;
            x_inc=-x_inc;
          END

          IF(x>639)
            negpos=-negpos;
            x=638;
            x_inc=-x_inc;
          END


          IF(x_inc_work<0) BREAK; END
          //x+=x_inc;
        END
      END
      Angle=((x_inc*-2000)+Angle*5)/6;
      FRAME;

    END
  Playercount--;
END



PROCESS cloud(x,y,graph,size)
BEGIN
    z=1000-size;
    //Flags=7;
    LOOP
      x+=Wind*((size)/50);//oldmode+rand(-1,1);
      IF(x<-51)
        x=690;
        y=rand(0,480);
        graph=rand(10,11);
        size=rand(50,200);


      END

      IF(x>691)
        x=-50;
        y=rand(0,480);
        graph=rand(10,11);
        size=rand(50,200);

      END
      FRAME;
    END
END

PROCESS Cannonball(x,x_inc,y_inc,size)
BEGIN
    graph=20;
    y=500;
    z=90;
    LOOP
        size++;
        z++;
        x+=x_inc;
        y+=y_inc;
        y_inc++;
        FRAME;
        IF(y>501) BREAK; END
    END
END



PROCESS explode(x,y,size)

BEGIN
    FROM graph=30 TO 35; FRAME(150); END
END



PROCESS escproc()

BEGIN
    LOOP
        IF(Key(_esc) OR Playercount==0 OR Playercount==10)
            Playercount--;
            FRAME(600);
            LOOP
                IF(Key(_esc))
                    fade_off();
                    exit("Ride Canonballs again soon!",Score);
                END
                FRAME;
            END
        END
        FRAME;
    END
END



PROCESS WindRegulator();

BEGIN
    LOOP
        Windchange++;
        IF(Windchange>frames*10)
            Windnew=rand(-25,25);
            Windchange=0;
        END

        LOOP
            IF(Wind>Windnew) Wind--; END
            IF(Wind<Windnew) Wind++; END
            IF(Wind==Windnew) BREAK; END
            FRAME(1200);

            //oldmode Wind=(15*Wind+Windnew)/16;
        END
        FRAME;
    END
END
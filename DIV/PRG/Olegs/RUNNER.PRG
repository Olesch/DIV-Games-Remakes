//****************************************************************************//
//***                     Runner                                           ***//
//***                       by                                             ***//
//***                         Lukas Schw.   & Oleg Yuschuk                 ***//
//****************************************************************************//


PROGRAM Runner;
GLOBAL
  Start;
  Time;
  Time24;
  Gewonnen;
  Counter;
BEGIN
    Set_fps(24,0);
    Set_mode(m640x480);
    load_fpg("Olegs\Runner.fpg");
    load_fnt("Olegs\Runner.fnt");
    put_screen(0,5);



    Maennchen(40,190,_left,_right,_up,3);

    Maennchen(40,250,_a,_d,_w,3);


    write(1,320,190,4,"SPIELER RECHTS");
    write(1,320,250,4,"SPIELER LINKS");

    write(1,320,40,4,"AUF DIE PLAETZE...");
    FRAME(4800);
    delete_text(all_text);
    write(1,320,190,4,"SPIELER RECHTS");
    write(1,320,250,4,"SPIELER LINKS");
    write(1,320,40,4,"...FERTIG...");
    FRAME(3600);
    delete_text(all_text);
    Start=1;
    Timecounter();
    write(1,320,40,4,"...LOS");
    FRAME(3600);
    delete_text(all_text);
    write_int(1,310,430,5,OFFSET Time);
    write_int(1,330,410,3,OFFSET Time24);
    write(1,330,450,3,"24");

END


PROCESS Maennchen(x,y,Keyl,Keyr,Keyu,speed)

PRIVATE

 LR=1;  //Links=1  Rechts=2
 Foul;
 vel;

BEGIN
    graph=1;

    LOOP
        IF(Start==1)
            IF(LR==1)
                IF(key(Keyl) AND NOT key(keyr)) LR=2; graph=2; vel+=speed; END

              ELSE

              IF(key(Keyr) AND NOT key(keyl)) LR=1; graph=3; vel+=speed; END

            END

            /*IF(key(Keyu) AND NOT key(keyr) AND NOT key(keyl))
                LR=rand(1,2);
                graph=LR+1;
                x+=x/5;
                y-=speed;
                FRAME;
                x+=x/5;
                y+=speed;
                FRAME(1200);

            END*/

        END

        /*IF(vel>7)
            vel--;
        END*/
        vel-=vel/4;
        IF(vel<0) vel=0; END
        x+=vel/2;

        IF(x>=600)
            graph=4;
            write(1,320,40,4,"GEWONNEN");
            Gewonnen=1;
            LOOP
                FRAME;
            END
        END


        IF(key(Keyr) AND Start!=1 OR key(Keyl) AND Start!=1)

            write(1,320,240,4,"FOUL");
            Foul=1;

        END

        IF(Foul==1 AND Start!=1)
            write(1,320,240,4,"FOUL");

          ELSE
          IF(Foul==1)
            delete_text(all_text);
            write(1,320,240,4,"FOUL");
            LOOP
                FRAME;
            END


          END

        END
        FRAME;

    END

END





PROCESS Timecounter()

BEGIN

    LOOP
        IF(Gewonnen!=1)
            Time24++;

            IF(Time24>24)
                Time24-=24;
                Time++;
            END
          ELSE
          LOOP
            FRAME;
          END
        END



        FRAME;
    END

END



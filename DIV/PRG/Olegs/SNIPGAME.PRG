//
//-------------------------------------------------------------------
// TITLE:   Tutorial 1
// AUTHOR:  Antonio Marchal
// DATE:    10/10/97
//-------------------------------------------------------------------

PROGRAM Tutorial_1;

GLOBAL
    score=0;     // Variable used to store the score
    Fadenkreuz_id:
    Sniperfollo;

BEGIN
    load_fpg("Olegs\SnipGame.fpg");  // Loads graphics' file
    //load_fnt("Olegs\Space.fnt");  // Loads font type

    set_mode(m1024x768);               // Sets video mode to 640x480
    set_fps(24,0);                    // Number of frames per second

    Fadenkreuz_id=Fadenkreuz();                 // Creates ship process

    Sniperfollo=Sniper(95,370,0);
    SniperBody(100,384);


    FROM x=0 TO 768 STEP 50;
        Sniper(95,x,0);
    END

    /*
    Sniper(95,570,1);
    SniperBody(100,584);

    Sniper(95,170,1);
    SniperBody(100,184);

    Sniper(95,470,2);
    SniperBody(100,484);

    Sniper(95,270,2);
    SniperBody(100,284);*/

    LOOP
     Ballon(Rand(300,1024),Rand(15,50),Rand(2,9));
     FRAME(2400);
    END
END

//-------------------------------------------------------------------
// Handles player's ship
// Entries: Coordinates and graphic's code number
//-------------------------------------------------------------------

PROCESS Sniper(x,y,MODE)
PRIVATE
 SchussLadezeit;
 Ammo;
 Drehzahl;

BEGIN
    graph=6;
    LOOP


      angle=get_angle(Fadenkreuz_id);
      IF(Schussladezeit<0)
        IF(key(_up))
          y-=3;
        END
        IF(key(_down))
          y+=3;
        END

        IF(mouse.left)

          IF(MODE==0)//Normaler Sniper
            Shot(x,y,angle,MODE);
            mouse.x-=30;
            mouse.y-=200;
            FRAME;
            angle=get_angle(Fadenkreuz_id);
            Schussladezeit=40;
            x-=5;
            FRAME;
            x+=2;
            FRAME;
            x+=2;
            FRAME;
            x+=1;
            FRAME;

          END

          IF(MODE==1)//Minigun
            IF(Drehzahl<76)
              Drehzahl+=6;
            END

            IF(Drehzahl>75)
              IF(Ammo<75)
                Shot(x,y,angle,MODE);
                x-=5;
                FRAME(100);
                x+=5;
                Ammo++;
                mouse.y-=rand(80,100);
                mouse.x-=rand(30,50);

              END
            END
          END

          IF(MODE==2)//Grenade Launcher

            Shot(x,y,angle,MODE);
            x-=8;
            FRAME(100);
            x+=8;
            mouse.y-=rand(200,250);
            mouse.x-=rand(70,90);
            Schussladezeit=40;

          END
          Drehzahl-=5;


        END
        IF(mouse.right)


          IF(MODE==0)//Normaler Sniper

          END

          IF(MODE==1)//Minigun
            Ammo=0;
            Drehzahl=0;
            FRAME(3600);
          END

        END

       ELSE
       Schussladezeit--;
      END
      FRAME;
    END
END

PROCESS SniperBody(x,y)
BEGIN
    graph=2;
    z=1;
    LOOP
      y=Sniperfollo.y+14;
      FRAME;


    END
END

PROCESS Fadenkreuz()
BEGIN
  graph=5;
  LOOP
    mouse.x+=rand(-8,8);
    mouse.y+=rand(-8,8);

    x=mouse.x;
    y=mouse.y;

    IF(x<150)
      mouse.x=150;
      x=150;
    END



    FRAME;
  END
END


PROCESS Shot(x,y,angle,MODE)

BEGIN

    graph=8;

    IF(MODE==2)//Grenade Launcher
      graph=11;

    END

    WHILE (NOT out_region(id,0))

        IF(MODE==0 OR MODE==1)
          advance(70);
        END

        IF(MODE==2)
          Smoke(x+rand(-2,2),y+rand(-2,2));
          advance(26);
          //Angle=(Angle*20-90000)/21;
          IF(Angle>-90000)
            Angle-=2750;
          END
        END

        FRAME;  // Shows graphic on screen

    END

END


PROCESS Smoke(x,y)
BEGIN
  Graph=12;
  Angle=Rand(-180000,180000);
  LOOP
    Size-=2;
    y-=5;
    FRAME;
    IF(size<0)
      RETURN;
    END
  END
END

PROCESS Ballon(x,size,speed)
PRIVATE
  Hit;

BEGIN
    y=768;
    graph=9;
    WHILE (NOT out_region(id,0))
        y-=speed;
        IF(Hit=collision(TYPE Shot))
          graph=10;
          FRAME(600);
          RETURN;
        END;

        FRAME;  // Shows graphic on screen
    END

END







//-------------------------------------------------------------------
// Process asteroid
// Handles all asteroids, bigs and small ones
// Entries: Asteroid type code number, which is it's initial graphic
//-------------------------------------------------------------------

PROCESS asteroid(codenumber)
BEGIN
    LOOP
        // Creates an asteroid on left top corner
        // (Coordinates: 0,0) and assigns code number to graphic
        x=0; y=0; graph=codenumber;
        // Chooses an angle randomly
        angle=rand(-180000,180000);
        LOOP
            // Animates the graphic, by adding one to it's code number
            graph=graph+1;
            // If animation's limit is overpassed, reinitializes it
            IF (graph==codenumber+20) graph=codenumber; END
            // Makes graphic to advance on the defined direction
            advance(4);
            // If it collides with shot's graphic then
            // exits loop, which another way would be endless
            IF (collision (TYPE shot)) BREAK; END
            // Finds new coordinates, so it keeps on screen
            // forcing it to appear by the opposite side of screen
            new_coordinates();
            FRAME;      // Shows graphic on screen
        END
        score=score+5;    // Adds 5 point to total score
        // Plays explosion's animation through a loop
        FROM graph=43 TO 62; FRAME; END
    END
END

//-------------------------------------------------------------------
// Process new_coordinates
// Finds new coordinates for the process that called this process
//-------------------------------------------------------------------

PROCESS new_coordinates()
BEGIN
    // If it gets out by the left, forces it to appear by the right
    // subtracting screen's wide
    IF (father.x<-20) father.x=father.x+680; END
    // If it gets out by the right, forces it to appear by the left
    IF (father.x>660) father.x=father.x-680; END
    // If it gets out by the top, forces it to appear by the bottom
    IF (father.y<-20) father.y=father.y+520; END
    // If it gets out by the bottom, forces it to appear by the top
    IF (father.y>500) father.y=father.y-520; END
END


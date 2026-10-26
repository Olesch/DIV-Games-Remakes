//
//-------------------------------------------------------------------
// TITLE:   Tutorial 1
// AUTHOR:  Antonio Marchal
// DATE:    10/10/97
//-------------------------------------------------------------------

PROGRAM Tutorial_1;

GLOBAL

BEGIN
    load_fpg("Olegs\OLTron.fpg");  // Loads graphics' file
    //load_fnt("Olegs\Space.fnt");  // Loads font type

    set_mode(m1024x768);               // Sets video mode to 640x480
    set_fps(60,0);                    // Number of frames per second
    Tron(100,100,2,_left,_right,22,2);                 // Creates ship process

    Tron(924,668,3,_a,_d,54,4);                 // Creates ship process
    map();
    /*write_int(1,320,0,1,OFFSET score);     // Shows the score
    FROM x=1 TO 4; asteroid(1); END        // Creates 4 big asteroids
    FROM x=1 TO 4; asteroid(21); END */      // Creates 4 small asteroids
END


//-------------------------------------------------------------------
// Handles player's ship
// Entries: Coordinates and graphic's code number
//-------------------------------------------------------------------

PROCESS Tron(x,y,graph,left,right,color,dir)
PRIVATE
  dir;    //Direction
  dclick; //Prevents doubleclicking
  speedwait=100;  //Speed of your bike
  speed=10;
  x_look;
  y_look;
  go_out; //Fuers beschleunigen

BEGIN
    LOOP
      LOOP
        IF(dclick==0)
            IF (key(left)) Dir++; dclick=1; END
            IF (key(right)) Dir--; dclick=1; END
        END

        IF(dclick==1)
            IF( NOT(key(left)) AND NOT (key(right)))
                dclick=0;
            END
        END

        IF (Dir==5) Dir=1; END
        IF (Dir==0) Dir=4; END

        IF (Dir==1) x--; END
        IF (Dir==2) y++; END
        IF (Dir==3) x++; END
        IF (Dir==4) y--; END

        //IF (key(_up)) speed--; END
        IF(map_get_pixel(0,1,x,y)!=0) // AND map_get_pixel(0,1,x,y)!=color )
          RETURN;
        END


        /*IF(x<0 OR y<0 OR x>1024 OR y>768)
          RETURN;
        END*/

        IF(x<0) x=1023; END
        IF(y<0) y=767; END
        IF(x>1024) x=1; END
        IF(y>768) y=1; END

        map_put_pixel(0,1,x,y,color);

        IF(speedwait<1)
          BREAK;
         ELSE
         speedwait--;
        END

      END

      speedwait=speed;
      FRAME(100);  // Prints ship's graphic on screen
      /*FROM x_look=-10 TO 10;
        FROM y_look=-10 TO 10;
          IF(map_get_pixel(0,1,x_look+x,y_look+y)!=color)
            IF(map_get_pixel(0,1,x_look+x,y_look+y)!=0)
              speed++;
              go_out=1;
            END
          END
          IF(Go_out==1) BREAK; END
        END
        IF(Go_out==1) BREAK; END
      END*/
      Go_out=0;
    END
END

PROCESS map()
BEGIN
  z=25;
  x=512;
  y=384;
  graph=1;
  LOOP
     FRAME;
  END
END

/*
//-------------------------------------------------------------------
// Process shot
// Creates ship's shots
// Entries: Shot's coordinates and angle
//-------------------------------------------------------------------

PROCESS shot(x,y,angle,sp)
BEGIN
    // Makes an initial advance, and defines the graphic to be used
    advance(24); graph=42;
    // While the graphic is inside the screen
    WHILE (NOT out_region(id,0))
        // Makes it to advance on the predefined angle it had
        IF (sp<10); sp=10; END
        advance(sp/4+5);
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
  */
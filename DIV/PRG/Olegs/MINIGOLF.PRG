
//-------------------------------------------------------------------
// TITLE:   Minigolf
// AUTHOR:  Oleg Yuschuk
//-------------------------------------------------------------------

PROGRAM Minigolf_1;

GLOBAL
    SpeedLR=0;   // Waitingtime for LR
    SpeedUD=0;   // Waitingtime for UD
    score=0;     // Variable used to store the score
    speed=0;     // Variable used to store the speed

BEGIN
    load_fpg("Olegs\Minigolf.fpg");
    load_fnt("Olegs\Space.fnt");

    set_mode(m640x480);
    set_fps(300,0);
    put_screen(0,4);
/*    write_int(1,320,50,1,OFFSET x);     // Shows the score
    write_int(1,320,0,1,OFFSET y);     // Shows the score  */
    CreateBall();

END

//-------------------------------------------------------------------
// Handles player's ship
// Entries: Coordinates and graphic's code number
//-------------------------------------------------------------------


PROCESS Ball(x,y,graph)

BEGIN
    LOOP
    IF (key(_left)) SpeedLR-=1; END

    IF (key(_right)) SpeedLR+=1; END

    IF (key(_up)) SpeedUD-=1; END

    IF (key(_down)) SpeedUD+=1; END

    IF (SpeedLR>70) SpeedLR=70; END
    IF (SpeedLR<-70) SpeedLR=-70; END
    IF (SpeedUD>70) SpeedUD=70; END
    IF (SpeedUD<-70) SpeedUD=-70; END

    WandTreffena(x,y);
    x+=SpeedLR;
    y+=SpeedUD;
    //LochTreffen(x,y);
    FRAME;

    END
END




PROCESS CreateBall()
PRIVATE
    number_color;

BEGIN
    LOOP
        number_color=color(x,y);
        IF(number_color==254) Break; END
        x+=1;
        IF(x>641) x=0; y+=1; END
        IF(y>481)  x=50; y=50; Break; END
    END
    set_fps(24,0);
    Ball(x,y,1);
END




PROCESS color(x,y)
BEGIN

/*    IF ((x<105 OR x>534) AND (y==225 OR y==226))
        RETURN(12);
    END */


    RETURN(map_get_pixel(0,4,x,y));
    FRAME;
END


PROCESS WandTreffenb(x,y)
BEGIN
    IF(map_get_pixel(0,4,x-3,y)==253) SpeedLR=SpeedLR*-1; END
    IF(map_get_pixel(0,4,x+3,y)==253) SpeedLR=SpeedLR*-1; END
    IF(map_get_pixel(0,4,x,y-3)==253) SpeedUD=SpeedUD*-1; END
    IF(map_get_pixel(0,4,x,y+3)==253) SpeedUD=SpeedUD*-1; END

END

PROCESS WandTreffena(x,y)
BEGIN
    IF(map_get_pixel(0,4,x-9,y)!=253) SpeedLR=SpeedLR*-1; END
    IF(map_get_pixel(0,4,x+9,y)!=253) SpeedLR=SpeedLR*-1; END
    IF(map_get_pixel(0,4,x,y-9)!=253) SpeedUD=SpeedUD*-1; END
    IF(map_get_pixel(0,4,x,y+9)!=253) SpeedUD=SpeedUD*-1; END

END
/*
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
END*/

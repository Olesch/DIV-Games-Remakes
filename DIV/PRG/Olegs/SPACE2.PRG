//
//-------------------------------------------------------------------
// TITLE:   Tutorial 1
// AUTHOR:  Antonio Marchal
// DATE:    10/10/97
//-------------------------------------------------------------------

PROGRAM Tutorial_1;

GLOBAL
    Mode=2;     //Random Angle++(0) choosen angle++(1) Counted Angle(2)
    Modeb=0;    //Just 1 draws(1) or all(0)
    Speeds[12]=1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,11000,12000;
    Howmuch_counts=20;
    Size_ins=50;

    Speed_Pointer=0;
    Howmuch;
    score=0;     // Variable used to store the score
    speed=0;     // Variable used to store the speed
    Schl;        // Kartennummer



LOCAL
 pa_x;
 pa_y;


BEGIN
    set_mode(m1024x768);               // Sets video mode to 640x480
    FRAME;
    Schl=load_map("Schluessel.map");  // Loads graphics' file

    set_fps(100,0);                    // Number of frames per second
//    put_screen(0,63);                 // Puts background screen
    IF(Mode==0)
      Dreher1(512,384,Schl,Rand(2500,-2500));
     ELSE
     IF(MODE==1)
       Dreher1(512,384,Schl,Speeds[Speed_pointer]);
      ELSE
       Dreher1(512,384,Schl,5000);
     END
    END
    /*scroll[0].camera=id;
    LOOP
      IF(key(_down)) x+=5; END
      IF(key(_up)) x-=5; END
      IF(key(_left)) y-=5; END
      IF(key(_right)) y+=5; END
      FRAME;
    END */

END


PROCESS Dreher1(x,y,graph,Rotsp)


BEGIN
    IF(Mode==0)
      IF(howmuch_counts==0)
      Dreher3(Schl,Rand(4500,-4500),priority-1);
      ELSE
      Dreher2(Schl,Rand(4500,-4500),priority-1);
      END
     ELSE
     IF(MODE==1)
     Speed_pointer++;
     IF(howmuch_counts==0)
     Dreher3(Schl,Speeds[Speed_pointer],priority-1);
     ELSE
     Dreher2(Schl,Speeds[Speed_pointer],priority-1);
     END
     ELSE
     IF(howmuch_counts==0)
     Dreher3(Schl,Rotsp+1000,priority-1);
     ELSE
     Dreher2(Schl,Rotsp+1000,priority-1);
     END

     END

    END
    size=Size_ins;

    LOOP
        get_real_point(1, offset pa_x, offset pa_y);
        IF(modeb==0)
          put_pixel(pa_x, pa_y, 15);
        END
        Angle+=Rotsp;
        FRAME;


    END
END

PROCESS Dreher2(graph,Rotsp,priority)

BEGIN
    Howmuch++;
    IF(Howmuch<Howmuch_counts)
        IF(Mode==0)
          Dreher2(Schl,Rand(4500,-4500),priority-1);
         ELSE
         IF(MODE==1)
         Speed_pointer++;
         Dreher2(Schl,Speeds[Speed_pointer],priority-1);
         ELSE
         Dreher2(Schl,Rotsp+1000,priority-1);
         END
        END
     ELSE
        IF(Mode==0)
          Dreher3(Schl,Rand(4500,-4500),priority-1);
         ELSE
         IF(Mode==1)
         Speed_pointer++;
         Dreher3(Schl,Speeds[Speed_pointer],priority-1);
         ELSE
         Dreher3(Schl,Rotsp+1000,priority-1);
         END
        END

    END
    size=Size_ins;

    LOOP
        get_real_point(1, offset pa_x, offset pa_y);
        x=father.pa_x;
        y=father.pa_y;
        IF(modeb==0)
          put_pixel(pa_x, pa_y, 15);
        END
        Angle+=Rotsp;
        FRAME;  // Prints ship's graphic on screen


    END
END

PROCESS Dreher3(graph,Rotsp,priority)

BEGIN
    size=Size_ins;
    LOOP
        x=father.pa_x;
        y=father.pa_y;
        get_real_point(1, offset pa_x, offset pa_y);
        put_pixel(pa_x, pa_y, 15);
        Angle+=Rotsp;
        FRAME;  // Prints ship's graphic on screen


    END
END




PROCESS new_coordinates()
BEGIN
    ctype=c_scroll;
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

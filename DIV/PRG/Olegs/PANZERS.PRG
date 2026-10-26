PROGRAM Panzers;

GLOBAL

LOCAL
  Point1_x;
  Point1_y;
  Whatdo;

BEGIN
    //max_process_time=5000;
    load_fpg("Olegs\Panzers.fpg");  // Loads graphics' file
    //load_fnt("Olegs\Space.fnt");  // Loads font type

    //define_region(0,0,0,1024,768);
    set_mode(m1024x768);

    set_fps(24,0);                    // Number of frames per second
    Panzer(100,100,_j,_l,_k,_u,_o,_i);
    Panzer(924,668,_a,_d,_s,_q,_e,_w);
    Graszeichner(4);
    Graszeichner(1);
    Graszeichner(2);
    put_screen(0,4);                  // Puts background screen

END




PROCESS Panzer(x,y,links,rechts,fahren,linksk,rechtsk,schiessen)


BEGIN
    graph=1;
    Turm(links,rechts,linksk,rechtsk,schiessen);

    LOOP
        IF(key(links))   angle+=7000; END
        IF(key(rechts))  angle-=7000; END
        IF(key(fahren)) advance(10); END
        get_real_point(1, offset Point1_x, offset Point1_y);


        FRAME;

    END
END


PROCESS Turm(links,rechts,linksk,rechtsk,schiessen)


BEGIN
    graph=2;

    LOOP
        x=father.Point1_x;
        y=father.Point1_y;

        IF(key(links))     angle+=7000; END
        IF(key(rechts))    angle-=7000; END
        IF(key(linksk))    angle+=10000; END
        IF(key(rechtsk))   angle-=10000; END
        IF(key(schiessen)) Schuss(x,y,angle); END


        FRAME;

    END
END


PROCESS Schuss(x,y,angle)

BEGIN
    advance(40);
    Schussbild();
    LOOP
        advance(15);

        FRAME;

    END
END

PROCESS Schussbild()

BEGIN
    graph=3;
    LOOP
        x=father.x;
        y=father.y;

        IF (out_region(id, 0))
            signal(father,s_kill);
            RETURN;
        END

        FRAME;
    END
END


PROCESS Graszeichner(GraphNumber)
PRIVATE


BEGIN
  LOOP
    IF(map_get_pixel(0,Graphnumber,x,y)!=0);
      map_put_pixel(0,GraphNumber,x,y,rand(32,35));  //32,35
    END
    x++;
    IF(x>1024)
      x=0;
      y++;
    END
    IF(y>768)
      RETURN;
    END

  END
END



















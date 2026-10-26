

PROGRAM Balls;

GLOBAL
    file_id;

LOCAL


PRIVATE


BEGIN
    resolution=10;
    file_id=load_fpg("Olegs\Ball.fpg");  // Loads graphics' file
    //load_fnt("Olegs\Mini2.fnt");  // Loads font type

    set_mode(m1024x768);               // Sets video mode to 640x480
    set_fps(100,0);                    // Number of frames per second
    MAPPA(5120,3840,1);
    LOOP
        x=rand(1,4);
        IF(x==1)
            Ball(rand(0,10240),0,0);
        END
        IF(x==2)
            Ball(rand(0,10240),7680,0);
        END
        IF(x==3)
            Ball(0,rand(0,7680),0);
        END
        IF(x==4)
            Ball(10240,rand(0,7680),0);
            FRAME(400);
            Ball(10240,rand(0,7680),0);
            FRAME(400);
            Ball(10240,rand(0,7680),0);
            FRAME(400);
            Ball(10240,rand(0,7680),0);
        END
        FRAME(600);
    END
END



PROCESS Ball(x,y,Stay);

PRIVATE
    Stay;
    Counter;
    Kill;
    i;

BEGIN

    resolution=10;
    angle=fget_angle(x,y,5120,3840);
    graph=1;
    LOOP
        FROM i=1 TO 40;
            IF(collision(TYPE Ball))
                //Map_put(file_id,2,1,x/10,y/10);
                BREAK;
                Kill=1;
            END
            IF(collision(TYPE MAPPA))
                Map_put(file_id,2,1,x/10,y/10);
                BREAK;
            END
            advance(10);
        END

        FRAME;
        graph=1;
        IF(x<-50 OR x>10290 OR y>7730 OR y<-50)
            BREAK;
        END

    END

END





PROCESS MAPPA (x,y,z)

BEGIN
    resolution=10;
    graph=2;
    LOOP
        FRAME;
    END
END





















































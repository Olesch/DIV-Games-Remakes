


PROGRAM Funktion;

GLOBAL
  x_zeichne;
  y_zeichne;

BEGIN
    set_fps(24,0);
    set_mode(m1024x768);



    /*FROM y=-1024 TO 1024;

        y_zeichne=y;
        x_zeichne=y_zeichne*y_zeichne/100;

        put_pixel((x_zeichne/50)+512,(y_zeichne)+384,15);
    END*/




    LOOP
        x_zeichne=0;
        y_zeichne=0;
        FROM x=0 TO 512;
            x_zeichne+=rand(0,2);
        END
        FROM x=0 TO 384;
            y_zeichne+=rand(0,2);
        END

        put_pixel(x_zeichne,y_zeichne,get_pixel(x_zeichne,y_zeichne)+1);
       FRAME(1);
    END

END
















































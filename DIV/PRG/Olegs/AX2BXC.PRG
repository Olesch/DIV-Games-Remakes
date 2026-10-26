

PROGRAM Rechnen;

GLOBAL
    Zahl1;
    Zahl2;
    Zahl3;
    xvar;
    Steping=1;

BEGIN

    //x=a y=b
    set_mode(m1024x768);
    set_fps(16,0);
    xvar=1;
    Zahl1=50;
    FOR(x=0; x<=1024; x++)
        Zahl2=Zahl1+(Zahl1*(500-Zahl1))/10000;

        put_pixel(x,Zahl2,15);
        Zahl1=Zahl2;

    END
    LOOP
        FRAME;
    END



END
             /*

    //x=a y=b
    set_mode(m1024x768);
    set_fps(16,0);
    xvar=1;
    FROM x=-1024 TO -1;
        FROM y=-384 TO 768;
            Zahl1=xvar*xvar*x;
            Zahl2=xvar*y;
            Zahl3=((y*y)-5)/(4*x);
            IF(Zahl1+Zahl2+Zahl3>0)
                put_pixel(x+1024,y+0,15);
            END


        END
    END
    LOOP
        FRAME;
    END
           */

































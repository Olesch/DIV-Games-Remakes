

PROGRAM KriegsSimulator;


CONST




GLOBAL

    STRUCT Einheiten[255]
        lifepoints;
        Attackpoints;
    END=                         0, 0,   //Nullte Position
                                10,  1,   //Bauer
                                30,  2,   //Krieger
                                40,  4,   //Ritter
                               100, 10;   //Elite-Kaempfer







BEGIN
    load_fpg("Olegs\Kriessi.fpg");
    set_mode(m320x240);
    GiveLands();
    MakeLife();
    StartMoving();
    Map();
END



Process GiveLands()

BEGIN
    LOOP
        IF(map_get_pixel(0,1,x,y)!=0)
            IF(x>160)
                map_put_pixel(0,2,x,y,1);
            ELSE
                map_put_pixel(0,2,x,y,2);
            END
        END
        x++;
        IF(x>320)
            x=0;
            y++;
        END
        IF(y>240)
            RETURN;
        END
    END
END

Process MakeLife()

BEGIN
    LOOP
        IF(map_get_pixel(0,1,x,y)!=0)
                map_put_pixel(0,3,x,y,Einheiten[map_get_pixel(0,1,x,y)].lifepoints);
        END
        x++;
        IF(x>320)
            x=0;
            y++;
        END
        IF(y>340)
            RETURN;
        END
    END
END


Process StartMoving()
PRIVATE
    xmov;
    ymov;

BEGIN
    LOOP
        IF(map_get_pixel(0,1,x,y)!=0)

            IF(rand(0,4)==0)
                IF(y>120+rand(-7,7))
                    ymov=y-1;
                    xmov=x;

                ELSE
                    ymov=y+1;
                    xmov=x;
                END


            ELSE
                IF(x>180+rand(-7,7))
                    xmov=x-1;
                    ymov=y;
                ELSE
                    xmov=x+1;
                    ymov=y;
                END


            END


            IF(Map_get_pixel(0,2,xmov,ymov)!=Map_get_pixel(0,2,x,y)
                AND Map_get_pixel(0,2,xmov,ymov)!=0)

                IF(Map_get_pixel(0,3,xmov,ymov)-Einheiten[Map_get_pixel(0,1,x,y)].Attackpoints>0)
                    Map_put_pixel(0,3,xmov,ymov,Map_get_pixel(0,3,xmov,ymov)-Einheiten[Map_get_pixel(0,1,x,y)].Attackpoints);
                ELSE
                    Map_put_pixel(0,1,xmov,ymov,0);
                    Map_put_pixel(0,2,xmov,ymov,0);
                    Map_put_pixel(0,3,xmov,ymov,0);

                END
            END

            IF(Map_get_pixel(0,1,xmov,ymov)==0)
                Map_put_pixel(0,1,xmov,ymov,map_get_pixel(0,1,x,y));
                Map_put_pixel(0,2,xmov,ymov,map_get_pixel(0,2,x,y));
                Map_put_pixel(0,3,xmov,ymov,map_get_pixel(0,3,x,y));
                Map_put_pixel(0,1,x,y,0);
                Map_put_pixel(0,2,x,y,0);
                Map_put_pixel(0,3,x,y,0);
            END





        END
        x++;
        IF(x>320)
            x=0;
            y++;
        END
        IF(y>240)
            y=0;
            FRAME(100);
        END
    END
END


PROCESS Map()

BEGIN
    x=180;
    y=120;

    LOOP
        FRAME;
        IF(Key(_a))
            graph=1;                  // Puts background screen
        END
        IF(Key(_b))
            graph=2;                  // Puts background screen
        END
        IF(Key(_c))
            graph=3;                  // Puts background screen
        END

    END


END



























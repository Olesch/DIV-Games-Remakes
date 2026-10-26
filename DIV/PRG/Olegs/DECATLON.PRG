
PROGRAM Decathlon;

GLOBAL
    Spacestufe;
    Accx;
    Accy;
    Kill;
    Weite;
    Movement;
    Hiscore;


LOCAL
    Gelenkx;
    Gelenky;

PRIVATE
    Antifastspace;
    Countera;
    Counterb;

BEGIN

    load("sav\decatlon.dat",OFFSET Hiscore);
    set_mode(m800x600);
    load_fpg("Olegs\Decatlon.FPG");
    Movementometer();
    Write_int(0,600,100,4,OFFSET Hiscore);
    Write_int(0,200,100,4,OFFSET Movement);
    Write_int(0,400,200,4,OFFSET Weite);
    Arma(400,400);

  LOOP
    LOOP
        IF(key(_space))
            IF(Antifastspace!=1)
                Spacestufe++;
                Antifastspace=1;
            END
        ELSE
            Antifastspace=0;
        END
        FRAME;
        IF(Kill==1)
            BREAK;
        END

    END
    FRAME(200);
    x=80;
    y=580;
    LOOP

        FOR(countera=-2;countera<=2;countera++);
            FOR(counterb=-2;counterb<=2;counterb++);
                put_pixel(x+countera,y+counterb,15-abs(countera)*3-abs(counterb)*3);
            END
        END

        put_pixel((2*x+accx)/2,(2*y+accy)/2,5);
        x+=accx;
        y+=accy;
        accy+=1;
        FRAME;
        IF(y>600)
            BREAK;
        END
        Weite=x-80;
    END
    Weite=x-80;
    IF(weite>Hiscore)
        Hiscore=weite;
        save("sav\decatlon.dat",OFFSET Hiscore,sizeof(Hiscore));
    END

    LOOP
        FRAME;
        IF(key(_space))
            BREAK;
        END
    END


    clear_screen();
    Spacestufe=0;
    Accx=0;
    Accy=0;
    Kill=0;
    Weite=0;
    Movement=0;
    Gelenkx=0;
    Gelenky=0;
    Antifastspace=0;
    Countera=0;
    Counterb=0;
    Arma(400,400);
    FRAME(500);

  END

END



PROCESS Arma(x,y)


BEGIN

    angle=220000;
    graph=1;
    Armb();
    LOOP
        IF(Spacestufe>=1)
            Angle-=3000+Movement*80;
        END
        IF(angle<0)
            Spacestufe=4;
        END

        get_real_point(1,OFFSET Gelenkx, OFFSET Gelenky);
        Specani(x,y,angle,graph);
        FRAME;
        IF(Kill==1)
            RETURN;
        END
    END
END



PROCESS Armb()

PRIVATE
    Oldx;
    Oldy;


BEGIN
    angle=200000;
    graph=2;
    LOOP



        x=father.gelenkx;
        y=father.gelenky;



        IF(Spacestufe>=1)
            Angle-=500;
        END
        IF(Spacestufe>=2)
            Angle-=4500+Movement*120;
        END

        Oldx=Gelenkx;
        Oldy=Gelenky;


        get_real_point(1,OFFSET Gelenkx, OFFSET Gelenky);
        IF(Spacestufe>=3)
            Accx=Gelenkx-Oldx;
            Accy=Gelenky-Oldy;
            Kill=1;
            RETURN();
        END
        Specani(x,y,angle,graph);
        FRAME;
    END
END




PROCESS Movementometer();

PRIVATE
    WKey;
    Antifasta;
    Antifastd;

BEGIN
    LOOP
      IF(Spacestufe>0)
        IF(Key(_left) AND Wkey==0 AND Antifasta==0)
            Wkey=1;
            Antifasta=1;
            Movement+=5;
        END
        IF(Key(_right) AND Wkey==1 AND Antifastd==0)
            Wkey=0;
            Antifastd=1;
            Movement+=5;
        END
        Movement-=1+Movement/17;
        IF(Movement<0) Movement=0; END
        IF(Movement>50) Movement=50; END

        IF(NOT(key(_left)))
            Antifasta=0;
        END
        IF(NOT(key(_right)))
            Antifastd=0;
        END


      END
      FRAME;
    END
END




PROCESS Specani(x,y,angle,graph)

PRIVATE
    counter;

BEGIN
    flags=4;
    z=50;
    FOR(counter=0; counter<28; counter++)
        FRAME(100);
    END
END











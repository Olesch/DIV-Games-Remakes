
PROGRAM Ballkill;

GLOBAL
    Level;
    Ballcount;
    Mousewait;
    Score;
    Levelwait;
    Foen_id;
    HiScore;


BEGIN
//    Load("Saves\Ballkill.dat", offset HiScore);
    load_fpg("Olegs\Ballkill.Fpg");
    load_fnt("Olegs\Ballkill.Fnt");
    Write_int(1,0,0,0,OFFSET Score);
    Write_int(1,800,600,8,OFFSET HiScore);
    Write_int(1,800,0,2,OFFSET Level);
    Leveltext();
    set_mode(m800x600);
    mouse.graph=3;            // Selects mouse cursor graphic
    Foen_id=Foen();
    LOOP
        IF (NOT mouse.left)
            mousewait=0;
        END
        IF (mouse.left)
            mousewait++;
            IF(mousewait<2)
                //mouse.x-=15;
                //mouse.y-=15;
            END
        END

        IF(Ballcount<Level)
            Ball();
            Ballcount++;
        END
        Levelwait++;
        IF(Levelwait>100*Level)
            Levelwait=0;
            Level++;
        END


        FRAME;
    END

END

PROCESS Ball()

PRIVATE
    Life;
    Xinc;
    MaxXinc;

BEGIN
    Resolution=100;
    graph=1;
    Life=rand(0,Level);
    MaxXinc=rand(0,Level)*100;
    IF(MaxXinc<100) MaxXinc=100; END
    Xinc=Maxxinc;
    size=100+Life*10;
    y=60000;
    x=rand(0,80000);
    LOOP
        IF(x<Foen_id.x+4000 AND x>Foen_id.x-4000 AND y<60000)
            Xinc-=10;
        END
        Xinc+=3;
        IF(Xinc>Maxxinc)
            Xinc=Maxxinc;
        END

        y-=Xinc;
        FRAME;
        IF (mouse.left)
            IF (collision(TYPE mouse) AND mousewait<2)
                Life--;
                size-=10;
                Score++;
                IF(life<1)
                    Ballcount--;
                    Score++;
                    BREAK;
                END
            END
        END
        IF(y<0)
            let_me_alone();
            Leveltext();
            graph=4;
            x=40000;
            y=0;
            IF(score>HiScore)
                Hiscore=score;
                save("Sav\Ballkill.dat", offset HiScore, sizeof(HiScore)); // The file is saved.
            END
            size=100;
            For(y=0; y<60000; y+=500)
                FRAME;
            END
            exit("Nice playing",Score);
        END

    END
    graph=2;
    FRAME;
END

PROCESS Foen()

BEGIN
    resolution=100;
    x=40000;
    graph=5;
    LOOP
        IF(mouse.right)
            IF(x<78000)
                x+=500;
            END
        ELSE
            IF(x>2000)
                x-=500;
            END
        END
        FRAME;

    END



END


PROCESS Leveltext()

BEGIN
    x=750;
    graph=6;
    LOOP
        FRAME;
    END
END













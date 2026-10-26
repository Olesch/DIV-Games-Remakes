

PROGRAM AntJumper;

CONST
    Farben=2;

GLOBAL
    KI[Farben]=0,1;  //-1< 0^ 1>
    Colour[Farben]=0,15;
    Anticolour[15]= 0,1;//-1, 1,-1,-1, 2,-1,-1, 3,-1,-1, 4,-1,-1, 5;
                 // 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15



BEGIN
    x=512;
    y=384;
    set_mode(m1024x768);
    load_fpg("Olegs\Ant.Fpg");
    graph=1;
    z=5;
    Ant(512,384,0);
    /*Ant(508,384,0);
    Ant(516,384,1);
    Ant(512,388,2);
    Ant(512,380,3);*/
    LOOP
        IF(key(_alt)) size+=10; END
        IF(key(_control)) size-=10; END
        IF(key(_w)) y+=5; END
        IF(key(_a)) x+=5; END
        IF(key(_s)) y-=5; END
        IF(key(_d)) x-=5; END


        FRAME;
    END

END

PROCESS Ant(x,y,priority)

PRIVATE
    poscol;
    Dir; //^>V<  0123
    counter;

BEGIN


    LOOP
        IF(dir==0)
            y--;
        END
        IF(dir==1)
            x++;
        END
        IF(dir==2)
            y++;
        END
        IF(dir==3)
            x--;
        END

        poscol=map_get_pixel(0,1,x,y);

        dir+=KI[Anticolour[poscol]];

        dir=dir mod 4;
        IF(dir==-1) dir=3; END
        IF(dir==-2) dir=2; END
        IF(dir==-3) dir=1; END



        map_put_pixel(0,1,x,y,Colour[(Anticolour[poscol]+1) mod (Farben+1)]);



        counter++;
        IF(counter>3000)
            FRAME(100);
            counter=0;
        END





    END
END































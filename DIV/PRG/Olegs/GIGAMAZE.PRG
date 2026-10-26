/*
Levelpoints:
0=Center
1-4=Player1-4
5-10=Diamond-Places
11-18=greenlaser
19-26=Redlaser
27-30=Stunner
31-38=Rockets
39-43=Nukes
44-47=health
48-51=shield
52-55=Telepa1;Telepa2;Telepb1;Telepb2;
*/

PROGRAM GigaMaze;

GLOBAL
    fpsa=40;
    fpsb;
    Level=0;
    STRUCT Stat[3]
            playid;
            life;
            Ammo;
            Weapon;
            Score;
    END
    Telepa1;
    Telepa2;
    Telepb1;
    Telepb2;



LOCAL
    Player;

PRIVATE
    Counter;



BEGIN
    Level+=500;
    graph=level;
    load_fpg("Olegs\Gigamaze.fpg");  // Loads graphics' file
    load_fnt("Olegs\Gigamaze.fnt");  // Loads graphics' file
    set_mode(m640x480);
    set_fps(fpsa,fpsb);
    Framers():
    ship(0,_up,_down,_left,_right,_Control);
    ship(1,_2,_w,_q,_e,_1);
    ship(2,_9,_o,_i,_p,_8);
    ship(3,_h,_n,_b,_m,_g);
    Crystal();
    z=5;
    x=320;
    y=240;
    Leiste();
    FOR(Counter=0; Counter<4; Counter++)
        Write_int(1,19+counter*160,448,3,OFFSET stat[counter].score);
        Write_int(1,130+counter*160,449,3,OFFSET stat[counter].Ammo);
        Write_int(1,40+counter*160,467,5,OFFSET stat[counter].life);
        //Write_int(1,155+counter*160,467,5,OFFSET stat[counter].Weapon);
    END
    FOR(Counter=11; Counter<56; Counter++)
        Item(Counter);
    END

    LOOP
        FRAME;
    END


END




PROCESS Framers();

PRIVATE
    counter;

BEGIN

    LOOP //Frame-Debugger
        IF(key(_F1))
            fpsa--;
            set_fps(fpsa,fpsb);
        END
        IF(key(_F2))
            fpsa++;
            set_fps(fpsa,fpsb);
        END
        IF(key(_F3))
            fpsb--;
            set_fps(fpsa,fpsb);
            FRAME(300);
        END
        IF(key(_F4))
            fpsb++;
            set_fps(fpsa,fpsb);
            FRAME(300);
        END
        IF(key(_F5))
            Write_Int(0,290,20,4,OFFSET fpsa);
            Write_Int(0,350,20,4,OFFSET fpsb);
        END
        IF(key(_ESC))
            exit("May the force be with you!",0);
        END


        FRAME;
    END
END




PROCESS Ship(player,up,down,left,right,shot)

PRIVATE
    dir;
    Counterb;
    Counter;
    Moving;
    xdist;
    ydist;
    AnFaSho;


BEGIN
    stat[player].playid=id;
    stat[player].life=100;
    stat[player].Ammo=99;
    stat[player].Weapon=0;
    get_point(0,level,player+1,OFFSET x, OFFSET y);
    graph=player*4+rand(1,4);
    dir=-1;
    FRAME;
    LOOP
        Moving=1;
        IF(Key(up))
            graph=player*4+2;
            dir=0;
        END
        IF(Key(right))
            graph=player*4+1;
            dir=1;
        END
        IF(Key(left))
            graph=player*4+3;
            dir=2;
        END
        IF(Key(down))
            graph=player*4+4;
            dir=3;
        END
        IF(Key(shot) AND AnFaSho==0)
            Patron(x,y,dir,stat[player].Weapon);
            Stat[player].ammo--;
            IF(Stat[player].ammo<1)
                Stat[player].weapon=0;
                Stat[player].ammo=99;
            END
            AnFaSho=1;
        END
        IF(NOT key(shot))
            AnFaSho=0;
        END


        FOR(Counterb=0; Counterb<4; Counterb++)
            moving=1;
            FOR(Counter=0; Counter<4; Counter++)
                IF(player!=Counter)
                    xdist=x-stat[Counter].playid.x;
                    ydist=y-stat[Counter].playid.y;

                    IF(dir==0) ydist=ydist-1;END
                    IF(dir==1) xdist=xdist+1;END
                    IF(dir==2) xdist=xdist-1;END
                    IF(dir==3) ydist=ydist+1;END
                    xdist=abs(xdist);
                    ydist=abs(ydist);


                    IF(ydist<14 AND xdist<14)
                        moving=0;
                        BREAK;
                    END
                END
            END
            xdist=x;
            ydist=y;
            IF(dir==0) ydist=ydist-7;END
            IF(dir==1) xdist=xdist+7;END
            IF(dir==2) xdist=xdist-7;END
            IF(dir==3) ydist=ydist+7;END
            IF(Map_get_pixel(0,level,xdist,ydist)!=1)
                moving=0;
            END
            IF(dir==0) xdist=xdist-6;END
            IF(dir==1) ydist=ydist+6;END
            IF(dir==2) ydist=ydist-6;END
            IF(dir==3) xdist=xdist+6;END
            IF(Map_get_pixel(0,level,xdist,ydist)!=1)
                moving=0;
            END
            IF(dir==0) xdist=xdist+12;END
            IF(dir==1) ydist=ydist-12;END
            IF(dir==2) ydist=ydist+12;END
            IF(dir==3) xdist=xdist-12;END
            IF(Map_get_pixel(0,level,xdist,ydist)!=1)
                moving=0;
            END




            IF(dir==0 AND moving==1)y--;END
            IF(dir==1 AND moving==1)x++;END
            IF(dir==2 AND moving==1)x--;END
            IF(dir==3 AND moving==1)y++;END
            xdist=x;
            ydist=y;
            IF(dir==0) ydist=ydist-7;END
            IF(dir==1) xdist=xdist+7;END
            IF(dir==2) xdist=xdist-7;END
            IF(dir==3) ydist=ydist+7;END
            IF(xdist<1) x=639; END
            IF(ydist<1) y=439; END
            IF(xdist>639) x=1; END
            IF(ydist>439) y=1; END


        END


        FRAME(100);
    END
END



PROCESS Crystal()

PRIVATE
    hit;

BEGIN
    get_point(0,level,rand(5,10),OFFSET x, OFFSET y);
    graph=17;

    LOOP
        IF(hit=collision(TYPE ship))
            stat[hit.Player].score+=200;
            get_point(0,level,rand(5,10),OFFSET x, OFFSET y);
        END
        FRAME;

    END

END



PROCESS Item(Number)

PRIVATE
    hit;

BEGIN
    get_point(0,level,Number,OFFSET x, OFFSET y);
    IF(x<0 OR y<0 OR x>640 OR y>440);
        RETURN;
    END

/*
Levelpoints:
0=Center
1-4=Player1-4
5-10=Diamond-Places
11-18=greenlaser
19-26=Redlaser
27-30=Stunner
31-38=Rockets
39-43=Nukes
44-47=health
48-51=shield
52-55=Telepa1;Telepa2;Telepb1;Telepb2;
*/

    IF(number=>11 AND number<=18) graph=53; END
    IF(number=>19 AND number<=26) graph=56; END
    IF(number=>27 AND number<=30) graph=58; END
    IF(number=>31 AND number<=38) graph=59; END
    IF(number=>39 AND number<=43) graph=60; END
    IF(number=>44 AND number<=47) graph=61; END
    IF(number=>48 AND number<=51) graph=62; END
    IF(number=>52 AND number<=53) graph=63; END
    IF(number=>54 AND number<=55) graph=64; END




    LOOP
        IF(graph==53)
            IF(hit=collision(TYPE ship))
                stat[hit.Player].weapon=1;
                stat[hit.Player].Ammo=10;
                BREAK;
            END
        END
        IF(graph==56)
            IF(hit=collision(TYPE ship))
                stat[hit.Player].weapon=2;
                stat[hit.Player].Ammo=5;
                BREAK;
            END
        END
        IF(graph==58)
            IF(hit=collision(TYPE ship))
                stat[hit.Player].weapon=3;
                stat[hit.Player].Ammo=1;
                BREAK;
            END
        END
        IF(graph==60)
            IF(hit=collision(TYPE ship))
                stat[hit.Player].weapon=4;
                stat[hit.Player].Ammo=3;
                BREAK;
            END
        END
        IF(graph==61)
            IF(hit=collision(TYPE ship))
                stat[hit.Player].weapon=5;
                stat[hit.Player].Ammo=1;
                BREAK;
            END
        END


        FRAME;

    END

END




PROCESS Leiste()

BEGIN
    graph=20;
    x=320;
    y=460;
    LOOP
        FRAME;
    END
END






PROCESS Patron(x,y,dir,Art)

PRIVATE
    hit; //urld
    inc;
    counter;

BEGIN
    IF(dir==-1)
        RETURN;
    END
    IF(Art==0)
        graph=50;
        inc=8;
    END
    IF(Art==1)
        IF(dir==0 OR dir==3)
            graph=52;
        END
        IF(dir==1 OR dir==2)
            graph=51;
        END
        inc=7;
    END
       /* IF(dir==0)y-=10;END
        IF(dir==1)x+=10;END
        IF(dir==2)x-=10;END
        IF(dir==3)y+=10;END  */

    LOOP
      FOR(counter=0; Counter<inc; Counter++)
        IF(hit=collision(TYPE ship))
            IF(Art==0 AND hit!=father)
                stat[hit.Player].life-=5;
                stat[father.Player].score+=10;
                RETURN;
            END
            IF(Art==1 AND hit!=father)
                stat[hit.Player].life-=10;
                stat[father.Player].score+=20;
                RETURN;
            END
        END


        IF(Map_get_pixel(0,level,x,y)!=1)
            RETURN;
        END
        IF(dir==0)y-=1;END
        IF(dir==1)x+=1;END
        IF(dir==2)x-=1;END
        IF(dir==3)y+=1;END
      END
      FRAME;

    END

END











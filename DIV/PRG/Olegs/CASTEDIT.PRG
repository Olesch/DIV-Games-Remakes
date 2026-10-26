/*Movement:
      z-Floorchooser
      x-ObjectsChooser
      ijkl-Moving through Stages
      cursorkeys-Moving Cursor
      del-Deleting that field
      enter-filling the field
      Control+s-Save the levels



*/






PROGRAM Castedit;


GLOBAL
    Stat;//0=EditFloor; 1=EditObjects; 2=Floorgetter; 3=Objectgetter;

    STRUCT Map[35]
        STRUCT Layer[1]
            STRUCT Xpos[39]
                Ypos[29];
            END
        END
    END
    erease;
    stage;
    difficulty;
    set;







BEGIN
    Stage=13;
    load_fpg("olegs/Castle.FPG");
    set_fps(24,0);
    set_mode(m800x600);

    write(0,400,300,4,"Welches Mapset? 1,2");
    LOOP
        IF(Key(_1))
            load("saves/Level1.dat",OFFSET map);
            set=1;
            BREAK;
        END
        IF(Key(_2))
            load("saves/Level2.dat",OFFSET map);
            set=2;
            BREAK;
        END
        FRAME;
    END
    delete_text(All_text);
    Levelzeichner();
    Background();
    Painter();
    Chooser();
    Back();
END









PROCESS Background()

BEGIN
    z=10;
    graph=100;
    LOOP
        FRAME;
    END
END





PROCESS Levelzeichner()


PRIVATE
    Field;
    Picture;
    Additional;

BEGIN
    LOOP
        //Field=map_get_pixel(Campaign,Stage,x,y);
        Field=map[stage].Layer[0].xpos[x].ypos[y];

        SWITCH (Field)
            CASE 0:
                Picture=110;
                map_put(0,100,Picture,x*20,y*20);
                map[stage].Layer[0].Xpos[x].ypos[y]=22;
            END
            CASE 6:
                IF(rand(0,10)==0)
                    Picture=rand(101,104);
                ELSE
                    Picture=101;
                END
                map_put(0,100,Picture,x*20,y*20);
            END
            CASE 22:
                IF(rand(0,10)==0)
                    Picture=rand(110,112);
                ELSE
                    Picture=110;
                END
                map_put(0,100,Picture,x*20,y*20);
            END
            CASE 20:
                Picture=136;//Nur Editor
                map_put(0,100,Picture,x*20,y*20);
            END
            CASE 26:
                Picture=120;
                map_put(0,100,Picture,x*20,y*20);
            END
            CASE 28:
                Picture=121;
                map_put(0,100,Picture,x*20,y*20);
            END
            CASE 71:
                Picture=125;
                map_put(0,100,Picture,x*20,y*20);
            END
            CASE 40:
                Picture=132;
                map_put(0,100,Picture,x*20,y*20);
            END
            CASE 212:
                Picture=130;
                map_put(0,100,Picture,x*20,y*20);
            END
            CASE 211:
                Picture=134;
                map_put(0,100,Picture,x*20,y*20);
            END
            CASE 213:
                Picture=135;
                map_put(0,100,Picture,x*20,y*20);
            END
            CASE 214:
                Picture=131;
                map_put(0,100,Picture,x*20,y*20);
            END
            CASE 11:
                Picture=126;
                map_put(0,100,Picture,x*20,y*20);
            END
        END
        IF(x==39 AND y==29)
            map_put(0,100,113,x*20,y*20);
        END


        //Field=map_get_pixel(Campaign,Stage+1,x,y);
        Field=map[stage].Layer[1].xpos[x].ypos[y];
        additional=0;
        SWITCH (Field)

            CASE 7:
                Potion(69,1,x*20+10,y*20+10);
            END
            CASE 22:
                Potion(60,rand(5,20)-difficulty,x*20+10,y*20+10);
            END
            CASE 20:
                Potion(61,rand(15,25)-difficulty,x*20+10,y*20+10);
            END
            CASE 54:
                Potion(63,rand(6,8)-difficulty/2,x*20+10,y*20+10);
            END
            CASE 52:
                Potion(64,rand(20,30)-difficulty,x*20+10,y*20+10);
            END
            CASE 118:
                Potion(66,rand(1,3),x*20+10,y*20+10);
            END
            CASE 116:
                Potion(67,rand(7,13)-difficulty,x*20+10,y*20+10);
            END
            CASE 71:
                Potion(127,1,x*20+10,y*20+10);
            END
            CASE 74:
                Potion(74,100,x*20+10,y*20+10);
            END
            CASE 11:
                Potion(128,1,x*20+10,y*20+10);
            END
            CASE 250:
                Potion(72,1,x*20+10,y*20+10);
            END
            CASE 120:
                Potion(75,1,x*20+10,y*20+10);
            END
            CASE 121:
                Potion(76,1,x*20+10,y*20+10);
            END
            CASE 122:
                Potion(77,1,x*20+10,y*20+10);
            END
            CASE 59:
                Potion(78,1,x*20+10,y*20+10);
            END
            CASE 60:
                Potion(79,1,x*20+10,y*20+10);
            END
            CASE 61:
                Potion(80,1,x*20+10,y*20+10);
            END

            CASE 41:
                Enemy(200,rand(10,20),rand(3,5)+additional,x*20+10,y*20+10,rand(70,100),10,0,0,0);
            END
            CASE 40:
                Enemy(210,rand(30,50),rand(6,8)+additional,x*20+10,y*20+10,rand(100,130),25,0,40,0);
            END
            CASE 39:
                Enemy(205,rand(10,20),rand(4,6)+additional,x*20+10,y*20+10,5000,15,1,0,0);
            END
            CASE 38:
                Enemy(220,rand(300,320),rand(18,20),x*20+10,y*20+10,5000,160,0,40,2);
            END
            CASE 17:
                Enemy(215,rand(190,220),rand(13,15),x*20+10,y*20+10,80,80,0,300,1);
            END
            CASE 18:
                Enemy(230,rand(190,220),rand(22,27),x*20+10,y*20+10,5000,110,2,300,1);
            END
            CASE 13:
                Enemy(225,rand(80,90),rand(10,11),x*20+10,y*20+10,120,90,0,88,3);
            END
        //Enemy(Initgraph,Life,Strength,x,y,DefRad,exp,weap,res,spec)
        //res:Magic;bow;sword

        END






    /*IF(map_get_pixel(0,Graphnumber,x,y)==0);
      map_put_pixel(0,GraphNumber,x,y,rand(32,35));
    END*/


        x++;
        IF(x>39)
            x=0;
            y++;
        END
        IF(y>29)
            RETURN;
        END

    END
END


PROCESS Potion(graph,Healpower,x,y);

PRIVATE
    hit;
    Inix;
    Iniy;

BEGIN

    LOOP
        IF(Erease==1)
            RETURN;
        END
        FRAME;
    END

END




PROCESS Enemy(Initgraph,Life,Strength,x,y,DefRad,expgive,weapon,resist,spec)

BEGIN
    IF(spec==4 OR spec==5)
        flags=4;
    END
    graph=initgraph;
    LOOP
        IF(erease==1)
            RETURN;
        END


        FRAME;
    END
END






PROCESS Painter()

PRIVATE
    Object;
    Oldx;
    Oldy;


BEGIN

    graph=860;
    x=10;
    y=10;
    z=-20;
    LOOP
        IF(key(_z))
            IF(Stat<2)
                oldx=x;
                oldy=y;
                x=10;
                y=10;
            END
            //Bodenwahl
            Stat=2;
        END
        IF(key(_x))
            IF(Stat<2)
                oldx=x;
                oldy=y;
                x=10;
                y=10;
            END
            //Objectwahl
            Stat=3;
        END
        IF(key(_right) AND x<780)
            x+=20;
        END
        IF(key(_left) AND x>20)
            x-=20;
        END
        IF(key(_up) AND y>20)
            y-=20;
        END
        IF(key(_down) AND y<580)
            y+=20;
        END
        IF(key(_i) AND Stage>5)
            Stage-=6;
            erease=1;
            FRAME;
            erease=0;
            Levelzeichner();
        END
        IF(key(_k) AND Stage<29)
            Stage+=6;
            erease=1;
            FRAME;
            erease=0;
            Levelzeichner();
        END
        IF(key(_j) AND Stage mod 6>0)
            Stage-=1;
            erease=1;
            FRAME;
            erease=0;
            Levelzeichner();
        END
        IF(key(_l) AND Stage mod 6<5)
            Stage+=1;
            erease=1;
            FRAME;
            erease=0;
            Levelzeichner();
        END


        IF(key(_Enter))
            IF(Stat>1)
                Object=get_Object((x-10)/20,(y-10)/20,Stat-2);
                stat-=2;
                x=oldx;
                y=oldy;
                FRAME(300);
            ELSE
                erease=1;
                FRAME;
                erease=0;
                map[stage].Layer[stat].xpos[(x-10)/20].ypos[(y-10)/20]=Object;
                Levelzeichner();
            END
        END
        IF(key(_del))
            erease=1;
            FRAME;
            erease=0;
            IF(stat==0)
                map[stage].Layer[0].xpos[(x-10)/20].ypos[(y-10)/20]=6;
                Levelzeichner();
            END
            IF(stat==1)
                map[stage].Layer[1].xpos[(x-10)/20].ypos[(y-10)/20]=0;
                Levelzeichner();
            END
        END
        IF(key(_control) AND key(_s))
            IF(set==1)
                save("saves/Level1.dat",OFFSET map,sizeof(map));
            END
            IF(set==2)
                save("saves/Level2.dat",OFFSET map,sizeof(map));
            END
        END

        FRAME;

    END

END


PROCESS Chooser()

BEGIN
    x=400;
    y=300;
    z=-10;
    LOOP
        IF(Stat==2)
            graph=851;
        END
        IF(Stat==3)
            graph=852;
        END
        FRAME;
        graph=0;
    END

END

PROCESS Back()

BEGIN
    x=400;
    y=300;
    z=-9;
    LOOP
        IF(Stat==2)
            graph=853;
        END
        IF(Stat==3)
            graph=853;
        END
        FRAME;
        graph=0;
    END

END



PROCESS get_Object(x,y,Picture)

BEGIN
    IF(Picture==0)//Floors
        IF(y==0)
            SWITCH (x)
                CASE 0:
                    RETURN(6);
                END
                CASE 1:
                    RETURN(22);
                END
                CASE 2:
                    RETURN(26);
                END
                CASE 3:
                    RETURN(28);
                END
                CASE 4:
                    RETURN(71);
                END
                CASE 5:
                    RETURN(11);
                END
                CASE 6:
                    RETURN(212);
                END
                CASE 7:
                    RETURN(214);
                END
                CASE 8:
                    RETURN(211);
                END
                CASE 9:
                    RETURN(213);
                END
                CASE 10:
                    RETURN(40);
                END
                CASE 11:
                    RETURN(20);
                END
            END
        END
    END
    IF(Picture==1)//Objects
        IF(y==0)//Items
            SWITCH (x)
                CASE 0:
                    RETURN(22);
                END
                CASE 1:
                    RETURN(20);
                END
                CASE 2:
                    RETURN(54);
                END
                CASE 3:
                    RETURN(52);
                END
                CASE 4:
                    RETURN(118);
                END
                CASE 5:
                    RETURN(116);
                END
                CASE 6:
                    RETURN(7);
                END
                CASE 7:
                    RETURN(250);
                END
                CASE 8:
                    RETURN(74);
                END
                CASE 9:
                    RETURN(71);
                END
                CASE 10:
                    RETURN(11);
                END
                CASE 11:
                    RETURN(120);
                END
                CASE 12:
                    RETURN(121);
                END
                CASE 13:
                    RETURN(122);
                END
                CASE 14:
                    RETURN(59);
                END
                CASE 15:
                    RETURN(60);
                END
                CASE 16:
                    RETURN(61);
                END
            END
        END
        IF(y==3)//Enemys
            SWITCH (x)
                CASE 0:
                    RETURN(41);
                END
                CASE 1:
                    RETURN(39);
                END
                CASE 2:
                    RETURN(40);
                END
                CASE 3:
                    RETURN(17);
                END
                CASE 4:
                    RETURN(38);
                END
                CASE 5:
                    RETURN(13);
                END
                CASE 6:
                    RETURN(18);
                END
            END
        END
    END
END

/*    Objects:
        7=Shield++
        10=Fields, not very allowed to move (secretpassage)(Leveleditors help)
        11=SilverKey
        13=Ghost
        15=Fields, allowed to move (Leveleditors help)
        17=Ogre
        18=OgreStonethrower
        20=StrongPotion
        22=Potion
        38=OrkHeld
        39=OrkSchuetze
        40=HelmOrk
        41=Ork
        52=StrongManaPotion
        54=ManaPotion
        71=GoldKey
        74=Allhealer
        116=ManyArrows
        118=Arrows
        250=Saver
    Map:    6 =Floor
            11=NeedSilverKey
            20=Secretpassage
            22=Wall
            26=SchiessScharte
            28=duenne SchiessScharte
            40=Slime
            71=NeedGoldKey
            211=Falltueraktivator
            212=Zugefallene Falltuer
            213=Falltuer
            214=Falltueroeffner2Felder*/















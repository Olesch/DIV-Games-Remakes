//22-Tot
//41-Win
//54-Wall
//73-Hole
//89-Hill

//Point 1: Starting Position

//Pixel 1: Speedup
//Pixel 2: Speed-Multiplier
//Pixel 3: Yellow-Strength
//Pixel 4: Ballers-Gravity
//Pixel 5: Reibung
//Reihe 2:
//Pixel 1:
//Pixel 2:
//Pixel 3: Lila-Strength
//Blue(54)=Standard
//Max(255)=54


//To be made:
//FPS-Saving
//Levels
//New terrains(BlueBallKiller(?))
//Canons
//2 Player Mode


PROGRAM Baller;

GLOBAL
    Level=117;
    LevelReal;
    NOER;
    Killed;
    Colour;
    Time;
    Pictures;
    SmallBall_x;
    SMallBall_y;
    Ball_x;
    Ball_y;
    fpsa=40;
    fpsb;
    Speedup=2;
    Speedmul=5;
    Speedcount;
    YellowStr=10;
    LilaStr=6;
    BBGrav=50;
    Reibung=10;
    ReibCount;
    HiTimes[30];


BEGIN
    Levelreal=Level-99;
    load("saves\Ballers.dat", offset HiTimes); // The disk data are loaded
    resolution=100;
    Pictures=load_fpg("Olegs\Baller.fpg");  // Loads graphics' file
    set_mode(m640x480);               // Sets video mode to 640x480
    set_fps(40,0);                    // Number of frames per second
    get_point(Pictures,Level,1, offset x, offset y);
    SmallBall(x*100,y*100);
    Framers();
    start_scroll(0,Pictures,Level,0,0,0);
    Write_Int(0,290,50,4,OFFSET Time);
    Write_Int(0,290,40,4,OFFSET HiTimes[Levelreal]);

    SPeedup=map_get_pixel(pictures,Level,0,0);
    IF(SPeedup==54)
        Speedup=2;
    END
    IF(SPeedup==255)
        Speedup=54;
    END

    SPeedmul=map_get_pixel(pictures,Level,1,0);
    IF(SPeedmul==54)
        Speedmul=5;
    END
    IF(SPeedmul==255)
        Speedmul=54;
    END

    YellowStr=map_get_pixel(pictures,Level,2,0);
    IF(YellowStr==54)
        YellowStr=10;
    END
    IF(YellowStr==255)
        YellowStr=54;
    END

    BBGrav=map_get_pixel(pictures,Level,3,0);
    IF(BBGrav==54)
        BBGrav=50;
    END
    IF(BBGrav==255)
        BBGrav=54;
    END
    BBGrav=BBGrav*10;

    Reibung=map_get_pixel(pictures,Level,4,0);
    IF(Reibung==54)
        Reibung=10;
    END
    IF(Reibung==255)
        Reibung=54;
    END


    LilaStr=map_get_pixel(pictures,Level,2,1);
    IF(LilaStr==54)
        LilaStr=6;
    END
    IF(LilaStr==255)
        LilaStr=54;
    END


    LOOP
        Time++;

        FRAME;
        IF(Killed==1)
            BREAK;
        END
    END

END



PROCESS SmallBall(x,y)



                                     BEGIN
    scroll.camera=id;
    resolution=100;
    ctype=c_scroll;             // Puts within scroll
    graph=2;
    Ball(x,y);
    LOOP
        IF(key(_up))
            SmallBall_y-=Speedup;
        END
        IF(key(_down))
            SmallBall_y+=Speedup;
        END
        IF(key(_left))
            SmallBall_x-=Speedup;
        END
        IF(key(_right))
            SmallBall_x+=Speedup;
        END
        IF(SMallBall_x>99)
            SMallBall_x=99;
        END
        IF(SMallBall_x<-99)
            SMallBall_x=-99;
        END
        IF(SMallBall_y>99)
            SMallBall_y=99;
        END
        IF(SMallBall_y<-99)
            SMallBall_y=-99;
        END


        FOR (Speedcount=0; Speedcount<Speedmul; Speedcount++)
            x+=SmallBall_x;
            y+=SmallBall_y;
        END


        FRAME;
    END

END

PROCESS Ball(x,y);

BEGIN
    resolution=100;
    ctype=c_scroll;             // Puts within scroll
    graph=1;
    z=1;
    LOOP
        IF(key(_r) AND NoEr>0 AND Killed==0)
            father.x=x;
            father.y=y;
            NoEr=-100;
            Time+=24;
        END
        NoEr++;
        Ball_x+=(Father.x-x)/BBGrav;
        Ball_y+=(Father.y-y)/BBGrav;

        IF(Ball_x>99)
            Ball_x=99;
        END
        IF(Ball_x<-99)
            Ball_x=-99;
        END
        IF(Ball_y>99)
            Ball_y=99;
        END
        IF(Ball_y<-99)
            Ball_y=-99;
        END


        FOR (Speedcount=0; Speedcount<Speedmul; Speedcount++)
            x+=Ball_x;
            y+=Ball_y;
            Walls(x,y);
        END

        IF(Reibung!=0)
            Reibcount++;
            IF(Reibcount>=Reibung)
                IF(Ball_x>0)
                    Ball_x-=1;
                END
                IF(Ball_x<0)
                    Ball_x+=1;
                END
                IF(Ball_y>0)
                    Ball_y-=1;
                END
                IF(Ball_y<0)
                    Ball_y+=1;
                END
                Reibcount=0;
            END
        END

        IF(killed==1)
            BREAK;
        END

        FRAME;
    END
    LOOP
        FRAME;
    END

END

PROCESS Walls(x,y)

BEGIN
        IF(map_get_pixel(pictures,Level,x/100,y/100)==22)
            Killed=1;
            Write(0,290,70,4,"You LOOSE");
        END
        IF(map_get_pixel(pictures,Level,x/100,y/100)==41)
            Killed=1;
            Write(0,290,70,4,"You WIN!");
            IF(Hitimes[Levelreal]==0)
                Hitimes[Levelreal]=Time;
            END
            IF(Hitimes[Levelreal]>Time)
                Hitimes[Levelreal]=Time;
            END

            save("saves\Ballers.dat", offset Hitimes, sizeof(Hitimes));
        END

        IF(map_get_pixel(pictures,Level,x/100+4,y/100)==54 AND Ball_x>0)
            Ball_x=-Ball_x;
            father.x+=Ball_x;
        END
        IF(map_get_pixel(pictures,Level,x/100-4,y/100)==54 AND Ball_x<0)
            Ball_x=-Ball_x;
            father.x+=Ball_x;
        END
        IF(map_get_pixel(pictures,Level,x/100,y/100+4)==54 AND Ball_y>0)
            Ball_y=-Ball_y;
            father.y+=Ball_y;
        END
        IF(map_get_pixel(pictures,Level,x/100,y/100-4)==54 AND Ball_y<0)
            Ball_y=-Ball_y;
            father.y+=Ball_y;
        END

        IF(map_get_pixel(pictures,Level,x/100+8,y/100)==73)
            Ball_x+=YellowStr;
        END
        IF(map_get_pixel(pictures,Level,x/100-8,y/100)==73)
            Ball_x-=YellowStr;
        END
        IF(map_get_pixel(pictures,Level,x/100,y/100+8)==73)
            Ball_y+=YellowStr;
        END
        IF(map_get_pixel(pictures,Level,x/100,y/100-8)==73)
            Ball_y-=YellowStr;
        END

        IF(map_get_pixel(pictures,Level,x/100+8,y/100)==89)
            Ball_x-=LilaStr;
        END
        IF(map_get_pixel(pictures,Level,x/100-8,y/100)==89)
            Ball_x+=LilaStr;
        END
        IF(map_get_pixel(pictures,Level,x/100,y/100+8)==89)
            Ball_y-=LilaStr;
        END
        IF(map_get_pixel(pictures,Level,x/100,y/100-8)==89)
            Ball_y+=LilaStr;
        END

        IF(Ball_x>99)
            Ball_x=99;
        END
        IF(Ball_x<-99)
            Ball_x=-99;
        END
        IF(Ball_y>99)
            Ball_y=99;
        END
        IF(Ball_y<-99)
            Ball_y=-99;
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

        FRAME;



    END
END



















//1840,280
//  1850 250

PROGRAM Huhnshot;

GLOBAL
    Pictures;
    AmmoAmount=6;
    Maxmunition=6;
    Schuesse=0;
    Treffer=0;
    Score;
    ENDSCORE;
    Time=90;
    Combobalken;
    Flowers=15;
    Berge=2;
    Burg=4;
    Deadbirdtext;
    Bonusmaster;
    Birdskillamount;
    Accuracy;
    TimeBonus;
    Combobonus;
    fpsa=24;
    fpsb;


LOCAL
    Killed;


BEGIN

    Pictures=load_fpg("Olegs\Huhn.fpg");  // Loads graphics' file
    load_fnt("Olegs\Huhn.fnt");  // Loads graphics' file
    set_mode(m800x600);               // Sets video mode to 640x480
    set_fps(24,0);                    // Number of frames per second
    start_scroll(0,Pictures,101,0,0,0);
    Front();
    Cursor();
    Munition(0);
    SCORER();
    Comber();
    FRAMErS();
    Write_int(1,800,0,2,OFFSET Score);
    Write_int(1,800,50,2,OFFSET Birdskillamount);
    Write_int(1,800,100,2,OFFSET Accuracy);
    Write_int(1,50,0,2,OFFSET Time);

    Bird(rand(0,24000),rand(0,6000),rand(0,1));
    Bird(rand(0,24000),rand(0,6000),rand(0,1));
    Bird(rand(0,24000),rand(0,6000),rand(0,1));
    Bird(rand(0,24000),rand(0,6000),rand(0,1));
    FOR(x=0; x<Flowers; x++)
        SpecialItems(rand(0,2400),rand(435,600),rand(111,114),rand(5,15),-51,0);
    END


    SpecialItems(1834,232,110,100,-1,3);
    SpecialItems(1922,235,110,100,-1,3);
    SpecialItems(1840,280,117,100,-1,5);
    SpecialItems(1850,250,118,100,-1,8);

    SpecialItems(700,200,116,500,-1,15);
    SpecialItems(0,60,115,500,-1,20);

    LOOP
        IF(rand(0,(Schuesse+20))<(Treffer+5))

            IF(rand(0,1)==0)
                Bird(rand(0,24000),6000,rand(0,1));
            ELSE
                IF(rand(0,1)==0)
                    Bird(0,rand(0,6000),1);
                ELSE
                    Bird(24000,Rand(0,6000),0);
                END
            END
        END


        FRAME(2400);
        Time--;
        IF(Flowers==0)
            Text(500,scroll[0].x0+400,300);
            textb("Flowerbonus",scroll[0].x0+400,250);
            Flowers=-1;
            score+=500;
            time+=10;
            Maxmunition++;
        END
        IF(Berge==0)
            textb("LAWINE!!",scroll[0].x0+400,250);
            time+=10;
                Bird(rand(0,24000),6000,rand(0,1));
                Bird(rand(0,24000),6000,rand(0,1));
                Bird(rand(0,24000),6000,rand(0,1));
                Bird(rand(0,24000),6000,rand(0,1));
                Bird(0,rand(0,6000),1);
                Bird(0,rand(0,6000),1);
                Bird(24000,Rand(0,6000),0);
                Bird(24000,Rand(0,6000),0);
            Berge=-1;
            Maxmunition++;
        END
        IF(Burg==0)
            Text(500,scroll[0].x0+400,300);
            textb("Burgruine",scroll[0].x0+400,250);
            score+=500;
            time+=10;
            Burg=-1;
            Maxmunition++;
        END
        IF(Burg==-1)
            IF(rand(0,3)==0)
                Bird(18680,3130,rand(0,1));
            END
        END
        IF(Combobonus==-1 AND Timebonus==-1 AND Burg==-1 AND Berge==-1 AND Flowers==-1 AND Deadbirdtext==1 AND Bonusmaster==0)
            Text(500,scroll[0].x0+400,200);
            textb("ALL",scroll[0].x0+300,350);
            textb("BONUSES",scroll[0].x0+400,400);
            textb("FOUND!!!",scroll[0].x0+500,450);
            textb("HOLD MG FOR MACHINEGUNMODE!!!",scroll[0].x0+500,500);
            score+=500;
            time+=10;
            BONUSMASTER=1;
            Maxmunition++;
        END


    END
END




PROCESS cursor()

PRIVATE
    AntiFastClick;
    AntiFastClickb;
    HitBird;
    MGWAIT;
    Counter;
    Bird_chasing;

BEGIN
    CursorDeko();
    mouse.x=400;
    mouse.y=300;
    graph=1;
    //scroll[0].camera=id;
    z=-100;
    //ctype=c_scroll;
    LOOP

        /*x+=mouse.x-320;
        y+=mouse.y-240;

        mouse.x=320;
        mouse.y=240;

        IF(y>600)
            y=600;
        END
        IF(y<0)
            y=0;
        END
        IF(x<0)
            x=0;
        END
        IF(x>2400)
            x=2400;
        END*/

        IF(Schuesse>1)
            Accuracy=(Treffer*100)/Schuesse;
        END


        x=mouse.x;
        y=mouse.y;

        IF(mouse.y>600)
            mouse.y=600;
        END
        IF(mouse.y<0)
            mouse.y=0;
        END
        IF(mouse.x<0)
            mouse.x=0;
        END
        IF(mouse.x>800)
            mouse.x=800;
        END
        IF(key(_left))
            scroll[0].x0-=8;
        END
        IF(key(_right))
            scroll[0].x0+=8;
        END
        IF(mouse.x<3)
            scroll[0].x0-=8;
        END
        IF(mouse.x>797)
            scroll[0].x0+=8;
        END

        IF(mouse.left AND AntiFastClick==0 AND AmmoAmount>0)
            IF(mouse.x<50 AND mouse.y<25 AND Timebonus==0)
                Time+=10;
                Timebonus=-1;
                Text(100,scroll[0].x0+400,300);
                textb("Uhr abgeknallt!",scroll[0].x0+400,250);
                score+=100;
                Maxmunition++;
            END
            Schuesse++;
            AntiFastClick=1;
            AmmoAmount--;
            IF(HitBird=Collision(TYPE Bird))
                Hitbird.Killed=1;
            END
            IF(HitBird=Collision(TYPE Specialitems))
                Hitbird.Killed=1;
            END

        END
        IF(mouse.right AND AntiFastClickb==0)
            AntiFastClickb=1;
            AmmoAmount=Maxmunition;
            Score-=50+Flowers;
        END
        IF(Score<0)
            Score=0;
        END

        IF(NOT mouse.left)
            AntiFastClick=0;
        END
        IF(NOT mouse.right)
            AntiFastClickb=0;
        END
        IF(key(_m) AND key(_g) AND BONUSMASTER==1)
            MGWAIT++;
            IF(MGWAIT>2)
                AntiFastClick=0;
                MGWAIT=0;
            END
            IF(AmmoAmount<1)
                AmmoAmount=Maxmunition;
                Score-=10;
            END

        END
        /*IF(key(_a))
            FROM counter=1 TO 50;
                // We take the processes' identifiers
                Bird_Chasing=get_id(TYPE Bird);
                IF(Bird_chasing!=0)
                    IF(SQRT((x+scroll[0].x0-Bird_chasing.x/10)*(x+scroll[0].x0-Bird_chasing.x/10)+(y-Bird_chasing.y/10)*(y-Bird_chasing.y/10))<100)
                        //textb("YES!!",scroll[0].x0+400,250);
                        mouse.x=(mouse.x+Bird_chasing.x/10)/2-scroll[0].x0;
                        mouse.y=(mouse.y+Bird_chasing.y/10)/2;
                    END
                END
            END
        END*/   //Autozielmode

        //mouse.x=320;
        //mouse.y=240;





        FRAME;

    END
END


PROCESS Bird(x,y,flags)

PRIVATE
    Waittograph;
    XSpeed;
    YSpeed;
    Points;
    Deadshot;

BEGIN
    resolution=10;
    ctype=c_scroll;
    graph=10;
    size=rand(25,100);
    z=-size;
    YSpeed=rand(-20,20);
    XSpeed=(((flags*2)-1)*size*rand(4,6))/10;
    IF(Xspeed==0)
        XSpeed=(flags*2)-1;
    END
    LOOP
        x+=Xspeed;
        y+=Yspeed;
        IF(rand(0,15)==0)
            IF(rand(0,1)==0)
                YSpeed+=7;
            ELSE
                YSpeed-=7;
            END
        END
        IF(y<750 AND rand(0,1)==0)
            ySpeed+=1;
        END
        IF(y>5250 AND rand(0,1)==0)
            ySpeed-=1;
        END
        IF(ySpeed>30)
            ySpeed=30;
        END
        IF(ySpeed<-30)
            ySpeed=-30;
        END

        Waittograph++;
        IF(Waittograph>10)
            graph++;
            IF(graph==14)
                graph=10;
            END
            Waittograph=0;
        END
        FRAME;
        IF(Killed==1)
            Birdskillamount++;
            Treffer++;
            flags+=2;
            Points=(110-size)+ABS(XSpeed/4)+10;
            Score+=Points;
            Combobalken+=Points;
            Text(Points,x/10,y/10);
            BREAK;

        END
        IF(x>24500 OR x<-500 OR y>6500 OR y<-500)
            signal(id,s_kill);
        END
    END
    Killed=0;
    LOOP
        IF(Killed==1)
            DEADSHOT++;
            Killed=0;
            Treffer++;
        END
        IF(DEADSHOT>4)
            Text(points,x/10,y/10);
            IF(Deadbirdtext!=1)
                textb("VERY DEAD BIRD BONUS!!",scroll[0].x0+400,250);
                Deadbirdtext=1;
                Maxmunition++;
            END
            score+=Points;
            Combobalken+=Points;
            BREAK;
        END

        y+=40;
        FRAME;
        IF(y>8000)
            BREAK;
        END
    END

END



PROCESS Munition(Number)

PRIVATE
    Number;

BEGIN
    IF(Number<15)
        Munition(Number+1);
    END
    x=800-(Number*20);
    y=600;
    graph=5;
    LOOP
        IF(AmmoAmount-Number>0)
            graph=5;
        ELSE
            graph=1;
        END
        FRAME;
    END

END



PROCESS Text(Points,x,y)

PRIVATE
    TextV;
    Counter;

BEGIN
    x-=scroll[0].x0;
    TextV=Write_int(1,x,y,7,OFFSET Points);
    FOR(counter=0; counter<30; counter++)
        y-=1;
        move_Text(TextV,x,y);
        FRAME(300);
    END
    delete_text(TextV);
END

PROCESS Textb(Points,x,y)

PRIVATE
    TextV;
    Counter;

BEGIN
    x-=scroll[0].x0;
    TextV=Write(1,x,y,7,Points);
    FOR(counter=0; counter<30; counter++)
        y-=1;
        move_Text(TextV,x,y);
        FRAME(300);
    END
    delete_text(TextV);
END



PROCESS Cursordeko();
BEGIN
    //ctype=c_scroll;
    graph=2;
    z=-100;
    LOOP
        x=father.x;
        y=father.y;
        FRAME;

    END
END





PROCESS Front();

BEGIN
    ctype=c_scroll;
    graph=100;
    z=-50;
    LOOP
        FRAME;
    END
END



PROCESS SCORER();

BEGIN
    LOOP
        IF(Time<0)
            ENDSCORE=score;
            Write_int(1,400,300,4,OFFSET ENDScore);
            BREAK;
        END

        FRAME;
    END
END

PROCESS COMBER();

BEGIN
    Write_int(1,100,50,2,OFFSET Combobalken);
    LOOP
        Combobalken--;
        IF(Combobalken>100)
            Score+=(Combobalken-100)/10;
            Combobalken--;
        END
        IF(Combobalken>250)
            Combobalken=250;

            IF(Combobonus==0)
                Text(500,scroll[0].x0+400,300);
                textb("Combobonus!!",scroll[0].x0+400,250);
                score+=500;
                time+=10;
                Combobonus=-1;
                Maxmunition++;
            END

        END
        IF(Combobalken<0)
            Combobalken=0;
        END



        FRAME;
    END
END


PROCESS SpecialItems(x,y,graph,Points,z,Life)

PRIVATE
    Points;
    Life;

BEGIN
    ctype=c_scroll;
    LOOP
        IF(Killed==1)
            IF(Life>0)
                Treffer++;
                Life--;
                Killed=0;
            ELSE
                Treffer++;
                Score+=Points;
                Combobalken+=Points/2;
                Text(Points,x,y);
                BREAK;
            END
        END
        FRAME;
    END
    IF(graph>110 AND graph<115)
        Flowers--;
    END
    IF((graph==116 OR graph==115))
        Combobalken-=200;
        Berge--;
    END
    IF((graph==110 OR graph==118 OR graph==117))
        Burg--;
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









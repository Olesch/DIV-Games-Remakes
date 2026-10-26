/*
Picture-Points:0-Centre
               1-  1-Cannon
               2/3 2-Cannons



Weapons: 0-none
         1-straight forward
         2-upper shot  \
         3-downer shot - (only upper shot needed-both created)
         4-targeting
         5-PowerCannons
         6-Two turning Cannons
         7-5 targetters


Art: Snake-Colony: 0-Forward
                   1-Move random up down
                   2-"Jump" up down down up
                   3-"longjump" up down
                   4-"longjump" up down and stopping on screen
                   5-"longjump" up down and nearly stopping on screen
                   6-"jump" up down down up and stopping on screen
                   7-"jump" up down down up and nearly stopping on screen
                   8-"Jump" up down down up with constant movement
                   9-Turning clockwise (NO WEAPONS!) Use special graphs
                   10-Turning anticlockwise (NO WEAPONS!)
                   11-"longJump" up down with constant movement



Art: Jump_Shooter: 1-Clone 2 near to him


*/
PROGRAM S_Type;

GLOBAL
    fpsa=40;
    fpsb;
    Pictures;
    Gatta;
    Playersnummer=1;//0-1-2-3
    Psh=-1;     //Playersstillhere


    STRUCT Player[3]


        Player;
        Weapon;
        Center;
        Lives;
        killed;
        Powers;
        Shield;
        Compains;
    END

    Level;
    Randomer;
    Endenemy;
    EndyText;
    Speceffects;
    dealedlifes;
    Joystick4;
    zeigerpos;
    Passivloose=1;


LOCAL
    Life;
    Strength;
    nummer;
    Schuss;

BEGIN
    //load("saves\S-Type.dat", offset HiTimes); // The disk data are loaded
    Pictures=load_fpg("Olegs\S-Type.fpg");  // Loads graphics' file
    Pictures=load_fnt("Olegs\S-Type.fnt");  // Loads graphics' file
    Pictures=load_fnt("Olegs\S-Type2.fnt");  // Loads graphics' file
    Pictures=load_fnt("Olegs\S-Type3.fnt");  // Loads graphics' file
    Pictures=load_fnt("Olegs\S-Type4.fnt");  // Loads graphics' file
    set_mode(m800x600);               // Sets video mode to 640x480
    set_fps(40,0);                    // Number of frames per second
    Framers();
    x=190;
    y=0;
    graph=1;

    write(0,0,0,0,"Spielerzahl:1-4");
    write(0,0,15,0,"Gemeinsame Leben:0=nein 1=ja");
    write(0,0,30,0,"Graphikstufe:1-3");
    write(0,0,45,0,"Spieler 4 Joystick?:0=nein 1=ja");
    write(0,0,60,0,"Passive Waffen beim Tod weg?               0=nein 1=ja(bei 'nein' erfolgt schwaechung der Waffen)");

    write_int(0,200,0,0,OFFSET Playersnummer);
    write_int(0,200,15,0,OFFSET dealedlifes);
    write_int(0,200,30,0,OFFSET Speceffects);
    write_int(0,200,45,0,OFFSET Joystick4);
    write_int(0,200,60,0,OFFSET Passivloose);

    LOOP
        IF(Key(_down)) y+=15; zeigerpos+=1;END
        IF(Key(_up)) y-=15; zeigerpos-=1;END

        IF(Key(_left))
            IF(zeigerpos==1 AND Playersnummer>1) Playersnummer-=1; END
            IF(zeigerpos==2 AND dealedlifes>0) dealedlifes-=1; END
            IF(zeigerpos==3) Speceffects-=1; END
            IF(zeigerpos==4) Joystick4-=1; END
            IF(zeigerpos==5) Passivloose-=1; END
        END

        IF(Key(_right))
            IF(zeigerpos==1 AND Playersnummer<4) Playersnummer+=1; END
            IF(zeigerpos==2 AND dealedlifes<1) dealedlifes+=1; END
            IF(zeigerpos==3) Speceffects+=1; END
            IF(zeigerpos==4) Joystick4+=1; END
            IF(zeigerpos==5) Passivloose+=1; END
        END


        IF(Key(_esc) OR Key(_enter) OR Key(_space))
            delete_text(all_text);
            BREAK;
        END
        FRAME;
    END
    Write_int(0,400,1,2,OFFSET Gatta);
    x=-50000;
    y=-50000;
    Playersnummer--;


    Background();
    Buyline();
    Player[0].Player=Ship(0,_left,_right,_up,_down,_Control,_r_shift,_enter);
    Player[0].Center=Centerpoint(-5000,-5000,0);
    Buychooser(0);
    shieldAnimation(0);
    write_int(2,0,35,0,OFFSET Player[0].lives);
    IF(Playersnummer>=1)
        Player[1].Player=Ship(1,_z,_c,_s,_x,_a,_w,_q);
        Player[1].Center=Centerpoint(-5000,-5000,1);
        Buychooser(1);
        shieldAnimation(1);

        IF(Dealedlifes==0)
            write_int(3,800,35,2,OFFSET Player[1].lives);
        END
    END
    IF(Playersnummer>=2)
        Player[2].Player=Ship(2,_j,_l,_i,_k,_h,_u,_y);
        Player[2].Center=Centerpoint(-5000,-5000,2);
        Buychooser(2);
        shieldAnimation(2);
        IF(Dealedlifes==0)
            write_int(4,0,600,6,OFFSET Player[2].lives);
        END
    END
    IF(Playersnummer>=3)
        Player[3].Player=Ship(3,_v,_n,_g,_b,_f,_t,_r);
        //Player[3].Player=Ship(3,_v,_n,_g,_b,_f,_t,_r);
        Player[3].Center=Centerpoint(-5000,-5000,3);
        Buychooser(3);
        shieldAnimation(3);
        IF(Dealedlifes==0)
            write_int(1,800,600,8,OFFSET Player[3].lives);
        END
    END
    IF(Dealedlifes==1)
        Player[0].lives=(Playersnummer+1)*5;
    END

    /*dump_type=partial_dump;
    restore_type=no_restore;*/








//
//
//
//      LEVEL 1
//
//
//












        Endytext=write(1,400,300,4,"Level 1 - Get Started");
        FRAME(12000);
        delete_text(Endytext);
        snake_colony(80000,30000,500,0,5+psh*2,0,1,0,200,10);
        FRAME(18000);
        snake_colony(80000,40000,500,-100 ,5 ,5 ,1 ,0 ,200,10);
        snake_colony(80000,20000,500,100  ,5 ,5 ,1 ,0 ,200,10);
        FRAME(18000);
        snake_colony(80000,10000,500,0,2,5,0,0,200,10);
        snake_colony(80000,20000,500,0,2,5,0,0,200,10);
        snake_colony(96000,30000,500,0,0,5,0,2,200,10);
        snake_colony(80000,40000,500,0,2,5,0,0,200,10);
        snake_colony(80000,50000,500,0,2,5,0,0,200,10);
        snake_colony(80000,15000,500,0,2,5,0,0,200,10);
        snake_colony(80000,25000,500,0,2,5,0,0,200,10);
        snake_colony(80000,35000,500,0,2,5,0,0,200,10);
        snake_colony(80000,45000,500,0,2,5,0,0,200,10);
        FRAME(18000);
        snake_colony(80000,30000,500   ,0     ,1    ,5    ,1  ,1     ,200  ,10);
        FRAME(18000);
        Boomer(80000,20000,650  ,1      ,180000,2000     ,100);
        Boomer(80000,40000,650  ,1      ,180000,2000     ,100);
        FRAME(18000);
        FRAME(18000);
        snake_colony(80000,30000,300   ,0     ,psh  ,101  ,0  ,0     ,200  ,1);
        FRAME(18000);
        snake_colony(80000,10000,500   ,0     ,3    ,5    ,1  ,1     ,200  ,10);
        snake_colony(80000,30000,500   ,0     ,3    ,5    ,1  ,1     ,200  ,10);
        snake_colony(80000,50000,500   ,0     ,3    ,5    ,1  ,1     ,200  ,10);
        FRAME(18000);
        snake_colony(80000,30000,300   ,0     ,0+psh/2,100,1  ,4     ,200  ,50);
        snake_colony(80000,10000,500   ,0     ,3    ,5    ,1  ,2     ,200  ,10);
        snake_colony(80000,50000,500   ,0     ,3    ,5    ,1  ,2     ,200  ,10);
      //snake_colony(x    ,y    ,xspeed,yspeed,count,money,art,weapon,graph,life);
        FRAME(18000);
            Endytext=write(1,400,300,4,"Careful!");
            FRAME(8000);
            FOR(Randomer=0; Randomer<2; Randomer++)

            delete_text(Endytext);
            Endytext=write(1,700,300,5,">");
            FRAME(500);
            delete_text(Endytext);
            Endytext=write(1,400,500,7,"V");
            FRAME(500);
            delete_text(Endytext);
            Endytext=write(1,100,300,3,"<");
            FRAME(500);
            delete_text(Endytext);
            Endytext=write(1,400,150,1,"^");
            FRAME(500);

            END
            delete_text(Endytext);

            Boomer(80000,30000,800  ,1      ,180000,4000     ,100);
            Boomer(    0,30000,800  ,1      ,     0,4000     ,100);
            Boomer(40000,    0,800  ,1      ,270000,4000     ,100);
            Boomer(40000,60000,800  ,1      , 90000,4000     ,100);
        FRAME(18000);
        snake_colony(80000,10000,500   ,0     ,2    ,4    ,0  ,2     ,200  ,11);
        snake_colony(80000,50000,500   ,0     ,2    ,4    ,0  ,2     ,200  ,11);
        snake_colony(80000,30000,500   ,0     ,2    ,4    ,0  ,1     ,200  ,11);

        FRAME(18000);
        snake_colony(80000,10000,500   ,500     ,0    ,2    ,7  ,5     ,200  ,30);
        snake_colony(80000,50000,500   ,500     ,0    ,2    ,7  ,5     ,200  ,30);
        FRAME(4000);
        Boomer(80000,5000,650  ,1      ,225000,2000     ,100);



      //Boomer(x    ,y    ,speed,moneypr,angle ,anglenear,life);
      //snake_colony(x    ,y    ,xspeed,yspeed,count,money,art,weapon,graph,life);

        FRAME(18000);
        snake_colony(80000,10000,150   ,400   ,1    ,6    ,7  ,rand(1,2),200,40);
        snake_colony(80000,20000,150   ,400   ,1    ,6    ,7  ,rand(1,2),200,40);
        snake_colony(80000,30000,150   ,400   ,1    ,6    ,7  ,rand(1,2),200,40);
        snake_colony(80000,40000,150   ,400   ,1    ,6    ,7  ,rand(1,2),200,40);
        snake_colony(80000,50000,150   ,400   ,1    ,6    ,7  ,rand(1,2),200,40);
        FRAME(24000);
            Endytext=write(1,400,300,4,"Danger! Danger!");

        FRAME(18000);

        delete_text(Endytext);
        IF(psh>=2)
            Endenemy=snake_colony(80000,30000,100,900,0,100,6,7,203,1000+psh*500);
        ELSE
            Endenemy=snake_colony(80000,30000,100,900,0,100,6,5,203,1000+psh*500);
        END
        Endytext=write_int(1,750,550,8,OFFSET Endenemy.life);


        FRAME(18000);

    LOOP
        snake_colony(80000,rand(10000,50000),500,rand(-500,500),rand(0,2),30,rand(0,3),rand(0,4),200,rand(15,30));


        FRAME(7000);
        IF(Endenemy.life<=0)
            delete_text(Endytext);
            Endytext=write(1,400,300,4,"Level 1 Won!!");
            BREAK;
        END


    END


    FRAME(15000);
    delete_text(Endytext);



//
//
//
//      LEVEL 2
//
//
//




        Endytext=write(1,400,300,4,"Level 2 - Far away from home");
        FRAME(1200);//0);
        delete_text(Endytext);
        snake_colony(80000,30000,500,0,5+psh*2,0,1,0,204,10);
    FRAME(6000);
    Jump_Shooter(30000,0    ,700     ,70       ,20   ,5      ,1  ,30         ,207  ,30  );
    Jump_Shooter(30000,60000,700     ,70       ,20   ,5      ,1  ,30         ,207  ,30  );
    FRAME(24000);
    snake_colony(80000,15000,400   ,200   ,5    ,5    ,8  ,1     ,200  ,25  );
    snake_colony(80000,55000,400   ,-200  ,5    ,5    ,8  ,1     ,204  ,25  );
    FRAME(20000);
    snake_colony(80000,50000,300   ,-200  ,4    ,5    ,9  ,0     ,209  ,15  );
    snake_colony(80000,10000,300   ,200   ,4    ,5    ,10 ,0     ,208  ,15  );
    FRAME(24000);

        snake_colony(80000,10000,300,0,1,5,2,1,204,15);
        snake_colony(80000,20000,400,0,1,5,2,1,204,15);
        snake_colony(96000,30000,500,0,0,5,2,4,204,15);
        snake_colony(80000,40000,400,0,1,5,2,1,204,15);
        snake_colony(80000,50000,300,0,1,5,2,1,204,15);
        snake_colony(80000,15000,350,0,1,5,2,2,200,15);
        snake_colony(80000,25000,450,0,1,5,2,2,200,15);
        snake_colony(80000,35000,450,0,1,5,2,2,200,15);
        snake_colony(80000,45000,350,0,1,5,2,2,200,15);
    FRAME(24000);
    snake_colony(40000,0    ,0     ,400   ,6    ,5    ,11 ,1     ,220  ,1   );
    FRAME(10000);
    snake_colony(40000,60000,0     ,-400  ,6    ,5    ,11 ,1     ,220  ,1   );
    FRAME(10000);
    snake_colony(40000,0    ,0     ,400   ,6    ,5    ,11 ,1     ,220  ,10  );
    FRAME(10000);
    snake_colony(40000,60000,0     ,-400  ,6    ,5    ,11 ,1     ,220  ,10  );
    FRAME(10000);
    snake_colony(40000,0    ,0     ,400   ,6    ,5    ,11 ,1     ,220  ,22  );
    FRAME(10000);
    snake_colony(40000,60000,0     ,-400  ,6    ,5    ,11 ,1     ,220  ,22  );
    FRAME(24000);
    Bomb(80000,20000,100   ,0     ,6   ,550    ,50  );
    Bomb(80000,30000,100   ,0     ,9   ,550    ,50  );
    Bomb(80000,40000,100   ,0     ,3   ,550    ,50  );
    FRAME(24000);
    Jump_Shooter(55000,0    ,700     ,70       ,20   ,5      ,0  ,70         ,207  ,30  );
    Jump_Shooter(55000,60000,700     ,70       ,20   ,5      ,0  ,70         ,207  ,30  );
    Jump_Shooter(25000,0    ,700     ,70       ,20   ,5      ,0  ,70         ,207  ,30  );
    Jump_Shooter(25000,60000,700     ,70       ,20   ,5      ,0  ,70         ,207  ,30  );
    Jump_Shooter(80000,20000,700     ,70       ,20   ,5      ,0  ,70         ,207  ,30  );
    Jump_Shooter(80000,40000,700     ,70       ,20   ,5      ,0  ,70         ,207  ,30  );
    Jump_Shooter(    0,20000,700     ,70       ,20   ,5      ,0  ,70         ,207  ,30  );
    Jump_Shooter(    0,40000,700     ,70       ,20   ,5      ,0  ,70         ,207  ,30  );
    FRAME(24000);
    Boomer(80000,30000,800  ,5      ,180000,1500     ,200  );
    Bomb(80000,10000,300   ,200   ,4   ,550    ,50  );
    Bomb(80000,50000,300   ,-200  ,4   ,550    ,50  );
    FRAME(24000);


  //Jump_Shooter(x    ,y    ,movspeed,Standtime,decsp,moneypr,art,weaponspeed,graph,life);
  //Boomer(x    ,y    ,speed,moneypr,angle ,anglenear,life);
  //snake_colony(x    ,y    ,xspeed,yspeed,count,money,art,weapon,graph,life);
  //Bomb(x    ,y    ,xspeed,yspeed,time,expsize,life);
    FOR(x=0;x<50;x++)
        IF(x==25)
            Compainplus(80000,30000);
            snake_colony(80000,30000,1500  ,0     ,25    ,20   ,0  ,0     ,220  ,20  );
        END
        snake_colony(80000,rand(0,60000),1500  ,rand(-50,50),0    ,2    ,0  ,0     ,220  ,70  );
        snake_colony(80000,rand(0,60000),1500  ,rand(-50,50),0    ,2    ,0  ,0     ,220  ,70  );
        snake_colony(80000,rand(0,60000),1500  ,rand(-50,50),0    ,2    ,0  ,0     ,220  ,70  );
        FRAME(1000);

    END



    Endytext=write(1,400,300,4,"Danger! Danger!");
    money(85000,20000);
    money(85000,25000);
    money(85000,35000);
    money(85000,40000);
    money(90000,20000);
    money(90000,25000);
    money(90000,30000);
    money(90000,35000);
    money(90000,40000);
    IF(PSH>1)
        money(95000,20000);
        money(95000,25000);
        money(95000,30000);
        money(95000,35000);
        money(95000,40000);
    END

    shieldplus(80000,20000);
    shieldplus(80000,25000);
    shieldplus(80000,35000);
    shieldplus(80000,40000);
    Liveplus(80000,30000);
    Liveplus(85000,30000);

    FRAME(18000);
    delete_text(Endytext);
    Endenemy=Endenemy1Hitpoint(0,1000,30000);
    Endytext=write_int(1,750,550,8,OFFSET Endenemy.life);
    LOOP
        IF(Endenemy.life<=0)
            delete_text(Endytext);
            Endytext=write(1,400,300,4,"Level 2 Won!!");
            BREAK;
        END
        FRAME;
    END


















END







        /*Randomer=rand(0,3);
        IF(randomer==0)
        snake_colony(80000,10000,300,0,2,5,0,0,200,10);
        snake_colony(80000,20000,400,0,2,5,0,0,200,10);
        snake_colony(96000,30000,500,0,0,5,0,2,200,10);
        snake_colony(80000,40000,400,0,2,5,0,0,200,10);
        snake_colony(80000,50000,300,0,2,5,0,0,200,10);
        snake_colony(80000,15000,350,0,2,5,0,0,200,10);
        snake_colony(80000,25000,450,0,2,5,0,0,200,10);
        snake_colony(80000,35000,450,0,2,5,0,0,200,10);
        snake_colony(80000,45000,350,0,2,5,0,0,200,10);
        END
        IF(randomer==1)
        snake_colony(80000,10000,500   ,0     ,2    ,4    ,0  ,2     ,200  ,11);
        snake_colony(80000,50000,500   ,0     ,2    ,4    ,0  ,2     ,200  ,11);
        snake_colony(80000,30000,500   ,0     ,2    ,4    ,0  ,1     ,200  ,11);
        END
        IF(randomer==2)
        snake_colony(80000,30000,500   ,0     ,0    ,0    ,1  ,4     ,200  ,50);
        END
        IF(randomer==3)
            Boomer(80000,30000,800  ,1      ,180000,4000     ,100);
            Boomer(    0,30000,800  ,1      ,     0,4000     ,100);
            Boomer(40000,    0,800  ,1      ,270000,4000     ,100);
            Boomer(40000,60000,800  ,1      , 90000,4000     ,100);
        END
        IF(rand(0,1)==0)
            Boomer(80000,20000,650  ,1      ,180000,2000     ,100);
        END
        IF(rand(0,1)==0)
            Boomer(    0,20000,650  ,1      ,     0,2000     ,100);
        END

        FRAME(24000);

        snake_colony(80000,rand(10000,50000),500,0,rand(2,8),5,rand(0,1),rand(0,4),200,rand(15,30));
        IF(rand(0,1)==0)
        snake_colony(80000,rand(10000,50000),500,0,rand(2,8),5,rand(0,1),rand(0,4),200,rand(15,30));
        END
        IF(rand(0,2)==0)
        snake_colony(80000,rand(10000,50000),500,0,rand(2,8),5,rand(0,1),rand(0,4),200,rand(15,30));
        END
        IF(rand(0,3)==0)
        snake_colony(80000,rand(10000,50000),500,0,rand(2,8),5,rand(0,1),rand(0,4),200,rand(15,30));
        END
            Boomer(80000,20000,650  ,1      ,180000,2000     ,500);
         *///Funny continous Enemys



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
        IF(key(_a) AND key(_l) AND key(_e) AND key(_x))
            //snake_colony(80000,rand(10000,50000),500,0,rand(2,8),5,rand(0,1),rand(0,4),200,rand(15,30));
            snake_colony(80000,10000,500,500,5,1,2,5,200,25);
            snake_colony(80000,55000,500,500,5,1,2,5,200,25);
            FRAME(800);
        END


        FRAME;
    END
END



PROCESS Ship(Nummer,links,rechts,oben,unten,Schuss,Kauf,Waffewechsel);

PRIVATE
    Antifastenter;
    Antifastshift;//Oh, surely it's not true. I've had to change from shift to alt!
    Pict;
    Ship_Speed=500;
    Normshotwait;
    Reargun=0;
    Rearshotwait=0;
    Redgun=0;
    Redshotwait;
    Gatling=0;
    gatlingshotwait;
    Boinggun;
    Boinggunwait;
    Boinganiwait;
    Centergun;
    Centergunwait;
    Flakgun;
    Flakgunwait;
    Flamegun;
    Flamegunwait;
    Killwait;
    Flameda;
    Flakda;

BEGIN
    Psh++;
    player[nummer].lives=5;
    resolution=100;
    graph=1;
    x=10000;
    y=15000+nummer*10000;
    compain(nummer,0);
    LOOP
        IF(key(oben))
            y-=Ship_speed;
            IF(NOT key(schuss))
                Player[nummer].Center.y-=3*Ship_speed;
            END
        END
        IF(key(unten))
            y+=Ship_speed;
            IF(NOT key(schuss))
                Player[nummer].Center.y+=3*Ship_speed;
            END
        END
        IF(key(links))
            x-=Ship_speed;
            IF(NOT key(schuss))
                Player[nummer].Center.x-=3*Ship_speed;
            END
        END
        IF(key(rechts))
            x+=Ship_speed;
            IF(NOT key(schuss))
                Player[nummer].Center.x+=3*Ship_speed;
            END
        END
        IF(key(Schuss))
            IF(Normshotwait>13 )//AND Player[nummer].Weapon==0)
                Normalshot(x,y+600);
                Normshotwait=0;
            END
            IF(Redgun>0 AND redshotwait>10 AND Player[nummer].Weapon==1)
                IF(Redgun>=1)
                    Redshot(x,y,0);
                END
                IF(Redgun>=2)
                    Redshot(x,y,-30000);
                    Redshot(x,y,30000);
                END
                IF(Redgun>=3)
                    Redshot(x,y,15000);
                    Redshot(x,y,-15000);
                END
                IF(Redgun>=4)
                    Redshot(x,y,45000);
                    Redshot(x,y,-45000);
                END
                Redshotwait=0;
            END
            IF(Gatling>0 AND gatlingshotwait>3 AND Player[nummer].Weapon==2)
                IF(Gatling>=1)
                    Gatlingshot(x+rand(-300,300),y+rand(-1500,1500),0);
                END
                IF(Gatling>=2)
                    Gatlingshot(x+rand(5700,6300),y+rand(-1500,1500),0);
                END
                IF(Gatling>=3)
                    Gatlingshot(x+rand(3700,4300),y+rand(-1500,1500),0);
                END
                IF(Gatling>=4)
                    Gatlingshot(x+rand(3700,4300),y+rand(-1500,1500),0);
                END
                gatlingshotwait=0;
            END

            IF(reargun>0 AND rearshotwait>20)
                IF(reargun>=1)
                    Rearshot(x,y,-180000,0);
                END
                IF(reargun>=2)
                    Rearshot(x,y,-210000,0);
                    Rearshot(x,y,-150000,0);
                END
                IF(reargun>=3)
                    Rearshot(x,y,-240000,0);
                    Rearshot(x,y,-120000,0);
                END
                IF(reargun>=4)
                    Rearshot(x,y,-270000,0);
                    Rearshot(x,y,-90000,0);
                END
                Rearshotwait=0;
            END
            IF(flakgun>0 AND flakgunwait>20-flakgun*3)
                IF(flakgun>=1)
                    Rearshot(x-1500,y-1000,60000,1);
                END
                IF(flakgun>=3)
                    Rearshot(x-1500+rand(-500,500),y-1000+rand(-500,500),60000+rand(-7000,7000),1);
                END
                flakgunwait=0;
            END

            IF(flamegun>0 AND flamegunwait>3)
                IF(flamegun>=1)
                    Flameshot(x+rand(-500,500),y+600+rand(-500,500),-60000+rand(-7000,7000),Flamegun);
                END
                IF(flamegun>=3)
                    Flameshot(x+rand(-500,500),y+600+rand(-500,500),-60000+rand(-7000,7000),Flamegun-1);
                END
                flamegunwait=0;
            END

            IF(Boinggun>0 AND Player[nummer].Weapon==3)
                Boinganiwait++;
                Boinggunwait++;
                IF(Boinganiwait>1)
                    IF(Boinggun>=3)
                        Boinggunwait++;
                    END
                    IF(Boinggunwait>60)
                        Boingloadspec(x,y,150,nummer);
                    ELSE
                        IF(Boinggunwait>45)
                            Boingloadspec(x,y,110,nummer);
                        ELSE
                            IF(Boinggunwait>30)
                                Boingloadspec(x,y,80,nummer);
                            ELSE
                                IF(Boinggunwait>15)
                                    Boingloadspec(x,y,50,nummer);
                                END
                            END
                        END
                    END
                    Boinganiwait=0;
                END
                IF(Boinggunwait>Boinggun*15)
                    Boinggunwait=Boinggun*15;
                END
            END


            IF(Centergun>0 AND Centergunwait>23 AND Player[nummer].Weapon==4)
                IF(Centergun==1 OR Centergun==3)
                    Centermissile(x,y,180000,Player[nummer].center.x,Player[nummer].center.y);
                    Centermissile(x,y,-60000,Player[nummer].center.x,Player[nummer].center.y);
                    Centermissile(x,y,60000,Player[nummer].center.x,Player[nummer].center.y);
                END
                IF(Centergun==2 OR Centergun==4)
                    Centermissile(x,y,180000,Player[nummer].center.x,Player[nummer].center.y);
                    Centermissile(x,y,-90000,Player[nummer].center.x,Player[nummer].center.y);
                    Centermissile(x,y,90000,Player[nummer].center.x,Player[nummer].center.y);
                    Centermissile(x,y,0,Player[nummer].center.x,Player[nummer].center.y);
                END
                IF(Centergun==3)
                    Centermissile(x,y,0,Player[nummer].center.x,Player[nummer].center.y);
                    Centermissile(x,y,-120000,Player[nummer].center.x,Player[nummer].center.y);
                    Centermissile(x,y,120000,Player[nummer].center.x,Player[nummer].center.y);
                END
                IF(Centergun==4)
                    Centermissile(x,y,45000,Player[nummer].center.x,Player[nummer].center.y);
                    Centermissile(x,y,-45000,Player[nummer].center.x,Player[nummer].center.y);
                    Centermissile(x,y,135000,Player[nummer].center.x,Player[nummer].center.y);
                    Centermissile(x,y,-135000,Player[nummer].center.x,Player[nummer].center.y);
                END
                Centergunwait=0;
            END


        END
        IF(NOT (key(schuss)))
            IF(Boinggunwait>0)
                Boinggunwait=Boinggunwait/15;
                IF(Boinggunwait!=0)


                    Boinglaser(x,y,0,Boinggunwait,0);
                    /*IF(Boinggunwait>=2)
                        Boinglaser(x,y,30000,0,0);
                        Boinglaser(x,y,-30000,0,0);
                    END
                    IF(Boinggunwait>=3)
                        Boinglaser(x,y,15000,0,0);
                        Boinglaser(x,y,-15000,0,0);
                    END*/

                END
                Boinggunwait=0;
            END
        END




        IF(key(kauf) AND Antifastshift==0 )
            Antifastshift=1;
            IF(Player[nummer].POWERS==1 AND Ship_Speed<1030)
                Ship_Speed+=Ship_speed/4;
                Player[nummer].POWERS=0;
            END
            IF(Player[nummer].POWERS==2 AND REARGUN<4)
                Reargun++;
                Player[nummer].POWERS=0;
            END
            IF(Player[nummer].POWERS==3 AND REDGUN<4)
                Redgun++;
                Player[nummer].POWERS=0;
            END
            IF(Player[nummer].POWERS==4 AND Gatling<4)
                Gatling++;
                Player[nummer].POWERS=0;
            END
            IF(Player[nummer].POWERS==5 AND Flakgun<4)
                IF(Flakgun==0 AND Flakda==0)
                    Flakda=1;
                    Flakanimation();
                END
                Flakgun++;
                Player[nummer].POWERS=0;
            END
            IF(Player[nummer].POWERS==6 AND Boinggun<4)
                Boinggun++;
                Player[nummer].POWERS=0;
            END
            IF(Player[nummer].POWERS==7 AND Flamegun<4)
                IF(Flamegun==0 AND Flameda==0)
                    Flameda=1;
                    Flameanimation();
                END
                Flamegun++;
                Player[nummer].POWERS=0;
            END
            IF(Player[nummer].POWERS==8 AND Centergun<4)
                Centergun++;
                Player[nummer].POWERS=0;
            END
            IF(Player[nummer].POWERS==9)
                player[nummer].Shield+=3;
                Player[nummer].POWERS=0;
            END
            IF(Player[nummer].POWERS==11)
                Player[nummer].lives++;
                Player[nummer].POWERS=0;
            END
        END

        IF(Player[nummer].POWERS==11)
            Player[nummer].compains++;
            Player[nummer].POWERS=0;
        END


        IF(NOT key(kauf))
            Antifastshift=0;
        END

        //IF(key(_o) AND key(_l) AND key(_e) AND key(_g))
        IF(key(_o))
            Gatling=4;
            Redgun=4;
            Boinggun=4;
            Centergun=4;
            Reargun=4;
            Player[nummer].shield=4;
            IF(Flamegun==0)
                Flameanimation();
            END
            IF(Flakgun==0)
                Flakanimation();
            END
            Flakgun=4;
            Flamegun=4;
            IF(Ship_Speed<1030)
                Ship_Speed+=Ship_speed/4;
            END
            Player[nummer].lives++;
            Player[nummer].compains=4;
        END


        IF(key(Waffewechsel) AND Antifastenter==0)
            Antifastenter=1;
            Player[nummer].Weapon=(Player[nummer].Weapon+1) mod 5;
            IF(Redgun==0 AND Player[nummer].Weapon==1)
                Player[nummer].Weapon++;
            END
            IF(Gatling==0 AND Player[nummer].Weapon==2)
                Player[nummer].Weapon++;
            END
            IF(Boinggun==0 AND Player[nummer].Weapon==3)
                Player[nummer].Weapon++;
            END
            IF(Centergun==0 AND Player[nummer].Weapon==4)
                Player[nummer].Weapon=0;
            END
            IF(Player[nummer].Weapon==4)
                Player[nummer].Center.y=y;
                Player[nummer].Center.x=x;
            END
            Redshotwait=0;
            gatlingshotwait=0;
            Boinggunwait=0;
            Centergunwait=0;
        END
        IF(key(_1) AND Redgun>0 AND nummer==0)
            Player[nummer].Weapon=1;
        END
        IF(key(_2) AND Gatling>0 AND nummer==0)
            Player[nummer].Weapon=2;
        END
        IF(key(_3) AND Boinggun>0 AND nummer==0)
            Player[nummer].Weapon=3;
        END
        IF(key(_4) AND Centergun>0 AND nummer==0)
            Player[nummer].Weapon=4;
            Player[nummer].Center.y=y;
            Player[nummer].Center.x=x;
        END

        IF(Redgun==0 AND Player[nummer].Weapon==1)
            Player[nummer].Weapon=0;
        END
        IF(Gatling==0 AND Player[nummer].Weapon==2)
            Player[nummer].Weapon=0;
        END
        IF(Boinggun==0 AND Player[nummer].Weapon==3)
            Player[nummer].Weapon=0;
        END
        IF(Centergun==0 AND Player[nummer].Weapon==4)
            Player[nummer].Weapon=0;
        END




        IF(NOT key(_enter))
            Antifastenter=0;
        END


        Normshotwait++;
        Redshotwait++;
        gatlingshotwait++;
        Rearshotwait++;
        Centergunwait++;
        Flakgunwait++;
        Flamegunwait++;

        IF(x>75000) x=75000; END
        IF(x<5000) x=5000; END
        IF(y<8000) y=8000; END
        IF(y>55000) y=55000; END




        IF(Player[nummer].Killed==1)
            IF(Killwait==0)
                flags=4;
                explode(x,y,150,2);
                Killwait=120;
                IF(dealedlifes==0)

                    IF(Player[nummer].Lives<1)
                        player[nummer].lives=-1;
                        Psh--;
                        IF(Psh==-1)
                            write(1,400,300,4,"GAME OVER");
                            explode(x,y,250,5);
                            FRAME(5000);
                            fade_off();
                            exit("Play again!",0);
                        END
                        BREAK;
                    ELSE
                    Player[nummer].Lives--;
                    END
                ELSE
                    IF(Player[0].Lives<1)
                        player[0].lives=-1;
                        Psh=-1;
                        IF(Psh==-1)
                            write(1,400,300,4,"GAME OVER");
                            FRAME(5000);
                            fade_off();
                            exit("Play again!",0);
                        END
                        BREAK;
                    ELSE
                    Player[0].Lives--;
                    END
                END

                IF(player[nummer].shield>0)
                    player[nummer].shield--;
                ELSE
                    Redgun--;
                    Gatling--;
                    Boinggun--;
                    Centergun--;
                    Player[nummer].compains--;
                    IF(passivloose==1)
                        Flakgun--;
                        Flamegun--;
                        Reargun--;
                    END
                    IF(Reargun<0) Reargun=0; END
                    IF(Redgun<0) Redgun=0; END
                    IF(Gatling<0) Gatling=0; END
                    IF(Boinggun<0) Boinggun=0; END
                    IF(Centergun<0) Centergun=0; END
                    IF(Flakgun<0) Flakgun=0; END
                    IF(Flamegun<0) Flamegun=0; END
                    IF(Player[nummer].compains<0) Player[nummer].compains=0; END
                END


            END
            Killwait--;
            IF(Killwait<5)
                flags=0;
                Player[nummer].Killed=0;
                Killwait=0;
            END
        END

        FRAME;
        Pict=(Pict mod 11)+1;
        graph=Pict/6+20+nummer*2;
    END
END


PROCESS Compain(nummer,count)

PRIVATE
    shotwait;

BEGIN
    resolution=100;
    IF(count<3)
        Compain(nummer,count+1);
    END


    LOOP
        IF(player[nummer].compains>count)
            graph=30;
            angle=near_angle(angle,get_angle(father),10000);
            IF(get_dist(father)>3500)
                advance(400);
            END
            IF(key(player[nummer].player.schuss))
                IF(Player[nummer].Weapon==1 AND shotwait>18)
                    Redshot(x,y,angle-15000);
                    Redshot(x,y,angle+15000);
                    shotwait=0;
                END
                IF(Player[nummer].Weapon==2 AND shotwait>6)
                    gatlingshot(x,y,angle);
                    shotwait=0;
                END
                IF(Player[nummer].Weapon==3 AND shotwait>35)
                    Boinglaser(x,y,angle,0,0);
                    shotwait=0;
                END
                IF(Player[nummer].Weapon==4 AND shotwait>30)
                    Centermissile(x,y,angle,Player[nummer].center.x,Player[nummer].center.y);
                    shotwait=0;
                END
            END
            shotwait++;
            IF(rand(0,1)==0)
                shotwait++;
            END
        ELSE
            graph=0;
        END
        FRAME;
    END

END






PROCESS Flakanimation();

BEGIN
    resolution=100;
    graph=3;
    z=-1;
    LOOP
        x=father.x;
        y=father.y;
        IF(player[father.nummer].killed==1)
            flags=4;
        ELSE
            flags=0;
        END

        FRAME;
    END
END

PROCESS Flameanimation();

BEGIN
    resolution=100;
    graph=4;
    z=-1;
    LOOP
        x=father.x;
        y=father.y;
        IF(player[father.nummer].killed==1)
            flags=4;
        ELSE
            flags=0;
        END



        FRAME;
    END
END

PROCESS Shieldanimation(nummer);

PRIVATE
    wait;

BEGIN
    resolution=100;
    graph=10;
    z=-1;
    LOOP
        IF(player[nummer].shield>0)
            graph=10;
        ELSE
            graph=0;
        END

        x=player[nummer].player.x;
        y=player[nummer].player.y;
        wait=(wait+1) mod 20;
        IF(wait>10)
            flags=4;
        ELSE
            flags=0;
        END

        FRAME;
    END
END






PROCESS Normalshot(x,y);

PRIVATE
    hit;
    counter;

BEGIN
    resolution=100;
    graph=100;
    Strength=10;
    LOOP
        FOR(Counter=0;Counter<2;Counter++)
            x+=750;
            IF(hit=findhit(x,y,graph,size))
                explode(x,y,10,0);
                hit.life-=strength;
                RETURN;
            END
        END

        IF(x>80000 OR x<0 or y>60000 or y<0)
            BREAK;
        END
        FRAME;
    END
END




PROCESS FindHit(x,y,graph,size)

PRIVATE
    hit;

BEGIN
    resolution=100;
    IF(hit=(collision(TYPE snake_colony)
        OR collision(TYPE Boomer)
        OR collision(TYPE Jump_Shooter)
        OR collision(TYPE Endenemy1Hitpoint)
        OR collision(TYPE Endenemy1shield)
        OR collision(TYPE BOMB)))


        RETURN(hit);

    ELSE
        RETURN(0);
    END
END

PROCESS FindHitEnemy(x,y,graph,size)

PRIVATE
    hit;

BEGIN
    resolution=100;
    IF(collision(TYPE Bombkaboom))
        father.life--;
    END
END





PROCESS Redshot(x,y,angle);

PRIVATE
    hit;
    counter;

BEGIN
    resolution=100;
    graph=101;
    Strength=10;
    LOOP

        FOR(Counter=0;Counter<2;Counter++)
            advance(750);
            IF(hit=findhit(x,y,graph,size));
                explode(x,y,10,0);
                hit.life-=strength;
                RETURN;
            END
        END
        FRAME;
        IF(x>80000 OR x<0 or y>60000 or y<0)
            BREAK;
        END
    END
END

PROCESS Gatlingshot(x,y,angle);

PRIVATE
    hit;
    counter;

BEGIN
    Gatta++;
    resolution=100;
    graph=102;
    Strength=5;
    LOOP
        FOR(Counter=0;Counter<3;Counter++)
            advance(600);
            IF(hit=findhit(x,y,graph,size));
                explode(x,y,5,0);
                hit.life-=strength;
                RETURN;
            END
        END
        FRAME;
        IF(x>80000 OR x<0 or y>60000 or y<0)
            BREAK;
        END
    END
END

PROCESS Rearshot(x,y,angle,art);

PRIVATE
    hit;
    counter;

BEGIN
    resolution=100;
    graph=103;
    IF(art==0)
        Strength=3+(passivloose*2);
    END
    IF(art==1)
        Strength=9+(passivloose*6);
        size=130;
    END


    LOOP
        FOR(Counter=0;Counter<2;Counter++)
            advance(750);
            IF(hit=findhit(x,y,graph,size));
                explode(x,y,10,0);
                hit.life-=strength;
                RETURN;
            END
        END
        FRAME;
        IF(x>80000 OR x<0 or y>60000 or y<0)
            BREAK;
        END
    END
END


PROCESS BoingLaser(x,y,angle,Power,nothit);

PRIVATE
    hit;
    counter;
    counterb;
    Enemyid;
    Enemyfound;
    Enemytype;

BEGIN
    resolution=100;
    graph=104;
    Strength=10+Power*10;
    Size=50+Power*20;
    LOOP
        FOR(Counter=0;Counter<6;Counter++)
            BoingLaserSpec(x,y,angle);
            advance(20*size);
//Before copying LOOK!!            IF(hit=(collision(TYPE snake_colony) OR collision(TYPE Boomer))!=nothit)
            IF(hit=findhit(x,y,graph,size));
                IF(hit!=nothit)
                    hit.life-=strength;
                    IF(Power>0)

                        //Boinglaser(x,y,rand(-180000,180000),Power-1,hit);
                        Boinglaser(x,y,rand(-180000,180000),Power-1,hit);

                        //Tried to make it "homing"
                        FROM Enemytype=1 TO 4;
                        FROM counterb=1 TO 50;
                            IF(Enemytype==1)
                                Enemyid=(get_id(TYPE snake_colony));
                            END
                            IF(Enemytype==2)
                                Enemyid=(get_id(TYPE BOOMER));
                            END
                            IF(Enemytype==3)
                                Enemyid=(get_id(TYPE Jump_shooter));
                            END
                            IF(Enemytype==4)
                                Enemyid=(get_id(TYPE BOMB));
                            END
                            IF(Enemyid!=0 AND Enemyid!=hit)
                                IF(Enemyid.life>0)
                                    IF(Enemyfound!=0)

                                        IF(fget_dist(x,y,Enemyid.x,Enemyid.y)<fget_dist(x,y,Enemyfound.x,Enemyfound.y))
                                            Enemyfound=Enemyid;
                                        END
                                    ELSE
                                        Enemyfound=Enemyid;
                                    END
                                END
                            END
                            IF(Enemyid==0)
                                BREAK;
                            END
                        END
                        END

                        IF(Enemyfound!=0)
                            Boinglaser(x,y,fget_angle(x,y,Enemyfound.x,Enemyfound.y),Power-1,hit);
                        ELSE
                            Boinglaser(x,y,rand(-180000,180000),Power-1,hit);
                        END

                        //Boinglaser(x,y,angle+rand(-20000,20000),Power-1,hit);
                    END
                    RETURN;
                END
            END
            IF(x>80000 OR x<0 or y>60000 or y<0)
                RETURN;
            END
        END
        FRAME;
    END
END

PROCESS Boinglaserspec(x,y,angle)

BEGIN
    size=father.size;
    resolution=100;
    Graph=104;
    FRAME(300);
END

PROCESS Boingloadspec(x,y,size,nummer)

PRIVATE
    moving;

BEGIN
    angle=rand(-180000,180000);
    resolution=100;
    Graph=105;
    advance(50*size);
    flags=4;
    LOOP
        moving+=25;
        size-=3;
        IF(get_dist(Player[nummer].player)<1000)
            size-=9;
        ELSE
        angle=get_angle(Player[nummer].player);
        advance(moving);

        END
        angle=0;
        FRAME;
        IF(size<5)
            BREAK;
        END
    END


END

PROCESS CenterMissile(x,y,angle,centerx,centery);

PRIVATE
    hit;
    counter;
    changel;
    stopangle;

BEGIN
    resolution=100;
    graph=106;
    Strength=35;
    LOOP
        StopAngle++;
        IF(fget_dist(x,y,Centerx,Centery)<1500)
            stopangle=40;
        END
        IF(Stopangle<40)
            changel=fget_angle(x,y,Centerx,Centery);
            angle=near_angle(angle,changel,6000);
        END
        FOR(Counter=0;Counter<2;Counter++)
            advance(750);
            IF(hit=findhit(x,y,graph,size));
                explode(x,y,50,0);
                hit.life-=strength;
                RETURN;
            END
        END
        FRAME;
        IF(x>80000 OR x<0 or y>60000 or y<0)
            BREAK;
        END
    END
END

PROCESS CenterPoint(x,y,nummer)

BEGIN
    resolution=100;
    graph=107+nummer;
    LOOP
        IF(Player[nummer].Weapon==4)

        ELSE
            y=-10000;
            x=-10000;

        END
        IF(x>80000)
            x=80000;
        END
        IF(y>60000)
            y=60000;
        END
        IF(x<0)
            x=0;
        END
        IF(y<0)
            y=0;
        END

        FRAME;
    END
END




PROCESS Flameshot(x,y,angle,power);

PRIVATE
    hit;
    counter;
    Startspeed;
    Fathx;
    Fathy;
    xinc;
    yinc;

BEGIN
    resolution=100;
    graph=105;
    Strength=2+(passivloose*2);
    flags=4;
    size=5;
    Fathx=Father.x;
    Fathy=Father.y;
    FRAME;
    xinc=Father.x-Fathx;
    yinc=Father.y-Fathy;


    LOOP
        x+=xinc;
        y+=yinc;

        size+=3;
        angle+=1000;

        FOR(Counter=0;Counter<2;Counter++)
            advance(250);
            IF(hit=findhit(x,y,graph,size));
                hit.life-=strength;
                RETURN;
            END
        END
        Fathx=Father.x;
        Fathy=Father.y;
        FRAME;
        xinc=(Father.x-Fathx)/3;
        yinc=(Father.y-Fathy)/3;
        IF(x>80000 OR x<0 or y>60000 or y<0 or size>50+power*30)
            BREAK;
        END
    END
END









PROCESS Buyline();

BEGIN
    graph=5;
    z=-50;
    LOOP
        FRAME;
    END
END


PROCESS BuyChooser(nummer);

BEGIN
    graph=15+nummer;
    z=-51;
    LOOP
        x=(Player[nummer].Powers-1)*30-1;
        IF(Player[nummer].Powers==0)
            x=-100;
        END
        FRAME;
    END
END




PROCESS Money(x,y);

PRIVATE
    hit;

BEGIN
    resolution=100;
    graph=7;
    z=-1;
    LOOP
        x-=300;
        FRAME;
        IF(hit=collision(TYPE ship))
            Player[hit.nummer].POWERS++;


            BREAK;
        END
        IF(x<-200)
            BREAK;
        END


    END

END


PROCESS LivePlus(x,y);

PRIVATE
    hit;

BEGIN
    resolution=100;
    graph=8;
    z=-1;
    LOOP
        x-=300;
        FRAME;
        IF(hit=collision(TYPE ship))
            IF(Dealedlifes==0)
                Player[hit.nummer].Lives++;
            ELSE
                Player[0].Lives++;
            END
            BREAK;
        END
        IF(x<-200)
            BREAK;
        END
        IF(x mod 1500<750)
            graph=8;
        ELSE
            graph=9;
        END


    END

END


PROCESS Shieldplus(x,y);

PRIVATE
    wait;
    hit;

BEGIN
    resolution=100;
    graph=10;
    z=-1;
    LOOP
        x-=300;
        IF(hit=collision(TYPE ship))
            Player[hit.nummer].Shield++;
            BREAK;
        END
        IF(x<-200)
            BREAK;
        END

        wait=(wait+1) mod 20;
        IF(wait>10)
            flags=4;
        ELSE
            flags=0;
        END

        FRAME;
    END
END



PROCESS Compainplus(x,y);

PRIVATE
    hit;

BEGIN
    resolution=100;
    graph=31;
    z=-1;
    LOOP
        x-=300;
        IF(hit=collision(TYPE ship))
            IF(Player[hit.nummer].Compains<4)
                Player[hit.nummer].Compains++;
                BREAK;
            END
        END
        IF(x<-200)
            BREAK;
        END
        FRAME;
    END
END






PROCESS Background()

BEGIN
    graph=11;
    z=500;
    x=0;
    y=0;
    LOOP
        FRAME;
        x-=2;
        IF(x<-800)
            x=0;
        END
    END

END









PROCESS snake_colony(x,y,xspeed,yspeed,count,moneypr,art,weapon,graph,life);

PRIVATE
    xspeed;
    yspeed;
    line;
    hit;
    amplitude;

BEGIN
    amplitude=(count*10) mod 80;
    IF(Art==9)
        angle=-15000*count;
    END
    IF(Art==10)
        angle=15000*count;
    END

    IF(weapon!=0 AND Art!=9 AND Art!=10)
        IF(weapon==1)
            SnakeCannon(1);
        END
        IF(weapon==2)
            SnakeCannon(weapon);
            SnakeCannon(weapon+1);
        END
        IF(weapon==3)
            SnakeCannon(weapon);
            SnakeCannon(weapon-1);
        END
        IF(weapon==4)
            SnakeCannon(4);
        END
        IF(weapon==5)
            SnakeCannon(2);
            SnakeCannon(3);
            SnakeCannon(4);
            SnakeCannon(5);
            SnakeCannon(6);
        END
        IF(weapon==6)
            SnakeCannon(5);
            SnakeCannon(6);
        END
        IF(weapon==7)
            SnakeCannon(4);
            SnakeCannon(7);
            SnakeCannon(8);
            SnakeCannon(9);
            SnakeCannon(10);
        END

    END
    resolution=100;
    IF(count>0)
        snake_colony(x+8000,y,xspeed,yspeed,count-1,moneypr,art,weapon,graph,life);
    END
    LOOP


        x-=xspeed;
        IF(Art==1)
            yspeed+=rand(-10,10);
        END
        IF(Art==2 OR Art==6 OR Art==7 OR Art==8)
            Amplitude++;
            IF(Amplitude>10 AND Amplitude<20)
                y+=yspeed;
            END
            IF(Amplitude>30 AND Amplitude<40)
                y+=yspeed;
            END
            IF(Amplitude>50 AND Amplitude<60)
                y-=yspeed;
            END
            IF(Amplitude>70 AND Amplitude<80)
                y-=yspeed;
            END
            IF(Amplitude>80)
                Amplitude=0;
            END



        END
        IF(Art==3 OR Art==4 OR Art==5 OR art==11)
            Amplitude++;
            IF(Amplitude>10 AND Amplitude<40)
                y+=yspeed;
            END
            IF(Amplitude>50 AND Amplitude<80)
                y-=yspeed;
            END
            IF(Amplitude>80)
                Amplitude=0;
            END



        END
        IF(Art==4 OR Art==6)
            IF(x<70000)
                xspeed=0;
            END
        END
        IF(Art==5 OR Art==7)
            IF(x<70000)
                xspeed=100;
            END
        END


        IF(Art!=2 AND Art!=3 AND Art!=4 AND Art!=5 AND Art!=6 AND Art!=7)
            y+=yspeed;
        END
        IF(Art==9)
            angle+=3000;
        END
        IF(Art==10)
            angle-=3000;
        END




        IF(life<=0)
            IF(MoneyPr!=100)
                IF(MoneyPr!=101)
                    IF(rand(0,moneypr)==0)
                        Money(x,y);
                    END
                ELSE
                    ShieldPlus(x,y);
                END
            ELSE
                LivePlus(x,y);
            END

            Explode(x,y,70,0);
            IF(graph==203)
                Explode(x,y,150,4);
                Explode(x,y,100,6);
                Explode(x,y,70,8);
                Explode(x,y,50,30);
                    Money(x+rand(-10000,10000),y+rand(-5000,5000));
                    Money(x+rand(-10000,10000),y+rand(-5000,5000));
                    Money(x+rand(-10000,10000),y+rand(-5000,5000));
                    Money(x+rand(-10000,10000),y+rand(-5000,5000));
                    Money(x+rand(-10000,10000),y+rand(-5000,5000));
                    Money(x+rand(-10000,10000),y+rand(-5000,5000));
                    IF(psh>=2)
                        LivePlus(x+rand(-10000,10000),y+rand(-5000,5000));
                    END

            END
            BREAK;
        END
        IF(x<-20000 or y>80000 or y<-20000)
            BREAK;
        END

        IF(hit=(collision(TYPE ship)))
            Player[hit.nummer].killed=1;
        END
        FindHitEnemy(x,y,graph,size);



        FRAME;
    END
END


PROCESS SnakeCannon(weapon)

PRIVATE
    shotwait;
    searchplayer;


BEGIN

    searchplayer=rand(0,playersnummer);
    LOOP
        IF(Player[searchplayer].lives==-1 AND psh!=-1)
            searchplayer=rand(0,playersnummer);
        ELSE
            BREAK;
        END
    END
    resolution=100;
    graph=205;
    IF(father.graph==203)
        graph=206;
    END
    z=-1;
    IF(weapon==1)
        angle=180000;
    END
    IF(weapon==2)
        angle=150000;
    END
    IF(weapon==3)
        angle=210000;
    END

    LOOP
        IF(weapon==1 OR weapon==4)
            x=father.x;
            y=father.y;
        END
        IF(weapon==2 OR weapon==7)
            x=father.x-800;
            y=father.y-1300;
        END
        IF(weapon==3 OR weapon==8)
            x=father.x-800;
            y=father.y+1200;
        END
        IF(weapon==5 OR weapon==9)
            x=father.x+2700;
            y=father.y+1200;
        END
        IF(weapon==6 OR weapon==10)
            x=father.x+2700;
            y=father.y-1300;
        END
        IF(weapon==4 OR weapon==7 OR weapon==8 OR weapon==9 OR weapon==10)
            angle=get_angle(Player[searchplayer].player);
        END
        IF(weapon==5)
            angle+=5000;
        END
        IF(weapon==6)
            angle-=5000;
        END

        shotwait++;
        IF(shotwait>30)
            Snakeshot(x,y,angle);
            shotwait=0;

            searchplayer=rand(0,playersnummer);
            LOOP
                IF(Player[searchplayer].lives==-1 AND psh!=-1)
                    searchplayer=rand(0,playersnummer);
                ELSE
                    BREAK;
                END
            END

        END

        FRAME;
        IF(father.life<1)
            BREAK;
        END


    END


END


PROCESS Snakeshot(x,y,angle);

PRIVATE
    hit;
    counter;

BEGIN
    resolution=100;
    graph=103;
    LOOP
        FOR(Counter=0;Counter<2;Counter++)
            advance(450);
            IF(hit=(collision(TYPE ship)))
                Player[hit.nummer].killed=1;
                RETURN;
            END
        END
        FRAME;
        IF(x>80000 OR x<0 or y>60000 or y<0)
            BREAK;
        END
    END
END



PROCESS Boomer(x,y,speed,moneypr,angle,anglenear,life);

PRIVATE
    hit;
    Pict=4;
    searchplayer;

BEGIN
    resolution=100;
    graph=201;
    searchplayer=rand(0,playersnummer);
    LOOP
        IF(Player[searchplayer].lives==-1 AND psh!=-1)
            searchplayer=rand(0,playersnummer);
        ELSE
            BREAK;
        END
    END
    LOOP

        FRAME;

        advance(speed);

        IF(life<=0)
            IF(rand(0,moneypr)==0)
                Money(x,y);
            END
            Explode(x,y,150,2);
            BREAK;
        END
        //IF(x<-20000 or y>80000 or y<-20000 OR x>100000)
        //    BREAK;
        //END

        IF(hit=(collision(TYPE ship)))
            player[hit.nummer].killed=1;
            searchplayer=rand(0,playersnummer);
            LOOP
                IF(Player[searchplayer].lives==-1 AND psh!=-1)
                    searchplayer=rand(0,playersnummer);
                ELSE
                    BREAK;
                END
            END

        END

        angle=near_angle(angle,get_angle(player[searchplayer].player),anglenear);
        IF(pict==1)
            life--;
        END

        Pict=(Pict mod 11)+1;
        graph=Pict/6+201;
        FindHitEnemy(x,y,graph,size);
    END
END




PROCESS Jump_Shooter(x,y,movspeed,Standtime,decsp,moneypr,art,weaponspeed,graph,life);

PRIVATE
    movspeed;
    hit;
    Shotwait;
    Standtime;
    searchplayer;

BEGIN
    searchplayer=rand(0,playersnummer);
    LOOP
        IF(Player[searchplayer].lives==-1 AND psh!=-1)
            searchplayer=rand(0,playersnummer);
        ELSE
            BREAK;
        END
    END
    angle=get_angle(player[searchplayer].player);
    resolution=100;
    IF(Art==1)
        CLONE
            CLONE
                angle+=90000;
                art=0;
                advance(11000);
                angle-=90000;
            END
            IF(art==1)
                angle-=90000;
                advance(11000);
                angle+=90000;
            END
            art=1;
        END
    END

    LOOP
        angle=near_angle(angle,get_angle(player[searchplayer].player),5000+psh*1000);

        IF(MovSpeed>0)
            advance(movspeed);
            Movspeed-=decsp;
        ELSE
            IF(Standtime>0)
                StandTime--;
            ELSE
                advance(movspeed);
                Movspeed-=decsp;
            END
        END




        IF(life<=0)
            IF(MoneyPr!=100)
                IF(rand(0,moneypr)==0)
                    Money(x,y);
                END
            ELSE
                LivePlus(x,y);
            END
            Explode(x,y,70,0);
            BREAK;
        END
        IF(x<-20000 or y>80000 or y<-20000 or x>100000)
            BREAK;
        END

        IF(hit=(collision(TYPE ship)))
            Player[hit.nummer].killed=1;
        END

        shotwait++;
        IF(shotwait>weaponspeed)
            Snakeshot(x,y,angle);
            shotwait=0;

            searchplayer=rand(0,playersnummer);
            LOOP
                IF(Player[searchplayer].lives==-1 AND psh!=-1)
                    searchplayer=rand(0,playersnummer);
                ELSE
                    BREAK;
                END
            END

        END



        FindHitEnemy(x,y,graph,size);
        FRAME;
    END
END


PROCESS Bomb(x,y,xspeed,yspeed,time,expsize,life);

PRIVATE
    hit;

BEGIN
    time=time*25;
    resolution=100;
    graph=210;

    LOOP
        x-=xspeed;
        y+=yspeed;
        IF(hit=collision(TYPE ship))
            Player[hit.nummer].killed=1;


        END
        IF(Life<1)
            explode(x,y,150,1);
            BREAK;
        END

        time--;
        graph=218-time/25;
        IF(Time<2 OR collision(TYPE BombKaboom))
            Bombkaboom(x,y,expsize);
            BREAK;
        END
        FRAME;

    END

END

PROCESS BombKaboom(x,y,expsize)

PRIVATE
    hit;

BEGIN
    resolution=100;
    graph=219;
    size=1;
    flags=4;
    LOOP
        size+=20;
        WHILE(hit=(collision(TYPE ship)))
            Player[hit.nummer].killed=1;
        END
        IF(size>expsize)
            BREAK;
        END
        Bombkaboomspec(x,y,size);
        FRAME;
    END


END

PROCESS BombKaboomspec(x,y,size)

BEGIN
    resolution=100;
    Graph=219;
    flags=4;
    FRAME(200);
END



















































PROCESS Endenemy1Hitpoint(art,life,y);

PRIVATE
    hit;
    amplitude;
    laserwait;

BEGIN
    x=80000;
    z=-1;
    graph=404;
    amplitude=25;
    resolution=100;
    Endenemy1shield();
    Endenemy1graph();
    Endenemy1Cannon(1,-1100,-3600);
    Endenemy1Cannon(1,-1200,-1200);
    Endenemy1Cannon(1,-1400,800);
    Endenemy1Cannon(1,-1000,3100);
    Endenemy1Cannon(2,2400,-1200);
    Endenemy1Cannon(3,2400,800);
    LOOP

        IF(art==0)
            IF(x>65000)
                x-=150;
            END
        ELSE

            x-=150;

        END


        Amplitude++;
        IF(Amplitude>10 AND Amplitude<40)
            y+=200;
        END
        IF(Amplitude>50 AND Amplitude<80)
            y-=200;
        END
        IF(Amplitude>80)
            Amplitude=0;
        END
        laserwait++;
        IF(laserwait>250)
            IF(Laserwait mod 3==0)
                endenemy1laserspec(x,y);
            END
        END
        IF(laserwait>280)
            IF(rand(0,2)==0)
                IF(rand(0,4)==0)
                    Endenemy1laser(x,y,50000);
                    Endenemy1laser(x,y,25000);
                    Endenemy1laser(x,y,0);
                    Endenemy1laser(x,y,-25000);
                    Endenemy1laser(x,y,-50000);
                ELSE
                    Endenemy1laser(x,y,25000);
                    Endenemy1laser(x,y,-25000);
                END
            ELSE
                Endenemy1laser(x,y,0);
            END
            laserwait=0;

        END


        IF(life<=0)
            Explode(x,y,150,4);
            Explode(x,y,100,6);
            Explode(x,y,70,8);
            Explode(x,y,50,30);
            IF(art==0)
                LivePlus(x+rand(-10000,10000),y+rand(-5000,5000));
                Money(x+rand(-10000,10000),y+rand(-5000,5000));
                Money(x+rand(-10000,10000),y+rand(-5000,5000));
                Money(x+rand(-10000,10000),y+rand(-5000,5000));
                Money(x+rand(-10000,10000),y+rand(-5000,5000));
                Money(x+rand(-10000,10000),y+rand(-5000,5000));
                Money(x+rand(-10000,10000),y+rand(-5000,5000));
                IF(psh>=2)
                    LivePlus(x+rand(-10000,10000),y+rand(-5000,5000));
                END
            END
            BREAK;
        END
        IF(x<-20000 or y>80000 or y<-20000)
            BREAK;
        END

        IF(hit=(collision(TYPE ship)))
            Player[hit.nummer].killed=1;
        END




        FRAME;
    END
END


PROCESS Endenemy1Cannon(weapon,xplus,yplus)

PRIVATE
    shotwait;
    searchplayer;
    Direction;

BEGIN
    size=130;
    resolution=100;
    searchplayer=rand(0,playersnummer);
    LOOP
        IF(Player[searchplayer].lives==-1 AND psh!=-1)
            searchplayer=rand(0,playersnummer);
        ELSE
            BREAK;
        END
    END
    graph=401;
    z=-1;
    IF(weapon==1)
        angle=180000;
    END
    IF(weapon==2)
        angle=180000;
    END
    IF(weapon==3)
        angle=180000;
        weapon=2;
        direction=1;
    END
    life=750;

    LOOP
        x=father.x+xplus;
        y=father.y+yplus;

        IF(weapon==1)
            angle=get_angle(Player[searchplayer].player);
        END
        IF(weapon==2)
            IF(Direction==0)
                angle+=5000;
            END
            IF(Direction==1)
                angle-=5000;
            END
            IF(angle>225000)
                Direction=1;
            END
            IF(angle<135000)
                Direction=0;
            END

        END

        shotwait++;
        IF(Weapon==2)
            shotwait+=6;
        END

        IF(shotwait>50)
            Endenemy1shot(x,y,angle);
            IF(Weapon==1)
                Endenemy1shot(x,y,angle+45000);
                Endenemy1shot(x,y,angle-45000);
            END

            shotwait=0;

            searchplayer=rand(0,playersnummer);
            LOOP
                IF(Player[searchplayer].lives==-1 AND psh!=-1)
                    searchplayer=rand(0,playersnummer);
                ELSE
                    BREAK;
                END
            END

        END

        FRAME;
        IF(father.life<1)
            BREAK;
        END
        IF(life<1)
            explode(x,y,70,0);
            BREAK;
        END


    END


END


PROCESS Endenemy1shot(x,y,angle);

PRIVATE
    hit;
    counter;

BEGIN
    resolution=100;
    graph=405;
    LOOP
        FOR(Counter=0;Counter<2;Counter++)
            advance(450);
            IF(hit=(collision(TYPE ship)))
                Player[hit.nummer].killed=1;
                RETURN;
            END
        END
        FRAME;
        IF(x>80000 OR x<0 or y>60000 or y<0)
            BREAK;
        END
    END
END


PROCESS Endenemy1laser(x,y,angle);

PRIVATE
    hit;
    counter;
    dir;

BEGIN
    dir=rand(0,1);
    resolution=100;
    graph=403;
    flags=4;
    FOR(counter=0;counter<=15;counter++)
        x=father.x-2500;
        y=father.y;
        FRAME(100);
    END
    flags=0;
    counter=0;
    LOOP
        angle+=(dir*200)-100;
        x=father.x-2500;
        y=father.y;

        WHILE(hit=(collision(TYPE ship)))
            Player[hit.nummer].killed=1;
        END
        counter++;
        IF(counter>=80)
            BREAK:
        END
        FRAME;
    END
    flags=4;
    FOR(counter=0;counter<=15;counter++)
        x=father.x-2500;
        y=father.y;
        FRAME(100);
    END
END



PROCESS Endenemy1graph()

BEGIN
    resolution=100;
    graph=400;
    LOOP
        x=father.x;
        y=father.y;
        IF(father.life<1)
            BREAK;
        END

        FRAME;
    END
END



PROCESS Endenemy1shield()

PRIVATE
    unworking;
    sizing;

BEGIN
    life=1000;
    resolution=100;
    graph=402;
    LOOP
        x=father.x;
        y=father.y;
        IF(father.life<1)
            BREAK;
        END
        angle+=2500;
        IF(life<1)
            flags=4;
            FOR(size=size;size<=200;size+=10)
                x=father.x;
                y=father.y;
                angle+=5000;
                FRAME;
            END
            unworking=1;
        END
        IF(life>500 AND unworking==1)
            FOR(size=200;size>=95;size-=10)
                x=father.x;
                y=father.y;
                angle+=5000;
                FRAME;
            END
            flags=0;
            unworking=0;
        END
        IF(unworking==1)
            x=-50000;
            y=-50000;
            life+=5;
        END
        IF(sizing==0)
            size+=1;
        END
        IF(sizing==1)
            size-=1;
        END
        IF(size>120)
            sizing=1;
        END
        IF(size<95)
            sizing=0;
        END


        FRAME;
    END
END


PROCESS Endenemy1laserspec(x,y)

PRIVATE
    moving;

BEGIN
    angle=180000+rand(-30000,30000);
    resolution=100;
    Graph=406;
    advance(50*size);
    flags=4;
    LOOP
        moving+=25;
        size-=3;
        IF(get_dist(father)<1000)
            size-=9;
        ELSE
            angle=get_angle(father);
            advance(moving);

        END
        angle=0;
        FRAME;
        IF(size<5)
            BREAK;
        END
    END


END












PROCESS Explode(x,y,size,times)

BEGIN
    resolution=100;
    z=-10;
    graph=300;
    LOOP
        FRAME(100);
        IF(graph==305)
            IF(times>0)
                Explode(x+rand(-size*70,size*70),y+rand(-size*70,size*70),size-5,times-1);
            END
        END
        IF(graph==309)
            BREAK;
        END
        graph++;

    END


END










































































































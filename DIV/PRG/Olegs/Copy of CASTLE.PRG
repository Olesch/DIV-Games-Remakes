


/*
Einzubauen:
Quests//What Quests?
Manyplayermode;  //Why it's Impossible?... Because of the complex AI And the saving.
MORE ACTION! MORE FUN! MORE POSSIBILITYS! MORE CAMPAIGNS! MORE GAME!!!



Leveldata
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
            214=Falltueroeffner2Felder

    Objects:
        7=Shield++
        10=Fields, not very allowed to move (secretpassage)(Leveleditors help)
        11=SilverKey
        13=Ghost
        15=Fields, allowed to move (Leveleditors help)
        17=Ogre
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

Karte: 6x6;

        ******       900,902,904,906,908,910,   >+2
        ******       912,914,916,918,920,922,   <-2
        ******       924,926,928,930,932,934,   V+12
        ******       936,938,940,942,944,946,   ^-12
        ******       948,950,952,954,956,958,
        ******       960,962,964,966,968,970

Waytowin:900-902-904-902-904-902-914-912-914-926



DrawnCard:           S--*T-*  *  *  *
                        G
                        |
                     *-T*  *  *  *  *
                        P
                        |
                     * -*  *  *  *  *


                     *  *  *  *  *  *


                     *  *  *  *  *  *


                     *  *  *  *  *  *


        S=Start
        G=GetGoldkeyfromanothermaptopass
        T=Twoways
        P=Save Pointed with no back;
*/




PROGRAM Castle;

GLOBAL
    Stage=900;
    Campaign;//Die gespielte "Campaign"(FPG-File mit nur levels)
    STRUCT Stat[0]
        Hero_id;
        Maxlife;
        Life;
        Maxmana;
        Mana;
        Arrows;
        Defense;
        Strength;
        Strengthexp;
        Magic;
        Magicexp;
        Bow;
        Bowexp;
        Exp;
        level;
        Condition;
        maxCondition;
        Goldkeys;
        Silverkeys;

    END
    Difficulty;
    xhero;
    yhero;
    Difftext[6]="Baby","Schueler","Jugendlicher","Erwachsener","Kaempfer","Schlossherr","Diabolo";
    Otherlevel;


    /*STRUCT EditedLevel[1]
        STRUCT Xpos[39]
            Ypos[29];
        END
    END*/

LOCAL
    Life;
    Hit_Damage;
    nummer;
    weap;
    resist;

PRIVATE
    Text;

BEGIN
    Campaign=load_fpg("Olegs\Castle.fpg");
    load_fnt("Olegs\Castle.fnt");
    set_fps(24,0);
    set_mode(m800x600);
    Write(1,400,285,4,"S-Starte neues Spiel");
    Write(1,400,315,4,"L-Lade altes Spiel");

    WHILE(NOT key(_s) AND NOT key(_l))
        FRAME;
    END
    Delete_text(all_text);

        IF(key(_s))
            Write(1,400,300,5,"Schwierigkeitsstufe:");
            LOOP
                SpecEffect(400,300,rand(-180000,180000),rand(0,1)*10000-5000-difficulty*500,100+(difficulty+3)*20);
                IF(difficulty>-1)
                    SpecEffect(rand(0,800),600,rand(0,180000),rand(0,1)*10000-5000-difficulty*500,40+(difficulty+3)*20);
                END
                IF(difficulty>2)
                    SpecEffect(rand(0,800),0,rand(-180000,0),rand(0,1)*10000-5000-difficulty*500,40+(difficulty+3)*20);
                END

                text=write(1,400,300,3, Difftext[Difficulty+3]);
                FRAME(300);
                Delete_text(text);
                IF(key(_left) AND difficulty>-3)
                    difficulty--;
                END
                IF(key(_right) AND difficulty<3)
                    difficulty++;
                END
                fade((difficulty+3)*8+100,100,100,2);
                IF(key(_Enter) OR key(_Space))
                    BREAK;
                END
            END
            let_me_alone();
            fade(100,100,100,1);
        ELSE
            IF(key(_l))
                Write(1,400,285,5,"Waehle eine Nummer - 1  2  3  4");
                LOOP
                    IF(key(_1))
                        load("Saves\castle1.dat", offset stage);
                        stat[0].hero_id=Hero(_up,_down,_left,_right,_end,_del,_ins,_pgup,xhero,yhero,0);
                        EnergyLine();
                        Levelzeichner();
                        Background();
                        Statistic(0);
                        CurWeap(0);
                        RETURN();
                        Delete_text(all_text);
                    END
                    IF(key(_2))
                        load("Saves\castle2.dat", offset stage);
                        stat[0].hero_id=Hero(_up,_down,_left,_right,_end,_del,_ins,_pgup,xhero,yhero,0);
                        EnergyLine();
                        Levelzeichner();
                        Background();
                        Statistic(0);
                        CurWeap(0);
                        RETURN();
                        Delete_text(all_text);
                    END
                    IF(key(_3))
                        load("Saves\castle3.dat", offset stage);
                        stat[0].hero_id=Hero(_up,_down,_left,_right,_end,_del,_ins,_pgup,xhero,yhero,0);
                        EnergyLine();
                        Levelzeichner();
                        Background();
                        Statistic(0);
                        CurWeap(0);
                        RETURN();
                        Delete_text(all_text);
                    END
                    IF(key(_4))
                        load("Saves\castle4.dat", offset stage);
                        stat[0].hero_id=Hero(_up,_down,_left,_right,_end,_del,_ins,_pgup,xhero,yhero,0);
                        EnergyLine();
                        Levelzeichner();
                        Background();
                        Statistic(0);
                        CurWeap(0);
                        RETURN();
                        Delete_text(all_text);
                    END


                    FRAME;
                END

            END
        END


    Delete_text(all_text);



    stat[0].Maxlife=80-difficulty*10;
    stat[0].Life=10;
    stat[0].Maxmana=8-difficulty;
    stat[0].Mana=4;
    stat[0].Arrows=3;
    stat[0].Defense=2;
    stat[0].Strength=3-difficulty/2;
    stat[0].Magic=8-difficulty;
    stat[0].Bow=4-difficulty/2;
    stat[0].level=1;
    stat[0].condition=50-difficulty*8;
    stat[0].maxcondition=50-difficulty*8;


    stat[0].hero_id=Hero(_up,_down,_left,_right,_end,_del,_ins,_pgup,30,30,0);

    /*stat[0].Strength+=9;
    stat[0].Magic+=30;
    stat[0].Bow+=12;
    stat[0].exp+=10000;
    stat[0].life=stat[0].maxlife;
    stat[0].arrows=150;
    stat[0].mana=stat[0].maxmana;
    stat[0].defense=5;
    stage=914;
    stat[0].hero_id=Hero(_up,_down,_left,_right,_end,_del,_ins,_pgup,550,30,0);*/


    EnergyLine();
    Levelzeichner();
    Background();
    Statistic(0);
    CurWeap(0);


END





PROCESS Levelzeichner()


PRIVATE
    Field;
    Picture;
    Additional;

BEGIN
    LOOP
        Field=map_get_pixel(Campaign,Stage,x,y);


        SWITCH (Field)
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
                Picture=rand(111,112);
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
                Picture=101;
                map_put(0,100,Picture,x*20,y*20);
            END
            CASE 213:
                Picture=101;
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


        Field=map_get_pixel(Campaign,Stage+1,x,y);
        additional=0;
        IF(Stat[0].level>4)
            additional+=1;
        END
        IF(Stat[0].level>8)
            additional+=1;
        END
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
        IF(x>40)
            x=0;
            y++;
        END
        IF(y>30)
            RETURN;
        END

    END
END


PROCESS Background()

BEGIN
    z=10;
    graph=100;
    LOOP
//        x=400;
//        y=300;
        FRAME;
    END
END






PROCESS Hero(up,down,left,right,punch,OthWeap,run,heal,x,y,nummer)

PRIVATE
    dir;
    Movement;
    AnFaSho;
    Xinc;
    Yinc;
    Oldx;
    Oldy;
    dist;
    NoMove;
    changex;
    changey;
    Hero_id_old;
    gkold;
    skold;

BEGIN
    z=-1;
    LOOP

        stat[nummer].condition++;

        Xinc=0;
        Yinc=0;
        IF(Key(up))
            Movement++;
            dir=0;
            Yinc-=3;
        END
        IF(Key(right))
            Movement++;
            dir=1;
            Xinc+=3;
        END
        IF(Key(down))
            Movement++;
            dir=2;
            Yinc+=3;
        END
        IF(Key(left))
            Movement++;
            dir=3;
            Xinc-=3;
        END

        IF(Xinc>0 AND Yinc>0) Xinc=2; Yinc=2; Movement--; END
        IF(Xinc<0 AND Yinc>0) Xinc=-2; Yinc=2; Movement--; END
        IF(Xinc>0 AND Yinc<0) Xinc=2; Yinc=-2; Movement--; END
        IF(Xinc<0 AND Yinc<0) Xinc=-2; Yinc=-2; Movement--; END

        IF(key(run) AND stat[nummer].condition>2)
            IF(Xinc>0) Xinc++; END
            IF(Xinc<0) Xinc--; END
            IF(Yinc>0) Yinc++; END
            IF(Yinc<0) Yinc--; END
            stat[nummer].condition-=2;
        END


        /*IF((NOT Key(down)) AND (NOT Key(up)) AND (NOT Key(right)) AND (NOT Key(left)))
            Movement=1;
        END*/
        IF(Movement>20)
            Movement=1;
        END
        IF(Movement<0)
            Movement++;
        END
        IF(Movement==0)
            Movement=rand(1,20);
        END

        IF(Movement>-5 AND Movement<1)
            graph=dir*10+4;
        END
        IF(Movement>0 AND Movement<6)
            graph=dir*10+1;
        END
        IF(Movement>5 AND Movement<11)
            graph=dir*10+2;
        END
        IF(Movement>10 AND Movement<16)
            graph=dir*10+1;
        END
        IF(Movement>15 AND Movement<21)
            graph=dir*10+3;
        END

        Nomove=map_get_pixel(Campaign,Stage,x/20,y/20);
        IF(Nomove==40)
            IF(Xinc>0) XInc=1; END
            IF(Xinc<0) XInc=-1; END
            IF(Yinc>0) YInc=1; END
            IF(Yinc<0) YInc=-1; END
        END

        Oldx=x;
        Oldy=y;


        x+=XINC;


        Nomove=map_get_pixel(Campaign,Stage,x/20,y/20);
        IF(Nomove==211)
            FOR(changex=-2; changex<=2; changex+=1)
                FOR(changey=-2; changey<=2; changey+=1)
                    IF(map_get_pixel(Campaign,stage,x/20+changex,y/20+changey)==213)
                        map_put_pixel(Campaign,stage,x/20+changex,y/20+changey,212);
                        map_put(campaign,100,130,(x/20+changex)*20,(y/20+changey)*20);
                    END
                END
            END
        END
        IF(Nomove==214)
            FOR(changex=-2; changex<=2; changex+=1)
                FOR(changey=-2; changey<=2; changey+=1)
                    IF(map_get_pixel(Campaign,stage,x/20+changex,y/20+changey)==212)
                        map_put_pixel(Campaign,stage,x/20+changex,y/20+changey,213);
                        map_put(campaign,100,101,(x/20+changex)*20,(y/20+changey)*20);
                    END
                END
            END
        END
        IF(Nomove==11)
            IF(stat[nummer].Silverkeys>0)
                stat[nummer].Silverkeys--;
                map_put_pixel(Campaign,Stage,x/20,y/20,6);
                map_put(campaign,100,101,(x/20)*20,(y/20)*20);
            END
        END
        IF(Nomove==71)
            IF(stat[nummer].Goldkeys>0)
                stat[nummer].Goldkeys--;
                map_put_pixel(Campaign,Stage,x/20,y/20,6);
                map_put(campaign,100,101,(x/20)*20,(y/20)*20);
            END
        END

        IF(Nomove==22 OR Nomove==26 OR Nomove==28 OR Nomove==11 OR Nomove==71 OR Nomove==212)
            x=oldx;
        END

        WHILE(dist=Get_id(TYPE Hero))
            IF(dist!=0);
                IF(Get_dist(dist)<10 AND Get_dist(dist)!=0)
                    x=oldx;
                END
            END
        END
        WHILE(dist=Get_id(TYPE Enemy))
            IF(dist!=0);
                IF(Get_dist(dist)<10 AND Get_dist(dist)!=0)
                    x=oldx;
                END
            END
        END
        y+=Yinc;

        Nomove=map_get_pixel(Campaign,Stage,x/20,y/20);
        IF(Nomove==211)
            FOR(changex=-2; changex<=2; changex+=1)
                FOR(changey=-2; changey<=2; changey+=1)
                    IF(map_get_pixel(Campaign,stage,x/20+changex,y/20+changey)==213)
                        map_put_pixel(Campaign,stage,x/20+changex,y/20+changey,212);
                        map_put(campaign,100,130,(x/20+changex)*20,(y/20+changey)*20);
                    END
                END
            END
        END
        IF(Nomove==214)
            FOR(changex=-2; changex<=2; changex+=1)
                FOR(changey=-2; changey<=2; changey+=1)
                    IF(map_get_pixel(Campaign,stage,x/20+changex,y/20+changey)==212)
                        map_put_pixel(Campaign,stage,x/20+changex,y/20+changey,213);
                        map_put(campaign,100,101,(x/20+changex)*20,(y/20+changey)*20);
                    END
                END
            END
        END
        IF(Nomove==11)
            IF(stat[nummer].Silverkeys>0)
                stat[nummer].Silverkeys--;
                map_put_pixel(Campaign,Stage,x/20,y/20,6);
                map_put(campaign,100,101,(x/20)*20,(y/20)*20);
            END
        END
        IF(Nomove==71)
            IF(stat[nummer].Goldkeys>0)
                stat[nummer].Goldkeys--;
                map_put_pixel(Campaign,Stage,x/20,y/20,6);
                map_put(campaign,100,101,(x/20)*20,(y/20)*20);
            END
        END
        IF(Nomove==22 OR Nomove==26 OR Nomove==28 OR Nomove==11 OR Nomove==71 OR Nomove==212)
            y=oldy;
        END
        WHILE(dist=Get_id(TYPE Hero))
            IF(dist!=0);
                IF(Get_dist(dist)<10 AND Get_dist(dist)!=0)
                    y=oldy;
                END
            END
        END
        WHILE(dist=Get_id(TYPE Enemy))
            IF(dist!=0);
                IF(Get_dist(dist)<10 AND Get_dist(dist)!=0)
                    y=oldy;
                END
            END
        END

        IF(key(othweap) AND AnFaSho==0)
            Weap=(weap+1) mod 3;
            AnFaSho=1;
        END


        IF(key(heal) AND stat[nummer].mana>0 AND stat[nummer].life<stat[nummer].maxlife)
            stat[nummer].mana-=1;
            stat[nummer].life+=2;
        END

        IF(Key(punch) AND AnFaSho==0)
            IF(weap==0 AND stat[nummer].condition>10)
                Shot(x,y,dir,stat[nummer].strength,2,41,nummer);
                Movement=-4;
                Stat[nummer].condition-=10;
            END
            IF(weap==1 AND stat[0].arrows>0 AND stat[nummer].condition>5)
                Shot(x,y,dir,stat[nummer].bow,200,42,nummer);
                stat[0].arrows--;
                Stat[nummer].condition-=7;
            END
            IF(weap==2 AND stat[0].mana>0)
                Shot(x,y,dir,stat[nummer].magic,200,46,nummer);
                stat[0].mana--;
            END
            AnFaSho=1;
        END
        IF(NOT key(punch) AND NOT key(othweap))
            AnFaSho=0;
        END

        IF(Hit_Damage!=0)
            Hit_damage-=stat[nummer].Defense;
            IF(Hit_damage<1)
                Hit_damage=1;
            END
            stat[nummer].Life-=Hit_damage;
            Hit_damage=0;
        END

        IF(stat[nummer].Life<1)
            let_me_alone();
            FRAME(2400);
            FOR(Size=100; Size<2000; Size+=10)
                Blood(x,y,rand(-180000,180000),size);
                FRAME;
                angle+=15000;
            END
            exit("Bye",0);

        END
        IF(stat[nummer].life>stat[nummer].maxlife)
            stat[nummer].life=stat[nummer].maxlife;
        END
        IF(stat[nummer].mana>stat[nummer].maxmana)
            stat[nummer].mana=stat[nummer].maxmana;
        END
        IF(stat[nummer].condition>stat[nummer].maxcondition)
            stat[nummer].condition=stat[nummer].maxcondition;
        END
        IF(stat[nummer].exp>50*stat[nummer].level)
            stat[nummer].exp-=50*stat[nummer].level;
            stat[nummer].maxlife+=stat[nummer].strength/stat[nummer].level*2+1;
            stat[nummer].maxmana+=stat[nummer].magic/stat[nummer].level/2+1;
            stat[nummer].maxcondition+=stat[nummer].bow/stat[nummer].level+1;
            stat[nummer].life+=stat[nummer].strength/stat[nummer].level*2+1;
            stat[nummer].mana+=stat[nummer].magic/stat[nummer].level/2+1;
            stat[nummer].condition+=stat[nummer].bow/stat[nummer].level+1;
            stat[nummer].level++;
        END
        IF(x>790)
            Otherlevel=1;
            FRAME(200);
            Stage+=2;
            Otherlevel=0;
            Levelzeichner();
            x=30;
        END
        IF(x<10)
            Otherlevel=1;
            FRAME(200);
            Stage-=2;
            Otherlevel=0;
            Levelzeichner();
            x=770;
        END
        IF(y>590)
            Otherlevel=1;
            FRAME(200);
            Stage+=12;
            Otherlevel=0;
            Levelzeichner();
            y=30;
        END
        IF(y<10)
            Otherlevel=1;
            FRAME(200);
            Stage-=12;
            Otherlevel=0;
            Levelzeichner();
            y=570;
        END



        FRAME(100);
    END
END


PROCESS Shot(x,y,dir,strength,dist,graph,nummer);

PRIVATE
    hit;
    moved;

BEGIN
    IF(graph==41)
        graph=0;
    END
    IF(graph==42)
        graph+=dir;
    END


    FOR(dist=dist; Dist>0; Dist--)
        IF(dir==0)
            y-=6;
        END
        IF(dir==1)
            x+=6;
        END
        IF(dir==2)
            y+=6;
        END
        IF(dir==3)
            x-=6;
        END
        moved+=6;

        IF(nummer!=10)
            WHILE(Hit=Get_id(TYPE Enemy))
                IF(Hit!=0);
                    IF(Get_dist(Hit)<7)

                        IF(graph==0)
                            resist=hit.resist mod 10;
                            strength=(strength*(100-resist*10))/100;

                            stat[nummer].strengthexp+=10-resist;
                            IF(stat[nummer].strengthexp>100+difficulty*5)
                                stat[nummer].strengthexp=0;
                                stat[nummer].strength++;
                            END

                        END
                        IF(graph==46)
                            resist=(hit.resist-((hit.resist-(hit.resist mod 10)) mod 100)-(hit.resist mod 10))/100;
                            strength=(strength*(100-resist*10))/100;

                            stat[nummer].magicexp+=10-resist;
                            IF(stat[nummer].magicexp>60+difficulty*5)
                                stat[nummer].magicexp=0;
                                stat[nummer].magic++;
                            END
                        END
                        IF(graph==42 OR graph==43 OR graph==44 OR graph==45)
                            resist=((hit.resist-(hit.resist mod 10)) mod 100)/10;
                            strength=(strength*(100-resist*10))/100;

                            stat[nummer].Bowexp+=10-resist;
                            IF(stat[nummer].Bowexp>80+difficulty*5)
                                stat[nummer].Bowexp=0;
                                stat[nummer].Bow++;
                            END
                        END
                        Hit.Hit_damage+=strength;
                        IF(dir==0) Blood(x,y-6,rand(70000,110000),250-(resist*10)); END
                        IF(dir==1) Blood(x+6,y,rand(-20000,20000),250-(resist*10)); END
                        IF(dir==2) Blood(x,y+6,rand(-110000,-70000),250-(resist*10)); END
                        IF(dir==3) Blood(x-6,y,rand(-200000,-160000),250-(resist*10)); END
                        RETURN();
                    END
                END
            END
        ELSE
            WHILE(Hit=get_id(TYPE hero))
                IF(hit!=0)
                    IF(Get_dist(Hit)<7)
                        IF(dir==0) Blood(x,y-6,rand(70000,110000),150); END
                        IF(dir==1) Blood(x+6,y,rand(-20000,20000),150); END
                        IF(dir==2) Blood(x,y+6,rand(-110000,-70000),150); END
                        IF(dir==3) Blood(x-6,y,rand(-200000,-160000),150); END
                        Hit.Hit_damage+=strength;
                        RETURN;
                    END
                END
            END



        END

        hit=map_get_pixel(Campaign,Stage,x/20,y/20);
        IF(hit==22 OR hit==11 OR hit==71)
            RETURN();
        END
        IF(hit==28 AND moved>80)
            RETURN();
        END
        hit=0;
        IF(otherlevel==1)
            RETURN;
        END
        FRAME;
    END

END






PROCESS Enemy(Initgraph,Life,Strength,x,y,DefRad,expgive,weapon,resist,spec)
/*spec: 0=nothing
        1=regeneration
        2=Two Weapon Style (Bow and sword)//Start with weapon=0!
          Sword has twice the power of bow;
        3=ManaAbsorbing
        4=Wallwalking
        5=3+4

weapon:0=sword
       1=bow

resist:123
      / | \
     |  |  Schwertresistenz
     |  Bogenresistenz
     Magieresistenz

     0:Keine resistenz
     x: x*10% resistenz
     9: maximal 90% resistenz

*/
PRIVATE
    dir;
    Movement;
    AnFaSho;
    Xinc;
    Yinc;
    Oldx;
    Oldy;
    dist;
    Inix;
    Iniy;
    Nomove;
    Inilife;
    Attackwait;

BEGIN
    Inix=(x-10)/20;
    Iniy=(y-10)/20;
    Inilife=life;
    strength=(strength*(100+difficulty*10))/100;
    Life=(Life*(100+difficulty*8))/100;
    IF(spec==4 OR spec==5)
        flags=4;
    END
    LOOP
        IF(spec==2)
            IF(get_dist(stat[0].hero_id)<45 AND weapon==1)
                weapon=0;
                strength=strength*2;
            END
            IF(get_dist(stat[0].hero_id)>44 AND weapon==0)
                weapon=1;
                strength=strength/2;
            END
        END
        Xinc=0;
        Yinc=0;
        Movement++;
        angle=get_angle(stat[0].hero_id);
        IF(angle>45000 AND angle<=135000)
            dir=0;
        END
        IF(angle>-45000 AND angle<=45000)
            dir=1;
        END
        IF(angle>-135000 AND angle<=-45000)
            dir=2;
        END
        IF((angle<=180000 AND angle>135000) OR (angle>=-180000 AND angle<=-135000))
            dir=3;
        END

        IF(stat[0].hero_id.y<y)
            Yinc+=stat[0].hero_id.y-y;
            IF(Yinc<=-3)
                Yinc=-3;
            END
            IF(weapon==1)
                IF(get_dist(stat[0].hero_id)<20)
                    dir+=10;
                    Yinc=+3;
                    IF(stat[0].hero_id.x==x)
                        Xinc+=rand(-1,1);
                    END
                ELSE
                    Yinc=0;
                END
            END
        END
        IF(stat[0].hero_id.x>x)
            xinc+=stat[0].hero_id.x-x;
            IF(xinc>=3)
                xinc=+3;
            END
            IF(weapon==1)
                IF(get_dist(stat[0].hero_id)<20)
                    dir+=10;
                    Xinc=-3;
                    IF(stat[0].hero_id.y==y)
                        yinc+=rand(-1,1);
                    END
                ELSE
                    Xinc=0;
                END
            END
        END
        IF(stat[0].hero_id.y>y)
            Yinc+=stat[0].hero_id.y-y;
            IF(Yinc>=3)
                Yinc=3;
            END
            IF(weapon==1)
                IF(get_dist(stat[0].hero_id)<20)
                    dir+=10;
                    Yinc=-3;
                    IF(stat[0].hero_id.x==x)
                        Xinc+=rand(-1,1);
                    END
                ELSE
                    Yinc=0;
                END
            END
        END
        IF(stat[0].hero_id.x<x)
            xinc+=stat[0].hero_id.x-x;
            IF(xinc<=-3)
                xinc=-3;
            END
            IF(weapon==1)
                IF(get_dist(stat[0].hero_id)<20)
                    dir+=10;
                    Xinc=+3;
                    IF(stat[0].hero_id.y==y)
                        yinc+=rand(-1,1);
                    END
                ELSE
                    Xinc=0;
                END
            END

        END

        IF(dir>9)
            dir=((dir mod 10)+2) mod 4;
        END

        IF(weapon==1 AND get_dist(stat[0].hero_id)>25 AND Xinc==0 AND Yinc==0)
            //"Event" Zum Zielen der Bogenschuetzen
            IF(stat[0].hero_id.x-x>0 AND stat[0].hero_id.x-x<11)
                IF(stat[0].hero_id.x-x>2)
                    Xinc=3;
                ELSE
                    Xinc=1;
                END
            END
            IF(stat[0].hero_id.y-y>0 AND stat[0].hero_id.y-y<11)
                IF(stat[0].hero_id.y-y>2)
                    Yinc=3;
                ELSE
                    Yinc=1;
                END
            END
            IF(stat[0].hero_id.x-x<0 AND stat[0].hero_id.x-x>-11)
                IF(stat[0].hero_id.x-x<-2)
                    Xinc=-3;
                ELSE
                    Xinc=-1;
                END
            END
            IF(stat[0].hero_id.y-y<0 AND stat[0].hero_id.y-y>-11)
                IF(stat[0].hero_id.y-y<-2)
                    Yinc=-3;
                ELSE
                    Yinc=-1;
                END
            END


        END



        IF(dir==0) Angle=90000; END
        IF(dir==1) Angle=0; END
        IF(dir==2) Angle=-90000; END
        IF(dir==3) Angle=180000; END


        IF(Xinc>2 AND Yinc>2) Xinc=2; Yinc=2; END
        IF(Xinc<-2 AND Yinc>2) Xinc=-2; Yinc=2; END
        IF(Xinc>2 AND Yinc<-2) Xinc=2; Yinc=-2; END
        IF(Xinc<-2 AND Yinc<-2) Xinc=-2; Yinc=-2; END
        IF(get_dist(stat[0].hero_id)<15 AND weapon==0)
            Xinc=Xinc/2;
            Yinc=Xinc/2;
        END

        IF(get_dist(stat[0].hero_id)>defrad+rand(-10,10))
            Xinc=0;
            Yinc=0;
            Movement--;
        END


        IF(Movement>20)
            Movement=1;
        END
        IF(Movement<0)
            Movement++;
        END
        IF(Movement==0)
            Movement=rand(1,20);
        END

        IF(Movement>-5 AND Movement<1)
            graph=Initgraph+3;
        END

        IF(Movement>0 AND Movement<6)
            graph=Initgraph;
        END
        IF(Movement>5 AND Movement<11)
            graph=1+Initgraph;
        END
        IF(Movement>10 AND Movement<16)
            graph=Initgraph;
        END
        IF(Movement>15 AND Movement<21)
            graph=2+Initgraph;
        END


        IF(rand(0,8)==0 AND Attackwait>11)
            IF(weapon==1 AND get_dist(stat[0].hero_id)>19 AND
                (stat[0].hero_id.y<y-11 XOR stat[0].hero_id.y>y+11 XOR
                 stat[0].hero_id.x<x-11 XOR stat[0].hero_id.x>x+11))

                Shot(x,y,dir,strength,800,42,10);
                Movement=-4;
                Attackwait=0;
            END
            IF(weapon==0 AND get_dist(stat[0].hero_id)<18)
                IF(dir==0) Blood(stat[0].hero_id.x,stat[0].hero_id.y,rand(70000,110000),150); END
                IF(dir==1) Blood(stat[0].hero_id.x,stat[0].hero_id.y,rand(-20000,20000),150); END
                IF(dir==2) Blood(stat[0].hero_id.x,stat[0].hero_id.y,rand(-110000,-70000),150); END
                IF(dir==3) Blood(stat[0].hero_id.x,stat[0].hero_id.y,rand(-200000,-160000),150); END
                stat[0].hero_id.Hit_damage+=strength;
                Movement=-4;
                Attackwait=0;
                IF((spec==3 OR spec==5) AND stat[0].mana>2)
                    stat[0].mana-=3;
                END

            END
        END

        Attackwait++;



        Nomove=map_get_pixel(Campaign,Stage,x/20,y/20);
        IF(Nomove==40)
            IF(Xinc>0) XInc=1; END
            IF(Xinc<0) XInc=-1; END
            IF(Yinc>0) YInc=1; END
            IF(Yinc<0) YInc=-1; END
        END


        Oldx=x;
        Oldy=y;

        x+=Xinc;
        Nomove=map_get_pixel(Campaign,Stage,x/20,y/20);
        IF(Nomove==22 OR Nomove==26 OR Nomove==28 OR Nomove==11 OR Nomove==71 OR Nomove==212)
            IF(spec!=4 AND spec!=5)
                x=oldx;
            END
        END
        WHILE(dist=Get_id(TYPE Hero))
            IF(dist!=0);
                IF(Get_dist(dist)<10 AND Get_dist(dist)!=0)
                    x=oldx;
                END
            END
        END
        WHILE(dist=Get_id(TYPE Enemy))
            IF(dist!=0);
                IF(Get_dist(dist)<10 AND Get_dist(dist)!=0)
                    x=oldx;
                END
            END
        END
        y+=Yinc;
        Nomove=map_get_pixel(Campaign,Stage,x/20,y/20);
        IF(Nomove==22 OR Nomove==26 OR Nomove==28 OR Nomove==11 OR Nomove==71 OR Nomove==212)
            IF(spec!=4 AND spec!=5)
                y=oldy;
            END
        END
        WHILE(dist=Get_id(TYPE Hero))
            IF(dist!=0);
                IF(Get_dist(dist)<10 AND Get_dist(dist)!=0)
                    y=oldy;
                END
            END
        END
        WHILE(dist=Get_id(TYPE Enemy))
            IF(dist!=0);
                IF(Get_dist(dist)<10 AND Get_dist(dist)!=0)
                    y=oldy;
                END
            END
        END

        IF(Hit_Damage!=0)
            Life-=Hit_damage;
            Hit_damage=0;
            Defrad=5000;
        END

        IF(Life<1)
            Blood(x,y,rand(-180000,180000),250);
            Blood(x,y,rand(-180000,180000),250);
            Blood(x,y,rand(-180000,180000),250);
            stat[0].exp+=expgive;
            map_put_pixel(Campaign,Stage+1,inix,iniy,0);
            IF(weapon==1 OR spec==2)
                Potion(66,rand(1,3),x,y);
                //map_put_pixel(Campaign,Stage+1,inix,iniy,118);
                //Causes errors, Arrows appear twice
            END
            RETURN;
        END
        IF(spec==1 AND Life<Inilife)
            IF(rand(0,5)==0)
                life++;
            END
        END


        IF(otherlevel==1)
            RETURN;
        END


        FRAME;
    END
END


PROCESS Blood(x,y,angle,Power)

BEGIN
    Flags=4;
    graph=50;
    FOR(size=5; Size<Power; Size+=20)
        FRAME;
    END

END




PROCESS Energyline()

BEGIN
    graph=51;
    LOOP
        x=(stat[0].life*800)/(stat[0].maxlife)-800;
        y=-10;
        FRAME;
    END
END



PROCESS Potion(graph,Healpower,x,y);

PRIVATE
    hit;
    Inix;
    Iniy;

BEGIN
    Inix=(x-10)/20;
    Iniy=(y-10)/20;

    LOOP
        IF(hit=collision(TYPE Hero))
            IF(graph==60 AND stat[hit.nummer].life<stat[hit.nummer].maxlife)
                stat[hit.nummer].life+=Healpower;
                map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                RETURN();
            END
            IF(graph==61 AND stat[hit.nummer].life<stat[hit.nummer].maxlife)
                stat[hit.nummer].life+=stat[hit.nummer].maxlife*Healpower/100;
                map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                RETURN();
            END
            IF(graph==63 AND stat[hit.nummer].mana<stat[hit.nummer].maxmana)
                stat[hit.nummer].mana+=Healpower;
                map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                RETURN();
            END
            IF(graph==64 AND stat[hit.nummer].mana<stat[hit.nummer].maxmana)
                stat[hit.nummer].mana+=stat[hit.nummer].maxmana*Healpower/100;
                map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                RETURN();
            END
            IF(graph==66)
                stat[hit.nummer].arrows+=Healpower;
                map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                RETURN();
            END
            IF(graph==67)
                stat[hit.nummer].arrows+=Healpower;
                map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                RETURN();
            END
            IF(graph==69)
                stat[hit.nummer].defense+=1;
                map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                RETURN();
            END
            IF(graph==74)
                stat[hit.nummer].mana=stat[hit.nummer].maxmana;
                stat[hit.nummer].life=stat[hit.nummer].maxlife;
                map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                RETURN();
            END
            IF(graph==127)
                stat[hit.nummer].Goldkeys+=1;
                map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                RETURN();
            END
            IF(graph==128)
                stat[hit.nummer].Silverkeys+=1;
                map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                RETURN();
            END
            IF(graph==72 AND key(_control))
                xhero=stat[hit.nummer].hero_id.x;
                yhero=stat[hit.nummer].hero_id.y;
                IF(key(_1))
                    save("Saves\castle1.dat", offset stage, sizeof(stage)+sizeof(campaign)+sizeof(stat)+sizeof(Difficulty)+sizeof(xhero)+sizeof(yhero));
                    map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                    RETURN();
                END
                IF(key(_2))
                    save("Saves\castle2.dat", offset stage, sizeof(stage)+sizeof(campaign)+sizeof(stat)+sizeof(Difficulty)+sizeof(xhero)+sizeof(yhero));
                    map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                    RETURN();
                END
                IF(key(_3))
                    save("Saves\castle3.dat", offset stage, sizeof(stage)+sizeof(campaign)+sizeof(stat)+sizeof(Difficulty)+sizeof(xhero)+sizeof(yhero));
                    map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                    RETURN();
                END
                IF(key(_4))
                    save("Saves\castle4.dat", offset stage, sizeof(stage)+sizeof(campaign)+sizeof(stat)+sizeof(Difficulty)+sizeof(xhero)+sizeof(yhero));
                    map_put_pixel(Campaign,Stage+1,inix,iniy,0);
                    RETURN();
                END
            END
        END
        IF(otherlevel==1)
            RETURN;
        END
        FRAME;
    END

END




PROCESS Statistic(nummer)

PRIVATE
    Text[12];
    Counter;



BEGIN
    z=-10;
    x=400;
    y=0;
    LOOP
        IF(Key(_pgdn))
            graph=54;
            Text[0]=Write_int(1,121+x,61+y,5,OFFSET stat[nummer].life);
            Text[1]=Write_int(1,136+x,61+y,3,OFFSET stat[nummer].maxlife);
            Text[2]=Write_int(1,121+x,96+y,5,OFFSET stat[nummer].Mana);
            Text[3]=Write_int(1,136+x,96+y,3,OFFSET stat[nummer].maxMana);
            Text[4]=Write_int(1,121+x,128+y,5,OFFSET stat[nummer].arrows);
            Text[5]=Write_int(1,121+x,166+y,5,OFFSET stat[nummer].defense);
            Text[10]=Write_int(1,119+x,210+y,5,OFFSET stat[nummer].Condition);
            Text[11]=Write_int(1,135+x,210+y,3,OFFSET stat[nummer].maxCondition);

            Text[6]=Write_int(1,250+x,56+y,3,OFFSET stat[nummer].strength);
            Text[7]=Write_int(1,250+x,95+y,3,OFFSET stat[nummer].magic);
            Text[8]=Write_int(1,250+x,127+y,3,OFFSET stat[nummer].bow);
            Text[9]=Write_int(1,250+x,168+y,3,OFFSET stat[nummer].exp);
            Text[12]=Write_int(1,250+x,210+y,3,OFFSET stat[nummer].level);
        END
        WHILE(Key(_pgdn))
            FOR(counter=0; counter<stat[nummer].goldkeys; counter++)
                Picture(127,x+counter*10+40,y+250);
            END
            FOR(counter=0; counter<stat[nummer].silverkeys; counter++)
                Picture(128,x+counter*10+40,y+265);
            END
            FRAME;
        END
        graph=0;
        FOR(counter=0; Counter<13; Counter++)
            delete_text(Text[counter]);
        END

        WHILE(NOT Key(_pgdn))
            FRAME;
        END
        IF(stat[nummer].hero_id.x>400 AND stat[nummer].hero_id.y<300)
            x=0;
            y=300;
        ELSE
            x=400;
            y=0;
        END

    END

END

PROCESS Picture(graph,x,y);

BEGIN
    z=-15;
    FRAME;
END



PROCESS CurWeap(nummer)

BEGIN
    x=15;
    y=25;
    LOOP
        graph=55+stat[nummer].hero_id.weap;
        IF(stat[nummer].hero_id.weap==1)
            IF(stat[nummer].arrows<1)
                flags=4;
            END
        END
        IF(stat[nummer].hero_id.weap==2)
            IF(stat[nummer].mana<1)
                flags=4;
            END
        END

        FRAME;
        flags=0;
    END

END


PROCESS SpecEffect(x,y,angle,angpl,size)

BEGIN
    flags=4;
    graph=99;
    FOR(size=size; size>0; Size-=3)
        FRAME;
        advance(8);
        angle+=angpl;
    END
END











//****************************************************************************//
//               Minicosm                                                     //
//                     Nach dem Vorbild Microcosm                             //
//                              Von Oleg Yuschuk                              //
//****************************************************************************//

PROGRAM Minicosm;

GLOBAL
    secondPlayer;
    fpsa=60;      //FPS Variabeln
    fpsb=0;        //
    Fadenkreuz_id; //Selbsterklaerend
    RightShootMunition=2;
    LeftShootMunition=2;
    RightShootMunitionMax=2;
    KanonsCost=80;
    LeftShootMunitionMax=2;
    Money=250;
    SuperRocket;
    Schwierigkeitplus;
    Supermeteore;
    BirdsAmount;
    PotionsAmount;
    VogelZucht;
    NachLadeZeit;
    TraenkeVerb;
    ElektroMagnet;
    Difficulty=3;
    AtomBombe;
    AtomKosten=300;

LOCAL
    xincr;
    yincr;
    Art;              //Welcher Art gehoert der Meteor an?
                      //Muss zur Lokal Data, damit Blaue Raketen funktionieren.


BEGIN
    load_fpg("Olegs\Minicosm.fpg");  // Loads graphics' file
    load_fnt("Olegs\Minicosm.fnt");  // Loads graphics' file
    set_mode(m1024x768);             // Sets video mode to 640x480
    set_fps(24,0);                  // Number of frames per second
    x=1024/2;
    y=768/2;
    graph=100;

    Write_Int(0,653,755,6,OFFSET Difficulty);

    LOOP
        IF((key(_right) OR key(_plus)) AND Difficulty<5)
            Difficulty++;
        END
        IF((key(_left) OR key(_minus)) AND Difficulty>1)
            Difficulty--;
        END


        IF(key(_enter) OR key(_space) OR key(_esc) OR (mouse.left AND mouse.right))
            graph=0;
            delete_text(all_text);
            BREAK;
        END
        FRAME(100);
    END
    KanonsCost=80-(20*(difficulty-3));
    AtomKosten=300-(50*(difficulty-3));



    Fadenkreuz_id=Fadenkreuz();
    Canonleft();
    Canonleftfr();
    Canonleftbe();
    Canonright();
    Canonrightfr();
    Canonrightbe();
    Duk();
    Duk();
    Duk();
    Kaufmenu();
    Schwerer();
    Meteorenlos();
    MunitionsZeiger(1,0);
    MunitionsZeiger(1,1);
    KaufMenuKnoepfe(200);
    KaufMenuKnoepfe(201);
    KaufMenuKnoepfe(202);
    KaufMenuKnoepfe(203);
    KaufMenuKnoepfe(204);
    KaufMenuKnoepfe(210);
    KaufMenuKnoepfe(211);
    KaufMenuKnoepfe(214);
    KaufMenuKnoepfe(215);
    KaufMenuKnoepfe(216);
    KaufMenuKnoepfe(217);
    KaufMenuKnoepfe(218);

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
            Write_Int(0,290,50,4,OFFSET fpsa);
            Write_Int(0,350,50,4,OFFSET fpsb);
        END
        FRAME;

    END

END







PROCESS Duk()

PRIVATE
    Walkdir;                    //1=right,0=stand,-1=left
    Walkdircount;               //Counts until change Direction
    Graphcount;                 //Counts until change Graphic
    MovingSpeed;                //How fast does he move?
    Object_hit;                 //Object hit it
    Super;                      //Is he a superduk?
    Meteor_warning;             //Is there a nearby meteor?
    counter;                    //counting.

BEGIN
    graph=1;
    x=rand(0,1)*1024;
    y=rand(700,720);
    z-=y-690;
    LOOP
        Walkdircount++;
        IF(Walkdircount>rand(50,100))
            Walkdircount=0;
            Walkdir=rand(-1,1);
            Movingspeed=rand(1,2);
            money+=3;
            IF(difficulty>3)
                money+=difficulty-3;
            END
            IF(super==1)
                money+=5+difficulty-3;
            END
        END

        IF(Walkdir==1)
            flags=0;
            x+=Movingspeed;
        END
        IF(Walkdir==-1)
            flags=1;
            x-=Movingspeed;
        END
        IF(Walkdir==0)
            Walkdircount++;
            graphcount=14;
        END
        IF(x>874)
            Walkdir=-1;
        END
        IF(x<150)
            Walkdir=1;
        END

        IF(super==1) //wegrennen
            FROM counter=1 TO 50;
                // We take the processes' identifiers
                Meteor_warning=get_id(TYPE Meteor);
                IF(get_dist(Meteor_warning)<150)
                    IF(Meteor_warning.x+(Meteor_warning.xincr*Meteor_warning.yincr*2)-x>0)
                        Walkdir=-1;
                        Movingspeed=3;
                    ELSE
                        Walkdir=1;
                        Movingspeed=3;
                    END
                END

            END


        END



        graphcount=graphcount MOD 15;
        graphcount+=1;

        IF(graphcount<8)
            graph=2+(6*super);
        ELSE
            graph=1+(6*super);
        END


        IF(Object_hit=collision(TYPE Meteor))
            explosion(Object_hit.x,Object_hit.y,100);
            signal(Object_hit,s_kill);
            IF(super==0)
                BREAK;
            ELSE
                PotionsAmount--;
                Super=0;
            END

        END

        IF(super==0)
            IF(Object_hit=collision(TYPE Potion))
                signal(Object_hit,s_kill);
                super=1;
            END
        END

        IF(key(_s) AND key(_u) AND key(_p) )
            super=1;
        END
        IF(key(_t) AND key(_a) AND key(_x) )
            money=10000;
        END
        IF(key(_a) AND key(_r) AND key(_m) )
            Schwierigkeitplus=3500;
            Supermeteore=3;
        END



        FRAME;
    END
    graph=3;
    FRAME(400);
    graph=4;
    FRAME(400);
    graph=5;
    FRAME(400);
    graph=6;
    FRAME(400);



END


PROCESS Meteorenlos()

BEGIN
    LOOP
        Meteor(rand(0,1024),rand(-3,3),rand(3,6-(difficulty-3)),rand(-25000,25000),rand(0,Supermeteore));
        FRAME(rand(5200+200*(difficulty-3),7200-(Schwierigkeitplus/5)+300*(difficulty-3))-Schwierigkeitplus);
    END
END





PROCESS Canonleft()

PRIVATE
    count;
    ANTIFASTCLICK;        //0=SHOOT 1=Don't SHOOT


BEGIN
    x=0;
    y=768;
    graph=12;
    z=-2;
    LOOP
        angle=get_angle(Fadenkreuz_id);
        IF(mouse.left AND mouse.y>60 AND LeftShootMunition>=1 AND ANTIFASTCLICK==0)
            LeftShootMunition--;
            shot(x,y,angle,SuperRocket,0);
            ANTIFASTCLICK=1;
            FRAME;

        END
        IF(NOT mouse.left)
            ANTIFASTCLICK=0;
        END


        FRAME;



    END

END

PROCESS Canonleftfr()

BEGIN
    x=0;
    y=768;
    graph=11;
    z=-3;
    LOOP
        IF(LeftShootMunition<LeftShootMunitionMax)
            FRAME(8000-LeftShootMunitionMax*750-Nachladezeit*500-250*(difficulty-3));
            LeftShootMunition++;
        END
        FRAME;
    END

END

PROCESS Canonleftbe()

BEGIN
    x=0;
    y=768;
    graph=10;
    z=3;
    LOOP
      FRAME;
    END

END


PROCESS Canonright()

PRIVATE
    count;
    ANTIFASTCLICK;        //0=SHOOT 1=Don't SHOOT

BEGIN
    x=1024;
    y=768;
    graph=12;
    z=-2;
    LOOP
        angle=get_angle(Fadenkreuz_id);
        IF(mouse.right AND RightShootMunition>=1 AND ANTIFASTCLICK==0)
            RightShootMunition--;
            shot(x,y,angle,SuperRocket,0);
            ANTIFASTCLICK=1;

            FRAME;
        END
        IF(NOT mouse.right)
            ANTIFASTCLICK=0;
        END

      FRAME;

    END

END

PROCESS Canonrightfr()

BEGIN
    x=1024;
    y=768;
    graph=16;
    z=-3;
    LOOP
        IF(RightShootMunition<RightShootMunitionMax)
            FRAME(8000-RightShootMunitionMax*750-Nachladezeit*500-250*(difficulty-3));
            RightShootMunition++;
        END
        FRAME;
    END

END

PROCESS Canonrightbe()

BEGIN
    x=1024;
    y=768;
    graph=15;
    z=3;
    LOOP
      FRAME;
    END

END


PROCESS Fadenkreuz()
BEGIN
  graph=19;
  z=-512;
  LOOP
    x=mouse.x;
    y=mouse.y;
    FRAME;
  END
END



PROCESS Shot(x,y,angle,Art,pl);

PRIVATE
    counter;
    Meteor_chasing;
    EMStop;

BEGIN
    z=-1;
    EMStop=Elektromagnet*16;
    graph=20+Art;
    IF(pl==0)
        advance(190);
    END
    WHILE (NOT out_region(id,0))
        advance(10);
        IF(Art>=1)
            advance(10);
        END
        EMStop--;
        IF(Art>=2 AND EMStop<0)
            FROM counter=1 TO 50;
                // We take the processes' identifiers
                Meteor_chasing=get_id(TYPE Meteor);
                IF(Meteor_chasing!=0)
                    IF(get_dist(Meteor_chasing)<150 AND (Meteor_chasing.Art==1 OR Meteor_chasing.Art==3 OR Meteor_chasing.Art==4))
                        angle=near_angle(angle,get_angle(Meteor_chasing),7000);
                    END
                END
            END

        END
        IF(Art==2)
            graph=22;
        END
        FRAME;
    END
END



PROCESS Meteor(x,xincr,yincr,angleincr,Art)
/*
ART: 0=Normal-Meteor
     1=Eisen-Meteor
     2=Doppel-Meteor
     3=Doppel-Eisenmeteor
     4=Doppel-Eisenmeteor Cracks


*/
PRIVATE
    Object_hit;       //Object hit it


BEGIN
    graph=25+Art;
    angle=rand(-180000,180000);
    WHILE (NOT out_region(id,0))
        x+=xincr;
        y+=yincr;
        angle+=angleincr;
        IF(AtomBombe==1)
            shot(x,y,0,1,1);
        END

        Object_hit=collision(TYPE shot);
        IF(Object_hit==0)
            Object_hit=collision(TYPE bird);
        END
        IF(Object_hit!=0)
            IF(Object_hit.Art==3)
                Object_hit.Art=2;
            ELSE
                signal(Object_hit,s_kill);
            END
            IF(Object_hit.Art==100)
                BirdsAmount--;
            END

            IF(Art==0)
                explosion(x,y,100);
                BREAK;
            ELSE
                IF(Art==1)
                    explosion(x,y,100);
                    Art=0;
                    graph=25;
                ELSE
                    IF(Art==2)
                        explosion(x,y,175);
                        Art=0;
                        graph=25;
                        xincr=rand(-3,3);
                        CLONE
                            angle=rand(-180000,180000);
                            angleincr=rand(-25000,25000);
                            xincr=-xincr;
                        END
                    ELSE
                        IF(Art==3)
                            explosion(x,y,200);
                            Art=4;
                            graph=29;
                        ELSE
                            explosion(x,y,175);
                            Art=1;
                            graph=26;
                            xincr=rand(-3,3);
                            CLONE
                                angle=rand(-180000,180000);
                                angleincr=rand(-25000,25000);
                                xincr=-xincr;
                            END
                        END
                    END
                END
            END

        END
        IF(y>710)
            explosion(x,y,100);
            BREAK;
        END


        FRAME;

    END
END


PROCESS Explosion(x,y,size)

BEGIN
    graph=30;
    FRAME;
    graph=31;
    FRAME;
    graph=32;
    FRAME;
    graph=33;
    FRAME;
    graph=34;
    FRAME;
END



PROCESS Kaufmenu();

PRIVATE
    ANTIFASTCLICK;        //0=Buy 1=Don't buy

BEGIN

    write_int(1,1024,0,2,OFFSET Money);
    write(1,904,0,2,"$");


    /*z=-50;
    graph=35;
    size=200;*/
    LOOP
        IF(mouse.left AND mouse.y<61 AND ANTIFASTCLICK==0)
            IF(mouse.x<60 AND Money>=KanonsCost AND LeftShootMunitionMax<6)
                LeftShootMunitionMax++;
                Money-=KanonsCost;
                KanonsCost+=20;
            END

            IF(mouse.x>60 AND mouse.x<120 AND Money>=KanonsCost AND RightShootMunitionMax<6)
                RightShootMunitionMax++;
                Money-=KanonsCost;
                KanonsCost+=20;
            END

            IF(mouse.x>120 AND mouse.x<180 AND Money>=150-25*(difficulty-3))
                Duk();
                Money-=150-25*(difficulty-3);
            END
            IF(mouse.x>180 AND mouse.x<240 AND Money>=400 AND PotionsAmount<3+TraenkeVerb*3)
                Potion();
                Money-=400;
                PotionsAmount++;
            END
            IF(mouse.x>240 AND mouse.x<300 AND Money>=BirdsAmount*(20-VogelZucht*15)+50 AND BirdsAmount<10+Vogelzucht*10)
                Bird(100);
                Money-=BirdsAmount*(20-VogelZucht*15)+50;
                BirdsAmount++;
            END
            IF(mouse.x>300 AND mouse.x<360 AND Money>=AtomKosten)
                Money-=AtomKosten;
                LeftshootMunition=LeftshootMunitionMax;
                RightshootMunition=RightshootMunitionMax;
                AtomBombe=1;
                Atom();
                AtomKosten+=100;
            END
            IF(mouse.x>480 AND mouse.x<540 AND Money>=5000 AND SecondPlayer==0)
                SecondPlayer=1;
                PlayerTwo();
                Money-=3000;
            END
            IF(mouse.x>540 AND mouse.x<600 AND Money>=3000 AND Nachladezeit==1)
                Nachladezeit=2;
                Money-=3000;
            END
            IF(mouse.x>540 AND mouse.x<600 AND Money>=1500 AND Nachladezeit==0)
                Nachladezeit=1;
                Money-=1500;
            END
            IF(mouse.x>600 AND mouse.x<660 AND Money>=2500 AND Superrocket==2)
                SuperRocket=3;
                Money-=2500;
                LeftShootMunitionMax-=3;
                RightShootMunitionMax-=3;

            END
            IF(mouse.x>600 AND mouse.x<660 AND Money>=1200 AND Superrocket==1)
                SuperRocket=2;
                Money-=1200;
                LeftShootMunitionMax-=3;
                RightShootMunitionMax-=3;

            END
            IF(mouse.x>600 AND mouse.x<660 AND Money>=800 AND Superrocket==0)
                SuperRocket=1;
                Money-=800;
                LeftShootMunitionMax-=2;
                RightShootMunitionMax-=2;

            END
            IF(mouse.x>660 AND mouse.x<720 AND Money>=1000 AND Vogelzucht==0)
                VogelZucht=1;
                Money-=1000;

            END
            IF(mouse.x>720 AND mouse.x<780 AND Money>=3000 AND TraenkeVerb==0)
                TraenkeVerb=1;
                Money-=3000;

            END
            IF(mouse.x>780 AND mouse.x<840 AND Money>=750 AND ElektroMagnet==0)
                ElektroMagnet=1;
                Money-=750;

            END
            ANTIFASTCLICK=1;


        END
        IF(NOT mouse.left)
            ANTIFASTCLICK=0;
        END

        FRAME;
    END
END

PROCESS KaufMenuKnoepfe(graph)

PRIVATE
    KostenText;
    KostenVar;

BEGIN
    z=-51;
    y=45;
    IF(graph==200)
        x=30;
    END
    IF(graph==201)
        x=90;
    END
    IF(graph==202)
        x=150;
        KostenVar=150-25*(difficulty-3);
    END
    IF(graph==203)
        x=210;
        KostenVar=400;
    END
    IF(graph==211)
        x=270;
        KostenVar=50;
    END
    IF(graph==204)
        x=330;
        KostenVar=AtomKosten;
    END
    IF(graph==215)
        x=570;
        KostenVar=1500;
    END
    IF(graph==210)
        x=630;
        KostenVar=800;
    END
    IF(graph==214)
        x=690;
        KostenVar=1000;
    END
    IF(graph==216)
        x=750;
        KostenVar=3000;
    END
    IF(graph==217)
        x=810;
        KostenVar=750;
    END
    IF(graph==218)
        x=510;
        KostenVar=5000;
    END

    KostenText=write_int(0,x,y+30,4,OFFSET KostenVar);



    LOOP
        IF(Money<KostenVar)
            flags=4;
        ELSE
            flags=0;
        END
        IF(graph==200 OR graph==201)
            KostenVar=KanonsCost;
            IF(graph==200)
                IF(LeftShootMunitionMax>=6)
                    flags=4;
                END
            ELSE
                IF(RightShootMunitionMax>=6)
                    flags=4;
                END
            END
        END
        IF(Graph==211)
            IF(BirdsAmount>9+Vogelzucht*10)
                flags=4;
            END
            KostenVar=BirdsAmount*(20-VogelZucht*15)+50;
        END
        IF(Graph==203)
            IF(PotionsAmount>2+TraenkeVerb*3)
                flags=4;
            END
        END
        IF(Graph==210 AND superrocket>0)
            graph=212;
            KostenVar=1200;
        END
        IF(Graph==212 AND superrocket>1)
            graph=213;
            KostenVar=2500;
        END
        IF(graph==204)
            KostenVar=AtomKosten;
        END
        IF(Graph==213 AND superrocket>2)
            delete_text(KostenText);
            BREAK;
        END
        IF(Graph==214 AND Vogelzucht==1)
            delete_text(KostenText);
            BREAK;
        END
        IF(Graph==215 AND Nachladezeit==1)
            KostenVar=3000;
        END
        IF(Graph==215 AND Nachladezeit==2)
            delete_text(KostenText);
            BREAK;
        END
        IF(Graph==216 AND TraenkeVerb==1)
            delete_text(KostenText);
            BREAK;
        END
        IF(Graph==217 AND ElektroMagnet==1)
            delete_text(KostenText);
            BREAK;
        END
        IF(graph==217 AND SuperRocket<2)
            y=-100;
            delete_text(KostenText);
        ELSE
            IF(y!=45)
                y=45;
                KostenText=write_int(0,x,y+30,4,OFFSET KostenVar);
            END
        END
        IF(Graph==218)
            delete_text(KostenText);
            KostenText=write_int(0,x,y+30,4,OFFSET KostenVar);
        END
        IF(Graph==218 AND secondPlayer==1)
            delete_text(KostenText);
            BREAK;
        END




        FRAME;
    END
END


PROCESS Bird(Art)

PRIVATE
    Walkdir;                    //1=right,-1=left
    Graphcount;                 //Counts until change Graphic
    Object_hit;                 //Object hit it

BEGIN
    graph=36;
    x=rand(0,1)*1029;
    y=rand(650,670);
    z-=y-700;
    xincr=rand(3,5);
    //Art=100;

    LOOP
        IF(Walkdir==1)
            flags=0;
            x+=xincr;
        END
        IF(Walkdir==-1)
            flags=1;
            x-=xincr;
        END
        IF(x>874)
            Walkdir=-1;
            xincr=rand(3,5);
        END
        IF(x<150)
            Walkdir=1;
            xincr=rand(3,5);
        END


        graphcount=graphcount MOD 15;
        graphcount+=1;

        IF(graphcount<8)
            graph=37;
        ELSE
            graph=36;
        END
        FRAME;
    END
END


PROCESS Potion()


BEGIN
    x=rand(200,824);
    graph=38;
    FROM y=600 TO 710 STEP 3;
        FRAME;
    END
    LOOP
        FRAME;
    END


END

PROCESS Schwerer();

BEGIN
    LOOP
        Schwierigkeitplus++;
        FRAME(200);
        IF(Schwierigkeitplus>1200)
            FRAME;
        END
        IF(Schwierigkeitplus>2400)
            FRAME;
        END
        IF(Schwierigkeitplus>3600)
            FRAME;
        END
        IF(Schwierigkeitplus>4000)
            Schwierigkeitplus=1200+Supermeteore*400;
            IF(Supermeteore==2)
                SuperMeteore=3;
            END
            IF(Supermeteore==1)
                SuperMeteore=2;
            END
            IF(Supermeteore==0)
                SuperMeteore=1;
            END
        END
    END
END


PROCESS MunitionsZeiger(Nummer,Seite)

BEGIN
    IF(Seite==0)     //0=Links, 1=Rechts
        x=30;
    ELSE
        x=994;
    END
    y=568-Nummer*30;
    z=-5;


    IF(Nummer<6)
        MunitionsZeiger(Nummer+1,Seite);
    END

    LOOP
        IF(Seite==0)
            IF(LeftShootMunitionMax<Nummer)
                graph=0;
            ELSE
                IF(LeftShootMunition<Nummer)
                    graph=17;
                ELSE
                    graph=18;
                END

            END
        END
        IF(Seite==1)
            IF(RightShootMunitionMax<Nummer)
                graph=0;
            ELSE
                IF(RightShootMunition<Nummer)
                    graph=17;
                ELSE
                    graph=18;
                END

            END
        END



        FRAME;


    END
END


PROCESS PlayerTWO()
PRIVATE
    velocity;
    shotWait;

BEGIN
    x=512;
    y=768/2;
    graph=13;
    PLTWOUP();
    LOOP
        // Checks if left or right key are pressed
        // And modifies angles if they are so
        IF (key(_left)) angle=angle+10000; END
        IF (key(_right)) angle=angle-10000; END
        // If up key is pressed, the ship advances

        IF (key(_up)) IF(velocity<9) velocity++; END END

        IF (key(_down)) IF(velocity>-6) velocity--; END END

        advance(velocity);

        // If control key is pressed, creates a shot type process
        IF (key(_control) AND shotwait<0)
            shot(x,y,angle,superRocket,1);
            shotWait=45-Nachladezeit*6;
        END
        shotwait--;
        // Finds new coordinates, so the ship reappears on screen
        new_coordinates();
        FRAME;  // Prints ship's graphic on screen

    END

END

PROCESS PLTWOUP()

BEGIN
    z=-2;
    graph=14;
    LOOP
        x=father.x;
        y=father.y;
        angle=father.angle;
        FRAME;
    END

END

PROCESS Atom()

BEGIN
    explosion(512,768/2,1200);
    FRAME;
    FRAME;
    FRAME;
    FRAME;
    AtomBombe=0;
END




PROCESS new_coordinates()
BEGIN
    // If it gets out by the left, forces it to appear by the right
    // subtracting screen's wide
    IF (father.x<-20) father.x=father.x+1064; END
    // If it gets out by the right, forces it to appear by the left
    IF (father.x>1044) father.x=father.x-1064; END
    // If it gets out by the top, forces it to appear by the bottom
    IF (father.y<0) father.y=0; END
    // If it gets out by the bottom, forces it to appear by the top
    IF (father.y>768) father.y=768; END
END














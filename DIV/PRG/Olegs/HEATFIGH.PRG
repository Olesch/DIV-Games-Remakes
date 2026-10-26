//
//            Heatfighter:
//                 Coolfighter in 2d
//


PROGRAM Heatfighter;



GLOBAL
    Fighter1_id;
    Fighter2_id;
    //SLZGlob1;       //Da man ja in Private Variabs nicht eindringen kann,
    //SLZGlob2;       //muss ich fuer die SLZ auch noch Globale Variabeln benutzen!
    MODE=1;         //0=PlayMode
                    //1=TestMode
                    //
    Dontmove;    //Wenn man trifft, dann wird das Spiel kurzzeitig angehalten
                 //(Sozusagen Nano-Pause) damit man den Schlag richtig fuehlt!
    fpsa=100;      //FPS Variabeln
    fpsb=0;      //
    HitDontWait=0; //Wenn jemand getroffen wird kommt eine Minipause.
                 //Wie lange dauert sie?
    Player1_File;//File for player 1
    Player2_File;//File for player 2



LOCAL
    Charakter;  //Der Charakter
    Otherfighter_id; //Die ID des anderen Spielers
    Position=1; //Welcher Move wird ausgefuehrt?
                //Fuer Bilder benoetigt!
                //1=Stehen
                //2=Gehen
                //3=Springen
                //4=Duecken
                //5=Geschlagen werden
                //6=Wegfliegen
                //7=Am Boden liegen
                //8=Leichter Schlag
                //9=Starker Schlag
                //10=Leichter Schlag in der Luft
                //11=Starker Schlag in der Luft
                //12=Leichter Schlag bueckend
                //13=Starker Schlag bueckend
                //14=Block Tief(Bueck)
                //15=Block Mitte(Steh)
                //16=Block Hoch(Spring)
                //17=
                //18=
                //19=
                //20=Spezialmove1
                //21=
                //22=
    StehPosition; //In welcher Position steht er?
                  //1=TiefBueckend
                  //2=MitteStehend
                  //3=HochSpringend

    BlockPosition;//Welcher Block wird ausgefuehrt?
                  //0=Keiner         (Keine Schadensaenderung)
                  //1=TiefBueckend   (Schaden noch viel staerker Reduziert)
                  //2=MitteStehend   (Schaden Stark reduziert)
                  //3=HochSpringend  (Schaden wenig reduziert)
                  //
                  //
    AngriffsArt; //Welche Bloecke koennen diesen Angriff abwehren?
                 //0=Keine                     Wird geblockt durch:
                 //1=Tief (Buecken)             Bueckender Block
                 //2=Mitte(Stehend)             Stehender/Springender Block
                 //3=Hoch (Springend)           Stehender/Springender Block
                 //
    //Knoepfe:Dies wird fuer die Spezialmoves und die KI benoetigt
    //Wenn die Variabel auf 1 steht dann zaehlt der Knopf als gedrueckt
    _Links_Knopf;      //Der Links-Knopf (Wer haette das gedacht?)
    _Rechts_Knopf;     //Der Rechts-Knopf
    _Hoch_Knopf;       //Der Hoch-Knopf
    _Runter_Knopf;     //Der Runter-Knopf
    _Schlag1_Knopf;    //Der Schwacher Schlag-Knopf
    _Schlag2_Knopf;    //Der Starker Schlag-Knopf
    _Schlag3_Knopf;    //Der Variante(?) Schlag-Knopf
    _Spezial_Knopf;    //Der Spezial-Knopf
    //FFP:FastFire-Prevention: Damit man nicht einfach einen Knopf gedrueckt
    //haelt und somit die ganze Zeit schlaegt.
    FFP_Schlag1;
    FFP_Schlag2;
    FFP_Schlag3;
    FFP_Spezial;



    OldPosition;//Ob Picturenumber von neu anfaengt.
    Picturenumber;//Welches Bild soll angezeigt werden?
    Jumpspeed;   //Wie hoch springt er?
    Jumpspeedlr; //Wie weit springt er?
    Dist2Enemy;  //Distance to the Enemy.Ab wann schubst man den Gegner?
    Xdist;       //Entfernung auf der x Koordinate
    Ydist;       //Entfernung auf der y Koordinate
    SLZ;         //SchlagLaehmZeit. Je nach Schlag oder Combo verschieden
                 //Man kann nur dann wieder Aufstehen wennn sie wieder positiv
                 //ist. Je laenger sie anhaelt desto schneller erhohlt man sich
                 //wieder.
    ErhohlSpeed; //Wie Schnell erhohlt man sich von der SLZ?
    SLZWaitplus; //Wenn man lange gelaehmt ist, wird Erhohlspeed hoeher.
    SLZTime;     //Ersatz fuer die obere Variabel(Nach einiger Zeit
                 //Sinkt SLZ gleich auf Null.
    xFlug;       //Wenn die SLZ einen bestimmten Grad ueberschreitet, dann
    yFlug;       //wird man weggehauen und fliegt.
    Lifepoints=6000;  //Wie viele Lebenspunkte hat man?
    Schaden;     //Der Schaden der durch einen Angriff zugefuegt wird
                 //Das muss ein Variabel besitzen da der Schaden beim
                 //Blocken reduziert wird.
    FrameVar;    //Wie lange dauert die Aktion noch??
    Richtung;    //1=rechts -1=links
    PunchWait;   //Es gibt mehrere Frames in denen ein Schlag treffen kann
                 //aber dann wuerde er mehrere Male treffen obwohl er nur
                 //ein mal treffen soll. Wenn Punchwait=1, dann wird nicht mehr
                 //getroffen. Es muss aber wieder auf 0 gestellt werden!
    SLZOverload; //Wenn man Spezialmoves macht wir das SLZ ueberladen
                 //Damit der Gegner mehrmals schlagen muss um erfolgreich
                 //zu sein(1=SLZUeberladen)
    AttackAnimX; //Wenn man angegriffen wird wo kommt die BattleAnimantion?
    AttackAnimY;
    AttackAnimSize;
    AttackAnimGraph;

    LB[5];       //Welche 5 Knoepfe (B{uttons}) wurden zuletzt (L{ast}) geklickt?
                   //    V     <     >   ^   Spezial
                   //    1     2     3   4      5
    ClickedWait; //Zu Spezial wenn man seit der
                 //Letzten Bewegung zu lange gewartet hat
                 //wird kein Move mehr ausgefuehrt
    Spezialratio;//Wie lange warten bis neues Spezial-Bild gezeichnet?
    Mana;        //Die Manapunkte des Charakters
    SpezialOn;   //Spezial-Anim?



    //ComputerVars
    ComputerKIAction;  //Welche Aktion wird durch die KI ausgefuehrt?
    ComputerKIMovement;//Wohin will die KI laufen?
    KIToBlock;         //Blockt die KI?


PRIVATE
    new_palette[255];    //Wenn zwei gleiche Spieler auftauchen,
    counter;             //dann hat der andere auch andere Farben





BEGIN

    load_fpg("Olegs\Heatfigh.fpg");  // Loads graphics' file
    //load_fpg("Olegs\HfTemp.fpg");  // Loads graphics' file
    //load_fpg("Olegs\HfChain.fpg");  // Loads graphics' file
    //load_fpg("Olegs\HfEigen.fpg");  // Loads graphics' file
    //load_fpg("Olegs\HfClaw.fpg");  // Loads graphics' file
    //load_map("Claw.map");  // Loads graphics' file
    //load_fnt("Olegs\Arena.fnt");  // Loads font type

    set_mode(m640x480);               // Sets video mode to 640x480
    set_fps(100,0);                    // Number of frames per second
        Fighter1_id=Fighter(1,2,1);
        Fighter2_id=Fighter(2,2,2);
    //FROM x=0 TO 1;
    //    Fighter1_id=Fighter(1,2,2);
    //    Fighter2_id=Fighter(2,2,2);
    //END
    //    Fighter1_id=Fighter(1,1,2);
    //    Fighter2_id=Fighter(2,1,2);
    Write_Int(0,100,100,4,OFFSET fighter1_ID.SLZ);
    Write_Int(0,540,100,4,OFFSET fighter2_ID.SLZ);
    Write_Int(0,100,125,4,OFFSET fighter1_ID.Lifepoints);
    Write_Int(0,540,125,4,OFFSET fighter2_ID.Lifepoints);
    Write_Int(0,100,440,4,OFFSET fighter1_ID.Mana);
    Write_Int(0,540,440,4,OFFSET fighter2_ID.Mana);
    DontMovePlus();

    IF(Fighter1_id.Charakter!=Fighter1_id.Charakter)
        IF(Fighter1_id.Charakter==1)
            Player1_file=load_Fpg("Olegs\HfTemp.fpg");
        END
        IF(Fighter1_id.Charakter==2)
            Player1_file=load_Fpg("Olegs\HfChain.fpg");
        END
        IF(Fighter1_id.Charakter==3)
            Player1_file=load_Fpg("Olegs\HfEigen.fpg");
        END
        IF(Fighter2_id.Charakter==1)
            Player2_file=load_Fpg("Olegs\HfTemp.fpg");
        END
        IF(Fighter2_id.Charakter==2)
            Player2_file=load_Fpg("Olegs\HfChain.fpg");
        END
        IF(Fighter2_id.Charakter==3)
            Player2_file=load_Fpg("Olegs\HfEigen.fpg");
        END


    ELSE
        IF(Fighter1_id.Charakter==1)
            Player1_file=load_Fpg("Olegs\HfTemp.fpg");
            Player2_file=load_Fpg("Olegs\HfTemp.fpg");
        END
        IF(Fighter1_id.Charakter==2)
            Player1_file=load_Fpg("Olegs\HfChain.fpg");
            Player2_file=load_Fpg("Olegs\HfChain.fpg");
        END
        IF(Fighter1_id.Charakter==3)
            Player1_file=load_Fpg("Olegs\HfEigen.fpg");
            Player2_file=load_Fpg("Olegs\HfEigen.fpg");
        END


        FROM counter=1 TO 255;
            new_palette[counter]=(counter+16) MOD 256;
        END

        FROM counter=1 TO 100;
            convert_palette(Player2_file, counter, offset new_palette);
        END


    END







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
        IF (key(_F6))
            FROM counter=1 TO 100;
                convert_palette(Player1_file, counter, offset new_palette);
            END
            FRAME(300);
        END
        IF (key(_F7))
            FROM counter=1 TO 100;
                convert_palette(Player2_file, counter, offset new_palette);
            END
            FRAME(300);
        END



    END



END




PROCESS Fighter(Spielernr,Charakter,SpielerArt)
/*
Spielernr: 1=1.Spieler
           2=2.Spieler
           (3=3.Spieler)
           (4=4.Spieler)
Charakter: 1=Template
           2=Chain(Same Template)
           3=Eigen
Spielerart:1=Spieler
           2=Computer
*/

BEGIN
    FRAME;
    IF(Spielernr==1)
        Otherfighter_id=Fighter2_id;
    END
    IF(Spielernr==2)
        Otherfighter_id=Fighter1_id;
    END

    resolution=100;

    IF(Spielernr==1)
        x=26000;
        y=37000;
        file=Player1_file;
        graph=1;
    END
    IF(Spielernr==2)
        x=38000;
        y=37000;
        file=Player2_file;
        graph=1;
    END

    LOOP


















      IF(Charakter==1 OR Charakter==2)

        //------------------------------------------------------------------//
        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
        //                                                                  //
        // TTTTTT  EEEEEEE  M       M  PPP   L         A    TTTTTT  EEEEEEE //
        //   TT    EE       MM     MM  P  P  L        A A     TT    EE      //
        //   TT    EE       M M   M M  P  P  L       A   A    TT    EE      //
        //   TT    EEEEEEE  M  M M  M  PPP   L      A     A   TT    EEEEEEE //
        //   TT    EE       M   M   M  P     L      AAAAAAA   TT    EE      //
        //   TT    EE       M       M  P     L      A     A   TT    EE      //
        //   TT    EEEEEEE  M       M  P     LLLLL  A     A   TT    EEEEEEE //
        //                                                                  //
        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
        //------------------------------------------------------------------//







       //Welche Knoepfe werden gedrueckt?


        _Links_Knopf=0;
        _Rechts_Knopf=0;
        _Hoch_Knopf=0;
        _Runter_Knopf=0;
        _Schlag1_Knopf=0;
        _Schlag2_Knopf=0;
        _Schlag3_Knopf=0;
        _Spezial_Knopf=0;


       IF(Spielerart==1)

        IF((key(_d) AND Spielernr==1) OR (key(_up) AND Spielernr==2))
            _Hoch_Knopf=1;
        END
        IF((key(_c) AND Spielernr==1) OR (key(_down) AND Spielernr==2))
            _Runter_Knopf=1;
        END
        IF((key(_x) AND Spielernr==1) OR (key(_left) AND Spielernr==2))
            _Links_Knopf=1;
        END
        IF((key(_v) AND Spielernr==1) OR (key(_right) AND Spielernr==2))
            _Rechts_Knopf=1;
        END
        IF(((key(_1) AND Spielernr==1) OR (key(_9) AND Spielernr==2)) AND FFP_Schlag1!=1)
            _Schlag1_Knopf=1;
            FFP_Schlag1=1;
        END
        IF(NOT ((key(_1) AND Spielernr==1) OR (key(_9) AND Spielernr==2)))
            FFP_Schlag1=0;
        END

        IF(((key(_2) AND Spielernr==1) OR (key(_0) AND Spielernr==2)) AND FFP_Schlag2!=1)
            _Schlag2_Knopf=1;
            FFP_Schlag2=1;
        END
        IF(NOT ((key(_2) AND Spielernr==1) OR (key(_0) AND Spielernr==2)))
            FFP_Schlag2=0;
        END

        IF(((key(_3) AND Spielernr==1) OR (key(_minus) AND Spielernr==2)) AND FFP_Schlag3!=1)
            _Schlag3_Knopf=1;
            FFP_Schlag3=1;
        END
        IF(NOT ((key(_3) AND Spielernr==1) OR (key(_minus) AND Spielernr==2)))
            FFP_Schlag3=0;
        END

        IF(((key(_4) AND Spielernr==1) OR (key(_plus) AND Spielernr==2)) AND FFP_Spezial!=1)
            _Spezial_Knopf=1;
            FFP_Spezial=1;
        END
        IF(NOT ((key(_4) AND Spielernr==1) OR (key(_plus) AND Spielernr==2)))
            FFP_Spezial=0;
        END

       END


       //Die KI greift ein
       IF(Spielerart==2)
        IF(Spielernr==1)
            Xdist=fget_dist(x,0,fighter2_id.x,0);
            Ydist=fget_dist(0,y,0,fighter2_id.y);
        END
        IF(Spielernr==2)
            Xdist=fget_dist(x,0,fighter1_id.x,0);
            Ydist=fget_dist(0,y,0,fighter1_id.y);
        END



        IF(Rand(0,75)==0)
            KIToBlock=0;
        END
        IF(Rand(0,50)==0)
            KIToBlock=1;
        END

        IF(KIToBlock==1 AND (Position==1 OR Position==2 OR Position==3 OR Position==4))
            IF(Richtung==-1)
                _Rechts_Knopf=1;
            END
            IF(Richtung==1)
                _Links_Knopf=1;
            END
        END


        IF(Position==1)
            IF(Mana>500 AND Rand(0,150)==0 AND Otherfighter_id.position==5
                AND Xdist<18000 AND YDist<4000)
                ClickedWait=10;
                IF(Richtung==1)
                    LB[2]=1;
                    LB[1]=2;
                    _Schlag1_Knopf=1;
                ELSE
                    LB[2]=1;
                    LB[1]=3;
                    _Schlag1_Knopf=1;
                END
            END
            IF(XDist<7000 AND YDist<3000 AND Rand(0,12)==0)
                _Schlag1_Knopf=1;
            END
            IF(XDist<10000 AND YDist<3000 AND Rand(0,18)==0)
                _Schlag2_Knopf=1;
            END
            IF(XDist>4000 AND KIToBlock!=1)
                IF(Richtung==-1)
                    _Links_Knopf=1;
                END
                IF(Richtung==1)
                    _Rechts_Knopf=1;
                END
            END
            IF((YDist>8000 AND Rand(0,30)==0) OR Rand(0,80)==0)
                _Hoch_Knopf=1;
            END
            IF(Rand(0,300)==0 OR (Otherfighter_id.position==4 AND XDist<6000 AND
               Rand(0,24)==0) OR (Otherfighter_id.position==7 AND XDist<6000 AND
               Rand(0,10)==0))
                _Runter_Knopf=1;
            END
            IF(Rand(0,300)==0 OR (Otherfighter_id.position==4 AND XDist<6000 AND
               Rand(0,24)==0) OR (Otherfighter_id.position==7 AND XDist<6000 AND
               Rand(0,10)==0))
                _Runter_Knopf=1;
            END

        END

        IF(Position==2)
            IF(XDist>4000 AND KIToBlock!=1)
                IF(Richtung==-1)
                    _Links_Knopf=1;
                END
                IF(Richtung==1)
                    _Rechts_Knopf=1;
                END
            END
            IF((YDist>8000 AND Rand(0,30)==0) OR Rand(0,80)==0)
                _Hoch_Knopf=1;
            END
            IF(Rand(0,300)==0 OR (Otherfighter_id.position==4 AND XDist<6000 AND
               Rand(0,24)==0) OR (Otherfighter_id.position==7 AND XDist<6000 AND
               Rand(0,10)==0))
                _Runter_Knopf=1;
            END
        END

        IF(Position==3)
            IF(YDist>1000 AND Rand(0,10)==0)
                _Hoch_Knopf=1;
            END
            IF(XDist>3000 AND KIToBlock!=1)
                IF(Richtung==-1)
                    _Links_Knopf=1;
                END
                IF(Richtung==1)
                    _Rechts_Knopf=1;
                END
            END
            IF(XDist<14000 AND YDist<16000 AND Rand(0,10)==0)
                _Schlag1_Knopf=1;
            END
            IF(XDist<19000 AND YDist<16000 AND Rand(0,15)==0)
                _Schlag2_Knopf=1;
            END

        END

        IF(Position==4)
            _Runter_Knopf=1;
            IF(Rand(0,300)==0 OR (XDist>5000 AND rand(0,60)==0) OR
                (Otherfighter_id.position==3 AND Rand(0,30)==0))
                _Runter_Knopf=0;
            END

            IF(XDist<10000 AND YDist<4000 AND Rand(0,10)==0)
                _Schlag1_Knopf=1;
            END
            IF(XDist<16000 AND YDist<4000 AND Rand(0,15)==0)
                _Schlag2_Knopf=1;
            END

        END

        IF(Position==5 OR Position==6 OR Position==7)
            IF(SLZ>=0)
                IF(Rand(0,20)==0)
                    IF(Richtung==1)
                        _Rechts_Knopf=1;
                    END
                    IF(Richtung==-1)
                        _Links_Knopf=1;
                    END
                END
                IF(Rand(0,30)==0)
                    _Hoch_Knopf=1;
                END
                IF(Rand(0,40)==0)
                    IF(Richtung==1)
                        _Links_Knopf=1;
                    END
                    IF(Richtung==-1)
                        _Rechts_Knopf=1;
                    END
                END
            END

        END





       END
















        //KnoepfeSpeicherung


        IF(_Runter_Knopf==1 AND LB[1]!=1)
            ClickedWait=10;
            LB[5]=LB[4];
            LB[4]=LB[3];
            LB[3]=LB[2];
            LB[2]=LB[1];
            LB[1]=1;
        END

        IF(_Links_Knopf==1 AND LB[1]!=2)
            ClickedWait=10;
            LB[5]=LB[4];
            LB[4]=LB[3];
            LB[3]=LB[2];
            LB[2]=LB[1];
            LB[1]=2;
        END

        IF(_Rechts_Knopf==1 AND LB[1]!=3)
            ClickedWait=10;
            LB[5]=LB[4];
            LB[4]=LB[3];
            LB[3]=LB[2];
            LB[2]=LB[1];
            LB[1]=3;
        END


        IF(_Hoch_Knopf==1 AND LB[1]!=4)
            ClickedWait=10;
            LB[5]=LB[4];
            LB[4]=LB[3];
            LB[3]=LB[2];
            LB[2]=LB[1];
            LB[1]=4;
        END

        ClickedWait--;
        IF(ClickedWait<0)
            LB[5]=0;
            LB[4]=0;
            LB[3]=0;
            LB[2]=0;
            LB[1]=0;
        END




        IF(Oldposition!=Position)
            Picturenumber=1;
        END

        //Gegner schubsen!
        //
        IF(Spielernr==1)
            Xdist=fget_dist(x,0,fighter2_id.x,0);
            Ydist=fget_dist(0,y,0,fighter2_id.y);

            IF(Xdist<1500)
                IF(Ydist<4500)
                    IF(Fighter2_id.x<x)
                        x+=(1500-Xdist);
                      ELSE
                       x-=(1500-Xdist);
                    END
                END
            END
        END

        IF(Spielernr==2)
            Xdist=fget_dist(x,0,fighter1_id.x,0);
            Ydist=fget_dist(0,y,0,fighter1_id.y);

            IF(Xdist<1500)
                IF(Ydist<4500)
                    IF(Fighter1_id.x<x)
                        x+=(1500-Xdist);
                      ELSE
                       x-=(1500-Xdist);
                    END
                END
            END
        END



        /*Ohne Wand Modus//Aus Bildschirm fliegen!
        //
        IF(x>64000)
            x=1;
        END
        IF(x<0)
            x=63999;
        END
        IF(y<0)
            y=1;
            Jumpspeed=-Jumpspeed;

        END*/



        //Aus Bildschirm fliegen!
        //
        IF(x>64000)
            x=63999;
            IF(Position==3 OR Position==10 OR Position==11)
                Jumpspeedlr=-(Jumpspeedlr+10);
                Jumpspeed+=500;
            END
            IF(Position==6)
                Lifepoints-=(abs(xFlug))/5;
                AnimHau(x,y,abs(xFlug)/2,4);
                xFlug=-(xFlug/2);
            END

        END
        IF(x<0)
            x=1;
            IF(Position==3 OR Position==10 OR Position==11)
                Jumpspeedlr=-(Jumpspeedlr+10);
                Jumpspeed+=500;
            END
            IF(Position==6)
                Lifepoints-=(abs(xFlug))/5;
                AnimHau(x,y,abs(xFlug)/2,4);
                xFlug=-(xFlug/2);
            END

        END
        IF(y<0)
            y=1;
            Jumpspeed=-Jumpspeed;

        END


        /*Old"Walljumping"//Aus Bildschirm fliegen!
        //
        IF(x>64000)
            x=63999;
            IF(Position==3 OR Position==10 OR Position==11)
                Jumpspeedlr=-(Jumpspeedlr+30);
                Jumpspeed+=1500;
            END
            IF(Position==6)
                Lifepoints-=(abs(xFlug))/5;
                xFlug=-(xFlug/2);
            END

        END
        IF(x<0)
            x=1;
            IF(Position==3 OR Position==10 OR Position==11)
                Jumpspeedlr=-(Jumpspeedlr+30);
                Jumpspeed+=1500;
            END
            IF(Position==6)
                Lifepoints-=(abs(xFlug))/5;
                xFlug=-(xFlug/2);
            END

        END
        IF(y<0)
            y=1;
            Jumpspeed=-Jumpspeed;

        END             */

        Blockposition=0;    //Wenn man nicht blockt dann blockt man nicht!









        //******************************************************************
        IF(Position==1)      //Stehen

            //Nach rechts und links drehen
            //
            IF(Spielernr==1)
                IF(Fighter2_id.x>x)
                    Flags=0;
                    Richtung=1;
                  ELSE
                   Flags=1;
                   Richtung=-1;
                END
            END
            IF(Spielernr==2)
                IF(Fighter1_id.x>x)
                    Flags=0;
                    Richtung=1;
                  ELSE
                   Flags=1;
                   Richtung=-1;

                END
            END



            //Auf Knoepfe reagieren
            //
            IF(_Hoch_Knopf==1)
                Position=3;
                Jumpspeed=1500;
            END
            IF(_Runter_Knopf==1)
                Position=4;
            END
            IF(_Links_Knopf==1)
                Position=2;
            END
            IF(_Rechts_Knopf==1)
                Position=2;
            END
            IF(_Rechts_Knopf==1 AND _Links_Knopf==1)
                Position=1;
            END


            IF(_Schlag1_Knopf==1)

                IF(LookForMove(LB[1],LB[2],LB[3],LB[4],LB[5])*Richtung==-1 AND Mana>0)
                    Mana-=1000;
                    Position=20;
                    ClickedWait=-1;
                ELSE
                    Position=8;
                END
            END

            IF(_Schlag2_Knopf==1)
                Position=9;
            END




            //Bilder zeigen
            //
            Graph=(Picturenumber+15)/15;
            Picturenumber=((Picturenumber) mod 29)+1;

        END


        //******************************************************************
        IF(Position==2)        //Gehen

            //Wenn man sich nicht mehr bewegt dann stehen!
            //
            Position=1;


            //Auf Knoepfe reagieren
            //
            IF(_Links_Knopf==1)
                x-=300;
                Position=2;
                IF(Spielernr==1)
                    IF(Fighter2_id.x>x)
                        Blockposition=2;
                    END
                END
                IF(Spielernr==2)
                    IF(Fighter1_id.x>x)
                        Blockposition=2;
                    END
                END

            END
            IF(_Rechts_Knopf==1)
                x+=300;
                Position=2;
                IF(Spielernr==1)
                    IF(Fighter2_id.x<x)
                        Blockposition=2;
                    END
                END
                IF(Spielernr==2)
                    IF(Fighter1_id.x<x)
                        Blockposition=2;
                    END
                END
            END
            IF(_Rechts_Knopf==1 AND _Links_Knopf==1)
                Position=1;

            END //Man klickt in beide Richtungen!

            IF(_Hoch_Knopf==1)
                Position=3;
                Jumpspeed=1500;
                IF(_Links_Knopf==1)
                    Jumpspeedlr=-300;
                END
                IF(_Rechts_Knopf==1)
                    Jumpspeedlr=+300;
                END
            END
            IF(_Runter_Knopf==1)
                Position=4;
            END

            IF(_Schlag1_Knopf==1)

                IF(LookForMove(LB[1],LB[2],LB[3],LB[4],LB[5])*Richtung==-1 AND Mana>0)
                    Mana-=1000;
                    Position=20;
                    ClickedWait=-1;
                ELSE
                    Position=8;
                END
            END
            IF(_Schlag2_Knopf==1)
                Position=9;
            END

            //Bilder zeigen
            //
            Graph=((Picturenumber+11)/11)+1;
            Picturenumber=((Picturenumber) mod 21)+1;

        END







        //******************************************************************
        IF(Position==3)         //Springen


            IF(_Hoch_Knopf==1)
                Jumpspeed+=20;
            END
            IF(_Links_Knopf==1)
                Jumpspeedlr+=-50;
                IF(Spielernr==1)
                    IF(Fighter2_id.x>x)
                        Blockposition=3;
                    END
                END
                IF(Spielernr==2)
                    IF(Fighter1_id.x>x)
                        Blockposition=3;
                    END
                END
            END
            IF(_Rechts_Knopf==1)
                Jumpspeedlr+=+50;
                IF(Spielernr==1)
                    IF(Fighter2_id.x<x)
                        Blockposition=3;
                    END
                END
                IF(Spielernr==2)
                    IF(Fighter1_id.x<x)
                        Blockposition=3;
                    END
                END
            END
            IF(_Schlag1_Knopf==1)
                Position=10;
            END
            IF(_Schlag2_Knopf==1)
                Position=11;
                //Jumpspeed-=500;
                //Jumpspeedlr+=500*Richtung;

            END


            //Hoch/Runter-Bewegen
            //
            y-=Jumpspeed;
            x+=Jumpspeedlr;
            Jumpspeed-=100;


            //Pruefen wie tief man ist
            //
            IF(y>=37000)
                y=37000;
                Position=1;
                Jumpspeedlr=0;
            END



            //Bilder zeigen
            //
            Graph=((Picturenumber+8)/8)+2;
            Picturenumber=((Picturenumber) mod 15)+1;

        END


        //***************************************************************
        IF(Position==4)       //Buecken

            //Nach rechts und links drehen
            //
            IF(Spielernr==1)
                IF(Fighter2_id.x>x)
                    Flags=0;
                    Richtung=1;
                  ELSE
                   Flags=1;
                   Richtung=-1;
                END
            END
            IF(Spielernr==2)
                IF(Fighter1_id.x>x)
                    Flags=0;
                    Richtung=1;
                  ELSE
                   Flags=1;
                   Richtung=-1;

                END
            END

            //Auf Knoepfe reagieren
            //
            IF(_Runter_Knopf==0)
                Position=1;
            END
            IF(_Links_Knopf==1)
                IF(Spielernr==1)
                    IF(Fighter2_id.x>x)
                        Blockposition=1;
                    END
                END
                IF(Spielernr==2)
                    IF(Fighter1_id.x>x)
                        Blockposition=1;
                    END
                END
            END
            IF(_Rechts_Knopf==1)
                IF(Spielernr==1)
                    IF(Fighter2_id.x<x)
                        Blockposition=1;
                    END
                END
                IF(Spielernr==2)
                    IF(Fighter1_id.x<x)
                        Blockposition=1;
                    END
                END
            END
            IF(_Schlag1_Knopf==1)
                Position=12;
            END
            IF(_Schlag2_Knopf==1)
                Position=13;
            END


            Graph=5;

        END


        //**************************************************************
        //Da man auf die SLZ- und Block-Positionen nicht durch
        //eigene Knoepfe kommt, kommt hier ein Einschub
        //**************************************************************

        //
        //Ganz wichtig: Das Blocken!
        //

        //Wenn man liegt...
        IF(Position==7)
            IF(Angriffsart==2)
                SLZ=0;
                Schaden=0;
                xFlug=0;
                yFlug=0;
                AngriffsArt=0;
            END
            IF(Angriffsart==3)
                SLZ=0;
                Schaden=0;
                xFlug=0;
                yFlug=0;
                AngriffsArt=0;
            END
        END

        //Wenn man Bueckt...
        IF(Position==4 OR Position==12 OR Position==13 OR Position==14)
            IF(Angriffsart==2)
                SLZ=0;
                Schaden=0;
                xFlug=0;
                yFlug=0;
                AngriffsArt=0;
            END
        END

        IF(10!=10)
            write(0,360,240,4,"Der DIV-Maker spinnt!"); //Yeah! Very Funny...
        END

        //Wenn man blockt!
        IF(Blockposition!=0 AND Angriffsart!=0)
            IF(Blockposition==1)    //Der Bueckend-Blockende...
                IF(Angriffsart==1)  //...wird von einem Bueckendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    Dontmove=HitDontWait;

                END
                IF(Angriffsart==2)  //...wird von einem Stehendem angegriffen
                    SLZ=0;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;

                END
                IF(Angriffsart==3)  //...wird von einem Springendem angegriffen
                    Lifepoints-=Schaden;
                    Schaden=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    AngriffsArt=0;                   //????????????
                    Dontmove=HitDontWait;
                END
            END
            IF(Blockposition==2)    //Der Stehend-Blockende...
                IF(Angriffsart==1)  //...wird von einem Bueckendem angegriffen
                    Lifepoints-=Schaden;
                    Schaden=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    AngriffsArt=0;                   //????????????
                    Dontmove=HitDontWait;
                END
                IF(Angriffsart==2)  //...wird von einem Stehendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    Dontmove=HitDontWait;
                END
                IF(Angriffsart==3)  //...wird von einem Springendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    Dontmove=HitDontWait;
                END
            END
            IF(Blockposition==3)    //Der Springend-Blockende...
                IF(Angriffsart==1)  //...wird von einem Bueckendem angegriffen
                    Lifepoints-=Schaden;
                    Schaden=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    AngriffsArt=0;                   //????????????
                    Dontmove=HitDontWait;
                END
                IF(Angriffsart==2)  //...wird von einem Stehendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    Dontmove=HitDontWait;
                END
                IF(Angriffsart==3)  //...wird von einem Springendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    Dontmove=HitDontWait;
                END
            END
        END


        //
        //Die die nicht blocken haben einen KO-Schlag verdient
        //
        IF(Schaden!=0)
            Lifepoints-=Schaden;
            Schaden=0;
            AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
            AttackAnimX=0;
            AttackAnimY=0;
            AttackAnimSize=0;
            AttackAnimGraph=0;
            AngriffsArt=0;                   //????????????
            Dontmove=HitDontWait;
        END

        IF(Position==1 OR Position==2 OR Position==4 OR Position==5)
            IF(SLZ<0)
                FrameVar=0;
                Position=5;
                IF(SLZ<-500)
                    FrameVar=0;
                    Position=6;
                END
            END
        END

        IF((Position==3 OR Position==6) AND SLZ<0)
            FrameVar=0;
            Position=6;
        END

        IF((Position==7) AND SLZ<0)
            FrameVar=0;
            Position=7;
        END

        IF(SLZ<0)
            /*IF(Erhohlspeed>(SLZ/150)-7);
                Erhohlspeed=(SLZ/150)-7;
            END*/
            IF(Erhohlspeed>(-1*(sqrt(abs(SLZ))))-7);
                Erhohlspeed=(-1*(sqrt(abs(SLZ))))-7;
            END
            SLZWaitPlus++;
            IF(SLZWaitPlus==40)
                Erhohlspeed-=5;
            END
            IF(SLZWaitPlus==70)
                Erhohlspeed-=5;
            END
            IF(SLZWaitPlus==90)
                Erhohlspeed-=2;
                SLZWaitPlus=70;
            END
        END

        IF(SLZ>0)
            SLZ=0;
        END

        IF(SLZ==0 AND Position!=6 AND Position!=7 )
            xFlug=0;
            yFlug=0;
        END

        IF(SLZ==0 AND Position!=5 AND Position!=6 AND Position!=7 )
            IF(erhohlspeed>0)
                erhohlspeed+=3;
              ELSE
               erhohlspeed=0;
            END

            IF(SLZWaitplus>0)
                SLZWaitPlus-=3;
              ELSE
               SLZWaitplus=0;
            END
        END



        //********************************************************************
        IF(Position==5)     //Gehaut werden
            xFlug=0;
            yFlug=0;

            SLZ-=Erhohlspeed;


            IF(SLZ>=0)
                //Auf Knoepfe reagieren
                //
                IF(_Hoch_Knopf==1)
                    Position=3;
                    Jumpspeed=1500;
                END
                IF(_Runter_Knopf==1)
                    Position=4;
                END
                IF(_Links_Knopf==1)
                    Position=2;
                END
                IF(_Rechts_Knopf==1)
                    Position=2;
                END
                IF(_Links_Knopf==1 AND _Rechts_Knopf==1)
                    Position=1;
                END //Man klickt in beide Richtungen!
            END

            IF(SLZ<-500)
                Position=6;
            END

            //Bilder zeigen
            //
            Graph=7;

        END

        //*******************************************************************
        IF(Position==6)     //Wegfliegen

            SLZ-=Erhohlspeed/2;


            IF(SLZ>=0)
                IF(_Hoch_Knopf==1)
                    Position=3;
                    Jumpspeed=800;
                END
                IF(_Links_Knopf==1)
                    Position=3;
                    Jumpspeed=500;
                    Jumpspeedlr=-300;
                END
                IF(_Rechts_Knopf==1)
                    Position=3;
                    Jumpspeed=500;
                    Jumpspeedlr=300;
                END
            END

            //Hoch/Runter-Bewegen
            //
            y-=yFlug;
            x+=xFlug;
            yFlug-=100;


            //Pruefen wie tief man ist
            //
            IF(y>=37000)
                y=37000;
                Position=7;
                xFlug=0;
                yFlug=0;
            END



            //Bilder zeigen
            //
            Graph=8;

        END


        //*******************************************************************
        IF(Position==7)     //Am Boden liegen

            Jumpspeed=0;
            Jumpspeedlr=0;
            SLZ-=Erhohlspeed*5;
            IF(XFlug!=0 OR YFlug!=0)
                Position=6;
            END

            IF(SLZ>=0)
                IF(_Hoch_Knopf==1)
                    Position=3;
                    Jumpspeed=500;
                END
                IF(_Links_Knopf==1)
                    Position=3;
                    Jumpspeed=300;
                    Jumpspeedlr=-300;
                END
                IF(_Rechts_Knopf==1)
                    Position=3;
                    Jumpspeed=300;
                    Jumpspeedlr=300;
                END
            END
            //Bilder zeigen
            //
            Graph=9;

        END


        //*******************************************************************
        IF(Position==8)     //Schwacher Schlag

            FrameVar++;

            IF(FrameVar>6)
                Position=1;
                Punchwait=0;
                FrameVar=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
                FrameVar=0;
            END

            IF(FrameVar>2 AND FrameVar<5 AND Punchwait==0)

                IF(Spielernr==1)
                    Xdist=fget_dist(x+(1000*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(1000*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter1_id.y);
                END


                IF(Xdist<2500)
                    IF(Ydist<2000)
                        x-=250*Richtung;
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=250;
                            Fighter2_id.Schaden+=50;
                            Fighter2_id.xFlug+=50*Richtung;
                            Fighter2_id.yFlug+=600;
                            Fighter2_id.x+=200*Richtung;
                            Fighter2_id.Angriffsart=2;
                            Fighter2_id.AttackAnimX=x+(1100*Richtung);
                            Fighter2_id.AttackAnimY=y;
                            Fighter2_id.AttackAnimSize=100;
                            Fighter2_id.AttackAnimGraph=4;

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=250;
                            Fighter1_id.Schaden+=50;
                            Fighter1_id.xFlug+=50*Richtung;
                            Fighter1_id.yFlug+=600;
                            Fighter1_id.x+=200*Richtung;
                            Fighter1_id.Angriffsart=2;
                            Fighter1_id.AttackAnimX=x+(1100*Richtung);
                            Fighter1_id.AttackAnimY=y;
                            Fighter1_id.AttackAnimSize=100;
                            Fighter1_id.AttackAnimGraph=4;

                        END
                    END
                END
            END


            Graph=10;
        END







        //*******************************************************************
        IF(Position==9)      //Starker Schlag

            FrameVar++;

            IF(FrameVar>15)
                Position=1;
                Punchwait=0;
                FrameVar=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar>8 AND FrameVar<14 AND Punchwait==0)
                x+=500*Richtung;


                IF(Spielernr==1)
                    Xdist=fget_dist(x+(2000*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(2000*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter1_id.y);
                END


                IF(Xdist<3000)
                    IF(Ydist<2500)
                        x-=350*Richtung;
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=499;
                            Fighter2_id.Schaden+=100;
                            Fighter2_id.xFlug+=75*Richtung;
                            Fighter2_id.yFlug+=800;
                            Fighter2_id.x+=900*Richtung;
                            Fighter2_id.Angriffsart=2;
                            Fighter2_id.AttackAnimX=x+(2100*Richtung);
                            Fighter2_id.AttackAnimY=y;
                            Fighter2_id.AttackAnimSize=150;
                            Fighter2_id.AttackAnimGraph=4;

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=499;
                            Fighter1_id.Schaden+=100;
                            Fighter1_id.xFlug+=75*Richtung;
                            Fighter1_id.yFlug+=800;
                            Fighter1_id.x+=900*Richtung;
                            Fighter1_id.Angriffsart=2;
                            Fighter1_id.AttackAnimX=x+(2100*Richtung);
                            Fighter1_id.AttackAnimY=y;
                            Fighter1_id.AttackAnimSize=150;
                            Fighter1_id.AttackAnimGraph=4;

                        END
                    END
                END
            END


            IF(FrameVar<8)
                Graph=11;

            ELSE

                Graph=10;
            END

        END

        //*******************************************************************
        IF(Position==10)         //Schwacher Schlag in der Luft

            FrameVar++;

            IF(FrameVar>13)
                Position=3;
                FrameVar=0;
                Punchwait=0;
            END

            //Hoch/Runter-Bewegen
            //
            y-=Jumpspeed;
            x+=Jumpspeedlr;
            Jumpspeed-=100;


            //Pruefen wie tief man ist
            //
            IF(y>=37000)
                y=37000;
                Jumpspeed=0;
                Jumpspeedlr=0;
                Position=1;
                FrameVar=0;
                Punchwait=0;
            END


            IF(SLZ<0)
                Position=6;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar>4 AND FrameVar<8 AND Punchwait==0)


                IF(Spielernr==1)
                    Xdist=fget_dist(x+(2000*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y-1000,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(2000*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y-1000,0,fighter1_id.y);
                END


                IF(Xdist<3000)
                    IF(Ydist<3500)
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=350;
                            Fighter2_id.Schaden+=75;
                            Fighter2_id.xFlug+=125*Richtung;
                            Fighter2_id.yFlug+=700;
                            Fighter2_id.x+=600*Richtung;
                            Fighter2_id.Angriffsart=3;
                            Fighter2_id.AttackAnimX=x+(2100*Richtung);
                            Fighter2_id.AttackAnimY=y+1200;
                            Fighter2_id.AttackAnimSize=125;
                            Fighter2_id.AttackAnimGraph=4;

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=350;
                            Fighter1_id.Schaden+=75;
                            Fighter1_id.xFlug+=125*Richtung;
                            Fighter1_id.yFlug+=700;
                            Fighter1_id.x+=600*Richtung;
                            Fighter1_id.Angriffsart=3;
                            Fighter1_id.AttackAnimX=x+(2100*Richtung);
                            Fighter1_id.AttackAnimY=y+1200;
                            Fighter1_id.AttackAnimSize=125;
                            Fighter1_id.AttackAnimGraph=4;

                        END
                    END
                END
            END


            Graph=12;

        END


        //*******************************************************************
        IF(Position==11)         //Starker Schlag in der Luft

            FrameVar++;

            IF(FrameVar>19)
                Position=3;
                FrameVar=0;
                Punchwait=0;
            END

            //Hoch/Runter-Bewegen
            //
            y-=Jumpspeed;
            x+=Jumpspeedlr;
            Jumpspeed-=100;


            //Pruefen wie tief man ist
            //
            IF(y>=37000)
                y=37000;
                Jumpspeed=0;
                Jumpspeedlr=0;
                Position=1;
                FrameVar=0;
                Punchwait=0;
            END


            IF(SLZ<0)
                Position=6;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar<18 AND Punchwait==0)


                IF(Spielernr==1)
                    Xdist=fget_dist(x+(2000*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y+2200,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(2000*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y+2200,0,fighter1_id.y);
                END


                IF(Xdist<2500)
                    IF(Ydist<3000)
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=350;
                            Fighter2_id.Schaden+=150;
                            Fighter2_id.xFlug+=150*Richtung;
                            Fighter2_id.yFlug+=700;
                            Fighter2_id.x+=600*Richtung;
                            Fighter2_id.Angriffsart=3;
                            Fighter2_id.AttackAnimX=x+(2100*Richtung);
                            Fighter2_id.AttackAnimY=y+2200;
                            Fighter2_id.AttackAnimSize=175;
                            Fighter2_id.AttackAnimGraph=6;

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=350;
                            Fighter1_id.Schaden+=150;
                            Fighter1_id.xFlug+=150*Richtung;
                            Fighter1_id.yFlug+=700;
                            Fighter1_id.x+=600*Richtung;
                            Fighter1_id.Angriffsart=3;
                            Fighter1_id.AttackAnimX=x+(2100*Richtung);
                            Fighter1_id.AttackAnimY=y+2200;
                            Fighter1_id.AttackAnimSize=175;
                            Fighter1_id.AttackAnimGraph=6;

                        END
                        Position=10;
                        Punchwait=0;
                        FrameVar=10;
                    END
                END
            END


            Graph=13;

        END



        //*******************************************************************
        IF(Position==12)     //Schwacher Schlag Bueckend

            FrameVar++;

            IF(FrameVar>12)
                Position=4;
                FrameVar=0;
                Punchwait=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar>2 AND FrameVar<8 AND Punchwait==0)

                IF(Spielernr==1)
                    Xdist=fget_dist(x+(1200*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(1200*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter1_id.y);
                END


                IF(Xdist<3500)
                    IF(Ydist<2500)
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=150;
                            Fighter2_id.Schaden+=45;
                            Fighter2_id.xFlug+=50*Richtung;
                            Fighter2_id.yFlug+=400;
                            Fighter2_id.x+=150*Richtung;
                            Fighter2_id.Angriffsart=1;
                            Fighter2_id.AttackAnimX=x+(1100*Richtung);
                            Fighter2_id.AttackAnimY=y+2000;
                            Fighter2_id.AttackAnimSize=100;
                            Fighter2_id.AttackAnimGraph=4;

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=150;
                            Fighter1_id.Schaden+=45;
                            Fighter1_id.xFlug+=50*Richtung;
                            Fighter1_id.yFlug+=400;
                            Fighter1_id.x+=150*Richtung;
                            Fighter1_id.Angriffsart=1;
                            Fighter1_id.AttackAnimX=x+(1100*Richtung);
                            Fighter1_id.AttackAnimY=y+2000;
                            Fighter1_id.AttackAnimSize=100;
                            Fighter1_id.AttackAnimGraph=4;

                        END
                    END
                END
            END


            Graph=14;
        END


        //*******************************************************************
        IF(Position==13)     //Starker Schlag Bueckend

            FrameVar++;

            IF(FrameVar>25)
                Position=4;
                FrameVar=0;
                Punchwait=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar>12 AND FrameVar<17 AND Punchwait==0)

                IF(Spielernr==1)
                    Xdist=fget_dist(x+(1200*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y-800,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(1200*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y-800,0,fighter1_id.y);
                END


                IF(Xdist<3500)
                    IF(Ydist<3000)
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=350;
                            Fighter2_id.Schaden+=90;
                            Fighter2_id.xFlug+=10*Richtung;
                            Fighter2_id.yFlug+=1000;
                            Fighter2_id.x+=150*Richtung;
                            Fighter2_id.Angriffsart=1;
                            Fighter2_id.AttackAnimX=x+(1100*Richtung);
                            Fighter2_id.AttackAnimY=y+2000;
                            Fighter2_id.AttackAnimSize=130;
                            Fighter2_id.AttackAnimGraph=4;

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=350;
                            Fighter1_id.Schaden+=90;
                            Fighter1_id.xFlug+=10*Richtung;
                            Fighter1_id.yFlug+=1000;
                            Fighter1_id.x+=150*Richtung;
                            Fighter1_id.Angriffsart=1;
                            Fighter1_id.AttackAnimX=x+(1100*Richtung);
                            Fighter1_id.AttackAnimY=y+2000;
                            Fighter1_id.AttackAnimSize=130;
                            Fighter1_id.AttackAnimGraph=4;

                        END
                    END
                END
            END

            IF(FrameVar<12)
                Graph=14;
            ELSE
                Graph=15;
            END
        END

        //*******************************************************************
        IF(Position==20)      //SpezialMove1 Runter->Zurueck Schlag

            FrameVar++;

            IF(FrameVar>60)
                Position=1;
                FrameVar=0;
                Punchwait=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar>10 AND FrameVar<20 AND Punchwait==0)
                x+=500*Richtung;


                IF(Spielernr==1)
                    Xdist=fget_dist(x+(2000*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(2000*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter1_id.y);
                END


                IF(Xdist<3000)
                    IF(Ydist<2500)
                        FrameVar=20;
                        x-=350*Richtung;
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=750;
                            Fighter2_id.Schaden+=200;
                            Fighter2_id.xFlug+=100*Richtung;
                            Fighter2_id.yFlug+=800;
                            Fighter2_id.x+=900*Richtung;
                            Fighter2_id.Angriffsart=2;
                            Fighter2_id.AttackAnimX=x+(2100*Richtung);
                            Fighter2_id.AttackAnimY=y;
                            Fighter2_id.AttackAnimSize=150;
                            Fighter2_id.AttackAnimGraph=4;

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=750;
                            Fighter1_id.Schaden+=200;
                            Fighter1_id.xFlug+=100*Richtung;
                            Fighter1_id.yFlug+=800;
                            Fighter1_id.x+=900*Richtung;
                            Fighter1_id.Angriffsart=2;
                            Fighter1_id.AttackAnimX=x+(2100*Richtung);
                            Fighter1_id.AttackAnimY=y;
                            Fighter1_id.AttackAnimSize=150;
                            Fighter1_id.AttackAnimGraph=4;

                        END
                    END
                END
            END

            IF(FrameVar>20 AND FrameVar<60)
                x+=500*Richtung;


                IF(Spielernr==1)
                    Xdist=fget_dist(x+(2000*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(2000*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter1_id.y);
                END


                IF(Xdist<3000)
                    IF(Ydist<2500)
                        x-=550*Richtung;
                        Punchwait=1;
                        DontMove=4;
                        SpezialOn=1;
                        IF(Spielernr==1)

                            IF(FrameVar>55)
                                Fighter2_id.SLZ-=600;
                                Fighter2_id.Schaden+=50;
                                Fighter2_id.xFlug=600*Richtung;
                                Fighter2_id.yFlug=900;
                                Fighter2_id.x+=2000*Richtung;
                            ELSE
                                Fighter2_id.SLZ-=50;
                                Fighter2_id.Schaden+=Rand(10,20);
                                Fighter2_id.xFlug=95*Richtung;
                                Fighter2_id.yFlug=100;
                                Fighter2_id.x+=100*Richtung;
                            END
                            Fighter2_id.Angriffsart=Rand(1,2);
                            Fighter2_id.AttackAnimX=x+(3500*Richtung)+Rand(-1500,1500);
                            Fighter2_id.AttackAnimY=y+Rand(-3000,3000);
                            Fighter2_id.AttackAnimSize=75;
                            Fighter2_id.AttackAnimGraph=4;

                        END
                        IF(Spielernr==2)

                            IF(FrameVar>55)
                                Fighter1_id.SLZ-=600;
                                Fighter1_id.Schaden+=50;
                                Fighter1_id.xFlug=600*Richtung;
                                Fighter1_id.yFlug=900;
                                Fighter1_id.x+=2000*Richtung;
                            ELSE
                                Fighter1_id.SLZ-=50;
                                Fighter1_id.Schaden+=Rand(10,20);
                                Fighter1_id.xFlug=95*Richtung;
                                Fighter1_id.yFlug=100;
                                Fighter1_id.x+=100*Richtung;
                            END
                            Fighter1_id.Angriffsart=Rand(1,2);
                            Fighter1_id.AttackAnimX=x+(3500*Richtung)+Rand(-1500,1500);
                            Fighter1_id.AttackAnimY=y+Rand(-3000,3000);
                            Fighter1_id.AttackAnimSize=75;
                            Fighter1_id.AttackAnimGraph=4;

                        END
                    END
                END
            END


            IF(FrameVar==1)
                DontMove=20;
                EnergyLoad(x,y,150,7);
            END

            IF(FrameVar>0 AND FrameVar<10)
                Graph=16;
            END
            IF(FrameVar>10 AND FrameVar<20)
                Graph=17;
                x+=700*Richtung;
            END
            IF(FrameVar>20 AND FrameVar<60)

                Graph=rand(0,6);
                IF(Graph==0) Graph=10; END
                IF(Graph==1) Graph=11; END
                IF(Graph==2) Graph=12; END
                IF(Graph==3) Graph=14; END
                IF(Graph==4) Graph=15; END
                IF(Graph==5) Graph=17; END
                IF(Graph==6) Graph=18; END

            END


        END




        IF(SpezialOn!=0)
            IF(Spezialratio>0)
                Spezialratio--;
            ELSE
                SpezialAnim(x,y,Graph,flags,file,500);
                Spezialratio=SpezialOn;
            END
        END
        //Minifight(x,y,Graph,flags,file);
        Oldposition=Position;

        IF(MODE==1)
            SMTC(x,y);
        END

        IF(SLZ>0)     // Ja hier kommt noch mal dasselbe, aber
            SLZ=0;    // das muss halt eben so sein!
        END

        //Jetzt kommt das Mana-Element


        IF(Mana<0)
            IF(Mana<10000)
                Mana+=(8+(6000-Lifepoints)/500)/2;
            ELSE
                Mana=10000;
            END
        ELSE
            IF(Mana<10000)
                Mana+=8+(6000-Lifepoints)/500;
            ELSE
                Mana=10000;
            END
        END







        LOOP
            FRAME;
            IF(DontMove<1) BREAK; END
        END
        SpezialOn=0;

      END




























      IF(Charakter==3)

        //----------------------------------------------//
        //++++++++++++++++++++++++++++++++++++++++++++++//
        //                                              //
        //   EEEEEEE IIIII   GGGGG    EEEEEEE NN   NN   //
        //   EE         II  GG   GG   EE      NNN  NN   //
        //   EE         II  GG   GG   EE      NNNN NN   //
        //   EEEEEEE    II  GG        EEEEEEE NN N NN   //
        //   EE         II  GG  GGG   EE      NN NNNN   //
        //   EE      II II  GG   GG   EE      NN  NNN   //
        //   EEEEEEE  III    GGGG G   EEEEEEE NN   NN   //
        //                                              //
        //++++++++++++++++++++++++++++++++++++++++++++++//
        //----------------------------------------------//







       //Welche Knoepfe werden gedrueckt?


        _Links_Knopf=0;
        _Rechts_Knopf=0;
        _Hoch_Knopf=0;
        _Runter_Knopf=0;
        _Schlag1_Knopf=0;
        _Schlag2_Knopf=0;
        _Schlag3_Knopf=0;
        _Spezial_Knopf=0;


       IF(Spielerart==1)

        IF((key(_d) AND Spielernr==1) OR (key(_up) AND Spielernr==2))
            _Hoch_Knopf=1;
        END
        IF((key(_c) AND Spielernr==1) OR (key(_down) AND Spielernr==2))
            _Runter_Knopf=1;
        END
        IF((key(_x) AND Spielernr==1) OR (key(_left) AND Spielernr==2))
            _Links_Knopf=1;
        END
        IF((key(_v) AND Spielernr==1) OR (key(_right) AND Spielernr==2))
            _Rechts_Knopf=1;
        END
        IF(((key(_1) AND Spielernr==1) OR (key(_9) AND Spielernr==2)) AND FFP_Schlag1!=1)
            _Schlag1_Knopf=1;
            FFP_Schlag1=1;
        END
        IF(NOT ((key(_1) AND Spielernr==1) OR (key(_9) AND Spielernr==2)))
            FFP_Schlag1=0;
        END

        IF(((key(_2) AND Spielernr==1) OR (key(_0) AND Spielernr==2)) AND FFP_Schlag2!=1)
            _Schlag2_Knopf=1;
            FFP_Schlag2=1;
        END
        IF(NOT ((key(_2) AND Spielernr==1) OR (key(_0) AND Spielernr==2)))
            FFP_Schlag2=0;
        END

        IF(((key(_3) AND Spielernr==1) OR (key(_minus) AND Spielernr==2)) AND FFP_Schlag3!=1)
            _Schlag3_Knopf=1;
            FFP_Schlag3=1;
        END
        IF(NOT ((key(_3) AND Spielernr==1) OR (key(_minus) AND Spielernr==2)))
            FFP_Schlag3=0;
        END

        IF(((key(_4) AND Spielernr==1) OR (key(_plus) AND Spielernr==2)) AND FFP_Spezial!=1)
            _Spezial_Knopf=1;
            FFP_Spezial=1;
        END
        IF(NOT ((key(_4) AND Spielernr==1) OR (key(_plus) AND Spielernr==2)))
            FFP_Spezial=0;
        END

       END












       /*
       //Die KI greift ein
       IF(Spielerart==2)
        IF(Spielernr==1)
            Xdist=fget_dist(x,0,fighter2_id.x,0);
            Ydist=fget_dist(0,y,0,fighter2_id.y);
        END
        IF(Spielernr==2)
            Xdist=fget_dist(x,0,fighter1_id.x,0);
            Ydist=fget_dist(0,y,0,fighter1_id.y);
        END



        IF(Rand(0,20)==0)
            KIToBlock=0;
        END
        IF(Rand(0,150)==0)
            KIToBlock=1;
        END

        IF(KIToBlock==1 AND (Position==1 OR Position==2 OR Position==3 OR Position==4))
            IF(Richtung==-1)
                _Rechts_Knopf=1;
            END
            IF(Richtung==1)
                _Links_Knopf=1;
            END
        END


        IF(Position==1)

            IF(XDist>5000 AND Mana==10000)
                IF(Richtung==1)
                    LB[1]=3;
                    LB[2]=1;
                    LB[3]=2;
                    _Schlag2_Knopf=1;
                END
                IF(Richtung==2)
                    LB[1]=2;
                    LB[2]=1;
                    LB[3]=3;
                    _Schlag2_Knopf=1;
                END

            END

            IF(Mana>1000 AND Rand(0,30)==0 AND Xdist<14000 AND YDist<4000)
                ClickedWait=10;
                IF(Richtung==1)
                    LB[2]=1;
                    LB[1]=3;
                    _Schlag1_Knopf=1;
                ELSE
                    LB[2]=1;
                    LB[1]=2;
                    _Schlag1_Knopf=1;
                END
            END
            IF(XDist<7000 AND YDist<3000 AND Rand(0,10)==0)
                _Schlag1_Knopf=1;
            END
            IF(XDist<10000 AND YDist<3000 AND Rand(0,20)==0)
                _Schlag2_Knopf=1;
            END
            IF(XDist>4000 AND KIToBlock!=1)
                IF(Richtung==-1)
                    _Links_Knopf=1;
                END
                IF(Richtung==1)
                    _Rechts_Knopf=1;
                END
            END
            IF((YDist>8000 AND Rand(0,30)==0) OR Rand(0,80)==0)
                _Hoch_Knopf=1;
            END
            IF(Rand(0,200)==0 OR (Otherfighter_id.position==4 AND XDist<6000 AND
               Rand(0,15)==0) OR (Otherfighter_id.position==7 AND XDist<6000 AND
               Rand(0,6)==0))
                _Runter_Knopf=1;
            END

        END

        IF(Position==2)

            IF(XDist>20000 AND Mana>4500 AND Rand(0,200)==0)
                IF(Richtung==1)
                    LB[1]=3;
                    LB[2]=1;
                    LB[3]=2;
                    _Schlag2_Knopf=1;
                END
                IF(Richtung==2)
                    LB[1]=2;
                    LB[2]=1;
                    LB[3]=3;
                    _Schlag2_Knopf=1;
                END
            END
            IF(XDist>5000 AND Mana==10000)
                IF(Richtung==1)
                    LB[1]=3;
                    LB[2]=1;
                    LB[3]=2;
                    _Schlag2_Knopf=1;
                END
                IF(Richtung==2)
                    LB[1]=2;
                    LB[2]=1;
                    LB[3]=3;
                    _Schlag2_Knopf=1;
                END

            END

            IF(XDist>4000 AND KIToBlock!=1)
                IF(Richtung==-1)
                    _Links_Knopf=1;
                END
                IF(Richtung==1)
                    _Rechts_Knopf=1;
                END
            END
            IF((YDist>8000 AND Rand(0,30)==0) OR Rand(0,80)==0)
                _Hoch_Knopf=1;
            END
            IF(Rand(0,200)==0 OR (Otherfighter_id.position==4 AND XDist<6000 AND
               Rand(0,15)==0) OR (Otherfighter_id.position==7 AND XDist<6000 AND
               Rand(0,6)==0))
                _Runter_Knopf=1;
            END
        END

        IF(Position==3)


            IF(YDist>1000)
                IF(Jumpspeed<700)
                    IF(Mana>3000)
                        _Hoch_Knopf=1;
                    END
                ELSE
                    _Hoch_Knopf=1;
                END
            END
            IF(XDist>3000 AND KIToBlock!=1)
                IF(Richtung==-1)
                    _Links_Knopf=1;
                END
                IF(Richtung==1)
                    _Rechts_Knopf=1;
                END
            END
            IF(XDist<14000 AND YDist<16000 AND Rand(0,5)==0)
                _Schlag1_Knopf=1;
            END
            IF(XDist<19000 AND YDist<16000 AND Rand(0,10)==0)
                _Schlag2_Knopf=1;
            END

        END

        IF(Position==4)
            _Runter_Knopf=1;
            IF(Rand(0,300)==0 OR (XDist>6000 AND rand(0,60)==0) OR
                (Otherfighter_id.position==3 AND Rand(0,30)==0))
                _Runter_Knopf=0;
            END

            IF(XDist<7000 AND YDist<4000 AND Rand(0,10)==0)
                _Schlag1_Knopf=1;
            END
            IF(XDist<8000 AND YDist<4000 AND Rand(0,15)==0)
                _Schlag2_Knopf=1;
            END

        END

        IF(Position==5 OR Position==6 OR Position==7)
            IF(SLZ>=0)
                IF(Rand(0,20)==0)
                    IF(Richtung==1)
                        _Rechts_Knopf=1;
                    END
                    IF(Richtung==-1)
                        _Links_Knopf=1;
                    END
                END
                IF(Rand(0,30)==0)
                    _Hoch_Knopf=1;
                END
                IF(Rand(0,40)==0)
                    IF(Richtung==1)
                        _Links_Knopf=1;
                    END
                    IF(Richtung==-1)
                        _Rechts_Knopf=1;
                    END
                END
            END

        END
        IF(Position==13)
            IF(Punchwait==1)
                IF(Rand(0,3)==0)
                _Hoch_Knopf=1;
                END
            END
        END






       END*/





       //Die KI greift ein
       IF(Spielerart==2)
        IF(Spielernr==1)
            Xdist=fget_dist(x,0,fighter2_id.x,0);
            Ydist=fget_dist(0,y,0,fighter2_id.y);
        END
        IF(Spielernr==2)
            Xdist=fget_dist(x,0,fighter1_id.x,0);
            Ydist=fget_dist(0,y,0,fighter1_id.y);
        END



        IF(Rand(0,20)==0)
            KIToBlock=0;
        END
        IF(Rand(0,150)==0)
            KIToBlock=1;
        END

        IF(KIToBlock==1 AND (Position==1 OR Position==2 OR Position==3 OR Position==4))
            IF(Richtung==-1)
                _Rechts_Knopf=1;
            END
            IF(Richtung==1)
                _Links_Knopf=1;
            END
        END


        IF(Position==1)

            IF(XDist>5000 AND Mana==10000)
                IF(Richtung==1)
                    LB[1]=3;
                    LB[2]=1;
                    LB[3]=2;
                    _Schlag2_Knopf=1;
                END
                IF(Richtung==-1)
                    LB[1]=2;
                    LB[2]=1;
                    LB[3]=3;
                    _Schlag2_Knopf=1;
                END

            END

            IF(Mana>1000 AND Rand(0,10)==0 AND Xdist<14000 AND YDist<4000)
                ClickedWait=10;
                IF(Richtung==1)
                    LB[2]=1;
                    LB[1]=3;
                    _Schlag1_Knopf=1;
                ELSE
                    LB[2]=1;
                    LB[1]=2;
                    _Schlag1_Knopf=1;
                END
            END
            IF(XDist<7000 AND YDist<3000 AND Rand(0,3)==0)
                _Schlag1_Knopf=1;
            END
            IF(XDist<10000 AND YDist<3000 AND Rand(0,2)==0)
                _Schlag2_Knopf=1;
            END
            IF(XDist>4000 AND KIToBlock!=1)
                IF(Richtung==-1)
                    _Links_Knopf=1;
                END
                IF(Richtung==1)
                    _Rechts_Knopf=1;
                END
            END
            IF((YDist>8000 AND Rand(0,6)==0) OR Rand(0,12)==0)
                _Hoch_Knopf=1;
            END
            IF(Rand(0,200)==0 OR (Otherfighter_id.position==4 AND XDist<6000 AND
               Rand(0,15)==0) OR (Otherfighter_id.position==7 AND XDist<6000 AND
               Rand(0,6)==0))
                _Runter_Knopf=1;
            END

        END

        IF(Position==2)

            IF(XDist>20000 AND Mana>4500 AND Rand(0,50)==0)
                IF(Richtung==1)
                    LB[1]=3;
                    LB[2]=1;
                    LB[3]=2;
                    _Schlag2_Knopf=1;
                END
                IF(Richtung==-1)
                    LB[1]=2;
                    LB[2]=1;
                    LB[3]=3;
                    _Schlag2_Knopf=1;
                END
            END
            IF(XDist>5000 AND Mana==10000)
                IF(Richtung==1)
                    LB[1]=3;
                    LB[2]=1;
                    LB[3]=2;
                    _Schlag2_Knopf=1;
                END
                IF(Richtung==-1)
                    LB[1]=2;
                    LB[2]=1;
                    LB[3]=3;
                    _Schlag2_Knopf=1;
                END

            END

            IF(XDist>4000 AND KIToBlock!=1)
                IF(Richtung==-1)
                    _Links_Knopf=1;
                END
                IF(Richtung==1)
                    _Rechts_Knopf=1;
                END
            END
            IF((YDist>8000 AND Rand(0,30)==0) OR Rand(0,80)==0)
                _Hoch_Knopf=1;
            END
            IF(Rand(0,200)==0 OR (Otherfighter_id.position==4 AND XDist<6000 AND
               Rand(0,15)==0) OR (Otherfighter_id.position==7 AND XDist<6000 AND
               Rand(0,6)==0))
                _Runter_Knopf=1;
            END
        END

        IF(Position==3)


            IF(YDist>1000)
                IF(Jumpspeed<700)
                    IF(Mana>3000)
                        _Hoch_Knopf=1;
                    END
                ELSE
                    _Hoch_Knopf=1;
                END
            END
            IF(XDist>3000 AND KIToBlock!=1)
                IF(Richtung==-1)
                    _Links_Knopf=1;
                END
                IF(Richtung==1)
                    _Rechts_Knopf=1;
                END
            END
            IF(XDist<14000 AND YDist<16000 AND Rand(0,3)==0)
                _Schlag1_Knopf=1;
            END
            IF(XDist<19000 AND YDist<16000 AND Rand(0,2)==0)
                _Schlag2_Knopf=1;
            END

        END

        IF(Position==4)
            _Runter_Knopf=1;
            IF(Rand(0,300)==0 OR (XDist>6000 AND rand(0,60)==0) OR
                (Otherfighter_id.position==3 AND Rand(0,30)==0))
                _Runter_Knopf=0;
            END

            IF(XDist<7000 AND YDist<4000 AND Rand(0,2)==0)
                _Schlag1_Knopf=1;
            END
            IF(XDist<8000 AND YDist<4000 AND Rand(0,1)==0)
                _Schlag2_Knopf=1;
            END

        END

        IF(Position==5 OR Position==6 OR Position==7)
            IF(SLZ>=0)
                IF(Rand(0,20)==0)
                    IF(Richtung==1)
                        _Rechts_Knopf=1;
                    END
                    IF(Richtung==-1)
                        _Links_Knopf=1;
                    END
                END
                IF(Rand(0,30)==0)
                    _Hoch_Knopf=1;
                END
                IF(Rand(0,40)==0)
                    IF(Richtung==1)
                        _Links_Knopf=1;
                    END
                    IF(Richtung==-1)
                        _Rechts_Knopf=1;
                    END
                END
            END

        END
        IF(Position==13)
            IF(Punchwait==1)
                IF(Rand(0,1)==0)
                _Hoch_Knopf=1;
                END
            END
        END






       END





















        //KnoepfeSpeicherung


        IF(_Runter_Knopf==1 AND LB[1]!=1)
            ClickedWait=10;
            LB[5]=LB[4];
            LB[4]=LB[3];
            LB[3]=LB[2];
            LB[2]=LB[1];
            LB[1]=1;
        END

        IF(_Links_Knopf==1 AND LB[1]!=2)
            ClickedWait=10;
            LB[5]=LB[4];
            LB[4]=LB[3];
            LB[3]=LB[2];
            LB[2]=LB[1];
            LB[1]=2;
        END

        IF(_Rechts_Knopf==1 AND LB[1]!=3)
            ClickedWait=10;
            LB[5]=LB[4];
            LB[4]=LB[3];
            LB[3]=LB[2];
            LB[2]=LB[1];
            LB[1]=3;
        END


        IF(_Hoch_Knopf==1 AND LB[1]!=4)
            ClickedWait=10;
            LB[5]=LB[4];
            LB[4]=LB[3];
            LB[3]=LB[2];
            LB[2]=LB[1];
            LB[1]=4;
        END

        ClickedWait--;
        IF(ClickedWait<0)
            LB[5]=0;
            LB[4]=0;
            LB[3]=0;
            LB[2]=0;
            LB[1]=0;
        END




        IF(Oldposition!=Position)
            Picturenumber=1;
        END

        //Gegner schubsen!
        //
        IF(Spielernr==1)
            Xdist=fget_dist(x,0,fighter2_id.x,0);
            Ydist=fget_dist(0,y,0,fighter2_id.y);

            IF(Xdist<1500)
                IF(Ydist<4500)
                    IF(Fighter2_id.x<x)
                        x+=(1500-Xdist);
                      ELSE
                       x-=(1500-Xdist);
                    END
                END
            END
        END

        IF(Spielernr==2)
            Xdist=fget_dist(x,0,fighter1_id.x,0);
            Ydist=fget_dist(0,y,0,fighter1_id.y);

            IF(Xdist<1500)
                IF(Ydist<4500)
                    IF(Fighter1_id.x<x)
                        x+=(1500-Xdist);
                      ELSE
                       x-=(1500-Xdist);
                    END
                END
            END
        END



        //Aus Bildschirm fliegen!
        //
        IF(x>64000)
            x=63999;
            IF(Position==3 OR Position==10 OR Position==11)
                Jumpspeedlr=-(Jumpspeedlr+10);
                Jumpspeed+=500;
            END
            IF(Position==6)
                Lifepoints-=(abs(xFlug))/5;
                AnimHau(x,y,abs(xFlug)/2,4);
                xFlug=-(xFlug/2);
            END

        END
        IF(x<0)
            x=1;
            IF(Position==3 OR Position==10 OR Position==11)
                Jumpspeedlr=-(Jumpspeedlr+10);
                Jumpspeed+=500;
            END
            IF(Position==6)
                Lifepoints-=(abs(xFlug))/5;
                AnimHau(x,y,abs(xFlug)/2,4);
                xFlug=-(xFlug/2);
            END

        END
        IF(y<0)
            y=1;
            Jumpspeed=-Jumpspeed;

        END



        Blockposition=0;    //Wenn man nicht blockt dann blockt man nicht!









        //******************************************************************
        IF(Position==1)      //Stehen

            StehPosition=2;


            //Nach rechts und links drehen
            //
            IF(Spielernr==1)
                IF(Fighter2_id.x>x)
                    Flags=0;
                    Richtung=1;
                  ELSE
                   Flags=1;
                   Richtung=-1;
                END
            END
            IF(Spielernr==2)
                IF(Fighter1_id.x>x)
                    Flags=0;
                    Richtung=1;
                  ELSE
                   Flags=1;
                   Richtung=-1;

                END
            END



            //Auf Knoepfe reagieren
            //
            IF(_Hoch_Knopf==1)
                Position=3;
                Jumpspeed=1200;
            END
            IF(_Runter_Knopf==1)
                Position=4;
            END
            IF(_Links_Knopf==1)
                Position=2;
            END
            IF(_Rechts_Knopf==1)
                Position=2;
            END
            IF(_Rechts_Knopf==1 AND _Links_Knopf==1)
                Position=1;
            END


            IF(_Schlag1_Knopf==1)

                IF(LookForMove(LB[1],LB[2],LB[3],LB[4],LB[5])*Richtung==1 AND Mana>0)
                    Mana-=2500;
                    Position=20;
                    ClickedWait=-1;
                ELSE
                    Position=8;
                END
            END

            IF(_Schlag2_Knopf==1)
                IF(LookForMove(LB[1],LB[2],LB[3],LB[4],LB[5])*Richtung==2 AND Mana>0)
                    Mana-=5000;
                    Position=21;
                    ClickedWait=-1;
                ELSE
                    Position=9;
                END
            END




            //Bilder zeigen
            //
            Graph=(Picturenumber+15)/15;
            Picturenumber=((Picturenumber) mod 59)+1;

        END


        //******************************************************************
        IF(Position==2)        //Gehen
            StehPosition=2;

            //Wenn man sich nicht mehr bewegt dann stehen!
            //
            Position=1;


            //Auf Knoepfe reagieren
            //
            IF(_Links_Knopf==1)
                x-=200;
                Position=2;
                IF(Spielernr==1)
                    IF(Fighter2_id.x>x)
                        Blockposition=2;
                    END
                END
                IF(Spielernr==2)
                    IF(Fighter1_id.x>x)
                        Blockposition=2;
                    END
                END

            END
            IF(_Rechts_Knopf==1)
                x+=200;
                Position=2;
                IF(Spielernr==1)
                    IF(Fighter2_id.x<x)
                        Blockposition=2;
                    END
                END
                IF(Spielernr==2)
                    IF(Fighter1_id.x<x)
                        Blockposition=2;
                    END
                END
            END
            IF(_Rechts_Knopf==1 AND _Links_Knopf==1)
                Position=1;

            END //Man klickt in beide Richtungen!

            IF(_Hoch_Knopf==1)
                Position=3;
                Jumpspeed=1200;
                IF(_Links_Knopf==1)
                    Jumpspeedlr=-200;
                END
                IF(_Rechts_Knopf==1)
                    Jumpspeedlr=+200;
                END
            END
            IF(_Runter_Knopf==1)
                Position=4;
            END

            IF(_Schlag1_Knopf==1)

                IF(LookForMove(LB[1],LB[2],LB[3],LB[4],LB[5])*Richtung==1 AND Mana>0)
                    Mana-=2500;
                    Position=20;
                    ClickedWait=-1;
                ELSE
                    Position=8;
                END
            END
            IF(_Schlag2_Knopf==1)
                IF(LookForMove(LB[1],LB[2],LB[3],LB[4],LB[5])*Richtung==2 AND Mana>0)
                    Mana-=5000;
                    Position=21;
                    ClickedWait=-1;
                ELSE
                    Position=9;
                END
            END

            //Bilder zeigen
            //
            Graph=((Picturenumber+11)/11)+4;
            Picturenumber=((Picturenumber) mod 21)+1;

        END







        //******************************************************************
        IF(Position==3)         //Springen
            StehPosition=3;


            //Nach rechts und links drehen
            //
            IF(Spielernr==1)
                IF(Fighter2_id.x>x)
                    Flags=0;
                    Richtung=1;
                  ELSE
                   Flags=1;
                   Richtung=-1;
                END
            END
            IF(Spielernr==2)
                IF(Fighter1_id.x>x)
                    Flags=0;
                    Richtung=1;
                  ELSE
                   Flags=1;
                   Richtung=-1;

                END
            END


            Graph=7;
            IF(_Hoch_Knopf==1)
                IF(Jumpspeed>700)
                    Jumpspeed+=20;

                ELSE
                    IF(Mana>0)
                        Jumpspeed+=150;
                        Mana-=30;
                        Graph=28;
                    END
                END

            END
            IF(_Links_Knopf==1)
                Jumpspeedlr+=-55;
                IF(Spielernr==1)
                    IF(Fighter2_id.x>x)
                        Blockposition=3;
                    END
                END
                IF(Spielernr==2)
                    IF(Fighter1_id.x>x)
                        Blockposition=3;
                    END
                END
            END
            IF(_Rechts_Knopf==1)
                Jumpspeedlr+=+55;
                IF(Spielernr==1)
                    IF(Fighter2_id.x<x)
                        Blockposition=3;
                    END
                END
                IF(Spielernr==2)
                    IF(Fighter1_id.x<x)
                        Blockposition=3;
                    END
                END
            END
            IF(_Schlag1_Knopf==1)
                Position=10;
            END
            IF(_Schlag2_Knopf==1)
                Position=11;
                //Jumpspeed-=500;
                //Jumpspeedlr+=500*Richtung;

            END


            //Hoch/Runter-Bewegen
            //
            y-=Jumpspeed;
            x+=Jumpspeedlr;
            Jumpspeed-=100;

            //Pruefen wie tief man ist
            //
            IF(y>=37000)
                y=37000;
                Position=1;
                Jumpspeedlr=0;
            END



            //Bilder zeigen
            //
            IF(Graph==28)
                Graph=((Picturenumber)/11)+28;
            ELSE
                IF(Jumpspeed>0)
                    Graph=7;
                END
                IF(Jumpspeed<0)
                    Graph=8;
                END

            END
            Picturenumber=((Picturenumber) mod 21)+1;

        END


        //***************************************************************
        IF(Position==4)       //Buecken
            StehPosition=1;

            //Nach rechts und links drehen
            //
            IF(Spielernr==1)
                IF(Fighter2_id.x>x)
                    Flags=0;
                    Richtung=1;
                  ELSE
                   Flags=1;
                   Richtung=-1;
                END
            END
            IF(Spielernr==2)
                IF(Fighter1_id.x>x)
                    Flags=0;
                    Richtung=1;
                  ELSE
                   Flags=1;
                   Richtung=-1;

                END
            END

            //Auf Knoepfe reagieren
            //
            IF(_Runter_Knopf==0)
                Position=1;
            END
            IF(_Links_Knopf==1)
                IF(Spielernr==1)
                    IF(Fighter2_id.x>x)
                        Blockposition=1;
                    END
                END
                IF(Spielernr==2)
                    IF(Fighter1_id.x>x)
                        Blockposition=1;
                    END
                END
            END
            IF(_Rechts_Knopf==1)
                IF(Spielernr==1)
                    IF(Fighter2_id.x<x)
                        Blockposition=1;
                    END
                END
                IF(Spielernr==2)
                    IF(Fighter1_id.x<x)
                        Blockposition=1;
                    END
                END
            END
            IF(_Schlag1_Knopf==1)
                Position=12;
            END
            IF(_Schlag2_Knopf==1)
                Position=13;
            END


            Graph=9;

        END


        //**************************************************************
        //Da man auf die SLZ- und Block-Positionen nicht durch
        //eigene Knoepfe kommt, kommt hier ein Einschub
        //**************************************************************

        //
        //Ganz wichtig: Das Blocken!
        //

        //Wenn man liegt...
        IF(Position==7)
            IF(Angriffsart==2)
                SLZ=0;
                Schaden=0;
                xFlug=0;
                yFlug=0;
                AngriffsArt=0;
            END
            IF(Angriffsart==3)
                SLZ=0;
                Schaden=0;
                xFlug=0;
                yFlug=0;
                AngriffsArt=0;
            END
        END

        //Wenn man Bueckt...
        IF(Position==4 OR Position==12 OR Position==13 OR Position==14)
            IF(Angriffsart==2)
                SLZ=0;
                Schaden=0;
                xFlug=0;
                yFlug=0;
                AngriffsArt=0;
            END
        END

        IF(10!=10)
            write(0,360,240,4,"Der DIV-Maker spinnt!"); //Yeah! Very Funny...
        END

        //Wenn man blockt!
        IF(Blockposition!=0 AND Angriffsart!=0)
            IF(Blockposition==1)    //Der Bueckend-Blockende...
                IF(Angriffsart==1)  //...wird von einem Bueckendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    Dontmove=HitDontWait;

                END
                IF(Angriffsart==2)  //...wird von einem Stehendem angegriffen
                    SLZ=0;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;

                END
                IF(Angriffsart==3)  //...wird von einem Springendem angegriffen
                    Lifepoints-=Schaden;
                    Schaden=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    AngriffsArt=0;           //????????????
                    Dontmove=HitDontWait;
                END
            END
            IF(Blockposition==2)    //Der Stehend-Blockende...
                IF(Angriffsart==1)  //...wird von einem Bueckendem angegriffen
                    Lifepoints-=Schaden;
                    Schaden=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    AngriffsArt=0;           //????????????
                    Dontmove=HitDontWait;
                END
                IF(Angriffsart==2)  //...wird von einem Stehendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    Dontmove=HitDontWait;
                END
                IF(Angriffsart==3)  //...wird von einem Springendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    Dontmove=HitDontWait;
                END
            END
            IF(Blockposition==3)    //Der Springend-Blockende...
                IF(Angriffsart==1)  //...wird von einem Bueckendem angegriffen
                    Lifepoints-=Schaden;
                    Schaden=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    AngriffsArt=0;           //????????????
                    Dontmove=HitDontWait;
                END
                IF(Angriffsart==2)  //...wird von einem Stehendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    Dontmove=HitDontWait;
                END
                IF(Angriffsart==3)  //...wird von einem Springendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                    AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
                    AttackAnimX=0;
                    AttackAnimY=0;
                    AttackAnimSize=0;
                    AttackAnimGraph=0;
                    Dontmove=HitDontWait;
                END
            END
        END


        //
        //Die die nicht blocken haben einen KO-Schlag verdient
        //
        IF(Schaden!=0)
            Lifepoints-=Schaden;
            Schaden=0;
            AnimHau(AttackAnimX,AttackAnimY,AttackAnimSize,AttackAnimGraph);
            AttackAnimX=0;
            AttackAnimY=0;
            AttackAnimSize=0;
            AttackAnimGraph=0;
            AngriffsArt=0;                   //????????????
            Dontmove=HitDontWait;
        END


        //SLZ im Vergleich zum Template ueberarbeitet!


        IF(SLZ<0)
            SLZTime++;
            IF(SLZTime>90)
                SLZ=0;
            END
        END




        IF(Position==1 OR Position==2 OR Position==4 OR Position==5)
            IF(SLZ<0)
                FrameVar=0;
                Position=5;
                IF(SLZ<-500)
                    FrameVar=0;
                    Position=6;
                END
            END
        END

        IF((Position==3 OR Position==6) AND SLZ<0)
            FrameVar=0;
            Position=6;
        END

        IF((Position==7) AND SLZ<0)
            FrameVar=0;
            Position=7;
        END

        IF(SLZ<0)
            Erhohlspeed=-10;
        END

        IF(SLZ>0)
            SLZ=0;
        END

        IF(SLZ==0 AND Position!=6 AND Position!=7 )
            xFlug=0;
            yFlug=0;
        END

        IF(SLZ==0 AND Position!=5 AND Position!=6 AND Position!=7 )
            IF(SLZTime>0)
                SLZTime-=3;
              ELSE
               SLZTime=0;
            END

            IF(erhohlspeed>0)
                erhohlspeed+=3;
              ELSE
               erhohlspeed=0;
            END

            IF(SLZWaitplus>0)
                SLZWaitPlus-=3;
              ELSE
               SLZWaitplus=0;
            END
        END



        //********************************************************************
        IF(Position==5)     //Gehaut werden
            StehPosition=2;

            xFlug=0;
            yFlug=0;

            SLZ-=Erhohlspeed;


            IF(SLZ>=0)
                //Auf Knoepfe reagieren
                //
                IF(_Hoch_Knopf==1)
                    Position=3;
                    Jumpspeed=1200;
                END
                IF(_Runter_Knopf==1)
                    Position=4;
                END
                IF(_Links_Knopf==1)
                    Position=2;
                END
                IF(_Rechts_Knopf==1)
                    Position=2;
                END
                IF(_Links_Knopf==1 AND _Rechts_Knopf==1)
                    Position=1;
                END //Man klickt in beide Richtungen!
            END

            IF(SLZ<-500)
                Position=6;
            END

            //Bilder zeigen
            //
            Graph=10;

        END

        //*******************************************************************
        IF(Position==6)     //Wegfliegen
            StehPosition=3;

            SLZ-=Erhohlspeed;


            IF(SLZ>=0)
                IF(_Hoch_Knopf==1)
                    Position=3;
                    Jumpspeed=1000;
                END
                IF(_Links_Knopf==1)
                    Position=3;
                    Jumpspeed=800;
                    Jumpspeedlr=-400;
                END
                IF(_Rechts_Knopf==1)
                    Position=3;
                    Jumpspeed=800;
                    Jumpspeedlr=400;
                END
            END

            //Hoch/Runter-Bewegen
            //
            y-=yFlug;
            x+=xFlug;
            yFlug-=100;


            //Pruefen wie tief man ist
            //
            IF(y>=37000)
                y=37000;
                Position=7;
                xFlug=0;
                yFlug=0;
            END



            //Bilder zeigen
            //
            Graph=11;

        END


        //*******************************************************************
        IF(Position==7)     //Am Boden liegen
            StehPosition=1;

            Jumpspeed=0;
            Jumpspeedlr=0;
            SLZ-=Erhohlspeed*5;
            IF(XFlug!=0 OR YFlug!=0)
                Position=6;
            END

            IF(SLZ>=0)
                IF(_Hoch_Knopf==1)
                    Position=3;
                    Jumpspeed=500;
                END
                IF(_Links_Knopf==1)
                    Position=3;
                    Jumpspeed=300;
                    Jumpspeedlr=-300;
                END
                IF(_Rechts_Knopf==1)
                    Position=3;
                    Jumpspeed=300;
                    Jumpspeedlr=300;
                END
            END
            //Bilder zeigen
            //
            Graph=12;

        END


        //*******************************************************************
        IF(Position==8)     //Schwacher Schlag
            StehPosition=2;

            FrameVar++;

            IF(FrameVar>19)
                Position=1;
                Punchwait=0;
                FrameVar=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
                FrameVar=0;
            END

            IF(FrameVar>7 AND FrameVar<15 AND Punchwait==0)


                IF(Spielernr==1)
                    Xdist=fget_dist(x+(1000*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(1000*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter1_id.y);
                END


                IF(Xdist<2500)
                    IF(Ydist<2500)
                        x-=250*Richtung;
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=350;
                            Fighter2_id.Schaden+=50;
                            Fighter2_id.xFlug+=50*Richtung;
                            Fighter2_id.yFlug+=600;
                            Fighter2_id.x+=200*Richtung;
                            Fighter2_id.Angriffsart=2;
                            Fighter2_id.AttackAnimX=x+(1100*Richtung);
                            Fighter2_id.AttackAnimY=y;
                            Fighter2_id.AttackAnimSize=100;
                            Fighter2_id.AttackAnimGraph=4;

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=350;
                            Fighter1_id.Schaden+=50;
                            Fighter1_id.xFlug+=50*Richtung;
                            Fighter1_id.yFlug+=600;
                            Fighter1_id.x+=200*Richtung;
                            Fighter1_id.Angriffsart=2;
                            Fighter1_id.AttackAnimX=x+(1100*Richtung);
                            Fighter1_id.AttackAnimY=y;
                            Fighter1_id.AttackAnimSize=100;
                            Fighter1_id.AttackAnimGraph=4;

                        END
                    END
                END
            END


            IF(FrameVar<19)
                Graph=15;
            END
            IF(FrameVar<15)
                Graph=14;
            END
            IF(FrameVar<7)
                Graph=13;
            END
        END







        //*******************************************************************
        IF(Position==9)      //Starker Schlag
            StehPosition=2;

            FrameVar++;

            IF(FrameVar>39)
                Position=1;
                Punchwait=0;
                FrameVar=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar>9 AND FrameVar<22 AND Punchwait==0)


                IF(Spielernr==1)
                    Xdist=fget_dist(x+(2750*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(2750*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter1_id.y);
                END


                IF(Xdist<3400)
                    IF(Ydist<2500)
                        x-=350*Richtung;
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=499;
                            Fighter2_id.Schaden+=200;
                            Fighter2_id.xFlug+=1300*Richtung;
                            Fighter2_id.yFlug+=1000;
                            Fighter2_id.x+=900*Richtung;
                            Fighter2_id.Angriffsart=2;
                            Fighter2_id.AttackAnimX=x+(2750*Richtung);
                            Fighter2_id.AttackAnimY=y;
                            Fighter2_id.AttackAnimSize=250;
                            Fighter2_id.AttackAnimGraph=4;

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=499;
                            Fighter1_id.Schaden+=200;
                            Fighter1_id.xFlug+=1300*Richtung;
                            Fighter1_id.yFlug+=1000;
                            Fighter1_id.x+=900*Richtung;
                            Fighter1_id.Angriffsart=2;
                            Fighter1_id.AttackAnimX=x+(2750*Richtung);
                            Fighter1_id.AttackAnimY=y;
                            Fighter1_id.AttackAnimSize=250;
                            Fighter1_id.AttackAnimGraph=4;

                        END
                    END
                END
            END


            IF(FrameVar<39)
                Graph=16;
            END
            IF(FrameVar<33)
                Graph=18;
            END
            IF(FrameVar<19)
                Graph=17;
            END
            IF(FrameVar<9)
                Graph=16;
            END

        END

        //*******************************************************************
        IF(Position==10)         //Schwacher Schlag in der Luft
            StehPosition=3;

            FrameVar++;

            IF(FrameVar>12)
                Position=3;
                FrameVar=0;
                Punchwait=0;
            END

            //Hoch/Runter-Bewegen
            //
            y-=Jumpspeed;
            x+=Jumpspeedlr;
            Jumpspeed-=100;


            //Pruefen wie tief man ist
            //
            IF(y>=37000)
                y=37000;
                Jumpspeed=0;
                Jumpspeedlr=0;
                Position=1;
                FrameVar=0;
                Punchwait=0;
            END


            IF(SLZ<0)
                Position=6;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar>4 AND FrameVar<11 AND Punchwait==0)



                IF(Spielernr==1)
                    Xdist=fget_dist(x+(1700*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(1700*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter1_id.y);
                END


                IF(Xdist<3500)
                    IF(Ydist<3500)
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=350;
                            Fighter2_id.Schaden+=50;
                            Fighter2_id.xFlug+=175*Richtung;
                            Fighter2_id.yFlug+=700;
                            Fighter2_id.x+=600*Richtung;
                            Fighter2_id.Angriffsart=3;
                            Fighter2_id.AttackAnimX=x+(1700*Richtung);
                            Fighter2_id.AttackAnimY=y;
                            Fighter2_id.AttackAnimSize=60;
                            Fighter2_id.AttackAnimGraph=4;

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=350;
                            Fighter1_id.Schaden+=50;
                            Fighter1_id.xFlug+=175*Richtung;
                            Fighter1_id.yFlug+=700;
                            Fighter1_id.x+=600*Richtung;
                            Fighter1_id.Angriffsart=3;
                            Fighter1_id.AttackAnimX=x+(1700*Richtung);
                            Fighter1_id.AttackAnimY=y;
                            Fighter1_id.AttackAnimSize=60;
                            Fighter1_id.AttackAnimGraph=4;

                        END
                    END
                END
            END


            IF(FrameVar<12)
                Graph=20;
            END
            IF(FrameVar<4)
                Graph=19;
            END
        END


        //*******************************************************************
        IF(Position==11)         //Starker Schlag in der Luft
            StehPosition=3;

            FrameVar++;

            IF(FrameVar>19)
                Position=3;
                FrameVar=0;
                Punchwait=0;
            END

            //Hoch/Runter-Bewegen
            //
            y-=Jumpspeed;
            x+=Jumpspeedlr;
            Jumpspeed-=100;


            //Pruefen wie tief man ist
            //
            IF(y>=37000)
                y=37000;
                Jumpspeed=0;
                Jumpspeedlr=0;
                Position=1;
                FrameVar=0;
                Punchwait=0;
            END


            IF(SLZ<0)
                Position=6;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar<18 AND Punchwait==0)

                IF(Spielernr==1)
                    Xdist=fget_dist(x+(2000*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y+2200,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(2000*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y+2200,0,fighter1_id.y);
                END


                IF(Xdist<3500)
                    IF(Ydist<3500)
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=500;
                            Fighter2_id.Schaden+=200;
                            Fighter2_id.xFlug+=750*Richtung;
                            Fighter2_id.yFlug+=1300;
                            Fighter2_id.x+=600*Richtung;
                            Fighter2_id.Angriffsart=3;
                            Fighter2_id.AttackAnimX=x+(2000*Richtung);
                            Fighter2_id.AttackAnimY=y+2200;
                            Fighter2_id.AttackAnimSize=175;
                            Fighter2_id.AttackAnimGraph=6;

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=500;
                            Fighter1_id.Schaden+=200;
                            Fighter1_id.xFlug+=750*Richtung;
                            Fighter1_id.yFlug+=1300;
                            Fighter1_id.x+=600*Richtung;
                            Fighter1_id.Angriffsart=3;
                            Fighter1_id.AttackAnimX=x+(2000*Richtung);
                            Fighter1_id.AttackAnimY=y+2200;
                            Fighter1_id.AttackAnimSize=175;
                            Fighter1_id.AttackAnimGraph=6;

                        END
                    END
                END
            END


            Graph=21;

        END



        //*******************************************************************
        IF(Position==12)     //Schwacher Schlag Bueckend
            StehPosition=1;

            FrameVar++;

            IF(FrameVar>15)
                Position=4;
                FrameVar=0;
                Punchwait=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar>10 AND FrameVar<15 AND Punchwait==0)


                IF(Spielernr==1)
                    Xdist=fget_dist(x+(1200*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(1200*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter1_id.y);
                END


                IF(Xdist<3500)
                    IF(Ydist<2500)
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=150;
                            Fighter2_id.Schaden+=45;
                            Fighter2_id.xFlug+=50*Richtung;
                            Fighter2_id.yFlug+=400;
                            Fighter2_id.x+=150*Richtung;
                            Fighter2_id.Angriffsart=1;
                            Fighter2_id.AttackAnimX=x+(1100*Richtung);
                            Fighter2_id.AttackAnimY=y+2000;
                            Fighter2_id.AttackAnimSize=100;
                            Fighter2_id.AttackAnimGraph=4;

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=150;
                            Fighter1_id.Schaden+=45;
                            Fighter1_id.xFlug+=50*Richtung;
                            Fighter1_id.yFlug+=400;
                            Fighter1_id.x+=150*Richtung;
                            Fighter1_id.Angriffsart=1;
                            Fighter1_id.AttackAnimX=x+(1100*Richtung);
                            Fighter1_id.AttackAnimY=y+2000;
                            Fighter1_id.AttackAnimSize=100;
                            Fighter1_id.AttackAnimGraph=4;

                        END
                    END
                END
            END

            IF(FrameVar==10)
                x+=700*Richtung;
            END

            IF(FrameVar<15)
                Graph=24;
            END
            IF(FrameVar<10)
                Graph=23;
            END
            IF(FrameVar<5)
                Graph=22;
            END

        END


        //*******************************************************************
        IF(Position==13)     //Starker Schlag Bueckend
            StehPosition=1;

            FrameVar++;

            IF(FrameVar>32)
                Position=4;
                FrameVar=0;
                Punchwait=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar>13 AND FrameVar<19 AND Punchwait==0)


                IF(Spielernr==1)
                    Xdist=fget_dist(x+(5000*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(5000*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter1_id.y);
                END


                IF(Xdist<2500)
                    IF(Ydist<5000)
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=580;
                            Fighter2_id.Schaden+=300;
                            Fighter2_id.xFlug+=500*Richtung;
                            Fighter2_id.yFlug+=1300;
                            Fighter2_id.x+=150*Richtung;
                            Fighter2_id.Angriffsart=1;
                            Fighter2_id.AttackAnimX=x+(5000*Richtung);
                            Fighter2_id.AttackAnimY=y;
                            Fighter2_id.AttackAnimSize=200;
                            Fighter2_id.AttackAnimGraph=4;

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=580;
                            Fighter1_id.Schaden+=300;
                            Fighter1_id.xFlug+=500*Richtung;
                            Fighter1_id.yFlug+=1300;
                            Fighter1_id.x+=150*Richtung;
                            Fighter1_id.Angriffsart=1;
                            Fighter1_id.AttackAnimX=x+(5000*Richtung);
                            Fighter1_id.AttackAnimY=y;
                            Fighter1_id.AttackAnimSize=200;
                            Fighter1_id.AttackAnimGraph=4;

                        END
                    END
                END
            END

            IF(_Hoch_Knopf==1 AND Punchwait==1)
                Position=3;
                Jumpspeed=1200;
                Jumpspeedlr=500*Richtung;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar<32)
                Graph=27;
            END
            IF(FrameVar<15)
                Graph=26;
            END
            IF(FrameVar<10)
                Graph=25;
            END
        END

        //*******************************************************************
        IF(Position==20)      //SpezialMove1 Runter->Vor Schlag
            StehPosition=2;

            FrameVar++;

            IF(FrameVar>30)
                Position=1;
                FrameVar=0;
                Punchwait=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
            END




            IF(FrameVar==14)
                Schuss_Eigen_1(x,y,Richtung,Spielernr,1,file);

            END

            IF(FrameVar<30)
                Graph=31;
            END
            IF(FrameVar<7)
                Graph=30;
            END




        END

        //*******************************************************************
        IF(Position==21)      //SpezialMove2 Runter->Vor StarkerSchlag
            StehPosition=2;

            FrameVar++;

            IF(FrameVar>70)
                Position=1;
                FrameVar=0;
                Punchwait=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
            END




            IF(FrameVar==14)
                Schuss_Eigen_2(x,y,Richtung,Spielernr,file);
            END

            IF(FrameVar<70)
                Graph=32;
            END
            IF(FrameVar<7)
                Graph=30;
            END



        END







        IF(SpezialOn!=0)
            IF(Spezialratio>0)
                Spezialratio--;
            ELSE
                SpezialAnim(x,y,Graph,flags,file,500);
                Spezialratio=SpezialOn;
            END
        END
        //Minifight(x,y,Graph,flags,file);
        Oldposition=Position;

        IF(MODE==1)
            SMTC(x,y);
        END

        IF(SLZ>0)     // Ja hier kommt noch mal dasselbe, aber
            SLZ=0;    // das muss halt eben so sein!
        END

        //Jetzt kommt das Mana-Element


        IF(Mana<0)
            IF(Mana<10000)
                Mana+=(4+(6000-Lifepoints)/1000)/2;
            ELSE
                Mana=10000;
            END
        ELSE
            IF(Mana<10000)
                Mana+=4+(6000-Lifepoints)/1000;
            ELSE
                Mana=10000;
            END
        END







        LOOP
            FRAME;
            IF(DontMove<1) BREAK; END
        END
        SpezialOn=0;

      END















    END


END



PROCESS SpezialAnim(x,y,Graph,flags,file,Duration)

BEGIN
    z=10;
    resolution=100;
    FRAME(Duration);
    z++;
    FRAME(Duration);
    size+=5;
    z++;
    FRAME(Duration);
    flags+=4;
    z++;
    FRAME(Duration);
    size+=5;
    z++;
    FRAME(Duration);
END

PROCESS Minifight(x,y,Graph,flags,file)

BEGIN
    x+=40000;
    size=80;
    resolution=125;
    FRAME;
END


PROCESS HauPlatz(x,y,Xbreite,YBreite)

BEGIN
    Graph=1;
    resolution=100;
    Map_block_copy(0,1,500-Xbreite,500-Ybreite,2,500,500,2*Xbreite,2*Ybreite);
    FRAME;
END


PROCESS SMTC(x,y) //Showmethecenter

BEGIN
    graph=3;
    resolution=100;
    FRAME;
END


PROCESS AnimHau(X,Y,Size,Graph)

BEGIN
    z=-10;
    Flags=4;
    resolution=100;
    FRAME;
    Size+=4;
    FRAME;
    Size+=4;
    FRAME;
    Size+=4;
    FRAME;
    Size+=4;

END

PROCESS EnergyLoad(X,Y,Size,Graph)

BEGIN
    z=-10;
    Flags=4;
    resolution=100;
    FRAME;
    Size-=7;
    FRAME;
    Size-=7;
    FRAME;
    Size-=7;
    FRAME;
    Size-=7;
    FRAME;
    Size-=7;
    FRAME;
    Size-=7;
    FRAME;
    Size-=7;
    FRAME;
    Size-=7;
    FRAME;
    Size-=7;
    FRAME;

END




PROCESS LookForMove(LK1,LK2,LK3,LK4,LK5)   //Die Letzten 5 gedrueckten Knoepfe
//Nimmt an man Schaue nach rechts

BEGIN



    //3Knoepfer

    IF(LK1==3 AND LK2==1 AND LK3==2) //Zurueck->Ru1nter->Vor
        RETURN(2);
    END

    IF(LK1==2 AND LK2==1 AND LK3==3) //Vor->Runter->Zurueck
        RETURN(-2);
    END



    //2Knoepfer

    IF(LK1==3 AND LK2==1) //Runter->Vor
        RETURN(1);
    END

    IF(LK1==2 AND LK2==1) //Runter->Zurueck
        RETURN(-1);
    END




END

PROCESS DontMovePlus()

BEGIN
    Priority=-100;
    LOOP
        IF(DontMove>0)

            Dontmove--;

        END
        FRAME;

    END

END





































//Schuesse aller Charaktere




PROCESS Schuss_Eigen_1(x,y,Richtung,Spielernr,Art,file)

PRIVATE
    Zaehler;

BEGIN
    resolution=100;
    graph=101;
    x+=6000*Richtung;
    IF(Art==2)
        x-=3000*Richtung;
        y-=7000;
    END

    LOOP
        //x+=500*Richtung;
        //IF(Art==2)
        //    y+=250;
        //END
        angle+=rand(-180000,180000);
        Zaehler=(Zaehler+1) MOD 4;
        IF(Zaehler==1)
            AnimHau(x+rand(-4500,4500),y+rand(-4500,4500),rand(50,120),rand(8,9));
            AnimHau(x+rand(-100,100),y+rand(-100,100),rand(85,115),rand(8,9));
        END


        FrameVar++;
        IF(FrameVar>100)
            BREAK;
        END



        /*IF(MODE==1)
            HauPlatz(x,y,35,35);
        END*/


        IF(Spielernr==1)
            Xdist=fget_dist(x,0,fighter2_id.x,0);
            Ydist=fget_dist(0,y,0,fighter2_id.y);
        END
        IF(Spielernr==2)
            Xdist=fget_dist(x,0,fighter1_id.x,0);
            Ydist=fget_dist(0,y,0,fighter1_id.y);
        END


        IF(Xdist<3500 AND Ydist<3500 AND Punchwait!=1)
                Punchwait=1;
                IF(Spielernr==1)

                            Fighter2_id.SLZ-=450;
                            Fighter2_id.Schaden+=200;
                            Fighter2_id.xFlug+=600*Richtung;
                            Fighter2_id.yFlug+=800;
                            Fighter2_id.x+=400*Richtung;
                            IF(Fighter2_id.Stehposition==1)
                                Fighter2_id.Angriffsart=1;
                            END
                            IF(Fighter2_id.Stehposition==2)
                                Fighter2_id.Angriffsart=2;
                            END
                            Fighter2_id.AttackAnimX=x;
                            Fighter2_id.AttackAnimY=y;
                            Fighter2_id.AttackAnimSize=150;
                            Fighter2_id.AttackAnimGraph=rand(8,9);

                END
                IF(Spielernr==2)

                            Fighter1_id.SLZ-=450;
                            Fighter1_id.Schaden+=200;
                            Fighter1_id.xFlug+=600*Richtung;
                            Fighter1_id.yFlug+=800;
                            Fighter1_id.x+=400*Richtung;
                            IF(Fighter1_id.Stehposition==1)
                                Fighter1_id.Angriffsart=1;
                            END
                            IF(Fighter1_id.Stehposition==2)
                                Fighter1_id.Angriffsart=2;
                            END
                            Fighter1_id.AttackAnimX=x;
                            Fighter1_id.AttackAnimY=y;
                            Fighter1_id.AttackAnimSize=150;
                            Fighter1_id.AttackAnimGraph=rand(8,9);

                END
        END

        IF(FrameVar==20)
            Punchwait=0;
        END
        IF(FrameVar==40)
            Punchwait=0;
        END
        IF(FrameVar==60)
            Punchwait=0;
        END
        IF(FrameVar==80)
            Punchwait=0;
        END



        FRAME;



    END
END












PROCESS Schuss_Eigen_2(x,y,Richtung,Spielernr,file)

PRIVATE
    Zaehler;
    XSpeed;
    YSpeed;

BEGIN
    resolution=100;
    graph=101;
    x+=2700*Richtung;
    y-=6500;
    Size=0;
    LOOP
        Size+=2;
        AnimHau(x+rand(-45*Size,45*Size),y+rand(-45*Size,45*Size),Size+rand(-10,20),rand(8,9));
        Frame;
        IF(Size>75)
            BREAK;
        END

    END


    LOOP
        IF(Spielernr==1)
            IF(x+2*xspeed>Fighter2_id.x)
                IF(Xspeed>500)
                    Xspeed=500;
                END
                Xspeed-=25+rand(-10,10);
            END
            IF(x+2*xspeed<Fighter2_id.x)
                IF(Xspeed<-500)
                    Xspeed=-500;
                END
                Xspeed+=25+rand(-10,10);
            END
            IF(y+2*yspeed>Fighter2_id.y)
                IF(Yspeed>500)
                    Yspeed=500;
                END
                yspeed-=25+rand(-10,10);
            END
            IF(y+2*yspeed<Fighter2_id.y)
                IF(Yspeed<-500)
                    Yspeed=-500;
                END
                yspeed+=25+rand(-10,10);
            END
        END
        IF(Spielernr==2)
            IF(x+2*xspeed>Fighter1_id.x)
                IF(Xspeed>500)
                    Xspeed=500;
                END
                Xspeed-=25+rand(-10,10);
            END
            IF(x+2*xspeed<Fighter1_id.x)
                IF(Xspeed<-500)
                    Xspeed=-500;
                END
                Xspeed+=25+rand(-10,10);
            END
            IF(y+2*yspeed>Fighter1_id.y)
                IF(Yspeed>500)
                    Yspeed=500;
                END
                yspeed-=25+rand(-10,10);
            END
            IF(y+2*yspeed<Fighter1_id.y)
                IF(Yspeed<-500)
                    Yspeed=-500;
                END
                yspeed+=25+rand(-10,10);
            END
        END

        x+=xSpeed;
        y+=ySpeed;

        angle+=rand(-180000,180000);
        IF(rand(0,1))
            AnimHau(x+rand(-45*Size,45*Size),y+rand(-45*Size,45*Size),Size+rand(-10,20),rand(8,9));
        END

        FrameVar++;
        IF(FrameVar>300)
            size--;
            IF(Size<0)
                Break;
            END
        END



        /*IF(MODE==1)
            HauPlatz(x,y,20,20);
        END*/


        IF(Spielernr==1)
            Xdist=fget_dist(x,0,fighter2_id.x,0);
            Ydist=fget_dist(0,y,0,fighter2_id.y);
        END
        IF(Spielernr==2)
            Xdist=fget_dist(x,0,fighter1_id.x,0);
            Ydist=fget_dist(0,y,0,fighter1_id.y);
        END


        IF(Xdist<2000 AND Ydist<2000 AND Punchwait!=1)
                Punchwait=1;
                IF(Spielernr==1)

                            Fighter2_id.SLZ-=250;
                            Fighter2_id.Schaden+=100;
                            Fighter2_id.xFlug+=700*Richtung;
                            Fighter2_id.yFlug+=900;
                            Fighter2_id.x+=400*Richtung;
                            IF(Fighter2_id.Stehposition==1)
                                Fighter2_id.Angriffsart=1;
                            END
                            IF(Fighter2_id.Stehposition==2)
                                Fighter2_id.Angriffsart=2;
                            END
                            Fighter2_id.AttackAnimX=x;
                            Fighter2_id.AttackAnimY=y;
                            Fighter2_id.AttackAnimSize=100;
                            Fighter2_id.AttackAnimGraph=rand(8,9);

                END
                IF(Spielernr==2)

                            Fighter1_id.SLZ-=250;
                            Fighter1_id.Schaden+=100;
                            Fighter1_id.xFlug+=700*Richtung;
                            Fighter1_id.yFlug+=900;
                            Fighter1_id.x+=400*Richtung;
                            IF(Fighter1_id.Stehposition==1)
                                Fighter1_id.Angriffsart=1;
                            END
                            IF(Fighter1_id.Stehposition==2)
                                Fighter1_id.Angriffsart=2;
                            END
                            Fighter1_id.AttackAnimX=x;
                            Fighter1_id.AttackAnimY=y;
                            Fighter1_id.AttackAnimSize=100;
                            Fighter1_id.AttackAnimGraph=rand(8,9);

                END
        END

        Zaehler=(Zaehler+1) MOD 20;
        IF(Zaehler==0)
            Punchwait=0;
        END


        FRAME;



    END
END





















//------------------------------------//
//++++++++++++++++++++++++++++++++++++//
//                                    //
//   CCCCC  L         A    W   W   W  //
//  CC   CC L        A A   W   W   W  //
//  C       L       A   A  W   W   W  //
//  C       L      A     A W   W   W  //
//  C       L      AAAAAAA W   W   W  //
//  CC   CC L      A     A  W W W W   //
//   CCCCC  LLLLLL A     A   W   W    //
//                                    //
//++++++++++++++++++++++++++++++++++++//
//------------------------------------//


















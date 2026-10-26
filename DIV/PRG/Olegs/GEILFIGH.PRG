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
    MODE=0;         //0=PlayMode
                    //1=TestMode
                    //




LOCAL
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
                //
    BlockPosition;//Welcher Block wird ausgefuehrt?
                  //0=Keiner     (Keine Schadensaenderung)
                  //1=TiefStehend    (Schaden Stark reduziert)
                  //2=MitteBueckend   (Schaden noch viel staerker Reduziert)
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





    //ComputerVars
    ComputerKIAction;  //Welche Aktion wird durch die KI ausgefuehrt?
    ComputerKIMovement;//Wohin will die KI laufen?








BEGIN

    load_fpg("Olegs\Heatfigh.fpg");  // Loads graphics' file
    load_fpg("Olegs\HfTemp.fpg");  // Loads graphics' file
    load_fpg("Olegs\HfChain.fpg");  // Loads graphics' file
    load_map("Claw.map");  // Loads graphics' file
    //load_fnt("Olegs\Arena.fnt");  // Loads font type

    set_mode(m640x480);               // Sets video mode to 640x480
    set_fps(200,0);                    // Number of frames per second
    Fighter1_id=Fighter(1,0);
    Fighter2_id=Fighter(2,0);
    Write_Int(0,100,100,4,OFFSET fighter1_ID.SLZ);
    Write_Int(0,540,100,4,OFFSET fighter2_ID.SLZ);
    Write_Int(0,100,125,4,OFFSET fighter1_ID.Lifepoints);
    Write_Int(0,540,125,4,OFFSET fighter2_ID.Lifepoints);



END




PROCESS Fighter(Spielernr,Charakter)


BEGIN
    FRAME;
    resolution=100;

    IF(Spielernr==1)
        x=26000;
        y=37000;
    END
    IF(Spielernr==2)
        x=38000;
        y=37000;
    END
    IF(Charakter==1)
        graph=1;
        file=1;
    END
    IF(Charakter==2)
        graph=1;
        file=2;
    END

    LOOP

        //Welche Knoepfe werden gedrueckt?

        _Links_Knopf=0;
        _Rechts_Knopf=0;
        _Hoch_Knopf=0;
        _Runter_Knopf=0;
        _Schlag1_Knopf=0;
        _Schlag2_Knopf=0;
        _Schlag3_Knopf=0;
        _Spezial_Knopf=0;

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





        //------------------------------------------------------------------//
        //******************************************************************//
        //                                                                  //
        // TTTTTT  EEEEEEE  M       M  PPP   L         A    TTTTTT  EEEEEEE //
        //   TT    EE       MM     MM  P  P  L        A A     TT    EE      //
        //   TT    EE       M M   M M  P  P  L       A   A    TT    EE      //
        //   TT    EEEEEEE  M  M M  M  PPP   L      A     A   TT    EEEEEEE //
        //   TT    EE       M   M   M  P     L      AAAAAAA   TT    EE      //
        //   TT    EE       M       M  P     L      A     A   TT    EE      //
        //   TT    EEEEEEE  M       M  P     LLLLL  A     A   TT    EEEEEEE //
        //                                                                  //
        //******************************************************************//
        //------------------------------------------------------------------//




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
                FrameVar=12;
                Position=8;
            END
            IF(_Schlag2_Knopf==1)
                FrameVar=23;
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
                FrameVar=13;
                Position=10;
            END
            IF(_Schlag2_Knopf==1)
                FrameVar=19;
                Position=11;
                Jumpspeed-=500;
                Jumpspeedlr+=500*Richtung;

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
                FrameVar=12;
                Position=12;
            END
            IF(_Schlag2_Knopf==1)
                FrameVar=20;
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
                END
                IF(Angriffsart==2)  //...wird von einem Stehendem angegriffen
                    SLZ=0;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                END
                IF(Angriffsart==3)  //...wird von einem Springendem angegriffen
                    Lifepoints-=Schaden;
                    Schaden=0;
                END
            END
            IF(Blockposition==2)    //Der Stehend-Blockende...
                IF(Angriffsart==1)  //...wird von einem Bueckendem angegriffen
                    Lifepoints-=Schaden;
                    Schaden=0;
                END
                IF(Angriffsart==2)  //...wird von einem Stehendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                END
                IF(Angriffsart==3)  //...wird von einem Springendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                END
            END
            IF(Blockposition==3)    //Der Springend-Blockende...
                IF(Angriffsart==1)  //...wird von einem Bueckendem angegriffen
                    Lifepoints-=Schaden;
                    Schaden=0;
                END
                IF(Angriffsart==2)  //...wird von einem Stehendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                END
                IF(Angriffsart==3)  //...wird von einem Springendem angegriffen
                    SLZ=0;
                    Schaden=Schaden/10;
                    Lifepoints-=Schaden;
                    Schaden=0;
                    xFlug=0;
                    yFlug=0;
                    AngriffsArt=0;
                END
            END
        END


        //
        //Die die nicht blocken haben einen KO-Schlag verdient
        //
        IF(Schaden!=0)
            Lifepoints-=Schaden;
            Schaden=0;
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

            FrameVar--;

            IF(FrameVar<1)
                Position=1;
                Punchwait=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar>7 AND FrameVar<11 AND Punchwait==0)
                IF(MODE==1)
                    HauPlatz(x+(1000*Richtung),y,35,25);
                END

                IF(Spielernr==1)
                    Xdist=fget_dist(x+(1000*Richtung),0,fighter2_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter2_id.y);
                END
                IF(Spielernr==2)
                    Xdist=fget_dist(x+(1000*Richtung),0,fighter1_id.x,0);
                    Ydist=fget_dist(0,y,0,fighter1_id.y);
                END


                IF(Xdist<3500)
                    IF(Ydist<2500)
                        x-=250*Richtung;
                        Punchwait=1;
                        IF(Spielernr==1)

                            Fighter2_id.SLZ-=250;
                            Fighter2_id.Schaden+=50;
                            Fighter2_id.xFlug+=50*Richtung;
                            Fighter2_id.yFlug+=600;
                            Fighter2_id.x+=200*Richtung;
                            Fighter2_id.Angriffsart=2;
                            AnimHau(x+(1100*Richtung),y,100,4);

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=250;
                            Fighter1_id.Schaden+=50;
                            Fighter1_id.xFlug+=50*Richtung;
                            Fighter1_id.yFlug+=600;
                            Fighter1_id.x+=200*Richtung;
                            Fighter1_id.Angriffsart=2;
                            AnimHau(x+(1100*Richtung),y,100,4);

                        END
                    END
                END
            END


            Graph=10;
        END







        //*******************************************************************
        IF(Position==9)      //Starker Schlag

            FrameVar--;

            IF(FrameVar<1)
                Position=1;
                Punchwait=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar>8 AND FrameVar<14 AND Punchwait==0)
                x+=500*Richtung;

                IF(MODE==1)
                    HauPlatz(x+(2000*Richtung),y,30,25);
                END

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
                            AnimHau(x+(2100*Richtung),y,150,4);

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=499;
                            Fighter1_id.Schaden+=100;
                            Fighter1_id.xFlug+=75*Richtung;
                            Fighter1_id.yFlug+=800;
                            Fighter1_id.x+=900*Richtung;
                            Fighter1_id.Angriffsart=2;
                            AnimHau(x+(2100*Richtung),y,150,4);

                        END
                    END
                END
            END


            IF(FrameVar>16)
                Graph=11;

              ELSE

                IF(FrameVar>13)
                    Graph=1;
                  ELSE
                   Graph=10;
                END
            END

        END

        //*******************************************************************
        IF(Position==10)         //Schwacher Schlag in der Luft

            FrameVar--;

            IF(FrameVar<1)
                Position=3;
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

            IF(FrameVar>5 AND FrameVar<9 AND Punchwait==0)

                IF(MODE==1)
                    HauPlatz(x+(2000*Richtung),y-1000,30,35);
                END

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
                            AnimHau(x+(2100*Richtung),y+1200,125,4);

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=350;
                            Fighter1_id.Schaden+=75;
                            Fighter1_id.xFlug+=125*Richtung;
                            Fighter1_id.yFlug+=700;
                            Fighter1_id.x+=600*Richtung;
                            Fighter1_id.Angriffsart=3;
                            AnimHau(x+(2100*Richtung),y+1200,125,4);

                        END
                    END
                END
            END


            Graph=12;

        END


        //*******************************************************************
        IF(Position==11)         //Starker Schlag in der Luft

            FrameVar--;

            IF(FrameVar<1)
                Position=3;
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

            IF(FrameVar>1 AND Punchwait==0)

                IF(MODE==1)
                    HauPlatz(x+(2000*Richtung),y+2200,25,30);
                END

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
                            AnimHau(x+(2100*Richtung),y+2200,175,6);

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=350;
                            Fighter1_id.Schaden+=150;
                            Fighter1_id.xFlug+=150*Richtung;
                            Fighter1_id.yFlug+=700;
                            Fighter1_id.x+=600*Richtung;
                            Fighter1_id.Angriffsart=3;
                            AnimHau(x+(2100*Richtung),y+2200,175,6);

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

            FrameVar--;

            IF(FrameVar<1)
                Position=4;
                Punchwait=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar>7 AND FrameVar<11 AND Punchwait==0)
                IF(MODE==1)
                    HauPlatz(x+(1200*Richtung),y,35,25);
                END

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
                            AnimHau(x+(1100*Richtung),y+2000,100,4);

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=150;
                            Fighter1_id.Schaden+=45;
                            Fighter1_id.xFlug+=50*Richtung;
                            Fighter1_id.yFlug+=400;
                            Fighter1_id.x+=150*Richtung;
                            Fighter1_id.Angriffsart=1;
                            AnimHau(x+(1100*Richtung),y+2000,100,4);

                        END
                    END
                END
            END


            Graph=14;
        END


        //*******************************************************************
        IF(Position==13)     //Starker Schlag Bueckend

            FrameVar--;

            IF(FrameVar<1)
                Position=4;
                Punchwait=0;
            END

            IF(SLZ<0)
                Position=5;
                FrameVar=0;
                Punchwait=0;
            END

            IF(FrameVar>7 AND FrameVar<11 AND Punchwait==0)
                IF(MODE==1)
                    HauPlatz(x+(1200*Richtung),y-800,35,30);
                END

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
                            AnimHau(x+(1100*Richtung),y+2000,100,4);

                        END
                        IF(Spielernr==2)

                            Fighter1_id.SLZ-=350;
                            Fighter1_id.Schaden+=90;
                            Fighter1_id.xFlug+=10*Richtung;
                            Fighter1_id.yFlug+=1000;
                            Fighter1_id.x+=150*Richtung;
                            Fighter1_id.Angriffsart=1;
                            AnimHau(x+(1100*Richtung),y+2000,100,4);

                        END
                    END
                END
            END

            IF(FrameVar>11)
                Graph=14;
            ELSE
                Graph=15;
            END
        END



        //SpezialAnim(x,y,Graph,flags,file);
        //Minifight(x,y,Graph,flags,file);
        Oldposition=Position;

        IF(MODE==1)
            SMTC(x,y);
        END

        IF(SLZ>0)     // Ja hier kommt noch mal dasselbe, aber
            SLZ=0;    // das muss halt eben so sein!
        END


        FRAME;

    END





END



PROCESS SpezialAnim(x,y,Graph,flags,file)

BEGIN
    z=10;
    resolution=100;
    FRAME;
    z++;
    FRAME;
    size+=5;
    z++;
    FRAME;
    flags+=4;
    z++;
    FRAME;
    size+=5;
    z++;
    FRAME;
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

PROCESS AnimHau(x,y,Size,Graph)

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



PROGRAM WormBattleWarriors;

GLOBAL
    STRUCT Xp[31]
        STRUCT Yp[23]
            //Floor
            /* kleiner 100 Betretbar sonst unbetretbar(Ausnahmen Arbeiter)
            1=Gras;
            2=Abgetragene Erde;
            3=Loch in die Erde;
            101=Erde
            102=Blatt
            103=Ast
            104=Luft
            105=FutterLager
            106=Geburtort
            107=Kriegsausbilder
            */
            Floor;
            Stat;//auffrischen z.B.


            //Unit
            /*
            1=Worker         LifeMax=50;  MoveMax=5;
            2=Worker Wood
            3=Worker Leaf
            4=Worker Food
            5=FighterWeak
            6=FighterStrong
            +10=Spieler 2

            */
            Typ;
            Lifemax;
            Life;
            MoveMax;
            Move;
        END
    END

PRIVATE
    Rando;


BEGIN

    Load_FPG("Olegs\UndWorld.FPG");
    Load_FNT("Olegs\UndWorld.FNT");
    set_mode(m320x240);
    //set_mode(m800x600);

    FOR(x=0; x<=31; x++)
        FOR(y=0; y<=2; Y++)
            Xp[x].Yp[y].Floor=104;
        END
        FOR(y=3; y<=10; Y++)
            Rando=rand(0,9);
            IF(Rando==0)
                Xp[x].Yp[y].Floor=103;
            ELSE
                IF(Rando==1)
                    Xp[x].Yp[y].Floor=102;
                ELSE
                    Xp[x].Yp[y].Floor=1;
                END
            END
        END
        FOR(y=11; y<=23; Y++)
            Rando=rand(0,75);
            IF(Rando==0 OR Rando==1)
                Xp[x].Yp[y].Floor=105;
            ELSE
                IF(Rando==2)
                    Xp[x].Yp[y].Floor=106;
                ELSE
                    IF(Rando==3 OR Rando==4)
                        Xp[x].Yp[y].Floor=107;
                    ELSE
                        Xp[x].Yp[y].Floor=101;
                    END
                END
            END
        END

    END

    Xp[4].Yp[7].Typ=1;
    Xp[4].Yp[7].Lifemax=50;
    Xp[4].Yp[7].Life=50;
    Xp[4].Yp[7].MoveMax=5;
    Xp[4].Yp[7].Move=5;
    Xp[27].Yp[7].Typ=11;
    Xp[27].Yp[7].Lifemax=50;
    Xp[27].Yp[7].Life=50;
    Xp[27].Yp[7].MoveMax=5;
    Xp[27].Yp[7].Move=500;
    Xp[6].Yp[7].Typ=1;
    Xp[6].Yp[7].Lifemax=50;
    Xp[6].Yp[7].Life=50;
    Xp[6].Yp[7].MoveMax=5;
    Xp[6].Yp[7].Move=5;
    Xp[25].Yp[7].Typ=11;
    Xp[25].Yp[7].Lifemax=50;
    Xp[25].Yp[7].Life=50;
    Xp[25].Yp[7].MoveMax=5;
    Xp[25].Yp[7].Move=500;
    Xp[4].Yp[7].Floor=1;
    Xp[27].Yp[7].Floor=1;
    Xp[6].Yp[7].Floor=1;
    Xp[25].Yp[7].Floor=1;
    Xp[5].Yp[7].Floor=3;
    Xp[26].Yp[7].Floor=3;
    Xp[5].Yp[11].Floor=2;
    Xp[26].Yp[11].Floor=2;
    Xp[5].Yp[12].Floor=2;
    Xp[26].Yp[12].Floor=2;
    Xp[5].Yp[13].Floor=2;
    Xp[26].Yp[13].Floor=2;
    Xp[5].Yp[14].Floor=2;
    Xp[26].Yp[14].Floor=2;
    Xp[5].Yp[15].Floor=2;
    Xp[26].Yp[15].Floor=2;
    Xp[5].Yp[16].Floor=2;
    Xp[26].Yp[16].Floor=2;
    Xp[6].Yp[16].Floor=2;
    Xp[25].Yp[16].Floor=2;
    Xp[4].Yp[16].Floor=2;
    Xp[27].Yp[16].Floor=2;


    REPAINT();
    Background();
    Cursor();

END








PROCESS CURSOR()

PRIVATE
    AntiFast;
    PlayerTurn;
    Life;
    Lifemax;
    Move;
    MoveMax;
    Typ;
    Arbeiter;
    Ebene;
    newEbene;
    oldx;
    oldy;
    newx;
    newy;
    Betret;   //0=nicht betreten  1=betreten  2=Arbeiter betreten
    Out;

BEGIN
    Graph=10;
    z=-10;

    //AP/Leben zeigen
    Write(1,0,0,0,"LP:       /         AP:   /   ");
    Write_Int(1,100,0,2,OFFSET Life);
    Write_Int(1,120,0,0,OFFSET LifeMax);
    Write_Int(1,262,0,2,OFFSET Move);
    Write_Int(1,282,0,0,OFFSET MoveMax);

    //Player 1 am Zug
    Playerturn=0;

    LOOP
        //Jetzige Position
        oldx=x/10;
        oldy=y/10;

        //AP/Leben Der Unit auf die geschaut wird
        Life=Xp[oldx].Yp[Oldy].Life;
        Lifemax=Xp[oldx].Yp[Oldy].Lifemax;
        Move=Xp[oldx].Yp[Oldy].Move;
        Movemax=Xp[oldx].Yp[Oldy].Movemax;

        //Bewegung
        IF(Key(_Up) AND y>0)
            IF(Antifast<1 OR Antifast>4)
                y-=10;
            END
        END
        IF(Key(_Down) AND y<230)
            IF(Antifast<1 OR Antifast>4)
                y+=10;
            END
        END
        IF(Key(_Left) AND x>0)
            IF(Antifast<1 OR Antifast>4)
                x-=10;
            END
        END
        IF(Key(_Right) AND x<310)
            IF(Antifast<1 OR Antifast>4)
                x+=10;
            END
        END
        IF(NOT (Key(_down)) AND NOT (Key(_Up)) AND NOT (Key(_Right)) AND NOT (Key(_Left)))
            Antifast=0;
        ELSE
            AntiFast++;
        END



        //Wichtiger Enter-Knopf
        IF(Key(_Enter) AND Antifast==0)

            //Ist da grad eine Kreatur unter dem Zeiger?
            IF(Xp[x/10].Yp[y/10].Typ!=0)

                //Gehoert sie dir?
                IF(Xp[x/10].Yp[y/10].Typ/10==PlayerTurn)

                    //Cursorgraphik in Wahlgrapfik aendern
                    graph=11+Playerturn*2;

                    //Typ und Move in Privaten Speicher nehmen um weniger
                    //zu schreiben
                    Move=Xp[x/10].Yp[y/10].Move;
                    Typ=Xp[x/10].Yp[y/10].Typ;


                    //In welcher Ebene ist er?
                    IF(y/10>=3 AND y/10<=10)
                        Ebene=1;
                    ELSE
                        Ebene=0;
                    END


                    //Ist es ein Arbeiter?
                    IF((Typ mod 10)>0 AND (Typ mod 10)<5)
                        Arbeiter=1;
                    END

                    LOOP

                        //Eine auszufuehrende Aktion wird gewaehlt
                        LOOP

                            //Position
                            oldx=x/10;
                            oldy=y/10;

                            //AP-Leben
                            Life=Xp[oldx].Yp[Oldy].Life;
                            Lifemax=Xp[oldx].Yp[Oldy].Lifemax;
                            Move=Xp[oldx].Yp[Oldy].Move;
                            Movemax=Xp[oldx].Yp[Oldy].Movemax;



                            //Links-Knopf
                            IF(Key(_Left) AND AntiFast==0)

                                //neue Position errechnen
                                newx=x/10-1;
                                newy=y/10;

                                //Welche Ebene gerade?
                                IF(y/10>=3 AND y/10<=10)
                                    Ebene=1;
                                ELSE
                                    Ebene=0;
                                END

                                //Welche neue Ebene?
                                IF(newy>=3 AND newy<=10)
                                    newEbene=1;
                                ELSE
                                    newEbene=0;
                                END
                                Antifast=1;
                                BREAK;
                            END

                            //Hoch Knopf
                            IF(Key(_up) AND AntiFast==0)
                                newx=x/10;
                                newy=y/10-1;
                                IF(y/10>=3 AND y/10<=10)
                                    Ebene=1;
                                ELSE
                                    Ebene=0;
                                END
                                IF(newy>=3 AND newy<=10)
                                    newEbene=1;
                                ELSE
                                    newEbene=0;
                                END
                                Antifast=1;
                                BREAK;
                            END

                            //Runter Knopf
                            IF(Key(_down) AND AntiFast==0)
                                newx=x/10;
                                newy=y/10+1;
                                IF(y/10>=3 AND y/10<=10)
                                    Ebene=1;
                                ELSE
                                    Ebene=0;
                                END
                                IF(newy>=3 AND newy<=10)
                                    newEbene=1;
                                ELSE
                                    newEbene=0;
                                END
                                Antifast=1;
                                BREAK;
                            END

                            //Rechts Knopf
                            IF(Key(_right) AND AntiFast==0)
                                newx=x/10+1;
                                newy=y/10;
                                IF(y/10>=3 AND y/10<=10)
                                    Ebene=1;
                                ELSE
                                    Ebene=0;
                                END
                                IF(newy>=3 AND newy<=10)
                                    newEbene=1;
                                ELSE
                                    newEbene=0;
                                END
                                Antifast=1;
                                BREAK;
                            END

                            //Aufhoeren mit dieser Figur zu agieren
                            IF(Key(_BackSpace))
                                OUT=1;
                                BREAK;
                            END
                            FRAME;

                            //Antifast zurueck
                            IF(NOT (Key(_down)) AND NOT (Key(_Up)) AND NOT (Key(_Right)) AND NOT (Key(_Left)))
                                Antifast=0;
                            END
                        END




                        //Endlich hat man sich bewegt

                        //kommt man aus dem Rand raus?
                        IF(newx<=31 AND newx>=0 AND newy<=23 AND newy>=0 AND Out==0)

                        //Ebenenwechsel
                        //Beide Ebenen gleich-Null-Problemo-Baby
                        IF(Ebene==NewEbene)

                        //Ist das Feld unbesetzt?
                        IF(Xp[newx].Yp[newy].Typ==0)
                            SWITCH(Xp[newx].Yp[newy].Floor)
                                CASE 1,2://Normales Gehfeld
                                    IF(Xp[oldx].Yp[oldy].Move>0)//Aktionspunkte?
                                        Xp[newx].Yp[newy].Typ=Xp[oldx].Yp[oldy].Typ;
                                        Xp[newx].Yp[newy].Lifemax=Xp[oldx].Yp[oldy].Lifemax;
                                        Xp[newx].Yp[newy].Life=Xp[oldx].Yp[oldy].Life;
                                        Xp[newx].Yp[newy].Movemax=Xp[oldx].Yp[oldy].Movemax;
                                        Xp[newx].Yp[newy].Move=Xp[oldx].Yp[oldy].Move-1;
                                        Xp[oldx].Yp[oldy].Typ=0;
                                        Xp[oldx].Yp[oldy].Lifemax=0;
                                        Xp[oldx].Yp[oldy].Life=0;
                                        Xp[oldx].Yp[oldy].Movemax=0;
                                        Xp[oldx].Yp[oldy].Move=0;
                                        x=newx*10;
                                        y=newy*10;
                                    END
                                END
                                CASE 3://Loch nach unten
                                    IF(Xp[oldx].Yp[oldy].Move>0)//Aktionspunkte?
                                    IF(Xp[newx].Yp[11].Typ==0)//Freies Feld?
                                        Xp[newx].Yp[11].Typ=Xp[oldx].Yp[oldy].Typ;
                                        Xp[newx].Yp[11].Lifemax=Xp[oldx].Yp[oldy].Lifemax;
                                        Xp[newx].Yp[11].Life=Xp[oldx].Yp[oldy].Life;
                                        Xp[newx].Yp[11].Movemax=Xp[oldx].Yp[oldy].Movemax;
                                        Xp[newx].Yp[11].Move=Xp[oldx].Yp[oldy].Move-1;
                                        Xp[oldx].Yp[oldy].Typ=0;
                                        Xp[oldx].Yp[oldy].Lifemax=0;
                                        Xp[oldx].Yp[oldy].Life=0;
                                        Xp[oldx].Yp[oldy].Movemax=0;
                                        Xp[oldx].Yp[oldy].Move=0;
                                        x=newx*10;
                                        y=11*10;
                                    END
                                    END
                                END

                                CASE 101://Erde muss abgegraben werden!
                                    IF(Xp[oldx].Yp[oldy].Move>1)//Aktionspunkte?
                                    IF(Arbeiter==1)//Nur Arbeiter!
                                        Xp[newx].Yp[newy].Typ=Xp[oldx].Yp[oldy].Typ;
                                        Xp[newx].Yp[newy].Lifemax=Xp[oldx].Yp[oldy].Lifemax;
                                        Xp[newx].Yp[newy].Life=Xp[oldx].Yp[oldy].Life;
                                        Xp[newx].Yp[newy].Movemax=Xp[oldx].Yp[oldy].Movemax;
                                        Xp[newx].Yp[newy].Move=Xp[oldx].Yp[oldy].Move-2;
                                        Xp[newx].Yp[newy].Floor=2;
                                        Xp[oldx].Yp[oldy].Typ=0;
                                        Xp[oldx].Yp[oldy].Lifemax=0;
                                        Xp[oldx].Yp[oldy].Life=0;
                                        Xp[oldx].Yp[oldy].Movemax=0;
                                        Xp[oldx].Yp[oldy].Move=0;
                                        x=newx*10;
                                        y=newy*10;
                                    END
                                    END
                                END
                                CASE 102://Heb auf ein Blatt
                                    IF(Xp[oldx].Yp[oldy].Move>0)//Aktionspunkte?

                                    //Nur Arbeiter welcher nichts traegt!
                                    IF(Xp[oldx].Yp[oldy].Typ==1 OR Xp[oldx].Yp[oldy].Typ==11)
                                        Xp[newx].Yp[newy].Typ=Xp[oldx].Yp[oldy].Typ+2;
                                        Xp[newx].Yp[newy].Lifemax=Xp[oldx].Yp[oldy].Lifemax;
                                        Xp[newx].Yp[newy].Life=Xp[oldx].Yp[oldy].Life;
                                        Xp[newx].Yp[newy].Movemax=Xp[oldx].Yp[oldy].Movemax;
                                        Xp[newx].Yp[newy].Move=Xp[oldx].Yp[oldy].Move-1;
                                        Xp[newx].Yp[newy].Floor=1;
                                        Xp[oldx].Yp[oldy].Typ=0;
                                        Xp[oldx].Yp[oldy].Lifemax=0;
                                        Xp[oldx].Yp[oldy].Life=0;
                                        Xp[oldx].Yp[oldy].Movemax=0;
                                        Xp[oldx].Yp[oldy].Move=0;
                                        x=newx*10;
                                        y=newy*10;
                                    END
                                    END
                                END
                                CASE 103://Ast aufheben
                                    IF(Xp[oldx].Yp[oldy].Move>0)//AP?

                                    //Nur wenn er nichts traegt!
                                    IF(Xp[oldx].Yp[oldy].Typ==1 OR Xp[oldx].Yp[oldy].Typ==11)
                                        Xp[newx].Yp[newy].Typ=Xp[oldx].Yp[oldy].Typ+1;
                                        Xp[newx].Yp[newy].Lifemax=Xp[oldx].Yp[oldy].Lifemax;
                                        Xp[newx].Yp[newy].Life=Xp[oldx].Yp[oldy].Life;
                                        Xp[newx].Yp[newy].Movemax=Xp[oldx].Yp[oldy].Movemax;
                                        Xp[newx].Yp[newy].Move=Xp[oldx].Yp[oldy].Move-1;
                                        Xp[newx].Yp[newy].Floor=1;
                                        Xp[oldx].Yp[oldy].Typ=0;
                                        Xp[oldx].Yp[oldy].Lifemax=0;
                                        Xp[oldx].Yp[oldy].Life=0;
                                        Xp[oldx].Yp[oldy].Movemax=0;
                                        Xp[oldx].Yp[oldy].Move=0;
                                        x=newx*10;
                                        y=newy*10;
                                    END
                                    END

                                END
                                CASE 104:
                                    //Was will er an der Luft?
                                END
                                CASE 105://Das Futterlager
                                    IF(Xp[oldx].Yp[oldy].Move>0)//AP?
                                        //Nur wenn nichtstrager und Futter da ist:
                                        IF((Xp[oldx].Yp[oldy].Typ==1 OR Xp[oldx].Yp[oldy].Typ==11) AND Xp[newx].Yp[newy].Stat==0)
                                            Xp[newx].Yp[newy].Stat=4;
                                            Xp[oldx].Yp[oldy].Typ+=3;
                                            Xp[oldx].Yp[oldy].Move-=1;
                                            x=oldx*10;
                                            y=oldy*10;
                                        END

                                        //Blatttrager frischt alles auf
                                        IF(Xp[oldx].Yp[oldy].Typ==3 OR Xp[oldx].Yp[oldy].Typ==13 AND Xp[Newx].Yp[Newy].Stat>0)
                                            Xp[newx].Yp[newy].Stat=0;
                                            Xp[oldx].Yp[oldy].Typ-=2;
                                            Xp[oldx].Yp[oldy].Move-=1;
                                            x=oldx*10;
                                            y=oldy*10;
                                        END
                                    END
                                END
                                CASE 106://Hier werden Kinder geboren

                                    IF(Xp[oldx].Yp[oldy].Move>0)//AP?
                                    //Futter mus reingelegt werden
                                    IF(Xp[oldx].Yp[oldy].Typ==4 OR Xp[oldx].Yp[oldy].Typ==14)
                                        Xp[newx].Yp[newy].Typ=Xp[oldx].Yp[oldy].Typ-3;
                                        Xp[newx].Yp[newy].Lifemax=50;
                                        Xp[newx].Yp[newy].Life=50;
                                        Xp[newx].Yp[newy].Movemax=5;
                                        Xp[newx].Yp[newy].Move=2;
                                        Xp[oldx].Yp[oldy].Typ-=3;
                                        Xp[oldx].Yp[oldy].Move-=1;
                                    END
                                    END

                                END
                                CASE 107://Kaempfer gibt es hier auszubilden
                                    IF(Xp[oldx].Yp[oldy].Move>0)

                                    //Kaempfer Stufe 1
                                    IF((Xp[oldx].Yp[oldy].Typ==1 OR Xp[oldx].Yp[oldy].Typ==11) AND Xp[newx].Yp[newy].Stat==0)
                                        Xp[newx].Yp[newy].Stat=4;
                                        Xp[oldx].Yp[oldy].Typ+=4;
                                        Xp[oldx].Yp[oldy].Life+=50;
                                        Xp[oldx].Yp[oldy].LifeMax+=50;
                                        Xp[oldx].Yp[oldy].MoveMax+=0;
                                        Xp[oldx].Yp[oldy].Move-=1;
                                        Arbeiter=0;
                                        x=oldx*10;
                                        y=oldy*10;
                                    END

                                    //Kaempfer Stufe 2
                                    IF((Xp[oldx].Yp[oldy].Typ==5 OR Xp[oldx].Yp[oldy].Typ==15) AND Xp[newx].Yp[newy].Stat==0)
                                        Xp[newx].Yp[newy].Stat=4;
                                        Xp[oldx].Yp[oldy].Typ+=1;
                                        Xp[oldx].Yp[oldy].Life+=50;
                                        Xp[oldx].Yp[oldy].LifeMax+=50;
                                        Xp[oldx].Yp[oldy].MoveMax+=2;
                                        Xp[oldx].Yp[oldy].Move-=1;
                                        Arbeiter=0;
                                        x=oldx*10;
                                        y=oldy*10;
                                    END

                                    //Auffrischen
                                    IF(Xp[oldx].Yp[oldy].Typ==4 OR Xp[oldx].Yp[oldy].Typ==14 AND Xp[Newx].Yp[Newy].Stat>0)
                                        Xp[newx].Yp[newy].Stat=0;
                                        Xp[oldx].Yp[oldy].Typ-=3;
                                        Xp[oldx].Yp[oldy].Move-=1;
                                        Arbeiter=0;
                                        x=oldx*10;
                                        y=oldy*10;
                                    END
                                    END

                                END

                            END
                        ELSE
                            //Da steht schon jemand auf dem Feld!
                            //Interaktion muss kommen!
                        END

                        ELSE
                            //Wechsel die Ebene
                            IF(Ebene==0)
                                //Nur von Unten nach oben muss was getan werden!
                                //1:Ist da ein Loch schon da?
                                //2:Nein:Neues erstellen+Ja
                                //       Nicht moeglich: Nicht moeglich!
                                //  Ja: Rausgehen
                            END
                        END

                        END
                        Betret=0;

                        IF(Out==1)
                            Out=0;
                            graph=10+Playerturn*2;
                            BREAK;
                        END
                        Repaint();
                        FRAME;
                    END
                END
            END
        END








        FRAME;


    END
END













PROCESS REPAINT()

BEGIN
    FOR(x=0; x<=31; x++)
        FOR(y=0; y<=23; y++)
            SWITCH(Xp[x].Yp[y].floor)
            /*1=Gras;
            2=Abgetragene Erde;
            101=Erde
            102=Blatt
            103=Ast
            104=Luft
            105=FutterLager
            106=Geburtort
            107=Kreigsausbilder
            */
                CASE 1;
                    graph=206;
                END
                CASE 2;
                    graph=204;
                END
                CASE 3;
                    graph=210;
                END
                CASE 101;
                    graph=201;
                END
                CASE 102;
                    graph=209;
                END
                CASE 103;
                    graph=208;
                END
                CASE 104;
                    graph=211;
                END
                CASE 105;
                    IF(Xp[x].Yp[y].Stat<=0)
                        graph=217;
                    ELSE
                        graph=220;
                    END
                END
                CASE 106;
                    IF(Xp[x].Yp[y].Stat<=0)
                        graph=218;
                    ELSE
                        graph=216;
                    END
                END
                CASE 107;
                    IF(Xp[x].Yp[y].Stat<=0)
                        graph=219;
                    ELSE
                        graph=221;
                    END
                END




            END
            Map_Put(0,1,graph,x*10,y*10);

            /*
            1=Worker
            2=Worker Wood
            3=Worker Leaf
            4=Worker Food
            5=FighterWeak
            6=FighterStrong
            +10=Spieler 2

            */

            SWITCH(Xp[x].Yp[y].Typ)
                CASE 1;
                    graph=101;
                END
                CASE 2;
                    graph=102;
                END
                CASE 3;
                    graph=103;
                END
                CASE 4;
                    graph=106;
                END
                CASE 5;
                    graph=104;
                END
                CASE 6;
                    graph=105;
                END
                CASE 11;
                    graph=111;
                END
                CASE 12;
                    graph=112;
                END
                CASE 13;
                    graph=113;
                END
                CASE 14;
                    graph=116;
                END
                CASE 15;
                    graph=114;
                END
                CASE 16;
                    graph=115;
                END

            END
            Map_Put(0,1,graph,x*10,y*10);

            IF(Xp[x].Yp[y].life<=(Xp[x].Yp[y].lifemax*1)/2 AND Xp[x].Yp[y].life>0)
                IF(Xp[x].Yp[y].Typ>10)
                    Map_Put(0,1,117,x*10,y*10);
                ELSE
                    Map_Put(0,1,107,x*10,y*10);
                END
            END
            IF(Xp[x].Yp[y].move<Xp[x].Yp[y].movemax)
                IF(Xp[x].Yp[y].move==0)
                    Map_Put(0,1,92,x*10,y*10);
                ELSE
                    Map_Put(0,1,91,x*10,y*10);
                END
            ELSE
                IF(Xp[x].Yp[y].movemax!=0)
                    Map_Put(0,1,90,x*10,y*10);
                END
            END

        END
    END

END






PROCESS BACKGROUND()

BEGIN
    graph=1;
    x=160;
    y=120;
    LOOP
        FRAME;
    END
END












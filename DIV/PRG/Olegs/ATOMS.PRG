

Program Atoms;

GLOBAL
    CursorState; //0=Moving, 1=Creating Connections
    Connections[10]; //Number of Connections used by Actual Atom.
    ConInfo;       //Wieviele Connections werden vorhergesagt?
    NoAtom;
    MODE;        //0=Rand zaehlt zum Atom, 1=Rand zaehlt nicht zum Atom
    Points;
    HiEasy;
    HiHard;
    Field;
    GivenAtoms;
    Bombs;
    bombssupply;
    BombSNeed;
    Quad; //Anzahl der 4er Molekuele 0=normal 1=halbsooft

    STRUCT AtX[7]
        STRUCT AtY[7]
            exists;
            dirup;
            dirdo;
            dirle;
            dirri;
            checked;
        END
    END


LOCAL

BEGIN
    Set_mode(m640x480);
    Load_fpg("Olegs\Atoms.FPG");
    Load_fnt("Olegs\Atoms.FNT");

    Write(1,360,40,4,"*** ATOME ***");
    Write(1,360,40,4,"_____");
    Write(1,200,120,4,"Ein Spiel von:");
    Write(1,200,180,4,"OLEG YUSCHUK");
    Write(1,200,180,4,"____________");
    Write(1,400,260,4,"Erstellt mit dem:");
    Write(1,400,320,4,"DIV GAME MAKER");
    Write(1,400,320,4,"______________");
    FRAME(7200);

    Write(1,320,380,4,"Weiter mit: ENTER");
    Write(1,320,440,4,"Regeln mit: H");
    LOOP
        IF(KEY(_ENTER))
            BREAK;
        END
        IF(KEY(_h))
            x=320;
            y=240;
            delete_text(all_text);
            graph=4;
            WHILE(NOT KEY(_ENTER))
                FRAME;
            END
            graph=0;


            WHILE(KEY(_ENTER))
                FRAME;
            END

            Write(1,5,5,0,"Richtungspfeile:");
            Write(1,5,55,0,"    Cursor bewegen");
            Write(1,5,105,0,"Enter:");
            Write(1,5,155,0,"    Atom setzen");
            Write(1,5,205,0,"BackSpace:");
            Write(1,5,255,0,"    Bombe benutzen");
            Write(1,5,305,0,"ESC:");
            Write(1,5,355,0,"    Neue Runde");


            WHILE(NOT KEY(_ENTER))
                FRAME;
            END




            BREAK;
        END
        FRAME;
    END

    delete_text(all_text);
    WHILE(KEY(_ENTER))
        FRAME;
    END

  LOOP
    Write(1,320,60,4,"Modus waehlen");
    Write(1,320,150,4,"1-Leicht");
    Write(1,320,200,4,"Wand zaehlt als Bindung");
    Write(1,320,280,4,"2-Schwer");
    Write(1,320,330,4,"Wand zaehlt nicht als Bindung");
    Write(1,320,455,4,"ESC-Beenden");
    LOOP
        IF(NOT KEY(_ESC))
            BREAK;
        END
        FRAME;
    END


    LOOP
        IF(Key(_1))
            Mode=0;
            BREAK;
        END
        IF(Key(_2))
            Mode=1;
            BREAK;
        END
        IF(Key(_ESC))
            Exit("Thanks! Your Score:",Points);
            BREAK;
        END

        FRAME;
    END
    delete_text(All_text);
    WHILE(Key(_1) OR Key(_2))
        FRAME;
    END

    Write(1,320,60,4,"Anzahl der 4er-Atome");
    Write(1,320,150,4,"1-Normal");
    Write(1,320,200,4,"4er tauchen normal auf");
    Write(1,320,280,4,"2-Seltener");
    Write(1,320,330,4,"4er tauchen seltener auf");


    LOOP
        IF(Key(_1))
            Quad=0;
            BREAK;
        END
        IF(Key(_2))
            Quad=1;
            BREAK;
        END

        FRAME;
    END
    delete_text(All_text);


    Points=0;
    Write(1,320,60,4,"Groesse waehlen");
    Write_INT(1,320,200,4,OFFSET Field);
    Write(1,320,200,4,"<        >");
    field=5;
    LOOP
        IF(Key(_left) AND Field>2)
            Field--;
        END
        IF(Key(_right) AND Field<8)
            Field++;
        END
        IF(Key(_enter))
            Field--;
            BREAK;
        END
        FRAME;
    END
    delete_text(All_text);


    Write(1,320,60,4,"Vorgegebene Atome waehlen");
    Write_Int(1,320,200,4,OFFSET GivenAtoms);
    Write(1,320,200,4,"<        >");

    WHILE(KEY(_ENTER))
        FRAME;
    END

    LOOP
        IF(Key(_left) AND GivenAtoms>0)
            GivenAtoms--;
        END
        IF(Key(_right))
            IF(Mode==0)
                IF(GivenAtoms<(Field+1)*(Field+1)-1)
                    GivenAtoms++;
                END
            ELSE
                IF(GivenAtoms<(Field-1)*(Field-1))
                    GivenAtoms++;
                END
            END
        END
        IF(Key(_Enter))
            BREAK;
        END

        FRAME;
    END

    FOR(GivenAtoms=GivenAtoms; GivenAtoms>0; GivenAtoms--)
        GivenAtoms++;
        IF(Mode==0)
            x=rand(0,Field);
            y=rand(0,Field);

        ELSE
            x=rand(1,Field-1);
            y=rand(1,Field-1);
        END
        IF(ATX[x].ATY[y].exists==1)
            GivenAtoms++;
        ELSE
            ATX[x].ATY[y].exists=1;
            IF(rand(0,1)==1)
                ATX[x].ATY[y].dirup=1;
            END
            IF(rand(0,1)==1)
                ATX[x].ATY[y].dirdo=1;
            END
            IF(rand(0,1)==1)
                ATX[x].ATY[y].dirle=1;
            END
            IF(rand(0,1)==1)
                ATX[x].ATY[y].dirri=1;
            END
            Check(X,Y);
            FRAME(100);
            KILL();
            Repaint();
        END
        GivenAtoms--;
    END
    delete_text(All_text);

    Write(1,320,60,4,"Vorgegebene Bomben waehlen");
    Write_Int(1,320,200,4,OFFSET Bombs);
    Write(1,320,200,4,"<        >");

    WHILE(KEY(_ENTER))
        FRAME;
    END

    bombs=0;
    bombssupply=0;
    LOOP
        IF(Key(_left) AND bombs>0)
            bombs--;
        END
        IF(Key(_right))
            IF(Bombs<20)
                Bombs++;
            END
        END
        IF(Key(_Enter))
            BREAK;
        END

        FRAME;
    END

    delete_text(All_text);

    Write(1,320,60,4,"Benoetigte Punkte fuer Bombe");
    Write_Int(1,320,200,4,OFFSET BombSNeed);
    Write(1,320,200,4,"<        >");

    WHILE(KEY(_ENTER))
        FRAME;
    END

    BombSNeed=100;
    LOOP
        IF(Key(_left) AND BombSNeed>5)
            BombSNeed-=5;
        END
        IF(Key(_right))
            IF(BombSNeed<500)
                BombSNeed+=5;
            END
        END
        IF(Key(_Enter))
            BREAK;
        END

        FRAME;
    END



    delete_text(All_text);

    Write(1,320,60,4,"Angezeigte Atome waehlen");
    Write_Int(1,320,200,4,OFFSET ConInfo);
    Write(1,320,200,4,"<        >");

    WHILE(KEY(_ENTER))
        FRAME;
    END

    ConInfo=0;
    LOOP
        IF(Key(_left) AND ConInfo>0)
            ConInfo--;
        END
        IF(Key(_right))
            IF(ConInfo<10)
                ConInfo++;
            END
        END
        IF(Key(_Enter))
            BREAK;
        END

        FRAME;
    END

    delete_text(all_text);

    WHILE(KEY(_ENTER))
        FRAME;
    END



    Background();
    Repaint();
    Cursor();
    FOR(x=0; x<=ConInfo; x++)
        IF(Quad==0)
            Connections[x]=rand(1,4);
        ELSE
            Connections[x]=rand(3,13)/3;
        END
    END
    Write_Int(1,283,40,3,OFFSET Connections[0]);
    FOR(x=1; x<=ConInfo; x++)
        Write_Int(1,313+x*30,40,3,OFFSET Connections[x]);
    END
    Write_Int(1,90,170,4,OFFSET Points);
    Write(1,90,220,4,"Bombs:");
    Write_Int(1,90,270,4,OFFSET Bombs);
    IF(Mode==0)
        Write(1,5,480,6,"Leicht");
    ELSE
        Write(1,5,480,6,"Schwer");
    END


    LOOP
        IF(Key(_ESC))
            CursorState=0; //0=Moving, 1=Creating Connections
            FOR(x=0; x<=7; x++)
                FOR(y=0; y<=7; y++)
                    ATX[x].ATY[y].Exists=0;
                    ATX[x].ATY[y].Dirup=0;
                    ATX[x].ATY[y].Dirdo=0;
                    ATX[x].ATY[y].Dirle=0;
                    ATX[x].ATY[y].Dirri=0;
                    ATX[x].ATY[y].checked=0;
                END
            END
            delete_text(All_text);
            Let_me_alone();
            BREAK;
            /*IF(Mode==0)
                IF(Points>HiEasy)
                    HiEasy=Points;
                    Save("Saves\ATSCEA.DAT",OFFSET HIEASY,1);
                    Exit("Thanks! Your Score:",Points);
                END
            ELSE
                IF(Points>HiHard)
                    HiHard=Points;
                    Save("Saves\ATSCHA.DAT",OFFSET HIHard,1);
                    Exit("Thanks! Your Score:",Points);
                END

            END*/
        END
        FRAME;
    END

  END


END


PROCESS Cursor()

PRIVATE
    Xpos;
    Ypos;
    Steps;
    i;

BEGIN
    Graph=2;
    x=200;
    y=130;
    LOOP
        IF(CursorState==0)
            IF(Key(_up) AND Ypos>0)
                Ypos-=1;
                FOR(Steps=0; Steps<=2; Steps++)
                    y-=10;
                    FRAME;
                END
                y-=10;
            END
            IF(Key(_down) AND Ypos<Field)
                Ypos+=1;
                FOR(Steps=0; Steps<=2; Steps++)
                    y+=10;
                    FRAME;
                END
                y+=10;
            END
            IF(Key(_left) AND Xpos>0)
                Xpos-=1;
                FOR(Steps=0; Steps<=2; Steps++)
                    x-=10;
                    FRAME;
                END
                x-=10;
            END
            IF(Key(_right) AND Xpos<Field)
                Xpos+=1;
                FOR(Steps=0; Steps<=2; Steps++)
                    x+=10;
                    FRAME;
                END
                x+=10;
            END
            IF(Key(_Enter) AND ATX[Xpos].ATY[YPOS].exists==0)
                Cursorstate=1;
                ATX[Xpos].ATY[YPOS].exists=1;
                Repaint();
            END
            IF(Key(_BackSpace) AND Bombs>0 AND ATX[Xpos].ATY[YPOS].exists==1)
                Bombs--;
                ATX[xPOS].ATY[yPOS].Exists=0;
                ATX[xPOS].ATY[yPOS].Dirup=0;
                ATX[xPOS].ATY[yPOS].Dirdo=0;
                ATX[xPOS].ATY[yPOS].Dirle=0;
                ATX[xPOS].ATY[yPOS].Dirri=0;
                ATX[xPOS].ATY[yPOS].checked=0;
                Repaint();
            END


        ELSE
            IF(Key(_up) AND ATX[Xpos].ATY[YPOS].Dirup==0 AND Connections[0]>0)
                Connections[0]--;
                ATX[Xpos].ATY[YPOS].Dirup=1;
                Repaint();
            END
            IF(Key(_down) AND ATX[Xpos].ATY[YPOS].Dirdo==0 AND Connections[0]>0)
                Connections[0]--;
                ATX[Xpos].ATY[YPOS].Dirdo=1;
                Repaint();
            END
            IF(Key(_left) AND ATX[Xpos].ATY[YPOS].Dirle==0 AND Connections[0]>0)
                Connections[0]--;
                ATX[Xpos].ATY[YPOS].Dirle=1;
                Repaint();
            END
            IF(Key(_right) AND ATX[Xpos].ATY[YPOS].Dirri==0 AND Connections[0]>0)
                Connections[0]--;
                ATX[Xpos].ATY[YPOS].Dirri=1;
                Repaint();
            END
            IF(Connections[0]==0)
                Check(Xpos,Ypos);
                FRAME(200);
                KILL();

                FOR(i=0; i<ConInfo; i++)
                    Connections[i]=Connections[i+1];
                END
                IF(Quad==0)
                    Connections[ConInfo]=rand(1,4);
                ELSE
                    Connections[ConInfo]=rand(3,13)/3;
                END

                cursorstate=0;
                Repaint();
            END
        END

        FRAME;
    END
END






PROCESS Check(x,y)

BEGIN
    ATX[x].ATY[y].checked=1;

    //Atom auf Verbindungen pruefen.
    IF(y>0)
        IF(ATX[x].ATY[y].Dirup==1)
            IF(ATX[x].ATY[y-1].Dirdo!=1)
                NoAtom=1;
            END
        END
    ELSE
        IF(MODE==1)
            IF(ATX[x].ATY[y].Dirup==1)
                NoAtom=1;
            END
        END
    END


    IF(y<Field)
        IF(ATX[x].ATY[y].Dirdo==1)
            IF(ATX[x].ATY[y+1].Dirup!=1)
                NoAtom=1;
            END
        END
    ELSE
        IF(MODE==1)
            IF(ATX[x].ATY[y].Dirdo==1)
                NoAtom=1;
            END
        END
    END


    IF(x>0)
        IF(ATX[x].ATY[y].Dirle==1)
            IF(ATX[x-1].ATY[y].Dirri!=1)
                NoAtom=1;
            END
        END
    ELSE
        IF(MODE==1)
            IF(ATX[x].ATY[y].Dirle==1)
                NoAtom=1;
            END
        END
    END


    IF(x<Field)
        IF(ATX[x].ATY[y].Dirri==1)
            IF(ATX[x+1].ATY[y].Dirle!=1)
                NoAtom=1;
            END
        END
    ELSE
        IF(MODE==1)
            IF(ATX[x].ATY[y].Dirri==1)
                NoAtom=1;
            END
        END
    END

    //An alle ungeprueften, die nebenanliegen, Pruefungen schicken

    IF(y>0)
        IF(ATX[x].ATY[y].Dirup==1 AND ATX[x].ATY[y-1].checked==0)
            Check(x,y-1);
        END
    END

    IF(y<Field)
        IF(ATX[x].ATY[y].Dirdo==1 AND ATX[x].ATY[y+1].checked==0)
            Check(x,y+1);
        END
    END

    IF(x>0)
        IF(ATX[x].ATY[y].Dirle==1 AND ATX[x-1].ATY[y].checked==0)
            Check(x-1,y);
        END
    END

    IF(x<Field)
        IF(ATX[x].ATY[y].Dirri==1 AND ATX[x+1].ATY[y].checked==0)
            Check(x+1,y);
        END
    END
END




PROCESS KILL();

PRIVATE
    Counts;

BEGIN
    FOR(x=0; x<=Field; x++)
        FOR(y=0; y<=Field; y++)
            IF(ATX[x].ATY[y].Checked==1)
                IF(NoAtom==1)
                    ATX[x].ATY[y].checked=0;
                ELSE
                    Counts++;
                    ATX[x].ATY[y].checked=0;
                    ATX[x].ATY[y].exists=0;
                    ATX[x].ATY[y].Dirup=0;
                    ATX[x].ATY[y].Dirdo=0;
                    ATX[x].ATY[y].Dirle=0;
                    ATX[x].ATY[y].Dirri=0;
                END
            END
        END
    END
    //Counts-=2;
    //IF(Counts>0)

    IF(GivenAtoms==0)
        Points+=counts;
        bombssupply+=counts;
        IF(Bombssupply>=BombSNeed)
            Bombssupply-=BombSNeed;
            Bombs++;
        END

    ELSE
        GivenAtoms+=counts;
    END

    //END
    Counts=0;

    NoAtom=0;
END





PROCESS Repaint()

PRIVATE
    PLX;
    PLY;

BEGIN
    PLX=180;
    PLY=110;

    Map_put(0,1,3,0,0); //Loeschen
    Map_put(0,1,114-Field,0,0); //Hintergrund
    FOR(x=0; x<=Field; x++)   //Atome und Bindungen zeichnen.
        FOR(y=0; y<=Field; y++)
            IF(ATX[x].ATY[y].exists==1)
                Map_put(0,1,102,PLX+x*40,PLY+y*40);
            END

            IF(ATX[x].ATY[y].Dirle==1)
                Map_put(0,1,103,PLX+x*40,PLY+y*40);
            END
            IF(ATX[x].ATY[y].Dirup==1)
                Map_put(0,1,104,PLX+x*40,PLY+y*40);
            END
            IF(ATX[x].ATY[y].Dirri==1)
                Map_put(0,1,105,PLX+x*40,PLY+y*40);
            END
            IF(ATX[x].ATY[y].Dirdo==1)
                Map_put(0,1,106,PLX+x*40,PLY+y*40);
            END

        END
    END
END


PROCESS Background()

BEGIN
    x=320;
    y=240;
    z=50;
    graph=1;
    LOOP
        FRAME;
    END
END



























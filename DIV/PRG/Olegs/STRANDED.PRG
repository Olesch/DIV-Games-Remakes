




PROGRAM Stranded;
/*
FelderFarben: 41=Gras
FelderFarben: 54=Wasser
FelderFarben: 73=Sand

ObjektFarben: 4=Grosser Stein
ObjektFarben: 6=Stein
ObjektFarben: 56=Quelle
ObjektFarben: 59=Heilkraut
ObjektFarben: 39=Baum
ObjektFarben: 22=Beeren
ObjektFarben: 11=Geerntete Beeren
ObjektFarben: 73=Getreide
ObjektFarben: 70=Ausgesaetes Getreide


RADARPoints: 1=HELD


KnoepfeAktionen: E:Durchsuchen
KnoepfeAktionen: Q:Schlafen
KnoepfeAktionen: R:Nehmen

AKTIONEN: 1=Essen
AKTIONEN: 2=Benutzen
AKTIONEN: 3=Kombinieren


*/
GLOBAL
    Mauszeiger;
    Held_id;
    Suchen;
    Aktion=1;
    NachtStop;

    Uhrzeit;
    Time_id;//.x

    //Inventar
    Getreide=0;
    Beeren=0;
    Ast=0;
    Stein=0;
    Blatt=0;
    Liane=0;
    Heilkraut=0;
    Mehl=0;
    Teig=0;
    Hammer=0; //NICHT die Anzahl, Aequivalent mit TEX
    Axt=0; //NICHT die Anzahl, Aequivalent mit TEX
    Angel=0; //NICHT die Anzahl, Aequivalent mit TEX

    //Text-zeigen
    MehlTex;
    TeigTex;



    //Werkzeug



    //Statistiken
    Hunger=50; //Gut=100 Schlecht=0
    Durst=50;
    Gesundheit=50;




BEGIN
    load_fpg("Olegs\STRANDED.fpg");
    Draw_all();
    set_mode(m800x600);
    set_fps(24,0);
    define_Region(1,1,1,800,600);
    //MausZeiger=cursor();
    start_scroll(0,0,100,55,1,0);
    Scroll[0].ratio=400;
    Held_id=Held();
    WaterMove();
    KarteF();
    KarteO();
    PunktM();
    RadShad();
    ShowHunger();
    ShowHealth();
    ShowThirst();
    ShowItems();
    Time_id=TimeSun();
//    CardShad();

END




PROCESS Held()

PRIVATE
    Counter;
    AntiFastClick;
    CombAnzahl;

BEGIN
    graph=1;
    ctype=c_scroll;
    get_point(0,101,1,OFFSET x,OFFSET y);
    x=x*20;
    y=y*20;

    LOOP

        IF(key(_s) AND Begehbar(x/20,y/20-1) AND Suchen!=1 AND NachtStop!=1)
            Hunger-=rand(0,1);
            Durst--;
            FROM counter=0 TO 3;
                y-=4;
                Scroll[0].x0=x-400;
                Scroll[0].y0=y-300;
                FRAME;
            END
            y-=4;
            OpenCard(x,y);
        END
        IF(key(_x) AND Begehbar(x/20,y/20+1) AND Suchen!=1 AND NachtStop!=1)
            Hunger-=rand(0,1);
            Durst--;
            FROM counter=0 TO 3;
                y+=4;
                Scroll[0].x0=x-400;
                Scroll[0].y0=y-300;
                FRAME;
            END
            y+=4;
            OpenCard(x,y);
        END
        IF(key(_z) AND Begehbar(x/20-1,y/20) AND Suchen!=1 AND NachtStop!=1)
            Hunger-=rand(0,1);
            Durst--;
            FROM counter=0 TO 3;
                x-=4;
                Scroll[0].x0=x-400;
                Scroll[0].y0=y-300;
                FRAME;
            END
            x-=4;
            OpenCard(x,y);
        END
        IF(key(_c) AND Begehbar(x/20+1,y/20) AND Suchen!=1 AND NachtStop!=1)
            Hunger-=rand(0,1);
            Durst--;
            FROM counter=0 TO 3;
                x+=4;
                Scroll[0].x0=x-400;
                Scroll[0].y0=y-300;
                FRAME;
            END
            x+=4;
            OpenCard(x,y);
        END
        IF(key(_d) AND Suchen!=1 AND NachtStop!=1)
            Suchen=1;
            Heldsucht(x,y);

        END
        IF(key(_f) AND Suchen!=1 AND AntiFastClick!=1 AND NachtStop!=1)
            Antifastclick=1;
            Heldnimmt(x,y);

        END
        IF(key(_1) AND Aktion==1 AND Getreide>0 AND AntiFastClick!=1 AND NachtStop!=1)
            Antifastclick=1;
            Getreide--;
            Hunger+=4;
        END
        IF(key(_1) AND Aktion==2 AND Getreide>0 AND AntiFastClick!=1 AND NachtStop!=1)
            IF(Map_get_Pixel(0,103,x/20,y/20)==0 AND Map_get_pixel(0,101,x/20,y/20)==41)
                Antifastclick=1;
                Getreide--;
                map_put(0,100,73,x,y);
                map_put_pixel(0,103,x/20,y/20,70);
                refresh_Scroll(0);
            END
        END
        IF(key(_2) AND Aktion==1 AND Beeren>0 AND AntiFastClick!=1 AND NachtStop!=1)
            Antifastclick=1;
            Beeren--;
            Hunger+=5;
            Durst+=2;
        END
        IF(key(_7) AND Aktion==1 AND Heilkraut>0 AND AntiFastClick!=1 AND NachtStop!=1)
            Antifastclick=1;
            Heilkraut--;
            Hunger+=10;
            Durst+=10;
            Gesundheit+=20;
        END
        IF(key(_8) AND Aktion==1 AND Mehl>0 AND AntiFastClick!=1 AND NachtStop!=1)
            Antifastclick=1;
            Mehl--;
            Hunger+=8;
        END
        IF(key(_9) AND Aktion==1 AND Teig>0 AND AntiFastClick!=1 AND NachtStop!=1)
            Antifastclick=1;
            Teig--;
            Hunger+=12;
            Durst+=6;
            Gesundheit+=1;
        END
        CombAnzahl=0;
        IF(Aktion==3 AND NachtStop!=1 AND suchen!=1)
            IF(key(_1)) CombAnzahl++; END
            IF(key(_2)) CombAnzahl++; END
            IF(key(_3)) CombAnzahl++; END
            IF(key(_4)) CombAnzahl++; END
            IF(key(_5)) CombAnzahl++; END
            IF(key(_6)) CombAnzahl++; END
            IF(key(_7)) CombAnzahl++; END
            IF(CombAnzahl==2)
                IF(key(_1) AND key(_4) AND Getreide>2 AND Stein>0 AND AntifastClick!=1)
                    AntifastClick=1;
                    IF(Mehltex!=2)
                        MehlTex=1;
                    END
                    Getreide-=3;
                    Mehl++;
                    Schreiben("Mehl Hergestellt");
                END
                IF(key(_3) AND key(_4) AND Ast>0 AND Stein>0 AND AntifastClick!=1)
                    AntifastClick=1;
                    IF(Hammer==0)
                        Hammer=1;
                        Stein--;
                        Ast--;
                        Schreiben("Hammer Hergestellt");
                    END

                END
                IF(key(_3) AND key(_6) AND Ast>0 AND Liane>0 AND AntifastClick!=1)
                    AntifastClick=1;
                    IF(Angel==0)
                        Angel=1;
                        Liane--;
                        Ast--;
                        Schreiben("Angel Hergestellt");
                    END

                END

            END
            IF(CombAnzahl==3)
                IF(key(_3) AND key(_4) AND key(_6) AND Ast>0 AND Stein>0 AND Liane>0 AND AntifastClick!=1)
                    AntifastClick=1;
                    IF(Axt==0)
                        Axt=1;
                        Stein--;
                        Ast--;
                        Liane--;
                        Schreiben("Axt Hergestellt");
                    END
                END
            END
        END
        IF(Aktion==2 AND NachtStop!=1 AND suchen!=1)
            IF(key(_8) AND Mehl>0 AND AntifastClick!=1 AND Map_get_pixel(0,103,x/20,y/20)==56)
                AntifastClick=1;
                Mehl--;
                Teig++;
                IF(TeigTex!=2)
                    TeigTex=1;
                    Schreiben("Teig Hergestellt");
                END
            END
        END






        IF(key(_a) AND AntiFastClick!=1 AND NachtStop!=1 AND suchen!=1)
            AntiFastClick=1;
            IF(time_id.x>750)
                time_id.x=800;
            ELSE
                Schreiben("Zu Frueh!");
            END
        END

        /*IF(key(_h) AND AntiFastClick!=1 AND time_id.x<775 AND suchen!=1)
            AntiFastClick=1;
            IF(time_id.x>750)
                time_id.x=800;
            ELSE
                Schreiben("Zu Frueh!");
            END
        END   *///AXT



        IF(NOT key(_f) AND NOT key(_a) AND NOT key(_1) AND NOT key(_2) AND NOT key(_3) AND NOT key(_4) AND NOT key(_5) AND NOT key(_6) AND NOT key(_7) AND NOT key(_8) AND NOT key(_9))
            Antifastclick=0;
        END
        IF(Key(_v))
            Aktion=1;
        END
        IF(Key(_b))
            Aktion=2;
        END
        IF(Key(_g))
            Aktion=3;
        END

        Scroll[0].x0=x-400;
        Scroll[0].y0=y-300;
        FRAME;
    END

END

PROCESS Begehbar(x,y)
BEGIN
    SWITCH(Map_get_pixel(0,101,x,y))
        CASE 41:  //Gras
            RETURN(1);
        END
        CASE 54:  //Wasser
            RETURN(0);
        END
        CASE 73:  //Sand
            RETURN(1);
        END
        CASE 0:  //Unendliche Leere
            RETURN(0);
        END

    END
END


PROCESS OpenCard(x,y)

BEGIN
    Map_put_pixel(0,104,x/20+1,y/20+1,0);
    Map_put_pixel(0,104,x/20-1,y/20+1,0);
    Map_put_pixel(0,104,x/20-1,y/20-1,0);
    Map_put_pixel(0,104,x/20+1,y/20-1,0);
    Map_put_pixel(0,104,x/20+2,y/20,0);
    Map_put_pixel(0,104,x/20-2,y/20,0);
    Map_put_pixel(0,104,x/20,y/20+2,0);
    Map_put_pixel(0,104,x/20,y/20-2,0);

END

PROCESS HeldSucht(x,y)

PRIVATE
    found;
    Text;

BEGIN
    FRAME(4900);
    IF(NachtStop==1)
        Suchen=0;
        RETURN();
    END
    FRAME(4900);
    Suchen=0;
    IF(NachtStop==1)
        Suchen=0;
        RETURN();
    END
    SWITCH(Map_get_pixel(0,103,x/20,y/20))
        CASE 39:  //Baum
            found=rand(0,11);
            IF(found>=0 AND found<=3)
                Ast++;
                Text=Write(0,400,300,7,"Ast gefunden!");
            END
            IF(found>=4 AND found<=6)
                Blatt++;
                Text=Write(0,400,300,7,"Blatt gefunden!");
            END
            IF(found>=7 AND found<=8)
                Liane++;
                Text=Write(0,400,300,7,"Liane gefunden!");
            END
            IF(found>=9 AND found<=11)
                Text=Write(0,400,300,7,"Nichts gefunden!");
            END
            FRAME(9600);
            delete_text(Text);

        END
        CASE 22, 11, 59:  //BeerenBusch, Heilkraut
            found=rand(0,8);
            IF(found>=0 AND found<=1)
                Ast++;
                Text=Write(0,400,300,7,"Ast gefunden!");
            END
            IF(found>=2 AND found<=6)
                Blatt++;
                Text=Write(0,400,300,7,"Blatt gefunden!");
            END
            IF(found>=7 AND found<=8)
                Text=Write(0,400,300,7,"Nichts gefunden!");
            END
            FRAME(9600);
            delete_text(Text);

        END
        CASE 56, 6, 4:  //Stein
            found=rand(0,5);
            IF(found>=0 AND found<=3)
                Stein++;
                Text=Write(0,400,300,7,"Stein gefunden!");
            END
            IF(found>=4 AND found<=5)
                Text=Write(0,400,300,7,"Nichts gefunden!");
            END
            FRAME(9600);
            delete_text(Text);
        END
        DEFAULT:
            Text=Write(0,400,300,7,"Nichts gefunden!");
            FRAME(9600);
            delete_text(Text);
        END
    END
END

PROCESS HeldNimmt(x,y)

PRIVATE
    Text;

BEGIN
    SWITCH(Map_get_pixel(0,103,x/20,y/20))
        CASE 22: //Beeren
            Beeren++;
            Text=Write(0,400,280+rand(-20,20),7,"Beeren gefunden!");
            Map_put_pixel(0,103,x/20,y/20,11);
            map_put(0,100,66,x,y);
            refresh_scroll(0);
        END
        CASE 11: //Gepflueckte Beeren
            Blatt+=2;
            Text=Write(0,400,280+rand(-20,20),7,"2 Blaetter gefunden!");
            Map_put_pixel(0,103,x/20,y/20,0);
            map_put(0,100,rand(50,52),x,y);
            refresh_scroll(0);
        END
        CASE 73: //Getreide
            Getreide+=2;
            Text=Write(0,400,280+rand(-20,20),7,"2 Getreide gefunden!");
            Map_put_pixel(0,103,x/20,y/20,0);
            map_put(0,100,rand(50,52),x,y);
            refresh_scroll(0);
        END
        CASE 59: //Heilkraut
            Heilkraut+=1;
            Text=Write(0,400,280+rand(-20,20),7,"Heilkraut gefunden!");
            Map_put_pixel(0,103,x/20,y/20,0);
            map_put(0,100,rand(50,52),x,y);
            refresh_scroll(0);
        END
        CASE 6:  //Steine
            Stein+=2;
            Text=Write(0,400,280+rand(-20,20),7,"2 Steine gefunden!");
            Map_put_pixel(0,103,x/20,y/20,0);
            map_put(0,100,rand(50,52),x,y);
            refresh_scroll(0);
        END
        CASE 56:  //Quelle
            Durst+=5;
            Text=Write(0,400,280+rand(-20,20),7," ");
        END
        DEFAULT:
            Text=Write(0,400,300,7,"Nichts da!");
        END

    END
    FRAME(9600);
    delete_text(Text);

END


PROCESS Schreiben(ToWrite)

PRIVATE
    Text;

BEGIN
    Text=Write(0,400,280+rand(-20,20),7,ToWrite);
    FRAME(9600);
    delete_text(Text);
END



PROCESS cursor()
BEGIN
    //x=320;
    //y=240;
    graph=102;
    //scroll[0].camera=id;
    z=-100;
    ctype=c_screen;
    LOOP
        /*x+=mouse.x-320;
        y+=mouse.y-240;
        mouse.x=320;
        mouse.y=240;*/

        x=mouse.x;
        y=mouse.y;




        FRAME;

    END
END






PROCESS Draw_all()

PRIVATE
    Counterx;
    Countery;

BEGIN
    LOOP
        SWITCH(Map_get_pixel(0,101,counterx,countery))

            CASE 41:  //Gras
                map_put(0,100,rand(50,52),Counterx*20,Countery*20);
            END

            /*CASE 54:  //Wasser
                map_put(0,100,55,Counterx*20,Countery*20);
            END*/

            CASE 73:  //Sand
                map_put(0,100,rand(57,58),Counterx*20,Countery*20);
            END
        END

        Counterx++;
        IF(Counterx>250)
            Counterx=0;
            Countery++;
        END
        IF(Countery>250)
            BREAK;
        END
    END

    get_point(0,101,1,OFFSET counterx,OFFSET countery);
    map_put(0,100,64,Counterx*20+20,Countery*20);
    map_put_pixel(0,103,Counterx+1,Countery,73);
    map_put(0,100,72,Counterx*20-20,Countery*20);
    map_put_pixel(0,103,Counterx-1,Countery,59);
    map_put(0,100,64,Counterx*20,Countery*20+20);
    map_put_pixel(0,103,Counterx,Countery+1,73);
    map_put(0,100,70,Counterx*20,Countery*20-20);
    map_put_pixel(0,103,Counterx,Countery-1,56);

    FROM x=0 TO 18000;



        Counterx=Rand(0,249);
        Countery=Rand(0,249);
        IF(Map_get_Pixel(0,103,Counterx,Countery)==0)
            SWITCH(Map_get_pixel(0,101,counterx,countery))

                CASE 41:  //Gras
                    y=rand(0,137);
                    IF(y>=0 AND y<=60) //BAUM
                        map_put(0,100,rand(60,61),Counterx*20,Countery*20);
                        map_put_pixel(0,103,Counterx,Countery,39);
                    END
                    IF(y>=61 AND y<=100) //Deko
                        map_put(0,100,65,Counterx*20,Countery*20);
                    END
                    IF(y>=101 AND y<=110) //Beeren
                        map_put(0,100,63,Counterx*20,Countery*20);
                        map_put_pixel(0,103,Counterx,Countery,22);
                    END
                    IF(y==111) //Getreide
                        IF(rand(0,1)==1)
                            map_put(0,100,64,Counterx*20,Countery*20);
                            map_put_pixel(0,103,Counterx,Countery,73);
                        END
                    END
                    IF(y>=112 AND y<=124) //Stein
                        map_put(0,100,69,Counterx*20,Countery*20);
                        map_put_pixel(0,103,Counterx,Countery,6);
                    END
                    IF(y==125) //Quelle
                        map_put(0,100,70,Counterx*20,Countery*20);
                        map_put_pixel(0,103,Counterx,Countery,56);
                    END
                    IF(y>=126 AND y<=136) //Grosser Stein
                        map_put(0,100,71,Counterx*20,Countery*20);
                        map_put_pixel(0,103,Counterx,Countery,4);
                    END
                    IF(y==137) //Heilkraut
                        map_put(0,100,72,Counterx*20,Countery*20);
                        map_put_pixel(0,103,Counterx,Countery,59);
                    END



                END

                /*CASE 54:  //Wasser
                    map_put(0,100,55,Counterx*20,Countery*20);
                END*/
                CASE 73:  //Sand
                END
            END
        END
    END

    refresh_scroll(0);
END

PROCESS Refresh_all()

PRIVATE
    Counterx;
    Countery;

BEGIN
    LOOP
        SWITCH(Map_get_pixel(0,103,counterx,countery))

            CASE 11:  //Gepflueckte Beeren
                IF(rand(0,10)==10)
                    map_put(0,100,63,Counterx*20,Countery*20);
                    map_put_pixel(0,103,Counterx,Countery,22);
                END
            END

            /*CASE 54:  //Wasser
                map_put(0,100,55,Counterx*20,Countery*20);
            END*/

            CASE 70:  //Sand
                map_put(0,100,rand(50,52),Counterx*20,Countery*20);
                map_put(0,100,64,Counterx*20,Countery*20);
                map_put_pixel(0,103,Counterx,Countery,73);
            END
        END

        Counterx++;
        IF(Counterx>250)
            Counterx=0;
            Countery++;
        END
        IF(Countery>250)
            BREAK;
        END
    END


                /*CASE 41:  //Gras
                    y=rand(0,137);
                    IF(y>=0 AND y<=60) //BAUM
                        map_put(0,100,rand(60,61),Counterx*20,Countery*20);
                        map_put_pixel(0,103,Counterx,Countery,39);
                    END
                    IF(y>=61 AND y<=100) //Deko
                        map_put(0,100,65,Counterx*20,Countery*20);
                    END
                    IF(y>=101 AND y<=110) //Beeren
                        map_put(0,100,63,Counterx*20,Countery*20);
                        map_put_pixel(0,103,Counterx,Countery,22);
                    END
                    IF(y==111) //Getreide
                        IF(rand(0,1)==1)
                            map_put(0,100,64,Counterx*20,Countery*20);
                            map_put_pixel(0,103,Counterx,Countery,73);
                        END
                    END
                    IF(y>=112 AND y<=124) //Stein
                        map_put(0,100,69,Counterx*20,Countery*20);
                        map_put_pixel(0,103,Counterx,Countery,6);
                    END
                    IF(y==125) //Quelle
                        map_put(0,100,70,Counterx*20,Countery*20);
                        map_put_pixel(0,103,Counterx,Countery,56);
                    END
                    IF(y>=126 AND y<=136) //Grosser Stein
                        map_put(0,100,71,Counterx*20,Countery*20);
                        map_put_pixel(0,103,Counterx,Countery,4);
                    END
                    IF(y==137) //Heilkraut
                        map_put(0,100,72,Counterx*20,Countery*20);
                        map_put_pixel(0,103,Counterx,Countery,59);
                    END



                END*/


    refresh_scroll(0);
END


PROCESS WaterMove()
BEGIN
    LOOP
        Scroll[0].x1+=1;
        Scroll[0].y1+=1;
        FRAME(100);
        Scroll[0].x1+=1;
        FRAME(100);
    END
END


PROCESS KarteF();
BEGIN
    x=675;
    y=475;
    z=-2;
    graph=101;
    LOOP
        FRAME;
    END
END
PROCESS KarteO();
BEGIN
    x=675;
    y=475;
    z=-3;
    graph=103;
    LOOP
        FRAME;
    END
END
PROCESS PunktM();
BEGIN
    z=-4;
    LOOP
        x=550+Held_id.x/20;
        y=350+Held_id.x/20;
        FRAME;
    END
END
PROCESS RadShad();
BEGIN
    x=675;
    y=475;
    z=-5;
    graph=104;
    LOOP
        FRAME;
    END
END
PROCESS CardShad();
BEGIN
    x=5000/2;
    y=5000/2;
    z=-1;
    graph=104;
    size=2000;
    ctype=c_scroll;
    LOOP
        graph=104;
        FRAME;
    END
END


PROCESS ShowHunger()
PRIVATE
    Counter;

BEGIN
    graph=2;
    y=580;
    LOOP
        IF(Counter>=120)
            Counter=0;
            Hunger-=1;
        END
        IF(Hunger<0)
            Hunger=0;
        END
        IF(Hunger>100)
            Hunger=100;
        END
        x=Hunger-100;
        Counter++;
        FRAME(100);
    END
END
PROCESS ShowThirst()
PRIVATE
    Counter;

BEGIN
    graph=3;
    y=560;
    LOOP
        IF(Counter>=60)
            Counter=0;
            Durst-=1;
        END
        IF(Durst<0)
            Durst=0;
        END
        IF(Durst>100)
            Durst=100;
        END
        x=Durst-100;
        Counter++;
        FRAME(100);
    END
END
PROCESS ShowHealth()
PRIVATE
    Counter;

BEGIN
    graph=4;
    y=600;
    LOOP
        IF(Counter>=72)
            Counter=0;
            IF(Hunger<=0)
                Gesundheit--;
            END
            IF(Durst<=0)
                Gesundheit--;
            END
            IF(Hunger>90 AND Durst>90)
                Gesundheit++;
            END
        END
        IF(Gesundheit<0)
            Held_id.Graph=40;
            Gesundheit=0;
        END
        IF(Gesundheit>100)
            Gesundheit=100;
        END
        Counter++;
        x=Gesundheit-100;
        FRAME(100);
    END
END
PROCESS ShowItems()
PRIVATE
    Pfeil;

BEGIN
    Write(0,0,10,6,"1-Getreide:");
    Write_int(0,80,10,6,OFFSET Getreide);
    Write(0,0,20,6,"2-Beeren:");
    Write_int(0,80,20,6,OFFSET Beeren);
    Write(0,0,30,6,"3-Ast:");
    Write_int(0,80,30,6,OFFSET Ast);
    Write(0,0,40,6,"4-Stein:");
    Write_int(0,80,40,6,OFFSET Stein);
    Write(0,0,50,6,"5-Blatt:");
    Write_int(0,80,50,6,OFFSET Blatt);
    Write(0,0,60,6,"6-Liane:");
    Write_int(0,80,60,6,OFFSET Liane);
    Write(0,0,70,6,"7-Heilkraut:");
    Write_int(0,80,70,6,OFFSET Heilkraut);

    Write(0,720,10,6,"V-Essen");
    Write(0,720,20,6,"B-Benutzen");
    Write(0,720,30,6,"G-Kombinieren");
    Write(0,720,50,6,"D-Suchen");
    Write(0,720,60,6,"F-Aufnehmen");
    Write(0,720,70,6,"A-Schlafen");
    Pfeil=Write(0,700,10,6,"-->");

    LOOP
        IF(Aktion==1)
            Move_text(Pfeil,700,10);
        END
        IF(Aktion==2)
            Move_text(Pfeil,700,20);
        END
        IF(Aktion==3)
            Move_text(Pfeil,700,30);
        END
        IF(MehlTex==1)
            Write(0,0,80,6,"8-Mehl:");
            Write_int(0,80,80,6,OFFSET Mehl);
            MehlTex=2;
        END
        IF(TeigTex==1)
            Write(0,0,90,6,"9-Teig:");
            Write_int(0,80,90,6,OFFSET Teig);
            TeigTex=2;
        END
        IF(Axt==1)
            Write(0,720,90,6,"H-Axt");
            Axt=2;
        END
        IF(Angel==1)
            Write(0,720,100,6,"N-Angel");
            Angel=2;
        END
        IF(Hammer==1)
            Write(0,720,110,6,"J-Bauen");
            Hammer=2;
        END

        FRAME;
    END
END

PROCESS TimeSun()

BEGIN
    Graph=5;
    y=349;
    LOOP
        x=550;
        LOOP
            x+=1;
            IF(x>800)
                BREAK;
            END
            FRAME(1200);
        END

        SWITCH(Map_get_pixel(0,103,Held_id.x/20,Held_id.y/20))
            CASE 39:  //Baum
                Gesundheit-=15+rand(-5,5);
            END
            DEFAULT:
                Gesundheit-=25+rand(-5,5);
            END
        END

        NachtStop=1;
        Fade_Off();
        Refresh_all();
        FRAME(3000);
        Fade_On();
        NachtStop=0;
    END
END




















//-------------------------------------------------------------------
// TITLE:   Siedler
// AUTHOR:  Oleg Yuschuk
// DATE:    25/1/2005
//-------------------------------------------------------------------




//
//Bugs: Beim Rechts oder Nach unten gehen koennen
//      die Maennchen danach nochmal gehen da sie
//      zweimal geprueft werden
//
//      Man kann Haeuserbauplaetze erstellen aber Haeuser nicht bauen
//
//      Man kann kein Lehm sammeln
//
//


/*

StartMapObjects:40=Baum
                55=Siedler

StartMapTerrain:40=Gras
                55=Wasser
                120=Lehm/Ufer
                115=Haus
                116=Fertiges Haus

LogicMap:       55=Nichts Machen
                75=Laufen
                40=BaumFaeller
                41=BaumFaellerfaellt
                42=BaumFaellertraegtHolz
                120=LehmSammler
                121=LehmSammlersammelt
                122=LehmSammlertraegtLehm





//HausvervollstaendigungsMap:






*/

PROGRAM Siedler;

GLOBAL
    fpsa=24;      //FPS Variabeln
    fpsb=0;      //
    MausZeiger;   //Dies ist der Mauszeiger


    BeimBau;          //Es wird gebaut mit dem Mauszeiger
    Hausgroesse;      //Wie gross ist das Haus? 3x3=0303 10x15=1015
    HausBau_id;       //

    AktionsText;      //Welcher Text muss geloescht werden?
    AktionsZahl;      //Welche Zahl muss geloescht werden?


    Holzsetzen;       //Wird der Holzsammelpunkt gesetzt?
    HolzSPX=-1;       //HolzSammelPunktX
    HolzSPY=-1;       //HolzSammelPunktY
    HolzArbeiter;     //Wie viele Holzarbeiter gibt es?
    HolzArbeiterMax;  //Was ist das maximum?


    Lehmsetzen;       //Wird der Lehmsammelpunkt gesetzt?
    LehmSPX=-1;       //LehmSammelPunktX
    LehmSPY=-1;       //LehmSammelPunktY
    LehmArbeiter;     //Wie viele Lehmarbeiter gibt es?
    LehmArbeiterMax;  //Was ist das maximum?

    STOP;             //Naechsten Paar Aktionen nicht ausfuehren.


    Hauszaehler;         //Bei welchem Haus sind wir gerade?

    STRUCT Haus[50]
        X_coor;          //Obere Grenze
        Y_coor;          //Linke Grenze
        Width;           //Breite nach rechts
        Height;          //Hoehe nach unten
        Need_Wood;       //Wie viel Holz braucht man zur Vollendung?
        Need_Loam;       //Wie viel Lehm braucht man zur Vollendung?
        Building_Type;   //Was fuer ein Gebaeude-Typ ist das?
        Specific_Var;    //Von Gebaeude zu Gebaeude verschieden


    END=51 DUP (-1,-1,-1,-1,-1,-1,-1,-1);




BEGIN
    //load_pal("OLEGWASS.Pal");
    load_fpg("Olegs\Siedler.fpg");
    //load_fnt("Olegs\Space.fnt");

    set_mode(m640x480);
    set_fps(24,0);
    define_Region(1,1,1,640,480);
    MausZeiger=cursor();
    start_scroll(0,0,2,0,1,0);
    draw_all(1,1);
    Overlayer();
    Maennchen();
    KnoepfeEvent();
    //WaterAnim();
    HelpMap();


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







PROCESS Maennchen()



PRIVATE
    Counterx;
    Countery;
    CounterxTemp;
    CounteryTemp;

BEGIN
    LOOP

        SWITCH(Map_get_pixel(0,11,counterx,countery))//JobAenderung
            CASE 55://Stehen
                IF(Rand(0,50)==0)
                    Map_put_pixel(0,11,counterx,countery,75);
                END
            END
            CASE 75://Laufen
                IF(Rand(0,200)==0 AND HolzArbeiter<Holzarbeitermax)
                    Map_put_pixel(0,11,counterx,countery,40);
                    Holzarbeiter++;
                END
                IF(Rand(0,200)==0 AND LehmArbeiter<Lehmarbeitermax)
                    Map_put_pixel(0,11,counterx,countery,120);
                    Lehmarbeiter++;
                END
            END
            CASE 40://Holzfaeller
                IF(HolzSPX==-1 OR HolzSPY==-1 OR Rand(0,250==0))
                    Map_put_pixel(0,11,counterx,countery,55);
                    Loesche_Feld(Counterx,Countery);
                    map_put(0,8,100,Counterx*10,Countery*10);
                    HolzArbeiter--;
                    STOP=1;
                END

                IF(Holzarbeiter>Holzarbeitermax AND Rand(0,150)==0 AND STOP!=1)
                    Map_put_pixel(0,11,counterx,countery,55);
                    Loesche_Feld(Counterx,Countery);
                    map_put(0,8,100,Counterx*10,Countery*10);
                    HolzArbeiter--;
                    STOP=0;
                END
            END
            CASE 120://Lehmsammler
                IF(LehmSPX==-1 OR LehmSPY==-1 OR Rand(0,250==0))
                    Map_put_pixel(0,11,counterx,countery,55);
                    Loesche_Feld(Counterx,Countery);
                    map_put(0,8,100,Counterx*10,Countery*10);
                    LehmArbeiter--;
                    STOP=1;
                END

                IF(Lehmarbeiter>Lehmarbeitermax AND Rand(0,150)==0 AND STOP!=1)
                    Map_put_pixel(0,11,counterx,countery,55);
                    Loesche_Feld(Counterx,Countery);
                    map_put(0,8,100,Counterx*10,Countery*10);
                    LehmArbeiter--;
                    STOP=0;
                END
            END



        END





        SWITCH(Map_get_pixel(0,11,counterx,countery))//Bewegung

            CASE 55://Stehen
            END



            CASE 75://Laufen

                CounterxTemp=Counterx;
                CounteryTemp=Countery;

                SWITCH(rand(1,20))           //SWITCH IM SWITCH!!
                    CASE 1:
                        CounterxTemp++;
                    END
                    CASE 2:
                        CounterxTemp--;
                    END
                    CASE 3:
                        CounteryTemp++;
                    END
                    CASE 4:
                        CounteryTemp--;
                    END
                    CASE 5..20:
                        CounteryTemp=0;
                        CounterxTemp=0;
                    END
                END


                IF(CounterxTemp!=0 AND CounterxTemp!=1279 AND
                 CounteryTemp!=0 AND CounteryTemp!=959)
                    IF(Begehbar(CounterxTemp,CounteryTemp)==1)
                        map_put(0,8,100,CounterxTemp*10,CounteryTemp*10);
                        map_put_pixel(0,11,CounterxTemp,CounteryTemp,75);
                        map_put_pixel(0,11,Counterx,Countery,0);
                        Loesche_Feld(Counterx,Countery);

                    END
                END

            END


            CASE 40://Holzfaeller



                CounterxTemp=Counterx;
                CounteryTemp=Countery;
                SWITCH(rand(1,40))           //SWITCH IM SWITCH!!
                    CASE 1..5:          //Auf weiterer Koordinate hingehen
                        IF(abs(Counterx-HolzSPX)>abs(Countery-HolzSPY))
                            IF(Counterx-HolzSPX>0)
                                counterxtemp--;
                            ELSE
                                counterxtemp++;
                            END

                        ELSE
                            IF(Countery-HolzSPY>0)
                                counterytemp--;
                            ELSE
                                counterytemp++;
                            END

                        END
                    END
                    CASE 6..8:          //Auf naeherer Koordinate hingehen
                        IF(abs(Counterx-HolzSPX)<abs(Countery-HolzSPY))
                            IF(Counterx-HolzSPX>0)
                                counterxtemp--;
                            ELSE
                                counterxtemp++;
                            END

                        ELSE
                            IF(Countery-HolzSPY>0)
                                counterytemp--;
                            ELSE
                                counterytemp++;
                            END

                        END
                    END
                    CASE 7..33:      //Stehen bleiben
                        CounteryTemp=0;
                        CounterxTemp=0;
                    END
                    CASE 34..40:  //Zufaellig gehen

                        SWITCH(rand(1,20))           //SWITCH IM SWITCH IM SWITCH!!!!!
                            CASE 1:
                                CounterxTemp++;
                            END
                            CASE 2:
                                CounterxTemp--;
                            END
                            CASE 3:
                                CounteryTemp++;
                            END
                            CASE 4:
                                CounteryTemp--;
                            END
                            CASE 5..20:
                                CounteryTemp=0;
                                CounterxTemp=0;
                            END
                        END
                    END
                END


                IF(CounterxTemp!=0 AND CounterxTemp!=1279 AND
                 CounteryTemp!=0 AND CounteryTemp!=959)
                    IF(Begehbar(CounterxTemp,CounteryTemp)==1)
                        map_put(0,8,101,CounterxTemp*10,CounteryTemp*10);
                        map_put_pixel(0,11,CounterxTemp,CounteryTemp,40);
                        map_put_pixel(0,11,Counterx,Countery,0);
                        Loesche_Feld(Counterx,Countery);

                    END

                    IF(Map_get_pixel(0,9,CounterxTemp,CounteryTemp)==40 AND
                     Map_get_pixel(0,11,CounterxTemp,CounteryTemp)==0)

                        map_put(0,8,101,CounterxTemp*10,CounteryTemp*10);
                        map_put_pixel(0,11,CounterxTemp,CounteryTemp,41);
                        map_put_pixel(0,11,Counterx,Countery,0);
                        Loesche_Feld(Counterx,Countery);

                    END


                END





            END


            CASE 41://Holzfaeller faellt Holz
                IF(Rand(0,100)==0)
                    Loesche_Feld(Counterx,Countery);
                    map_put(0,8,102,Counterx*10,Countery*10);
                    map_put_pixel(0,11,Counterx,Countery,42);
                    map_put_pixel(0,9,Counterx,Countery,0);

                END
            END

            CASE 42://Holzfaeller traegt Holz

            END








            CASE 120://Lehmsammler



                CounterxTemp=Counterx;
                CounteryTemp=Countery;
                SWITCH(rand(1,40))           //SWITCH IM SWITCH!!
                    CASE 1..5:          //Auf weiterer Koordinate hingehen
                        IF(abs(Counterx-LehmSPX)>abs(Countery-LehmSPY))
                            IF(Counterx-LehmSPX>0)
                                counterxtemp--;
                            ELSE
                                counterxtemp++;
                            END

                        ELSE
                            IF(Countery-LehmSPY>0)
                                counterytemp--;
                            ELSE
                                counterytemp++;
                            END

                        END
                    END
                    CASE 6..8:          //Auf naeherer Koordinate hingehen
                        IF(abs(Counterx-LehmSPX)<abs(Countery-LehmSPY))
                            IF(Counterx-LehmSPX>0)
                                counterxtemp--;
                            ELSE
                                counterxtemp++;
                            END

                        ELSE
                            IF(Countery-LehmSPY>0)
                                counterytemp--;
                            ELSE
                                counterytemp++;
                            END

                        END
                    END
                    CASE 7..33:      //Stehen bleiben
                        CounteryTemp=0;
                        CounterxTemp=0;
                    END
                    CASE 34..40:  //Zufaellig gehen

                        SWITCH(rand(1,20))           //SWITCH IM SWITCH IM SWITCH!!!!!
                            CASE 1:
                                CounterxTemp++;
                            END
                            CASE 2:
                                CounterxTemp--;
                            END
                            CASE 3:
                                CounteryTemp++;
                            END
                            CASE 4:
                                CounteryTemp--;
                            END
                            CASE 5..20:
                                CounteryTemp=0;
                                CounterxTemp=0;
                            END
                        END
                    END
                END


                IF(CounterxTemp!=0 AND CounterxTemp!=1279 AND
                 CounteryTemp!=0 AND CounteryTemp!=959)
                    IF(Begehbar(CounterxTemp,CounteryTemp)==1)
                        map_put(0,8,105,CounterxTemp*10,CounteryTemp*10);
                        map_put_pixel(0,11,CounterxTemp,CounteryTemp,120);
                        map_put_pixel(0,11,Counterx,Countery,0);
                        Loesche_Feld(Counterx,Countery);

                    END

                    /*    OLLO! Petite Probleme!!!  **********

                    IF(Map_get_pixel(0,10,CounterxTemp,CounteryTemp)==120)

                        map_put(0,8,105,CounterxTemp*10,CounteryTemp*10);
                        map_put_pixel(0,11,CounterxTemp,CounteryTemp,121);
                        map_put_pixel(0,11,Counterx,Countery,0);
                        Loesche_Feld(Counterx,Countery);

                    END
                    */

                END





            END


            CASE 121://Lehmsammler sammelt Lehm
                IF(Rand(0,150)==0)
                    Loesche_Feld(Counterx,Countery);
                    map_put(0,8,106,Counterx*10,Countery*10);
                    map_put_pixel(0,11,Counterx,Countery,122);

                END
            END

            CASE 122://Holzfaeller traegt Holz

            END








        END










        Counterx++;
        IF(Counterx>129)
            Counterx=0;
            Countery++;
        END
        IF(Countery>97)
            counterx=0;
            countery=0;
            FRAME(100);
        END
    END
END































PROCESS cursor()
BEGIN
    x=320;
    y=240;
    graph=1;
    scroll[0].camera=id;
    z=-100;
    ctype=c_scroll;
    LOOP
        /*x+=mouse.x-320;
        y+=mouse.y-240;
        mouse.x=320;
        mouse.y=240;*/

        x+=mouse.x-320;
        y+=mouse.y-240;

        mouse.x=320;
        mouse.y=240;


        new_coordinates();

        IF(Mouse.left)
            IF(Holzsetzen==1)
                HolzSPX=x/10;
                HolzSPY=y/10;
                Holzsetzen=0;
            END

            IF(Lehmsetzen==1)
                LehmSPX=x/10;
                LehmSPY=y/10;
                Lehmsetzen=0;
            END

            IF(BeimBau==1)
                IF(Hausgroesse==0303)
                    IF(Begehbar(Hausbau_id.x/10,Hausbau_id.y/10)==1
                    AND Begehbar(Hausbau_id.x/10+1,Hausbau_id.y/10+1)==1
                    AND Begehbar(Hausbau_id.x/10+1,Hausbau_id.y/10-1)==1
                    AND Begehbar(Hausbau_id.x/10+1,Hausbau_id.y/10)==1
                    AND Begehbar(Hausbau_id.x/10-1,Hausbau_id.y/10+1)==1
                    AND Begehbar(Hausbau_id.x/10-1,Hausbau_id.y/10-1)==1
                    AND Begehbar(Hausbau_id.x/10-1,Hausbau_id.y/10)==1
                    AND Begehbar(Hausbau_id.x/10,Hausbau_id.y/10+1)==1
                    AND Begehbar(Hausbau_id.x/10,Hausbau_id.y/10-1)==1)


                        Haus[Hauszaehler].X_coor=x/10-1;     //Obere Grenze
                        Haus[Hauszaehler].Y_coor=y/10-1;     //Linke Grenze
                        Haus[Hauszaehler].Width=3;           //Breite nach rechts
                        Haus[Hauszaehler].Height=3;          //Hoehe nach unten
                        Haus[Hauszaehler].Need_Wood=6;       //Wie viel Holz braucht man zur Vollendung?
                        Haus[Hauszaehler].Need_Loam=0;       //Wie viel Lehm braucht man zur Vollendung?
                        Haus[Hauszaehler].Building_Type=1;   //Was fuer ein Gebaeude-Typ ist das?
                        Haus[Hauszaehler].Specific_Var=0;    //Von Gebaeude zu Gebaeude verschieden


                        Hauszaehler++;

                        map_put(0,2,30,Hausbau_id.x,Hausbau_id.y);
                        map_put(0,2,30,Hausbau_id.x,Hausbau_id.y+10);
                        map_put(0,2,30,Hausbau_id.x,Hausbau_id.y-10);
                        map_put(0,2,30,Hausbau_id.x+10,Hausbau_id.y);
                        map_put(0,2,30,Hausbau_id.x+10,Hausbau_id.y+10);
                        map_put(0,2,30,Hausbau_id.x+10,Hausbau_id.y-10);
                        map_put(0,2,30,Hausbau_id.x-10,Hausbau_id.y);
                        map_put(0,2,30,Hausbau_id.x-10,Hausbau_id.y+10);
                        map_put(0,2,30,Hausbau_id.x-10,Hausbau_id.y-10);

                        map_put_pixel(0,10,Hausbau_id.x/10,Hausbau_id.y/10,115);
                        map_put_pixel(0,10,Hausbau_id.x/10,Hausbau_id.y/10+1,115);
                        map_put_pixel(0,10,Hausbau_id.x/10,Hausbau_id.y/10-1,115);
                        map_put_pixel(0,10,Hausbau_id.x/10+1,Hausbau_id.y/10,115);
                        map_put_pixel(0,10,Hausbau_id.x/10+1,Hausbau_id.y/10+1,115);
                        map_put_pixel(0,10,Hausbau_id.x/10+1,Hausbau_id.y/10-1,115);
                        map_put_pixel(0,10,Hausbau_id.x/10-1,Hausbau_id.y/10,115);
                        map_put_pixel(0,10,Hausbau_id.x/10-1,Hausbau_id.y/10+1,115);
                        map_put_pixel(0,10,Hausbau_id.x/10-1,Hausbau_id.y/10-1,115);

                        refresh_scroll(0);


                    END
                END

            END
        END



        FRAME;

    END
END


Process Hausbau(graph)

BEGIN
    ctype=c_scroll;
    z=-50;
    LOOP
        x=Mauszeiger.x-(Mauszeiger.x MOD 10);
        y=Mauszeiger.y-(Mauszeiger.y MOD 10);
        IF(BeimBau==0)
            BREAK;
        END

        FRAME;
    END

END





PROCESS KnoepfeEvent()

BEGIN
    Delete_Text(all_text);
    AktionsText=write(0,0,480,6,"(M)enu");
    LOOP
        IF(Key(_M))
            Delete_Text(all_text);
            write(0,0,480,6,"(S)ammelpunkte setzen  (G)ebaeude bauen  A(r)beiterzahlen setzen  (A)bbruch");
            LOOP
                IF(Key(_S))
                    Delete_Text(all_text);
                    write(0,0,480,6,"(H)olz  (L)ehm  (A)bbruch");
                    LOOP
                        IF(Key(_H))
                            HolzSetzen=1;
                            Delete_Text(all_text);
                            write(0,0,480,6,"Links-Klick: Sammelpunkt setzen fuer Holz  (A)bbruch");
                            LOOP
                                IF(Holzsetzen!=1)
                                    BREAK;
                                END
                                IF(Key(_A))
                                    BREAK;
                                    HolzSetzen=0;
                                END
                                FRAME;
                            END
                            Delete_Text(all_text);
                            write(0,0,480,6,"(H)olz  (L)ehm  (A)bbruch");


                        END
                        IF(Key(_L))
                            LehmSetzen=1;
                            Delete_Text(all_text);
                            write(0,0,480,6,"Links-Klick: Sammelpunkt setzen fuer Lehm  (A)bbruch");
                            LOOP
                                IF(Lehmsetzen!=1)
                                    BREAK;
                                END
                                IF(Key(_A))
                                    BREAK;
                                    LehmSetzen=0;
                                END
                                FRAME;
                            END
                            Delete_Text(all_text);
                            write(0,0,480,6,"(H)olz  (L)ehm  (A)bbruch");



                        END
                        IF(Key(_A))
                            BREAK;
                        END
                        FRAME;
                    END
                    Delete_Text(all_text);
                    write(0,0,480,6,"(S)ammelpunkte setzen  (G)ebaeude bauen  A(r)beiterzahlen setzen  (A)bbruch");


                END
                IF(Key(_R))
                    Delete_Text(all_text);
                    write(0,0,480,6,"(H)olzfaeller  (L)ehmsammler  (A)bbruch");
                    LOOP
                        IF(Key(_H))
                            Delete_Text(all_text);
                            write(0,0,480,6,"Holzfaeller(+)(-)  (A)bbruch");
                            write_int(0,0,470,6,OFFSET HolzarbeiterMax);
                            LOOP
                                IF(key(_plus))
                                    HolzArbeiterMax++;
                                    FRAME(200);
                                END
                                IF(key(_minus))
                                    HolzArbeiterMax--;
                                    FRAME(200);
                                END
                                IF(Key(_A))
                                    BREAK;
                                END
                                FRAME;
                            END
                            Delete_Text(all_text);
                            write(0,0,480,6,"(H)olzfaeller  (L)ehmsammler  (A)bbruch");

                        END
                        IF(Key(_L))
                            Delete_Text(all_text);
                            write(0,0,480,6,"Lehmsammler(+)(-)  (A)bbruch");
                            write_int(0,0,470,6,OFFSET LehmarbeiterMax);
                            LOOP
                                IF(key(_plus))
                                    LehmArbeiterMax++;
                                    FRAME(200);
                                END
                                IF(key(_minus))
                                    LehmArbeiterMax--;
                                    FRAME(200);
                                END
                                IF(Key(_A))
                                    BREAK;
                                END
                                FRAME;
                            END
                            Delete_Text(all_text);
                            write(0,0,480,6,"(H)olzfaeller  (L)ehmsammler  (A)bbruch");

                        END
                        IF(Key(_A))
                            BREAK;
                        END
                        FRAME;


                    END
                    Delete_Text(all_text);
                    write(0,0,480,6,"(S)ammelpunkte setzen  (G)ebaeude bauen  A(r)beiterzahlen setzen  (A)bbruch");



                END
                IF(Key(_G))
                    Delete_Text(all_text);
                    write(0,0,480,6,"(H)aus (A)bbruch");
                    LOOP
                        IF(Key(_H))
                            IF(BeimBau==0)
                                BeimBau=1;
                                Hausgroesse=0303;
                                HausBau_id=HausBau(200);
                            END
                        END
                        IF(Key(_A))
                            BeimBau=0;
                            Hausgroesse=0;
                            BREAK;
                        END
                        FRAME;



                    END
                    Delete_Text(all_text);
                    write(0,0,480,6,"(S)ammelpunkte setzen  (G)ebaeude bauen  A(r)beiterzahlen setzen  (A)bbruch");




                END
                IF(Key(_A))
                    BREAK;
                END
                FRAME;
            END
            Delete_Text(all_text);
            AktionsText=write(0,0,480,6,"(M)enu");
        END
        FRAME;
    END
END







/*
PROCESS WaterAnim()


PRIVATE
    new_palette[255];
    counter;


BEGIN
    x=10;
    y=10;
    graph=15;

    FROM counter=1 TO 255;
        new_palette[counter]=counter;
    END
    LOOP
        new_palette[253]=253;
        new_palette[254]=254;
        new_palette[255]=255;
        convert_palette(0, 15, offset new_palette);
        refresh_scroll(0);
        FRAME(500);
        new_palette[253]=255;
        new_palette[254]=253;
        new_palette[255]=254;
        convert_palette(0, 15, offset new_palette);
        refresh_scroll(0);
        FRAME(500);
        new_palette[253]=254;
        new_palette[254]=255;
        new_palette[255]=253;
        convert_palette(0, 15, offset new_palette);
        refresh_scroll(0);
        FRAME(500);
    END
END
*/







PROCESS Draw_all(Terrain,Objects)

PRIVATE
    Counterx;
    Countery;

BEGIN
  IF(Terrain==1)
    LOOP
        SWITCH(Map_get_pixel(0,10,counterx,countery))

            CASE 40:  //Gras
                map_put(0,2,rand(3,7),Counterx*10,Countery*10);
            END


            CASE 55:  //Wasser
                map_put(0,2,rand(15,17),Counterx*10,Countery*10);
            END

            CASE 120:  //Lehm/Ufer
                map_put(0,2,rand(20,22),Counterx*10,Countery*10);
            END

            DEFAULT:
            END

        END

        Counterx++;
        IF(Counterx>129)
            Counterx=0;
            Countery++;
        END
        IF(Countery>97)
            BREAK;
        END
    END
  END
    refresh_scroll(0);

    counterx=0;
    countery=0;

  IF(Objects==1)
    LOOP


        SWITCH(Map_get_pixel(0,9,counterx,countery))

            CASE 40:  //Baum
                IF(Map_get_pixel(0,10,counterx,countery)==40)

                    map_put(0,8,rand(25,27),Counterx*10+rand(-1,1),Countery*10+rand(-1,1));
                ELSE
                    Map_put_pixel(0,10,counterx,countery,0);//Baum auf Nicht-Gras aus dem Gedaechtniss loeschen
                END
            END

            CASE 55:  //Maennchen
                IF(Map_get_pixel(0,10,counterx,countery)==40)

                    map_put(0,8,100,Counterx*10,Countery*10);
                    map_put_pixel(0,11,Counterx,Countery,55);//Activitaet des Maennchens
                    Map_put_pixel(0,9,counterx,countery,0);//Maennchen aus dem Gedaechtniss loeschen da Logic Map fuer die Maennchen sorgt

                ELSE
                    Map_put_pixel(0,9,counterx,countery,0);//Maennchen auf Nicht-Gras aus dem Gedaechtniss loeschen
                END
            END



            DEFAULT:
            END

        END

        Counterx++;
        IF(Counterx>129)
            Counterx=0;
            Countery++;
        END
        IF(Countery>97)
            BREAK;
        END


    END
  END
END



PROCESS Begehbar(x,y)

BEGIN

        SWITCH(Map_get_pixel(0,10,x,y))
            CASE 55:  //Wasser
                RETURN(0);
            END
            CASE 115:  //Baustelle
                RETURN(0);
            END
        END

        SWITCH(Map_get_pixel(0,9,x,y))
            CASE 40:  //Baum
                RETURN(0);
            END
        END

        IF(Map_Get_pixel(0,11,x,y)!=0)
            RETURN(0);
        END


    RETURN(1);
END




PROCESS Loesche_Feld(x,y) //Loescht Objekt-Bild
PRIVATE
    counterx;
    countery;

BEGIN
    LOOP
        map_put_pixel(0,8,(x*10)+Counterx-5,(y*10)+Countery-5,0);

        counterx++;
        IF(Counterx>9)
            Counterx=0;
            Countery++;
        END
        IF(Countery>9)
            BREAK;
        END


    END

END









PROCESS Overlayer()

BEGIN
    ctype=c_scroll;
    x=640;
    y=480;
    graph=8;
    LOOP
        FRAME;
    END
END

PROCESS HelpMap()

BEGIN
    Helpmapb();
    z=-10;
    x=576;
    y=432;
    graph=11;

    LOOP
        FRAME;
    END

END

PROCESS HelpMapb()

BEGIN
    z=-5;
    x=576;
    y=432;
    graph=12;

    LOOP
        FRAME;
    END

END




























PROCESS new_coordinates()
BEGIN
    // If it gets out by the left, forces it to appear by the right
    // subtracting screen's wide
    IF (father.x<0) father.x=0; END
    // If it gets out by the right, forces it to appear by the left
    IF (father.x>1280) father.x=1280; END
    // If it gets out by the top, forces it to appear by the bottom
    IF (father.y<-0) father.y=0; END
    // If it gets out by the bottom, forces it to appear by the top
    IF (father.y>960) father.y=960; END
END

//****************************************************************************//
//                               ARENA                                        //
//                         A RPG WITHOUT STORY                                //
//****************************************************************************//


PROGRAM Arena;

GLOBAL

    GewaehlterHeld;  //Welcher Held wurde gewaehlt??
    GewaehlterHeldb; //==GewaehlterHeld+1

    STRUCT Held[3]
            //Bemerkung: Kraft[0] ist seine jetzige durch Zauber und
            //           Staten usw. veraenderte Kraft.Kraft[1] ist die
            //           Kraft ohne Verzauberungen usw.

        Kraft[1];             //Wie stark sind die Angriffe?
        Ausdauer[1];          //Wie viele Lebenspunkte hat der Held?
        Intelligenz[1];       //Wie stark sind die Zauber?
        Charisma[1];          //Wie viele Manapunkte hat der Held?
        Geschick[1];          //Wie oft trifft der Held?
        Reaktion[1];          //Wie schnell erholt er sich wieder?
        Glueck[1];            //Wie viel Glueck hat der Held?


        Waffe[4];             //Die Ausgeruestete Waffe
                              //[0] Atk+
                              //[1] 1. Random Variabel
                              //[2] 2. Random Variabel
                              //[3] Spezialfaehigkeit
                              //[4] Spezialfaehigkeit Kraft

        Schild[2];            //Das Ausgeruestete Schild
                              //[0] Def+
                              //[1] Spezialfaehigkeit
                              //[2] Spezialfaehigkeit Kraft

        Ring[1];              //Der Ausgeruestete Ring
                              //[0] Spezialfaehigkeit
                              //[1] Spezialfaehigkeit Kraft

        Amulett[1];           //Das Ausgeruestete Amulett
                              //[0] Spezialfaehigkeit
                              //[1] Spezialfaehigkeit Kraft


    END




    /*STRUCT Gegner[3]
            //Bemerkung: Kraft[0] ist seine jetzige durch Zauber und
            //           Staten usw. veraenderte Kraft.Kraft[1] ist die
            //           Kraft ohne Verzauberungen usw.

        Kraft[1];             //Wie stark sind die Angriffe?
        Ausdauer[1];          //Wie viele Lebenspunkte hat der Held?
        Intelligenz[1];       //Wie stark sind die Zauber?
        Charisma[1];          //Wie viele Manapunkte hat der Held?
        Geschick[1];          //Wie oft trifft der Held?
        Reaktion[1];          //Wie schnell erholt er sich wieder?
        Glueck[1];            //Wie viel Glueck hat der Held?

    END*/



BEGIN

    //load_fpg("Olegs\Ollwars.fpg");  // Loads graphics' file
    load_fnt("Olegs\Arena.fnt");  // Loads font type

    set_mode(m1024x768);               // Sets video mode to 640x480
    set_fps(24,0);                    // Number of frames per second



    GewaehlterHeld=0;

    GewaehlterHeldb=GewaehlterHeld+1;


    write(1,5,5,0,"Held");
    write_int(1,80,5,0,OFFSET GewaehlterHeldb);

    write(1,20,40,0,"Kraft");
    write_int(1,270,40,2,OFFSET Held[GewaehlterHeld].Kraft[0]);
    write(1,280,40,1,"/");
    write_int(1,290,40,0,OFFSET Held[GewaehlterHeld].Kraft[1]);

    write(1,20,60,0,"Ausdauer");
    write_int(1,270,60,2,OFFSET Held[GewaehlterHeld].Ausdauer[0]);
    write(1,280,60,1,"/");
    write_int(1,290,60,0,OFFSET Held[GewaehlterHeld].Ausdauer[1]);

    write(1,20,80,0,"Intelligenz");
    write_int(1,270,80,2,OFFSET Held[GewaehlterHeld].Intelligenz[0]);
    write(1,280,80,1,"/");
    write_int(1,290,80,0,OFFSET Held[GewaehlterHeld].Intelligenz[1]);

    write(1,20,100,0,"Charisma");
    write_int(1,270,100,2,OFFSET Held[GewaehlterHeld].Charisma[0]);
    write(1,280,100,1,"/");
    write_int(1,290,100,0,OFFSET Held[GewaehlterHeld].Charisma[1]);

    write(1,20,120,0,"Geschick");
    write_int(1,270,120,2,OFFSET Held[GewaehlterHeld].Geschick[0]);
    write(1,280,120,1,"/");
    write_int(1,290,120,0,OFFSET Held[GewaehlterHeld].Geschick[1]);

    write(1,20,140,0,"Reaktion");
    write_int(1,270,140,2,OFFSET Held[GewaehlterHeld].Reaktion[0]);
    write(1,280,140,1,"/");
    write_int(1,290,140,0,OFFSET Held[GewaehlterHeld].Reaktion[1]);

    write(1,20,160,0,"Glueck");
    write_int(1,270,160,2,OFFSET Held[GewaehlterHeld].Glueck[0]);
    write(1,280,160,1,"/");
    write_int(1,290,160,0,OFFSET Held[GewaehlterHeld].Glueck[1]);


    write(1,560,5,2,"Klasse waehlen");
    write(1,500,35,0,"1 - Krieger");
    write(1,500,55,0,"2 - Dieb");
    write(1,500,75,0,"3 - Hexer");
    write(1,500,95,0,"4 - Kleriker");
    write(1,500,115,0,"5 - Pirat (Krieger+Dieb)");
    write(1,500,135,0,"6 - Paladin (Krieger+Kleriker)");
    write(1,500,155,0,"7 - Zauberer (Hexer+Kleriker)");
    write(1,500,175,0,"8 - Kampfmagier (Krieger+Hexer)");
    write(1,500,195,0,"9 - Bogenschuetze (Dieb+Hexer)");

    LOOP
        IF(key(_1))

            Held[GewaehlterHeld].Kraft[1]=17;
            Held[GewaehlterHeld].Ausdauer[1]=15;
            Held[GewaehlterHeld].Intelligenz[1]=7;
            Held[GewaehlterHeld].Charisma[1]=5;
            Held[GewaehlterHeld].Geschick[1]=10;
            Held[GewaehlterHeld].Reaktion[1]=7;
            Held[GewaehlterHeld].Glueck[1]=9;

            Held[GewaehlterHeld].Kraft[0]=17;
            Held[GewaehlterHeld].Ausdauer[0]=15;
            Held[GewaehlterHeld].Intelligenz[0]=7;
            Held[GewaehlterHeld].Charisma[0]=5;
            Held[GewaehlterHeld].Geschick[0]=10;
            Held[GewaehlterHeld].Reaktion[0]=7;
            Held[GewaehlterHeld].Glueck[0]=9;
        END

        IF(key(_2))

            Held[GewaehlterHeld].Kraft[1]=7;
            Held[GewaehlterHeld].Ausdauer[1]=17;
            Held[GewaehlterHeld].Intelligenz[1]=4;
            Held[GewaehlterHeld].Charisma[1]=7;
            Held[GewaehlterHeld].Geschick[1]=16;
            Held[GewaehlterHeld].Reaktion[1]=13;
            Held[GewaehlterHeld].Glueck[1]=12;

            Held[GewaehlterHeld].Kraft[0]=7;
            Held[GewaehlterHeld].Ausdauer[0]=17;
            Held[GewaehlterHeld].Intelligenz[0]=4;
            Held[GewaehlterHeld].Charisma[0]=7;
            Held[GewaehlterHeld].Geschick[0]=16;
            Held[GewaehlterHeld].Reaktion[0]=13;
            Held[GewaehlterHeld].Glueck[0]=12;
        END

        IF(key(_3))

            Held[GewaehlterHeld].Kraft[1]=6;
            Held[GewaehlterHeld].Ausdauer[1]=9;
            Held[GewaehlterHeld].Intelligenz[1]=16;
            Held[GewaehlterHeld].Charisma[1]=13;
            Held[GewaehlterHeld].Geschick[1]=9;
            Held[GewaehlterHeld].Reaktion[1]=11;
            Held[GewaehlterHeld].Glueck[1]=14;

            Held[GewaehlterHeld].Kraft[0]=6;
            Held[GewaehlterHeld].Ausdauer[0]=9;
            Held[GewaehlterHeld].Intelligenz[0]=16;
            Held[GewaehlterHeld].Charisma[0]=13;
            Held[GewaehlterHeld].Geschick[0]=9;
            Held[GewaehlterHeld].Reaktion[0]=11;
            Held[GewaehlterHeld].Glueck[0]=14;
        END

        IF(key(_4))

            Held[GewaehlterHeld].Kraft[1]=5;
            Held[GewaehlterHeld].Ausdauer[1]=12;
            Held[GewaehlterHeld].Intelligenz[1]=12;
            Held[GewaehlterHeld].Charisma[1]=17;
            Held[GewaehlterHeld].Geschick[1]=8;
            Held[GewaehlterHeld].Reaktion[1]=9;
            Held[GewaehlterHeld].Glueck[1]=16;

            Held[GewaehlterHeld].Kraft[0]=5;
            Held[GewaehlterHeld].Ausdauer[0]=12;
            Held[GewaehlterHeld].Intelligenz[0]=12;
            Held[GewaehlterHeld].Charisma[0]=17;
            Held[GewaehlterHeld].Geschick[0]=8;
            Held[GewaehlterHeld].Reaktion[0]=9;
            Held[GewaehlterHeld].Glueck[0]=16;
        END



        FRAME;
    END








END









































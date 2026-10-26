


PROGRAM Fritten;


GLOBAL
    Eiskosten;
    Eisanzahl;
    Eispreis;

    Frittenkosten;
    Frittenanzahl;
    Frittenpreis;


    Geld;
    Attraktivitaet;
    Stufe;

BEGIN
    //Init
    Geld=2500;
    Attraktivitaet=500;
    Stufe=1;

    Eiskosten=rand(55,75);
    Eispreis=100;
    Frittenkosten=rand(125,145);
    Frittenpreis=200;



    set_mode(m640x480);

    // ------
    Write(0,70,0,0,"Kaufen");
    Write(0,120,0,0,"Menge");
    Write(0,170,0,0,"Verkauf");
    // ||||||
    Write(0,0,20,0,"Eis");
    Write(0,0,40,0,"Fritten");
    // -|-|-|
    Write_int(0,70,20,0, OFFSET Eiskosten);
    Write_int(0,120,20,0, OFFSET Eisanzahl);
    Write_int(0,170,20,0, OFFSET Eispreis);

    Write_int(0,70,40,0, OFFSET Frittenkosten);
    Write_int(0,120,40,0, OFFSET Frittenanzahl);
    Write_int(0,170,40,0, OFFSET Frittenpreis);



    //******
    Write(0,400,0,0,"Geld");
    Write(0,400,20,0,"Attraktivitaet");
    Write(0,400,40,0,"Stufe");
    Write_int(0,500,0,0,OFFSET Geld);
    Write_int(0,500,20,0,OFFSET Attraktivitaet);
    Write_int(0,500,40,0,OFFSET Stufe);



    LOOP
        FRAME;
    END



END


























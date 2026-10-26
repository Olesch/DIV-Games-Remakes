


























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
    AntiFast;
    PlayerTurn;
    Move;
    Typ;
    Arbeiter;
    oldx;
    oldy;
    newx;
    newy;
    Betret;   //0=nicht betreten  1=betreten  2=Arbeiter betreten





UNITS
    Worker

    Health=50
    Move=5
    Attack=5

    Fighter

    Health=100
    Move=5
    Attack=15

    PowerFighter

    Health=150
    Move=7
    Attack=20









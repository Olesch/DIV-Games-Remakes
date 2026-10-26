PROGRAM Solve;

CONST
    Numbers=14;  //Maximum an Nummern
    Ziffers=2;  //Hoechste Ziffer

GLOBAL         //0 1 2 3 4 5 6 7 8 9 0 1 2 3 4
    Num[Numbers]=0,0,0,0,0,1,0,0,0,0,0,0,0,0,0;
    Counta;
    Startch;
    ch[20];
    Found;
    Searched;
    SF;
    FR;

BEGIN
    max_process_time=6000;
    set_mode(m800x600);
    Write_int(0,50,50,0, OFFSET Found);
    Write_int(0,50,60,0, OFFSET Searched);
    Write_int(0,150,55,0, OFFSET SF);
    FOR(Counta=0; Counta<=Numbers; Counta++)
        Write_int(0,Counta*6+10,10,0, OFFSET Num[Counta]);
    END
    LOOP
        Searched++;
        //Zahl erhoehen
        Num[Numbers]++;
        FOR(Counta=Numbers; Counta>=0; Counta--)
            IF(Num[Counta]>Ziffers)
                Num[Counta]=0;
                Num[Counta-1]++;
            END
        END
        Startch=0;
        FOR(Counta=0; Counta<=9; Counta++)
            ch[Counta]=0;
        END
        FOR(Counta=Numbers; Counta>=0; Counta--)
            IF(Startch==1)
                ch[Num[counta]]=1;
            END
            IF(Num[counta]!=0)
                Startch=1;
            END
        END
        IF(ch[0]+ch[1]+ch[2]+ch[3]+ch[4]+ch[5]+ch[6]+ch[7]+ch[8]+ch[9]==Ziffers+1)
            Found++;
        END
        FR++;
        IF(Key(_1))
            FR++;
        END
        IF(Key(_2))
            FR+=2;
        END
        IF(Key(_3))
            FR+=4;
        END
        IF(Found!=0)
            SF=Searched/Found;
        END
        IF(Key(_F) OR FR>12347)
            FRAME(400);
            FR=0;
        END
        IF(Num[4]==1)
            LOOP
                FRAME;
            END
        END
    END
END



























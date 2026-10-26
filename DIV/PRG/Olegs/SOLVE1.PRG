//Loest Landeswettbewerb 2004/2005 2.Runde 1. Aufgabe
//
//

PROGRAM Solve1;

GLOBAL
    Points[5];
    Lines[11];
    Numbers[10]=1,2,3,4,5,6,7,8,9,10,11;
    Used[10];
    n=2*3;                                   //(0 To 5)// 10) *3
    saved;
    counter=1;
    Timesorig=450000;
    Times;
    Tryagain;

BEGIN
    max_process_time=6000;
    Times=Timesorig;
    set_mode(m640x480);
    set_fps(200,0);
    write_int(0,20,10,0,OFFSET Points[0]);
    write_int(0,20,30,0,OFFSET Points[1]);
    write_int(0,20,50,0,OFFSET Points[2]);
    write_int(0,20,70,0,OFFSET Points[3]);
    write_int(0,20,90,0,OFFSET Points[4]);
    write_int(0,20,110,0,OFFSET Points[5]);

    write_int(0,20,150,0,OFFSET Lines[0]);
    write_int(0,20,170,0,OFFSET Lines[1]);
    write_int(0,20,190,0,OFFSET Lines[2]);
    write_int(0,20,210,0,OFFSET Lines[3]);
    write_int(0,20,230,0,OFFSET Lines[4]);
    write_int(0,20,250,0,OFFSET Lines[5]);
    write_int(0,20,270,0,OFFSET Lines[6]);
    write_int(0,20,290,0,OFFSET Lines[7]);
    write_int(0,20,310,0,OFFSET Lines[8]);
    write_int(0,20,330,0,OFFSET Lines[9]);
    write_int(0,20,350,0,OFFSET Lines[10]);
    write_int(0,20,370,0,OFFSET Lines[11]);



    LOOP
        Lines[0]=n;

        LOOP
            saved=rand(0,10);
            IF(Used[saved]==0)
                Lines[counter]=Numbers[saved];
                Used[saved]=1;
                counter++;
            END
            IF(counter>11)
                BREAK;
            END
            //FRAME(1);
        END
        Times--;


        Points[0]=Lines[9]+Lines[10]+Lines[11]+Lines[8];     //A
        Points[1]=Lines[1]+Lines[4]+Lines[10]+Lines[5];      //B
        Points[2]=Lines[2]+Lines[4]+Lines[9]+Lines[6];       //C
        Points[3]=Lines[8]+Lines[7]+Lines[6]+Lines[3];       //D
        Points[4]=Lines[7]+Lines[11]+Lines[5]+Lines[0];      //E
        Points[5]=Lines[0]+Lines[1]+Lines[2]+Lines[3];       //F

        IF(Points[0]==Points[1] AND
           Points[1]==Points[2] AND
           Points[2]==Points[3] AND
           Points[3]==Points[4] AND
           Points[4]==Points[5] )
            write(0,100,10,0,"Solution found!");
            LOOP
                FRAME;
            END

        END

        //FRAME(50);
        //FROM x=0 TO 5;
        //    Points[x]=0;
        //END

        FROM x=0 TO 11;
            Lines[x]=0;
        END
        FROM x=0 TO 10;
            Numbers[x]=x+1;
        END
        FROM x=0 TO 10;
            Used[x]=0;
        END
        counter=1;

        IF(Times<0)
            Tryagain=write(0,100,10,0,"Try again?");
            LOOP
                IF(key(_y))
                    Times=Timesorig;
                    delete_text(Tryagain);
                    FRAME;
                    BREAK;
                END
                FRAME;
            END
        END
    END
END































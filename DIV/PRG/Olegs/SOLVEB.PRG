PROGRAM solve;

GLOBAL
    Number;
    n[9];    //0 wird nich benutzt   1 ist erste Ziffer 9 letzte
    countera;
    counterb;
    Checked; //1=yes 0=no
    Tenner; //For creating the number;
    counterc;

BEGIN
    max_process_time=100000;
                write_int(0,10,10,4,OFFSET n[1]);
                write_int(0,20,10,4,OFFSET n[2]);
                write_int(0,30,10,4,OFFSET n[3]);
                write_int(0,40,10,4,OFFSET n[4]);
                write_int(0,50,10,4,OFFSET n[5]);
                write_int(0,60,10,4,OFFSET n[6]);
                write_int(0,70,10,4,OFFSET n[7]);
                write_int(0,80,10,4,OFFSET n[8]);
                write_int(0,90,10,4,OFFSET n[9]);


/*    FOR(n[1]=9; n[1]>=0; n[1]--)
        //IF(n[2]==0 AND n[1]!=0) BREAK; END
        IF(n[1]==4 OR n[1]==5) Continue; END   //4 oder 5
    FOR(n[2]=9; n[2]>=0; n[2]--)
        IF(n[2]==0 AND n[1]!=0) Continue; END //zero
        IF(n[2]==n[1]) Continue; END //same numbers
        IF(n[2]==4 OR n[2]==5) Continue; END   //4 oder 5
*/    FOR(n[3]=9; n[3]>=0; n[3]--)
        IF(n[3]==0 AND n[2]!=0) Continue; END
        IF(n[3]==n[1] OR n[3]==n[2]) Continue; END //same numbers
        IF(n[3]==4 OR n[3]==5) Continue; END   //4 oder 5
    FOR(n[4]=9; n[4]>=0; n[4]--)
        IF(n[4]==0 AND n[3]!=0) Continue; END
        IF(n[4]==n[1] OR n[4]==n[2] OR n[4]==n[3]) Continue; END //same numbers
        IF(n[4]==4 OR n[4]==5) Continue; END   //4 oder 5
    FOR(n[5]=9; n[5]>=0; n[5]--)
        IF(n[5]==0 AND n[4]!=0) Continue; END
        IF(n[5]==n[1] OR n[5]==n[2] OR n[5]==n[3]  OR n[5]==n[4]) Continue; END //same numbers
        IF(n[5]==4 OR n[5]==5) Continue; END   //4 oder 5
    FOR(n[6]=9; n[6]>=0; n[6]--)
        IF(n[6]==0 AND n[5]!=0) Continue; END
        IF(n[6]==n[1] OR n[6]==n[2] OR n[6]==n[3]  OR n[6]==n[4]  OR n[6]==n[5]) Continue; END //same numbers
        IF(n[6]==4 OR n[6]==5) Continue; END   //4 oder 5
    FOR(n[7]=9; n[7]>=0; n[7]--)
        IF(n[7]==0 AND n[6]!=0) Continue; END
        IF(n[7]==n[1] OR n[7]==n[2] OR n[7]==n[3]  OR n[7]==n[4]  OR n[7]==n[5]  OR n[7]==n[6]) Continue; END //same numbers
        IF(n[7]==4 OR n[7]==5) Continue; END   //4 oder 5
    FOR(n[8]=9; n[8]>=0; n[8]--)
        IF(n[8]==0 AND n[7]!=0) Continue; END
        IF(n[8]==n[1] OR n[8]==n[2] OR n[8]==n[3]  OR n[8]==n[4]  OR n[8]==n[5]  OR n[8]==n[6]  OR n[8]==n[7]) Continue; END //same numbers
        IF(n[8]==4 OR n[8]==5) Continue; END   //4 oder 5
    FOR(n[9]=9; n[9]>=0; n[9]--)//Counting all Numbers thru
        IF(n[9]==0 AND n[8]!=0) Continue; END
        IF(n[9]==n[1] OR n[9]==n[2] OR n[9]==n[3]  OR n[9]==n[4]  OR n[9]==n[5]  OR n[9]==n[6]  OR n[9]==n[7] OR n[9]==n[8]) Continue; END //same numbers
        IF(n[9]==4 OR n[9]==5) Continue; END   //4 oder 5
        counterc++;
        IF(counterc>10000)
            FRAME;
            counterc=0;
        END
        /*LOOP
            FRAME;
            IF(key(_space))
                FRAME(1200);
                BREAK;
            END
        END*/


        checked=1;
        /*FOR(countera=1; countera<=9; countera++) //Die Zahl wird ueberprueft
        FOR(counterb=1; counterb<=9; counterb++)
            IF(countera!=1)//Checking for Zeroes
                IF(n[countera]==0 AND n[countera-1]!=0)
                    checked=0;
                END
            END
            IF(n[countera]!=0 AND n[counterb]!=0)//Checking for same ones
                IF(countera!=counterb)
                    IF(n[countera]==n[counterb])
                        checked=0;
                    END
                END
            END

            IF(checked==0)
                BREAK;
            END

        END
            IF(checked==0)
                BREAK;
            END
        END
        */
        IF(checked==1) //Die Zahl wird getestet
            FOR(countera=1; countera<=9; countera++)//Waehle eine rausnehmzahl aus
                IF(n[countera]!=0)
                    number=0;
                    tenner=1;
                    FOR(counterb=9; counterb>=1; counterb--)//Erstelle die Zahl
                        IF(counterb!=countera)
                            number+=n[counterb]*tenner;
                            tenner=tenner*10;
                        END
                    END
                    IF(number mod n[countera]!=0)
                        checked=0;
                    END

                END

                IF(checked==0)
                    BREAK;
                END
            END
            IF(checked==1) //HEUREKA!!!
                LOOP
                    FRAME;
                END
            END
        END

    END
    END
    END
    END
    END
    END
    END
/*    END
    END  */




END
































PROGRAM Rubik;

CONST
    Dots=90;

GLOBAL
    Pos[8]=1,2,3,4,5,6,7,8,9;
    newPos[8]=1,2,3,4,5,6,7,8,9;
    Cursor; //   1  2  3
            // 12*  *  *4
            // 11*  *  *5
            // 10*  *  *6
            //   9  8  7
    STRUCT Pix[Dots];
        x;
        y;
        col;
        Dir[1];
    END


BEGIN
    FOR(x=0; x<=Dots; x++)
        Pix[x].x=rand(0,640);
        Pix[x].y=rand(0,480);
        Pix[x].col=rand(0,255);
        Pix[x].Dir[0]=rand(-1,1);
        Pix[x].Dir[1]=rand(-1,1);
    END

    set_mode(m640x480);
    repaint();
    cursor=rand(1,12); Move();
    //cursor=rand(1,12); Move();
    LOOP
        IF(key(_right)) Cursor++; FRAME; END
        IF(key(_left)) Cursor--; FRAME; END
        IF(cursor>12) cursor=1; END
        IF(cursor<1) cursor=12; END
        IF(Key(_Enter)) Move(); FRAME; END
        IF(Key(_m)) cursor=rand(1,12); Move(); END

        repaint();
        FRAME;
    END
END



PROCESS repaint()

BEGIN
    Clear_Screen();
    IF(pos[0]==1 AND pos[1]==2 AND pos[2]==3 AND pos[3]==4 AND pos[4]==5 AND pos[5]==6 AND pos[6]==7 AND pos[7]==8 AND pos[8]==9)
        /*FOR(x=0; x<=640*480/10; x++)
            put_pixel(rand(0,640),rand(0,480),rand(0,255));
        END*/
        FOR(x=0; x<=Dots; x++)
            put_pixel(pix[x].x,pix[x].y,pix[x].col);
            pix[x].x=(pix[x].x+pix[x].Dir[0]) mod 641;
            pix[x].y=(pix[x].y+pix[x].Dir[1]) mod 481;
            IF(rand(0,7)==0) pix[x].col=(pix[x].col-1) mod 256; END
            put_pixel(pix[x].x,pix[x].y,pix[x].col);
            pix[x].x=(pix[x].x+pix[x].Dir[0]) mod 641;
            pix[x].y=(pix[x].y+pix[x].Dir[1]) mod 481;
            IF(rand(0,7)==0) pix[x].col=(pix[x].col-1) mod 256; END
            put_pixel(pix[x].x,pix[x].y,pix[x].col);
            pix[x].x=(pix[x].x+pix[x].Dir[0]) mod 641;
            pix[x].y=(pix[x].y+pix[x].Dir[1]) mod 481;
            IF(rand(0,7)==0) pix[x].col=(pix[x].col-1) mod 256; END
            put_pixel(pix[x].x,pix[x].y,pix[x].col);
            IF(pix[x].col mod 16==0)
                pix[x].x=rand(0,80)+rand(0,80)+rand(0,80)+rand(0,80)+rand(0,80)+rand(0,80)+rand(0,80)+rand(0,80);
                pix[x].y=rand(0,60)+rand(0,60)+rand(0,60)+rand(0,60)+rand(0,60)+rand(0,60)+rand(0,60)+rand(0,60);
                Pix[x].Dir[0]=rand(-1,1);
                Pix[x].Dir[1]=rand(-1,1);
            END
        END
    END

    delete_text(all_text);
    write(0,320,210,4,"----------");
    write(0,320,230,4,"----------");
    write(0,320,250,4,"----------");
    write(0,320,270,4,"----------");

    FOR(y=212; y<=270; y+=5);
        write(0,290,y,4,"|");
    END
    FOR(y=212; y<=270; y+=5);
        write(0,310,y,4,"|");
    END
    FOR(y=212; y<=270; y+=5);
        write(0,330,y,4,"|");
    END
    FOR(y=212; y<=270; y+=5);
        write(0,350,y,4,"|");
    END

    Write_int(0,300,220,4, OFFSET pos[0]);
    Write_int(0,320,220,4, OFFSET pos[1]);
    Write_int(0,340,220,4, OFFSET pos[2]);
    Write_int(0,300,240,4, OFFSET pos[3]);
    Write_int(0,320,240,4, OFFSET pos[4]);
    Write_int(0,340,240,4, OFFSET pos[5]);
    Write_int(0,300,260,4, OFFSET pos[6]);
    Write_int(0,320,260,4, OFFSET pos[7]);
    Write_int(0,340,260,4, OFFSET pos[8]);

    IF(cursor==1) x=300; y=200; END
    IF(cursor==2) x=320; y=200; END
    IF(cursor==3) x=340; y=200; END
    IF(cursor==4) x=360; y=220; END
    IF(cursor==5) x=360; y=240; END
    IF(cursor==6) x=360; y=260; END
    IF(cursor==7) x=340; y=280; END
    IF(cursor==8) x=320; y=280; END
    IF(cursor==9) x=300; y=280; END
    IF(cursor==10)x=280; y=260; END
    IF(cursor==11)x=280; y=240; END
    IF(cursor==12)x=280; y=220; END
    Write(0,x,y,4,"*");

    Write(0,20,440,6,"M           - Mischen");
    Write(0,20,450,6,"Enter       - Zahlen bewegen");
    Write(0,20,460,6,"Pfeiltasten - Cursor bewegen");


END



PROCESS Move()

BEGIN
    IF(Cursor==1)
        newpos[3]=pos[0];
        newpos[6]=pos[3];
        newpos[0]=pos[6];
        pos[3]=newpos[3];
        pos[6]=newpos[6];
        pos[0]=newpos[0];
    END
    IF(Cursor==2)
        newpos[4]=pos[1];
        newpos[7]=pos[4];
        newpos[1]=pos[7];
        pos[4]=newpos[4];
        pos[7]=newpos[7];
        pos[1]=newpos[1];
    END
    IF(Cursor==3)
        newpos[5]=pos[2];
        newpos[8]=pos[5];
        newpos[2]=pos[8];
        pos[5]=newpos[5];
        pos[8]=newpos[8];
        pos[2]=newpos[2];
    END
    IF(Cursor==7)
        newpos[5]=pos[8];
        newpos[8]=pos[2];
        newpos[2]=pos[5];
        pos[5]=newpos[5];
        pos[8]=newpos[8];
        pos[2]=newpos[2];
    END
    IF(Cursor==8)
        newpos[4]=pos[7];
        newpos[7]=pos[1];
        newpos[1]=pos[4];
        pos[4]=newpos[4];
        pos[7]=newpos[7];
        pos[1]=newpos[1];
    END
    IF(Cursor==9)
        newpos[3]=pos[6];
        newpos[6]=pos[0];
        newpos[0]=pos[3];
        pos[3]=newpos[3];
        pos[6]=newpos[6];
        pos[0]=newpos[0];
    END

    IF(Cursor==4)
        newpos[2]=pos[0];
        newpos[1]=pos[2];
        newpos[0]=pos[1];
        pos[0]=newpos[0];
        pos[1]=newpos[1];
        pos[2]=newpos[2];
    END
    IF(Cursor==5)
        newpos[5]=pos[3];
        newpos[4]=pos[5];
        newpos[3]=pos[4];
        pos[3]=newpos[3];
        pos[4]=newpos[4];
        pos[5]=newpos[5];
    END
    IF(Cursor==6)
        newpos[8]=pos[6];
        newpos[7]=pos[8];
        newpos[6]=pos[7];
        pos[6]=newpos[6];
        pos[7]=newpos[7];
        pos[8]=newpos[8];
    END
    IF(Cursor==10)
        newpos[8]=pos[7];
        newpos[7]=pos[6];
        newpos[6]=pos[8];
        pos[6]=newpos[6];
        pos[7]=newpos[7];
        pos[8]=newpos[8];
    END
    IF(Cursor==11)
        newpos[5]=pos[4];
        newpos[4]=pos[3];
        newpos[3]=pos[5];
        pos[3]=newpos[3];
        pos[4]=newpos[4];
        pos[5]=newpos[5];
    END
    IF(Cursor==12)
        newpos[2]=pos[1];
        newpos[1]=pos[0];
        newpos[0]=pos[2];
        pos[0]=newpos[0];
        pos[1]=newpos[1];
        pos[2]=newpos[2];
    END


END
















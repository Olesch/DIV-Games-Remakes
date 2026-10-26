


PROGRAM PingPong;

GLOBAL
    Balla;
    Ballb;
    Candidate;
    Activity=4;
    Pointsa;
    Pointsb;


LOCAL
    xinc;
    yinc;

BEGIN
    load_fpg("Olegs\PingPong.fpg");
    set_mode(m640x480);
    set_fps(24,0);
    //balla=Ball(4,rand(0,1)*8-4);
    //ballb=Ball(-4,rand(0,1)*8-4);
    Bat(1,1);
    Bat(2,1);
    Background();
    FOR(x=0; x<35; x++)
        Ball(4*Activity,4*Activity);
        Ball(-4
        *Activity,-4*Activity);
        FRAME(300/Activity);
    END

    /*LOOP
        IF(rand(0,50)==0)
            IF(rand(0,1)==0)
                Ball(4,rand(0,1)*8-4);
            ELSE
                Ball(-4,rand(0,1)*8-4);
            END
        END
        FRAME;
    END*/

    LOOP
        IF(pointsa-500>pointsb)
            Write(0,320,240,4,"   Wins > ");
            Write(0,320,230,4,"   Wins > ");
            Write(0,320,250,4,"   Wins > ");
            Write(0,320,220,4,"   Wins > ");
            Write(0,320,260,4,"   Wins > ");
            RETURN();
        END
        IF(pointsb-500>pointsa)
            Write(0,320,240,4," < Wins   ");
            Write(0,320,230,4," < Wins   ");
            Write(0,320,250,4," < Wins   ");
            Write(0,320,220,4," < Wins   ");
            Write(0,320,260,4," < Wins   ");
            RETURN();
        END
        FRAME;
    END

END


PROCESS Bat(Player,Ki)


BEGIN
    graph=2;
    IF(player==1)
        x=4;
        y=240;
    END
    IF(player==2)
        x=636;
        y=240;
    END
    LOOP
        IF(key(_q) AND player==1 AND y>40 AND ki==1)
            y-=4*Activity;
        END
        IF(key(_a) AND player==1 AND y<440 AND ki==1)
            y+=4*Activity;
        END
        IF(key(_up) AND player==2 AND y>40 AND ki==1)
            y-=4*Activity;
        END
        IF(key(_down) AND player==2 AND y<440 AND ki==1)
            y+=4*Activity;
        END
        IF(ki==2)
            IF(player==2)
                Candidate=0;
                IF(balla.xinc>0)
                    Candidate+=1;
                END
                IF(ballb.xinc>0)
                    Candidate+=2;
                END
                IF(Candidate==1)
                    IF(y>balla.y AND y>40)
                        y-=4*Activity;
                    END
                    IF(y<balla.y AND y<440)
                        y+=4*Activity;
                    END
                END
                IF(Candidate==2)
                    IF(y>ballb.y AND y>40)
                        y-=4*Activity;
                    END
                    IF(y<ballb.y AND y<440)
                        y+=4*Activity;
                    END
                END
                IF(Candidate==3)
                    IF(balla.x>ballb.x)
                        IF(y>balla.y AND y>40)
                            y-=4*Activity;
                        END
                        IF(y<balla.y AND y<440)
                            y+=4*Activity;
                        END
                    ELSE
                        IF(y>ballb.y AND y>40)
                            y-=4*Activity;
                        END
                        IF(y<ballb.y AND y<440)
                            y+=4*Activity;
                        END
                    END
                END
            END


            IF(player==1)
                Candidate=0;
                IF(balla.xinc<0)
                    Candidate+=1;
                END
                IF(ballb.xinc<0)
                    Candidate+=2;
                END
                IF(Candidate==1)
                    IF(y>balla.y AND y>40)
                        y-=4*Activity;
                    END
                    IF(y<balla.y AND y<440)
                        y+=4*Activity;
                    END
                END
                IF(Candidate==2)
                    IF(y>ballb.y AND y>40)
                        y-=4*Activity;
                    END
                    IF(y<ballb.y AND y<440)
                        y+=4*Activity;
                    END
                END
                IF(Candidate==3)
                    IF(balla.x<ballb.x)
                        IF(y>balla.y AND y>40)
                            y-=4*Activity;
                        END
                        IF(y<balla.y AND y<440)
                            y+=4*Activity;
                        END
                    ELSE
                        IF(y>ballb.y AND y>40)
                            y-=4*Activity;
                        END
                        IF(y<ballb.y AND y<440)
                            y+=4*Activity;
                        END
                    END
                END


            END




        END


        FRAME;
    END
END


PROCESS Background()

BEGIN
    z=5;
    x=320;
    y=240;
    graph=1;
    LOOP
        FRAME;
    END

END

PROCESS Ball(xinc,yinc);


BEGIN
    x=320;
    y=240;
    graph=3;
    LOOP
        x+=xinc;
        y+=yinc;
        FRAME;
        IF(y>=468)
            yinc=-4*Activity;
        END
        IF(y<=12)
            yinc=4*Activity;
        END

        IF(collision(TYPE Bat))
            IF(x>320)
                xinc=-4*Activity;
            ELSE
                xinc=4*Activity;
            END
        END
        IF(x>648)
            IF(pointsa>pointsb)
                POintsb+=3;
            ELSE
                POintsb+=2;
            END

            x=320;
            y=240;
        END
        IF(x<-8)
            IF(pointsb>pointsa)
                POintsa+=3;
            ELSE
                POintsa+=2;
            END
            x=320;
            y=240;
        END

    END
END












































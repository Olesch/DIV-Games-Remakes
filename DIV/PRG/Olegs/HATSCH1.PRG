

PROGRAM Hatsch1;

GLOBAL
    fpsa=40;
    fpsb;
    shipa_id;
    shipb_id;
    shipc_id;
    shipd_id;



LOCAL
    life;


BEGIN
    load_fpg("Olegs\Hatsch1.fpg");  // Loads graphics' file
    load_fnt("Olegs\Hatsch1.fnt");  // Loads graphics' file
    set_mode(m800x600);               // Sets video mode to 640x480
    set_fps(fpsa,fpsb);                    // Number of frames per second
    put_screen(0,3);                 // Puts background screen
    Framers();
    shipa_id=ship(1,_right,_left,_up,_down);
    shipb_id=ship(2,_d,_a,_w,_s);
    shipc_id=ship(2,_l,_j,_i,_k);
    write_int(1,0,0,0,OFFSET shipa_id.life);
    write_int(1,800,0,2,OFFSET shipb_id.life);
    write_int(1,800,600,8,OFFSET shipc_id.life);

    LOOP
        FRAME;
    END


END




PROCESS ship(player,right,left,up,fire)

PRIVATE
    Antifastshot;
    Power;
    Wait;


BEGIN
    life=100;
    graph=player;
    IF(player==1)
        x=100;
        y=100;
    END
    IF(player==2)
        x=700;
        y=500;
    END
    IF(player==3)
        x=100;
        y=500;
    END
    LOOP
        IF(key(right))
            angle-=4000;
        END
        IF(key(left))
            angle+=4000;
        END
        IF(key(up))
            advance(5);
        END
        IF(key(fire) AND Antifastshot<1)
            Power++;
        END
        IF(NOT Key(fire) AND Power!=0)
            Power=Power/10;
            IF(Power<2)
                Power=2;
            END
            shot(x,y,angle,id,power*50);
            Antifastshot=5;
            advance(-Power*10);
            Power=0;
        END
        /*IF(rand(0,1000)==0)
            CLONE
                advance(1000);
            END
        END*/


        Antifastshot--;
        IF(x<0) x=800; END
        IF(y<0) y=600; END
        IF(x>800) x=0; END
        IF(y>600) y=0; END

        IF(life<1)
            life=0;
            Explosion(x,y,500);
            RETURN;
        END


        FRAME;
    END


END




PROCESS shot(x,y,angle,player,size)

PRIVATE
    hit;

BEGIN
    graph=4;
    LOOP
        advance(10);
        IF(x>800 OR x<0 OR y>600 OR y<0)
            RETURN;
        END
        WHILE(hit=collision(TYPE ship))
            IF(hit!=player)
                hit.life-=size/50;
                Explosion(x,y,50);
                RETURN;
            END
        END
        /*IF(rand(0,100)==0 AND size>102)
            CLONE
                angle+=20000;
            END
            angle-=10000;
            size=size/2;
        END*/



        FRAME;
    END

END





PROCESS Explosion(x,y,size)

BEGIN
    FOR(graph=10; graph<15; graph++)
        FRAME;
    END
END































PROCESS Framers();

PRIVATE
    counter;

BEGIN

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
            Write_Int(0,290,20,4,OFFSET fpsa);
            Write_Int(0,350,20,4,OFFSET fpsb);
        END
        FRAME;
    END
END








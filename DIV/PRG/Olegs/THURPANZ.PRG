
PROGRAM Thursday_Panzers;

GLOBAL
    Panzersteama;
    Panzersteamb;

LOCAL
    Move;
    life;
    power;
    velo;
    Team;
    backstab;
    Player;
    lifetext;

BEGIN
    load_fnt("Olegs\Thurpanz.FNT");
    load_fpg("olegs\Thurpanz.FPG");
    set_fps(24,0);
    set_mode(m800x600);
    Draw(1);
    write_int(1,0,20,0, OFFSET Panzersteama);
    write_int(1,800,20,2, OFFSET Panzersteamb);
    define_region(1,5,5,390,590);
    define_region(2,405,5,390,590);
    start_scroll(1,0,1,0,1,0);
    start_scroll(2,0,1,0,2,0);
    Panzer(0,0,300,10,40,1,1);
    Panzer(1600,1200,300,10,40,0,2);
    FOR(x=0;x<=1600;x+=80)
        Panzer(x+rand(-10,10),300+rand(-15,15),200,5,30,0,1);
    END
    FOR(x=0;x<=1600;x+=60)
        Panzer(x+rand(-10,10),900+rand(-15,15),200,5,30,0,2);
    END
    /*Panzer(5,5,500,10,30,1,1);
    Panzer(5000,5000,500,10,30,2,2);*/
    /*LOOP
        Panzer(rand(0,1600),rand(0,1200),75,5,25,0,2);
        Panzer(rand(0,1600),rand(0,1200),75,5,25,0,1);
        FRAME(2400);
    END*/


END






Process Draw(graph)

BEGIN
    FOR(x=0;x<=1600;x++)
        FOR(y=0;y<=1200;y++)
            map_put_pixel(0,graph,x,y,rand(34,37));
        END
    END
END





PROCESS Panzer(x,y,life,power,velo,player,team)

PRIVATE
    hit;
    shotwait;
    nearest;
    Candidate;

BEGIN
    ctype=c_scroll;
    IF(player==1)
        lifetext=write_int(1,0,0,0, OFFSET life);
        scroll[1].camera=id;
    END
    IF(player==2)
        lifetext=write_int(1,800,0,2, OFFSET life);
        scroll[2].camera=id;
    END
    IF(team==1)
        Panzersteama++;
        graph=100;
    END
    IF(team==2)
        Panzersteamb++;
        graph=101;
    END

    resolution=100;
    x=x*100;
    y=y*100;
    LOOP
        IF(player>=1)
          IF(player==1)
            IF(key(_left))
                angle+=velo*50+move*2;
            END
            IF(key(_right))
                angle-=velo*50+move*2;
            END
            IF(key(_up) AND Move<Velo*20)
                Move+=Velo;
            END
            IF(key(_down) AND Move>-Velo*5)
                Move-=Velo*2;
            END
            IF(key(_enter) AND shotwait<0)
                Schuss(x,y,angle,power,move);
                shotwait=24;
            END
          END
          IF(player==2)
            IF(key(_a))
                angle+=velo*50+move*2;
            END
            IF(key(_d))
                angle-=velo*50+move*2;
            END
            IF(key(_w) AND Move<Velo*20)
                Move+=Velo;
            END
            IF(key(_s) AND Move>-Velo*5)
                Move-=Velo*2;
            END
            IF(key(_q) AND shotwait<0)
                Schuss(x,y,angle,power,move);
                shotwait=24;
            END
          END
        ELSE
            nearest=0;
            WHILE(Candidate=get_id(TYPE Panzer))
                //Noch ein Einbau zum CRASHEN da das While doppelt wiederholt wird ohne Frame dazwischen
                    IF(get_dist(Candidate)<3000)
                        X-=get_distx(get_angle(Candidate),500);
                        Y-=get_disty(get_angle(Candidate),500);
                        Candidate.X+=get_distx(get_angle(Candidate),500);
                        Candidate.Y+=get_disty(get_angle(Candidate),500);
                        Move=(Move*2)/3;
                    END



                IF(Candidate.team!=team)
                    IF(nearest==0)
                        nearest=Candidate;
                    ELSE
                        IF(get_dist(Candidate)<get_dist(nearest))
                            nearest=Candidate;
                        END
                    END
                END
            END
            IF(Backstab<0)
                IF(get_dist(nearest)>15000 AND Move<Velo*20)
                    Move+=Velo;
                END
            ELSE
                IF(Move>-Velo*5)
                    Move-=Velo*2;
                END
            END
            Backstab--;
            angle=near_angle(angle,get_angle(nearest),velo*50+move*2);
            IF(Shotwait<0 AND angle+20000>get_angle(nearest) AND angle-20000<get_angle(nearest))
                Schuss(x,y,angle,power,move);
                shotwait=24;
            END
        END
        shotwait--;

        advance(Move);
        Move=near_angle(Move,0,velo/2);
        WHILE(Hit=get_id(TYPE Panzer)) //Collision
            IF(get_dist(hit)<3000)
                X-=get_distx(get_angle(hit),500);
                Y-=get_disty(get_angle(hit),500);
                hit.X+=get_distx(get_angle(hit),500);
                hit.Y+=get_disty(get_angle(hit),500);


                Move=(Move*2)/3;
            END
        END

        IF(x>157000) x=157000; END
        IF(y>117000) y=117000; END
        IF(x<3000) x=3000; END
        IF(y<3000) y=3000; END
        IF(angle>180000) angle-=360000; END
        IF(angle<-180000) angle+=360000; END

        FRAME;


        IF(life<0)
            explode(x/100,y/100,100);
            IF(team==1)
                Panzersteama--;
            END
            IF(team==2)
                Panzersteamb--;
            END
            IF(player!=0)
                WHILE(hit=get_id(TYPE Panzer))
                    IF(hit.team==team AND hit.player==0)
                        hit.player=player;
                        scroll[player].camera=hit;
                        delete_text(lifetext);
                        IF(player==1)
                            hit.lifetext=write_int(1,0,0,0, OFFSET hit.life);
                        END
                        IF(player==2)
                            hit.lifetext=write_int(1,800,0,2, OFFSET hit.life);
                        END
                        RETURN();
                    END
                END
            END
            RETURN();
        END
    END
END





PROCESS Schuss(x,y,angle,power,move)

PRIVATE
    Way;
    hit;
    Text;
    hit_ang;

BEGIN

    Graph=50;
    resolution=100;
    ctype=c_scroll;
    advance(2000);
    FOR(way=0; way<40; way++)
        advance(500+move);
        FRAME;
        IF(hit=collision(TYPE Panzer))
            IF(hit!=father)
                IF(hit.team==father.team)
                    Power=Power/5;
                END

                hit_ang=get_angle(hit)-hit.angle;
                IF(hit_ang>-135000 AND hit_ang<135000)
                    hit.life-=power*5;
                    explode(x/100,y/100,20);
                    hit.Backstab=50;
                ELSE
                    hit.life-=power;
                END
                RETURN();
            END
        END

    END
END

PROCESS Explode(x,y,size)

BEGIN
    ctype=c_scroll;
    FOR(graph=60;graph<=65;graph++)
        FRAME;
    END
END













































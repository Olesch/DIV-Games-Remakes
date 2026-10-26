/*
Energyusage:Fly:1
            shot:15 - Variabel
            shothit:50 - Variabel
            rocketshot:25
            rockethit:75
            teleport:50
            shieldframe:3


Fx=(k*x)/sqrt(pow(pow(x,2)+pow(y,2),3))

*/
PROGRAM Miniship;

GLOBAL
    fpsa=30;
    fpsb=0;
    shipa;
    shipb;
    shipc;
    shipd;
    shipatot=1;
    shipbtot=1;
    shipctot=1;
    shipdtot=1;
    shipamode=1;
    shipbmode=1;
    shipcmode=0;
    shipdmode=0;
    Pointsa;
    Pointsb;
    Pointsc;
    Pointsd;
    Newstart;
    text;
    Planet_id;

    gravity=8000;
    maxenergy=1000;
    Asteroids=0;
    Particelamount=1;
    Particeltext[2]="None","Normal","Much";
    Chtxtpar;

    Playertext[5]="OFF","ON","PC Easy","PC Normal","PC Hard","PC King";
    Chtxtpl1;
    Chtxtpl2;
    Chtxtpl3;
    Chtxtpl4;

    Lasertype=0;
    Lasertext[6]="Laser","Durable Laser","Lasershot","Machinelasershot","Spreader","Sniper","GravitLaser";
    Chtxtlas;

    Loadtype=2;
    Loadtext[4]="None","Slow","Normal","Fast","Starwars";
    Chtxtloa;

    Playtype=0;
    Playtext[2]="Standart","Simple","Hold the Flag";
    ChtxtPla;


    //Flaggame
    Follow;
    Flag_id;





LOCAL
    xinc;
    yinc;
    energy;
    //maxspeed=2000;
    Speedup=100;
    Weight;
    shielded;
    changed;
    id2;

BEGIN
    load_fpg("Olegs\Miniship.fpg");  // Loads graphics' file
    //Pictures=load_fnt("Olegs\S-Type.fnt");  // Loads graphics' file
    set_mode(m800x600);               // Sets video mode to 640x480
    set_fps(30,0);                    // Number of frames per second

 LOOP //Game loop

    Framers();

    graph=10;
    x=400;
    y=300;
    Moover();
    Chtxtlas=write(0,340,536,3,Lasertext[Lasertype]);
    write_int(0,145,533,3,OFFSET maxenergy);
    write_int(0,545,534,3,OFFSET Asteroids);
    write_int(0,145,544,3,OFFSET gravity);
    Chtxtpar=write(0,145,555,3,Particeltext[Particelamount]);
    Chtxtloa=write(0,340,547,3,Loadtext[Loadtype]);
    ChtxtPla=write(0,340,558,3,Playtext[Playtype]);

    ChtxtPl1=write(0,333,145,4,Playertext[shipamode]);
    ChtxtPl2=write(0,385,145,4,Playertext[shipbmode]);
    ChtxtPl3=write(0,445,145,4,Playertext[shipcmode]);
    ChtxtPl4=write(0,505,145,4,Playertext[shipdmode]);
    LOOP
        IF(playType==0)
            graph=10;
        END
        IF(playType==1)
            graph=13;
        END
        IF(playType==2)
            graph=14;
        END

        IF(key(_enter) AND shipamode+shipbmode+shipcmode+shipdmode>1)
            graph=0;
            delete_text(all_text);
            BREAK;
        END

        FRAME;
    END


    FOR(x=0; x<300; x++)
        put_pixel(rand(0,800),rand(0,600),15);
    END
    FOR(x=0; x<Asteroids; x++)
        Asteroid(rand(0,80000),rand(0,60000));
    END
    Planet_id=Planet(40000,30000,gravity);
    Energyline(0);
    Energyline(1);
    Energyline(2);
    Energyline(3);
    write_int(0,800,580,8,OFFSET pointsa);
    write_int(0,0,20,0,OFFSET pointsb);
    write_int(0,800,20,2,OFFSET pointsc);
    write_int(0,0,580,6,OFFSET pointsd);


    newstart=1;
    text=write(0,400,150,4,"GET READY");
    FRAME(1800);
    newstart=0;
    FRAME(400);
    delete_text(text);

    shipatot=0;
    shipbtot=0;
    shipctot=0;
    shipdtot=0;
    shipa=Ship(0,maxenergy,_up,_right,_left,_control);
    shipb=Ship(1,maxenergy,_w,_d,_a,_l_shift);
    shipc=Ship(2,maxenergy,_c_center,_c_pgdn,_c_end,_c_ins);
    shipd=Ship(3,maxenergy,_i,_l,_j,_space);
    IF(PlayType==2)
        Flag_id=flag();
    END

    LOOP
        IF(Playtype==0 OR Playtype==1)
            IF(shipatot+shipbtot+shipctot+shipdtot>=3)
                FRAME(400);
                IF(shipatot==0)
                    shipatot=1;
                    Pointsa++;
                END
                IF(shipbtot==0)
                    shipbtot=1;
                    Pointsb++;
                END
                IF(shipctot==0)
                    shipctot=1;
                    Pointsc++;
                END
                IF(shipdtot==0)
                    shipdtot=1;
                    Pointsd++;
                END
                newstart=1;
                text=write(0,400,150,4,"GET READY");
                FRAME(1800);
                newstart=0;
                FRAME(400);
                delete_text(text);

                shipatot=0;
                shipbtot=0;
                shipctot=0;
                shipdtot=0;
                shipa=Ship(0,maxenergy,_up,_right,_left,_control);
                shipb=Ship(1,maxenergy,_w,_d,_a,_l_shift);
                shipc=Ship(2,maxenergy,_c_center,_c_pgdn,_c_end,_c_ins);
                shipd=Ship(3,maxenergy,_i,_l,_j,_space);

            END
            FRAME;
        END
        IF(Playtype==2)
            IF(shipatot==1 AND shipamode!=0)
                FRAME(7200);
                shipatot=0;
                shipa=Ship(0,maxenergy,_up,_right,_left,_control);
            END
            IF(shipbtot==1 AND shipbmode!=0)
                FRAME(7200);
                shipbtot=0;
                shipb=Ship(1,maxenergy,_w,_d,_a,_l_shift);
            END
            IF(shipctot==1 AND shipcmode!=0)
                FRAME(7200);
                shipctot=0;
                shipc=Ship(2,maxenergy,_c_center,_c_pgdn,_c_end,_c_ins);
            END
            IF(shipdtot==1 AND shipdmode!=0)
                FRAME(7200);
                shipdtot=0;
                shipd=Ship(3,maxenergy,_i,_l,_j,_space);
            END
            FRAME;
        END
        IF(Key(_backspace))
            //WHILE(id2=get_id(0))
            //    IF(id2!=id)
            //        signal(id2,s_kill);
            //    END
            //END
            signal(son,s_kill_tree);
            signal(planet_id,s_kill_tree);
            break;

        END

    END

 END  //Geme Loop end

END


PROCESS Moover()

PRIVATE
    pos;

BEGIN
    x=130;
    y=533;
    graph=9;
    LOOP
        IF(key(_down) AND pos<6)
            Particeleffect(x*100,y*100,5,300);
            y+=11;
            pos++;
            IF(pos==0)
                x=130;
                y=533;
            END
            IF(pos==3)
                x=330;
                y=536;
            END
            IF(pos==6)
                x=530;
                y=534;
            END
            IF(pos==-1) x=313; y=145; END
            IF(pos==-2) x=365; y=145; END
            IF(pos==-3) x=425; y=145; END
            IF(pos==-4) x=485; y=145; END
            FRAME;
        END
        IF(key(_up) AND pos>-4)
            Particeleffect(x*100,y*100,5,300);
            y-=11;
            pos--;
            IF(pos==2)
                x=130;
                y=555;
            END
            IF(pos==5)
                x=330;
                y=558;
            END
            IF(pos==-1) x=313; y=145; END
            IF(pos==-2) x=365; y=145; END
            IF(pos==-3) x=425; y=145; END
            IF(pos==-4) x=485; y=145; END
            FRAME;
        END
        IF(key(_left))
            IF(pos==-4 AND shipdmode>0)
                shipdmode-=1;
                delete_text(Chtxtpl4);
                ChtxtPl4=write(0,505,145,4,Playertext[shipdmode]);
                FRAME;
            END
            IF(pos==-3 AND shipcmode>0)
                shipcmode-=1;
                delete_text(Chtxtpl3);
                ChtxtPl3=write(0,445,145,4,Playertext[shipcmode]);
                FRAME;
            END
            IF(pos==-2 AND shipbmode>0)
                shipbmode-=1;
                delete_text(Chtxtpl2);
                ChtxtPl2=write(0,385,145,4,Playertext[shipbmode]);
                FRAME;
            END
            IF(pos==-1 AND shipamode>0)
                shipamode-=1;
                delete_text(Chtxtpl1);
                ChtxtPl1=write(0,333,145,4,Playertext[shipamode]);
                FRAME;
            END
            IF(pos==0 AND maxEnergy>200)
                maxEnergy-=50;
            END
            IF(pos==1 AND Gravity>3000)
                gravity-=200;
            END
            IF(pos==2 AND Particelamount>0)
                Particelamount-=1;
                delete_text(Chtxtpar);
                Chtxtpar=write(0,145,555,3,Particeltext[Particelamount]);
                FRAME;
            END
            IF(pos==3 AND Lasertype>0)
                Lasertype-=1;
                delete_text(Chtxtlas);
                Chtxtlas=write(0,340,536,3,Lasertext[Lasertype]);
                FRAME;
            END
            IF(pos==4 AND Loadtype>0)
                Loadtype-=1;
                delete_text(Chtxtloa);
                Chtxtloa=write(0,340,547,3,Loadtext[Loadtype]);
                FRAME;
            END
            IF(pos==5 AND Playtype>0)
                playtype-=1;
                delete_text(Chtxtpla);
                ChtxtPla=write(0,340,558,3,Playtext[Playtype]);
                FRAME;
            END
            IF(pos==6 AND Asteroids>0)
                Asteroids-=1;
            END
            FRAME;
        END
        IF(key(_right))
            IF(pos==-4 AND shipdmode<5)
                shipdmode+=1;
                delete_text(Chtxtpl4);
                ChtxtPl4=write(0,505,145,4,Playertext[shipdmode]);
                FRAME;
            END
            IF(pos==-3 AND shipcmode<5)
                shipcmode+=1;
                delete_text(Chtxtpl3);
                ChtxtPl3=write(0,445,145,4,Playertext[shipcmode]);
                FRAME;
            END
            IF(pos==-2 AND shipbmode<5)
                shipbmode+=1;
                delete_text(Chtxtpl2);
                ChtxtPl2=write(0,385,145,4,Playertext[shipbmode]);
                FRAME;
            END
            IF(pos==-1 AND shipamode<5)
                shipamode+=1;
                delete_text(Chtxtpl1);
                ChtxtPl1=write(0,333,145,4,Playertext[shipamode]);
                FRAME;
            END
            IF(pos==0 AND maxEnergy<3000)
                maxEnergy+=50;
            END
            IF(pos==1 AND Gravity<16000)
                gravity+=200;
            END
            IF(pos==2 AND Particelamount<2)
                Particelamount+=1;
                delete_text(Chtxtpar);
                Chtxtpar=write(0,145,555,3,Particeltext[Particelamount]);
                FRAME;
            END
            IF(pos==3 AND Lasertype<6)
                Lasertype+=1;
                delete_text(Chtxtlas);
                Chtxtlas=write(0,340,536,3,Lasertext[Lasertype]);
                FRAME;
            END
            IF(pos==4 AND Loadtype<4)
                Loadtype+=1;
                delete_text(Chtxtloa);
                Chtxtloa=write(0,340,547,3,Loadtext[Loadtype]);
                FRAME;
            END
            IF(pos==5 AND Playtype<2)
                playtype+=1;
                delete_text(Chtxtpla);
                ChtxtPla=write(0,340,558,3,Playtext[Playtype]);
                FRAME;
            END
            IF(pos==6 AND Asteroids<9)
                Asteroids+=1;
            END
            FRAME;
        END
        IF(key(_enter) AND shipamode+shipbmode+shipcmode+shipdmode>1)
            RETURN;
        END

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
        IF(key(_ESC))
            exit("May the force be with you!",0);
        END


        FRAME;
    END
END



PROCESS Ship(Player,Energy,vor,rechts,links,Schuss)

PRIVATE
    Antifastshot;
    Antifastrocket;
    Portwait;
    hit;
    tempinc;
    Schusshold;
    naehest;
    Candidate;
    Loadwait;
    KIvor;
    KIrechts;
    KIlinks;
    KIschuss;
    Intelligence;
    Movement;


BEGIN
    IF(player==0)
        IF(Shipamode==0)
            shipatot=1;
            RETURN();
        END
        x=60000;
        y=45000;
        angle=90000;
    END
    IF(player==1)
        IF(Shipbmode==0)
            shipbtot=1;
            RETURN();
        END
        x=20000;
        y=15000;
        angle=-90000;
    END
    IF(player==2)
        IF(Shipcmode==0)
            shipctot=1;
            RETURN();
        END
        x=60000;
        y=15000;
        angle=180000;
    END
    IF(player==3)
        IF(Shipdmode==0)
            shipdtot=1;
            RETURN();
        END
        x=20000;
        y=45000;
    END
    //        xinc+=get_distx(angle,2500);
    //        yinc+=get_disty(angle,2000);
    FRAME;
    resolution=100;
    graph=player+1;
    Particeleffect(x,y,15,800);
    IF(player==0) intelligence=shipamode-2; END
    IF(player==1) intelligence=shipbmode-2; END
    IF(player==2) intelligence=shipcmode-2; END
    IF(player==3) intelligence=shipdmode-2; END
    LOOP



        IF((player==0 AND (shipamode==2 OR shipamode==3 OR shipamode==4 OR shipamode==5)) OR
        /**/(player==1 AND (shipbmode==2 OR shipbmode==3 OR shipbmode==4 OR shipbmode==5)) OR
        /**/(player==2 AND (shipcmode==2 OR shipcmode==3 OR shipcmode==4 OR shipcmode==5)) OR
        /**/(player==3 AND (shipdmode==2 OR shipdmode==3 OR shipdmode==4 OR shipdmode==5)))




            KIvor=0;
            KIrechts=0;
            KIlinks=0;
            KIschuss=0;
            Naehest=0;

            IF(PlayType==2 AND Follow!=id)////////////////
                IF(Follow==0)
                    naehest=Flag_id;
                ELSE
                    naehest=Follow;
                END

            END


            IF(Naehest==0)
                WHILE(Candidate=get_id(TYPE ship))
                    IF(get_dist(Candidate)!=0)
                        IF(Naehest==0 OR get_dist(Candidate)<get_dist(naehest))
                            naehest=candidate;
                        END
                    END
                END
            END

            IF(naehest!=0)
                IF(get_angle(naehest)<get_angle(Planet_id)+7000 AND
                   get_angle(naehest)>get_angle(Planet_id)-7000)

                    angle=near_angle(angle,get_angle(planet_id)+180000,pi/32);
                ELSE
                    angle=near_angle(angle,get_angle(naehest),pi/16);
                END
            END


            IF(fget_angle(x,xinc,y,yinc)<angle+7000 AND
               fget_angle(x,xinc,y,yinc)>angle-7000)

                Movement=sqrt(pow(xinc,2)+pow(yinc,2));
                IF(Movement<9500)
                    KIvor=1;
                END
            ELSE
                KIvor=1;
            END

            IF(naehest!=0 AND naehest!=flag_id)
                IF(get_dist(Naehest)<26000)
                    IF(naehest.shielded==0)
                        IF(Rand(0,(3-Intelligence)*5+1)==0)
                            KIschuss=1;
                        END
                    ELSE
                        KIrechts=1;
                        KIlinks=1;
                        IF(Rand(0,(3-Intelligence)*5+5)==0)
                            KIschuss=1;
                        END
                    END
                END
            END


            IF((energy>50 AND get_dist(Planet_id)<planet_id.size*55 AND Playtype!=1) OR (rand(0,1000)==0 AND energy>50 AND Playtype!=1))

                Particeleffect(x,y,8,100);
                energy-=50;
                telspecout(x/100,y/100);
                xinc=0;
                yinc=0;
                x=rand(0,80000);
                y=rand(0,60000);
                Particeleffect(x,y,8,100);
                telspecin(x/100,y/100);
            END

        END











        loadwait++;
        IF(loadtype==1 AND loadwait>3)
            energy++;
            loadwait=0;
        END
        IF(loadtype==2 AND loadwait>1)
            energy++;
            loadwait=0;
        END
        IF(loadtype==3)
            energy++;
        END
        IF(loadtype==4)
            energy+=3;
        END

        IF(energy>maxenergy)
            energy=maxenergy;
        END
        IF(energy<0)
            IF(player==0) shipatot=1; END
            IF(player==1) shipbtot=1; END
            IF(player==2) shipctot=1; END
            IF(player==3) shipdtot=1; END
            Particeleffect(x,y,15,800);
            IF(Playtype==2)
                IF(player==0) Pointsa--; END
                IF(player==1) Pointsb--; END
                IF(player==2) Pointsc--; END
                IF(player==3) Pointsd--; END
                IF(Follow!=0)
                    IF(Follow.graph==1 AND Follow.graph-1!=player)
                        Pointsa+=3;
                    END
                    IF(Follow.graph==2 AND Follow.graph-1!=player)
                        Pointsb+=3;
                    END
                    IF(Follow.graph==3 AND Follow.graph-1!=player)
                        Pointsc+=3;
                    END
                    IF(Follow.graph==4 AND Follow.graph-1!=player)
                        Pointsd+=3;
                    END
                END
            END


            BREAK;
        END
        x+=xinc/10;
        y+=yinc/10;
        IF((key(vor) OR KIVor==1) AND energy>1)
            Particeleffect(x,y,1,100);
            xinc+=get_distx(angle,Speedup);
            yinc+=get_disty(angle,Speedup);
            energy--;
        END
        IF(key(rechts))
            angle-=pi/16;
        END
        IF(key(links))
            angle+=pi/16;
        END
        IF(key(rechts) AND key(links) AND Portwait<18 AND Portwait>10
                       AND energy>50 AND PlayType!=1)
            Particeleffect(x,y,8,100);
            energy-=50;
            telspecout(x/100,y/100);
            xinc=0;
            yinc=0;
            x=rand(0,80000);
            y=rand(0,60000);
            Particeleffect(x,y,8,100);
            telspecin(x/100,y/100);
        END

        IF((key(rechts) OR KIrechts==1) AND (key(links) OR KIlinks==1) AND energy>3 AND PlayType!=1)
            Particeleffect(x,y,1,800);
            shielded=1;
            energy-=3;
            shieldspec(x/100,y/100);
            Portwait=20;
        ELSE
            shielded=0;
        END
        Portwait--;

        IF(x>80000) x=1; END
        IF(y>60000) y=1; END
        IF(x<0) x=79999; END
        IF(y<0) y=59999; END

        IF(key(schuss))
            Schusshold++;
        END
        /*IF(Schusshold>=20)
            IF(player!=0)
                naehest=shipa;
            END
            IF(player==0)
                naehest=shipb;
            ELSE
                IF(player!=1)
                    IF(get_dist(naehest)>get_dist(shipb))
                        naehest=shipb;
                    END
                END
            END
            IF(player!=2)
                IF(get_dist(naehest)>get_dist(shipc))
                    naehest=shipc;
                END
            END
            IF(player!=3)
                IF(get_dist(naehest)>get_dist(shipd))
                    naehest=shipd;
                END
            END
            angle=near_angle(angle,get_angle(naehest),pi/16);
            Fadenkreuz(naehest.x/100,naehest.y/100);

        END*///Autozielen


        IF((key(schuss) OR KIschuss) AND Antifastshot<1)
            IF((key(rechts) OR KIrechts==1) AND (key(links) OR KIlinks==1) AND PlayType!=1)
                IF(energy>25 AND Antifastrocket==0)
                    rocket(x,y,angle);
                    energy-=25;
                    Antifastrocket=1;
                END
            ELSE
                IF(Lasertype==0 AND energy>15)
                    shot(x,y,angle);
                    energy-=15;
                END
                IF(Lasertype==1 AND energy>3)
                    shot(x,y,angle);
                    energy-=3;
                END
                IF(Lasertype==2 AND energy>10)
                    shot(x,y,angle);
                    energy-=10;
                END
                IF(Lasertype==3 AND energy>6)
                    shot(x,y,angle);
                    energy-=6;
                END
                IF(Lasertype==4 AND energy>3)
                    shot(x,y,angle);
                    energy-=3;
                END
                IF(Lasertype==5 AND energy>25)
                    shot(x,y,angle);
                    energy-=25;
                END
                IF(Lasertype==6 AND energy>10)
                    shot(x,y,angle);
                    energy-=10;
                END
            END
            Antifastshot=3;
            IF(Lasertype==5)
                Antifastshot=70;
            END

        END
        IF(NOT key(schuss))
            IF(LaserType!=5)
                Antifastshot=0;
            END
            Antifastrocket=0;
            Schusshold=0;
        END
        IF(Lasertype==1 OR Lasertype==4)
            Antifastshot=0;
        END
        IF(Lasertype==3 OR Lasertype==5)
            Antifastshot-=1;
        END
        WHILE(hit=collision(TYPE ship))
            Particeleffect(x,y,5,500);
            hit.x+=get_distx(get_angle(hit),250);
            hit.y+=get_disty(get_angle(hit),250);

            x-=get_distx(get_angle(hit),250);
            y-=get_disty(get_angle(hit),250);

            IF(changed<1 AND hit.changed<1)
                tempinc=hit.xinc;
                hit.xinc=xinc;
                xinc=tempinc;

                tempinc=hit.yinc;
                hit.yinc=yinc;
                yinc=tempinc;
                changed=1;
            END

        END
        changed--;


        /*IF(xinc>maxspeed)
            xinc=maxspeed;
        END
        IF(xinc<-maxspeed)
            xinc=-maxspeed;
        END
        IF(yinc>maxspeed)
            yinc=maxspeed;
        END
        IF(yinc<-maxspeed)
            yinc=-maxspeed;
        END*/
        FRAME;
        IF(newstart==1)
            Particeleffect(x,y,15,800);
            RETURN;
        END
    END
END



PROCESS Shot(x,y,angle)

PRIVATE
    hit;
    Counter;

BEGIN
    size=130;
    resolution=100;
    graph=5;
    IF(Lasertype==6)
        Angle=get_angle(Planet_id);
    END
    LaserSpec(x,y,angle);
    advance(1800);
        FOR(Counter=0;Counter<21;Counter++)
            IF(Lasertype==0 OR Lasertype==2)
                Particeleffect(x,y,0,100);
            ELSE
                IF(Rand(0,3)==0)
                    Particeleffect(x,y,0,100);
                END
            END
            advance(1000);
            IF(Lasertype==4)
                Angle+=16000;//rand(-12000,12000);
            END
            IF(hit=Collision(TYPE ship));
                Particeleffect(x,y,5,500);
                IF(hit.shielded==0)
                    IF(Lasertype==0)
                        hit.energy-=50;
                    END
                    IF(Lasertype==1)
                        hit.energy-=10;
                    END
                    IF(Lasertype==2)
                        hit.energy-=60;
                    END
                    IF(Lasertype==3)
                        hit.energy-=45;
                    END
                    IF(Lasertype==4)
                        hit.energy-=30;
                    END
                    IF(Lasertype==5)
                        hit.energy-=500;
                    END
                    IF(Lasertype==6)
                        hit.energy-=90;
                    END
                    RETURN();
                ELSE
                    counter-=7;
                    angle+=rand(160000,200000);
                    advance(1800);
                END
            END
            IF(hit=Collision(TYPE Rocket));
                Particeleffect(x,y,4,100);
                signal(hit,s_kill);
                RETURN;
            END
            IF(hit=Collision(TYPE Planet));
                Particeleffect(x,y,2,200);
                RETURN;
            END
            IF(hit=Collision(TYPE Asteroid));
                Particeleffect(x,y,2,200);
                hit.xinc+=get_distx(get_angle(hit),800);
                hit.yinc+=get_disty(get_angle(hit),800);
                RETURN;
            END
            LaserSpec(x,y,angle);
            IF(x>80000) x=1; END
            IF(y>60000) y=1; END
            IF(x<0) x=79999; END
            IF(y<0) y=59999; END

            FRAME(1);
            IF(Lasertype==2 OR Lasertype==3)
                FRAME(99);
            END
            IF(newstart==1)
                RETURN;
            END
        END
END


PROCESS Rocket(x,y,angle)

PRIVATE
    hit;
    Counter;
    Time;

BEGIN
    resolution=100;
    graph=9;
    advance(1800);
    xinc=father.xinc;
    yinc=father.yinc;
    xinc+=get_distx(angle,5000);
    yinc+=get_disty(angle,5000);
        LOOP
            Time++;
            Particeleffect(x,y,0,100);
            x+=xinc/10;
            y+=yinc/10;
            IF(hit=Collision(TYPE ship));
                Particeleffect(x,y,5,200);
                hit.energy-=70;
                RETURN();
            END
            IF(hit=Collision(TYPE Planet));
                Particeleffect(x,y,5,200);
                RETURN;
            END
            IF(hit=Collision(TYPE Asteroid));
                Particeleffect(x,y,5,200);
                hit.xinc+=get_distx(get_angle(hit),1400);
                hit.yinc+=get_disty(get_angle(hit),1400);
                RETURN;
            END
            IF(x>80000) x=1; END
            IF(y>60000) y=1; END
            IF(x<0) x=79999; END
            IF(y<0) y=59999; END
            FRAME;
            IF(newstart==1 OR Time>600)
                Particeleffect(x,y,5,200);
                RETURN;
            END
        END
END



PROCESS Laserspec(x,y,angle)

BEGIN
    size=130;
    resolution=100;
    Graph=5;
    FRAME(100);
END

PROCESS shieldspec(x,y)

BEGIN
    Graph=8;
    FRAME(100);
END

PROCESS Fadenkreuz(x,y)

BEGIN
    Graph=12;
    FRAME(100);
END

PROCESS telspecout(x,y)

BEGIN
    Graph=8;
    FOR(size=100;size<150;size+=3)
        FRAME(100);
    END
END

PROCESS telspecin(x,y)

BEGIN
    Graph=8;
    FOR(size=150;size>100;size-=3)
        FRAME(100);
    END
END



PROCESS Planet(x,y,Weight)

PRIVATE
    hit;
    distx;
    disty;
    rockid;

BEGIN
    size=(weight+2000)/100;

    graph=6;
    resolution=100;
    LOOP
        IF(shipatot==0)
            distx=(shipa.x-x)/1000;
            disty=(shipa.y-y)/1000;
            shipa.xinc-=(Weight*distx)/pow(sqrt(pow(distx,2)+pow(disty,2)),3);
            shipa.yinc-=(Weight*disty)/pow(sqrt(pow(distx,2)+pow(disty,2)),3);
        END
        IF(shipbtot==0)
            distx=(shipb.x-x)/1000;
            disty=(shipb.y-y)/1000;
            shipb.xinc-=(Weight*distx)/pow(sqrt(pow(distx,2)+pow(disty,2)),3);
            shipb.yinc-=(Weight*disty)/pow(sqrt(pow(distx,2)+pow(disty,2)),3);
        END
        IF(shipctot==0)
            distx=(shipc.x-x)/1000;
            disty=(shipc.y-y)/1000;
            shipc.xinc-=(Weight*distx)/pow(sqrt(pow(distx,2)+pow(disty,2)),3);
            shipc.yinc-=(Weight*disty)/pow(sqrt(pow(distx,2)+pow(disty,2)),3);
        END
        IF(shipdtot==0)
            distx=(shipd.x-x)/1000;
            disty=(shipd.y-y)/1000;
            shipd.xinc-=(Weight*distx)/pow(sqrt(pow(distx,2)+pow(disty,2)),3);
            shipd.yinc-=(Weight*disty)/pow(sqrt(pow(distx,2)+pow(disty,2)),3);
        END
        WHILE(rockid=get_id(TYPE rocket))
            distx=(rockid.x-x)/1000;
            disty=(rockid.y-y)/1000;
            rockid.xinc-=(Weight*distx)/pow(sqrt(pow(distx,2)+pow(disty,2)),3);
            rockid.yinc-=(Weight*disty)/pow(sqrt(pow(distx,2)+pow(disty,2)),3);
        END
        WHILE(rockid=get_id(TYPE Asteroid))
            distx=(rockid.x-x)/1000;
            disty=(rockid.y-y)/1000;
            rockid.xinc-=(Weight*distx)/pow(sqrt(pow(distx,2)+pow(disty,2)),3);
            rockid.yinc-=(Weight*disty)/pow(sqrt(pow(distx,2)+pow(disty,2)),3);
        END
        WHILE(hit=collision(TYPE ship))
            //IF(hit.shielded==0)
                hit.energy=-500;
            //ELSE
            //    hit.xinc=0;
            //    hit.yinc=0;
            //    hit.x+=get_distx(get_angle(hit),5);
            //    hit.y+=get_disty(get_angle(hit),5);
            //END

        END


        FRAME;
    END
END

PROCESS Energyline(nummer)

BEGIN
    graph=7;
    LOOP
        IF(nummer==0)
            IF(shipatot==0 AND shipamode!=0)
                x=800-shipa.energy/(maxenergy/100);
                y=590;
            ELSE
                x=-800;
                y=-800;
            END
        END
        IF(nummer==1)
            IF(shipbtot==0 AND shipbmode!=0)
                x=shipb.energy/(maxenergy/100)-100;
                y=10;
            ELSE
                x=-800;
                y=-800;
            END
        END
        IF(nummer==2)
            IF(shipctot==0 AND shipcmode!=0)
                x=800-shipc.energy/(maxenergy/100);
                y=10;
            ELSE
                x=-800;
                y=-800;
            END
        END
        IF(nummer==3)
            IF(shipdtot==0 AND shipdmode!=0)
                x=shipd.energy/(maxenergy/100)-100;
                y=590;
            ELSE
                x=-800;
                y=-800;
            END
        END
        FRAME;
    END
END

PROCESS Particeleffect(x,y,count,power)

BEGIN
    IF(Particelamount==0)
        RETURN;
    END
    IF(Particelamount==1)
        IF(Count==0)
            IF(rand(0,1)==0)
                RETURN;
            END
        ELSE
            count--;
        END
    END

    graph=11;
    resolution=100;
    IF(count>0)
        Particeleffect(x,y,count-1,power);
    END
    IF(Particelamount==2)
        power=(power*4)/3;
    END
    angle=rand(-180000,180000);

    xinc+=get_distx(angle,rand(0,power));
    yinc+=get_disty(angle,rand(0,power));
    angle=0;

    LOOP
        x+=xinc;
        y+=yinc;
        IF(rand(0,6)==0)
            BREAK;
        END
        FRAME;
    END
END



PROCESS Flag()

PRIVATE
    hit;
    Movement;
    Immunity;

BEGIN
    x=rand(0,80000);
    y=rand(0,60000);
    xinc=rand(800,1200)*(rand(0,1)*2-1);
    yinc=rand(800,1200)*(rand(0,1)*2-1);
    resolution=100;
    Graph=20;
    LOOP
        IF(Follow==0)
            IF(hit=Collision(TYPE ship));
                IF(immunity<0)
                    Follow=hit;
                END
            END
            x+=xinc/10;
            y+=yinc/10;
            IF(x>80000) x=1; END
            IF(y>60000) y=1; END
            IF(x<0) x=79999; END
            IF(y<0) y=59999; END
            IF(Collision(TYPE Planet));
                x=rand(0,80000);
                y=rand(0,60000);
            END
        ELSE
            x=Follow.x+1000;
            y=Follow.y-1000;

            IF(Follow.energy<0)
                Follow=0;
                xinc=rand(800,1200)*(rand(0,1)*2-1);
                yinc=rand(800,1200)*(rand(0,1)*2-1);
                x+=2*xinc;
                y+=2*yinc;
            END
            IF(Follow!=0)
                Movement=sqrt(pow(Follow.xinc,2)+pow(Follow.yinc,2));
                IF(Movement>10000)
                    immunity=5;
                    Follow=0;
                    xinc=rand(800,1200)*(rand(0,1)*2-1);
                    yinc=rand(800,1200)*(rand(0,1)*2-1);
                    x+=2*xinc;
                    y+=2*yinc;
                END
            END
        END
        immunity--;
        FRAME;
    END
END




PROCESS Asteroid(x,y)

PRIVATE
    hit;
    Counter;
    Time;
    Tempinc;

BEGIN
    resolution=100;
    weight=rand(1,3);
    graph=20+weight;
    angle=rand(-180000,180000);
    xinc=get_distx(angle,rand(2000,7000)/weight);
    yinc=get_disty(angle,rand(2000,7000)/weight);
    angle=rand(-180000,180000);
        LOOP
            x+=xinc/10;
            y+=yinc/10;
            IF(hit=Collision(TYPE Planet));
                Particeleffect(x,y,15,700);
                x=-80000;
                y=-80000;
                FRAME(7000);
                x=0;
                y=0;
                weight=rand(1,3);
                graph=20+weight;
                angle=rand(-180000,180000);
                xinc=get_distx(angle,rand(2000,7000)/weight);
                yinc=get_disty(angle,rand(2000,7000)/weight);
                angle=rand(-180000,180000);
            END
            IF(x>80000) x=1; END
            IF(y>60000) y=1; END
            IF(x<0) x=79999; END
            IF(y<0) y=59999; END
            FRAME;

        WHILE(hit=collision(TYPE ship))
            Particeleffect(x,y,5,500);
            hit.x+=get_distx(get_angle(hit),250);
            hit.y+=get_disty(get_angle(hit),250);

            x-=get_distx(get_angle(hit),250);
            y-=get_disty(get_angle(hit),250);

            hit.energy-=10*weight;
            IF(changed<1 AND hit.changed<1)
                tempinc=hit.xinc;///weight;
                hit.xinc=xinc;//*weight;
                xinc=tempinc;

                tempinc=hit.yinc;
                hit.yinc=yinc;///weight;
                yinc=tempinc;//*weight;
                changed=1;
            END

        END

        WHILE(hit=collision(TYPE Asteroid))
            Particeleffect(x,y,5,500);
            hit.x+=get_distx(get_angle(hit),250);
            hit.y+=get_disty(get_angle(hit),250);

            x-=get_distx(get_angle(hit),250);
            y-=get_disty(get_angle(hit),250);

            IF(changed<1 AND hit.changed<1)
                tempinc=hit.xinc;///weight*hit.weight;
                hit.xinc=xinc;//*weight/hit.weight;
                xinc=tempinc;

                tempinc=hit.yinc;
                hit.yinc=yinc;///weight*hit.weight;
                yinc=tempinc;//*weight/hit.weight;
                changed=1;
            END

        END


        changed--;



        END
END














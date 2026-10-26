/*
  Actions:
  0=Waiting in se door
  1-7=Move Graph a
  8-14=Move Graph b
  15-20=Fall Graph a
  21-26=Fall Graph b
  27-33=climb Graph a
  34-40=climb Graph b
  41-63=Jump
  64-72=Buildladdera
  73-81=Buildladderb
  82-91=Dig in the Earth > a
  92-101=Dig in the Earth > b
  102-111=Dig in the Earth \ a
  112-121=Dig in the Earth \ b
  122-131=Dig in the Earth V a
  132-141=Dig in the Earth V b
  142-151=Stoppinga
  152-161=Stoppingb

  5000=Dead
  5001=In Exit


  Dir:
  1=>
  -1=<


    113=Movable


  Buttons:
  Climb
  Unbrella
  Jump  (leftclick= Jump when you will fall; Rightclick: Jump this one Time)
  Explode
  Build Ladder
  Stopper= LeftClick: Stopper or UnStopper   Right Click: Build Wall
  Dig>
  Dig\
  DigV





*/
PROGRAM Lommings;

GLOBAL
    Level=900;
    AvailableLevels[]=900,901,902,903,904,905,906,907,908,909,910,920,950,1000;
    Levelcounter;

    Levelxpos;
    MouseAction;

    Lommingsemerge;

    LommingsNumber;
    Lommingsemergemax;
    Time;
    ToSave;
    ClimbNr;
    UmbrellaNr;
    JumpNr;
    ExplodeNr;
    LadderNr;
    StopperNr;
    DigFrontNr;
    DigDiagonalNr;
    DigDownNr;

    STRUCT Lomming[99]
        x;
        y;
        dir;
        action;
        Umbrella;
        Climb;
        Jump;
        Fallen;
        Explode;
    END
    Lommingssaved;
    Lommingsaway;


    Jumpy[21]=-2,-2,-2,-2,-2,-2,-1,-1,-1,-1,0,0,1,1,1,1,2,2,2,2,2,2;
    Jumpx[21]= 0, 0, 0, 0, 1, 1, 1, 1, 2, 2,2,2,2,2,1,1,1,1,0,0,0,0;
    KillCount; //For the Backspacekey
    Tosaveadd;         //Showing one more
    Lommingsnumberadd; //Showing one more
    Speedup;
    Pause;


LOCAL


PRIVATE
    counter;
    text;

BEGIN
    load_fnt("Olegs\Lommings.FNT");
    load_fpg("olegs\Lommings.FPG");
    set_fps(24,0);
    set_mode(m320x240);

    Write_int(1,10,209,4, OFFSET ClimbNR);
    Write_int(1,30,209,4, OFFSET UmbrellaNR);
    Write_int(1,50,209,4, OFFSET JumpNR);
    Write_int(1,70,209,4, OFFSET ExplodeNR);
    Write_int(1,90,209,4, OFFSET LadderNR);
    Write_int(1,110,209,4, OFFSET StopperNR);
    Write_int(1,130,209,4, OFFSET DigfrontNR);
    Write_int(1,150,209,4, OFFSET DigDiagonalNR);
    Write_int(1,170,209,4, OFFSET DigDownNR);

    Write_int(1,250,209,4, OFFSET Time);
    Write_int(1,270,209,4, OFFSET Lommingsemerge);
    Write_int(1,290,209,4, OFFSET Lommingsemergemax);

    Write_int(1,270,234,4, OFFSET Lommingssaved);
    Write_int(1,290,234,4, OFFSET Tosaveadd);
    Write_int(1,310,234,4, OFFSET Lommingsnumberadd);


    Lomminger();
    Shower();
    Cursor();
    Items();

    LOOP
        map_put(0,2,Level,320,95);
        LommingsNumber=map_get_pixel(0,Level,0,0);
        Lommingsemergemax=map_get_pixel(0,Level,1,0);
        Lommingsemerge=Lommingsemergemax;
        Time=map_get_pixel(0,Level,2,0)*5;
        Tosave=map_get_pixel(0,Level,3,0);
        ClimbNr=map_get_pixel(0,Level,5,0);
        UmbrellaNr=map_get_pixel(0,Level,6,0);
        JumpNr=map_get_pixel(0,Level,7,0);
        ExplodeNr=map_get_pixel(0,Level,8,0);
        LadderNr=map_get_pixel(0,Level,9,0);
        StopperNr=map_get_pixel(0,Level,10,0);
        DigFrontNr=map_get_pixel(0,Level,11,0);
        DigDiagonalNr=map_get_pixel(0,Level,12,0);
        DigDownNr=map_get_pixel(0,Level,13,0);
        LOOP
            Tosaveadd=Tosave+1;
            Lommingsnumberadd=Lommingsnumber+1;
            FRAME(100);
            Lommingssaved=0;
            Lommingsaway=0;

            FOR(counter=0; counter<=Lommingsnumber; counter++)
                IF(Lomming[counter].action==5001)
                    Lommingssaved++;
                    Lommingsaway++;
                END
                IF(Lomming[counter].action==5000)
                    Lommingsaway++;
                END
            END
            IF(key(_o) AND key(_g))
                Lommingssaved=500;
                Lommingsaway=0;
                Time=0;
                FRAME(1000);
            END
            IF(time<1 OR lommingsaway>lommingsnumber)

                IF(Lommingssaved>Tosave)
                    Levelcounter++;
                    Level=AvailableLevels[Levelcounter];


                    IF(Level==1000)
                        EXIT("BYE!  YOUR LEVEL:",Levelcounter);
                    END
                    text=write(1,160,120,4, "Next Level!");
                    FRAME(2400);
                    delete_text(text);
                END
                FOR(counter=0; counter<=99; counter++)
                    Lomming[counter].x=0;
                    Lomming[counter].y=0;
                    Lomming[counter].dir=0;
                    Lomming[counter].action=0;
                    Lomming[counter].Umbrella=0;
                    Lomming[counter].Climb=0;
                    Lomming[counter].Jump=0;
                    Lomming[counter].Fallen=0;
                    Lomming[counter].Explode=0;
                END





                BREAK;
            END
        END
    END
END





PROCESS Lomminger()

PRIVATE
    WaitNew;
    Counter;
    Counterb;
    Exitx;
    Exity;
    dist;
    counterc;


BEGIN
    LOOP
      //IT'S THE SUPER-BOOSTER-SPEED-KEY: O!!!
      FOR(counterc=0; counterc<=Speedup; counterc++)

        get_point(0,Level,2,OFFSET Exitx,OFFSET Exity);

        //Creating new Lemmings

        WaitNew++;
        IF(WaitNew>Lommingsemerge)
            FOR(counter=0; Counter<=LommingsNumber; Counter++)
                IF(Lomming[Counter].Action==0)
                    get_point(0,Level,1,OFFSET Lomming[counter].x,OFFSET Lomming[counter].y);
                    Lomming[Counter].Action=1;
                    Lomming[Counter].dir=1;
                    WaitNew=0;
                    BREAK;
                END
            END

        END



        //Moving all created Lommings

        FOR(counter=0; Counter<=LommingsNumber; Counter++)
            SWITCH (Lomming[Counter].Action)
                CASE 0:
                    //Not in Game
                    BREAK;
                END
                CASE 1..7, 8..14:
                    //Moving

                    //First drawing
                    IF(Lomming[counter].action<8)
                        map_xput(0,1,100,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    ELSE
                        map_xput(0,1,101,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    END

                    //Moving Graph
                    Lomming[counter].action++;
                    IF(Lomming[counter].action>14)
                        Lomming[counter].action=1;
                    END

                    //x-Bewegung schauen
                    IF(map_get_pixel(0,2,Lomming[counter].x+Lomming[Counter].dir,Lomming[counter].y)==113)
                        //y-Bewegung schauen nach unten
                        FOR(counterb=1; Counterb<=5; Counterb++)

                            IF(map_get_pixel(0,2,Lomming[counter].x+Lomming[Counter].dir,Lomming[counter].y+Counterb)!=113)
                                Lomming[counter].x+=Lomming[Counter].dir;
                                Lomming[counter].y+=Counterb-1;
                                BREAK;
                            ELSE
                                IF(Counterb==5)
                                    IF(Lomming[counter].jump==1)
                                        Lomming[Counter].Action=41;
                                    ELSE
                                        Lomming[Counter].Action=15;
                                        Lomming[counter].x+=Lomming[Counter].dir;
                                    END
                                END
                            END
                        END
                    ELSE
                        //y-Bewegung schauen nach oben
                        FOR(counterb=-1; Counterb>=-4; Counterb--)
                            IF(map_get_pixel(0,2,Lomming[counter].x+Lomming[Counter].dir,Lomming[counter].y+Counterb)==113)
                                Lomming[counter].x+=Lomming[Counter].dir;
                                Lomming[counter].y+=Counterb;
                                BREAK;
                            ELSE
                                IF(Counterb==-4)
                                    IF(Lomming[counter].climb==1)
                                        Lomming[Counter].Action=27;
                                    ELSE
                                        Lomming[Counter].Dir=Lomming[Counter].Dir*-1;
                                    END
                                END
                            END
                        END
                    END
                    IF(Lomming[counter].y>=189)
                        Lomming[counter].action=5000;
                    END


                END

                CASE 15..20, 21..26:
                    //Falling


                    //Height
                    IF(Lomming[counter].action==15)
                        Lomming[counter].Fallen=0;
                    ELSE
                        Lomming[counter].Fallen++;
                    END
                    IF(Lomming[counter].umbrella==1)
                        Lomming[counter].Fallen=0;
                    END

                    //First drawing
                    IF(Lomming[counter].action<21)
                        map_xput(0,1,102+Lomming[counter].umbrella*4,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    ELSE
                        map_xput(0,1,103+Lomming[counter].umbrella*4,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    END

                    //Moving Graph
                    Lomming[counter].action++;
                    IF(Lomming[counter].action>26)
                        Lomming[counter].action=16;
                    END

                    //y-Bewegung schauen

                    IF(Lomming[counter].Umbrella==0 OR (Lomming[counter].Umbrella==1 AND Lomming[counter].action mod 2==1))
                        IF(map_get_pixel(0,2,Lomming[counter].x,Lomming[counter].y+1)==113)
                            Lomming[counter].y+=1;
                        ELSE
                            IF(Lomming[counter].fallen>80)
                                Lomming[counter].Action=5000;
                            ELSE
                                Lomming[counter].Action=1;
                            END
                        END
                    END

                END
                CASE 27..33, 34..40:
                    //Climbing

                    //First drawing
                    IF(Lomming[counter].action<34)
                        map_xput(0,1,104,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    ELSE
                        map_xput(0,1,105,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    END

                    //Moving Graph
                    Lomming[counter].action++;
                    IF(Lomming[counter].action>40)
                        Lomming[counter].action=27;
                    END

                    //y-Bewegung schauen
                    IF(lomming[counter].action mod 2==1)
                        IF(map_get_pixel(0,2,Lomming[counter].x+Lomming[counter].dir,Lomming[counter].y-1)==113)
                            Lomming[counter].y-=1;
                            Lomming[counter].x+=Lomming[counter].dir;
                            Lomming[counter].Action=1;
                        ELSE
                            IF(map_get_pixel(0,2,Lomming[counter].x,Lomming[counter].y-1)==113)
                                Lomming[counter].y-=1;
                            ELSE
                                Lomming[counter].Action=15;
                                Lomming[counter].dir=Lomming[counter].dir*-1;
                            END
                        END
                    END

                END

                CASE 41..63:
                    //Jumping

                    //First drawing
                    IF(Lomming[counter].action<53)
                        map_xput(0,1,102,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    ELSE
                        map_xput(0,1,103,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    END

                    //Moving Graph
                    Lomming[counter].action++;

                    //Sprungbewegung
                    IF(map_get_pixel(0,2,Lomming[counter].x+Jumpx[Lomming[counter].action-41]*Lomming[counter].dir,Lomming[counter].y+Jumpy[Lomming[counter].action-41])==113)
                        Lomming[counter].y+=Jumpy[Lomming[counter].action-41];
                        Lomming[counter].x+=Jumpx[Lomming[counter].action-41]*Lomming[counter].dir;
                    ELSE
                        //y-Bewegung schauen nach oben
                        FOR(counterb=-1; Counterb>=-4; Counterb--)
                            IF(map_get_pixel(0,2,Lomming[counter].x+Lomming[Counter].dir,Lomming[counter].y+Counterb)==113)
                                Lomming[counter].x+=Lomming[Counter].dir;
                                Lomming[counter].y+=Counterb+1;
                                Lomming[counter].action=1;
                                BREAK;
                            ELSE
                                IF(Counterb==-4)
                                    IF(Lomming[counter].climb==1)
                                        Lomming[Counter].Action=27;
                                    ELSE
                                        Lomming[Counter].Dir=Lomming[Counter].Dir*-1;
                                        Lomming[Counter].Action=15;
                                    END
                                END
                            END
                        END
                    END

                    //Ins Fallen uebergehen
                    IF(Lomming[counter].action>61)
                        Lomming[counter].action=15;
                    END


                END

                CASE 64..72, 73..81:
                    //Building a ladder


                    //Height  Here it means the number of builded Ladders
                    IF(Lomming[counter].action==64)
                        Lomming[counter].Fallen=0;
                    END

                    //First drawing
                    IF(lomming[counter].fallen>=15)
                        Lomming[counter].Fallen++;
                        map_xput(0,1,110,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    ELSE
                        IF(Lomming[counter].action<73)
                            map_xput(0,1,108,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                        ELSE
                            map_xput(0,1,109,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                        END
                    END
                    //Moving Graph
                    Lomming[counter].action++;
                    IF(Lomming[counter].action>81)
                        Lomming[counter].action=65;
                    END

                    //Building
                    IF(Lomming[counter].action==65 AND lomming[counter].fallen<=15)
                        Lomming[counter].Fallen++;
                        IF(map_get_pixel(0,2,Lomming[counter].x+Lomming[Counter].dir*2,Lomming[counter].y-1)==113)
                            map_put(0,2,80,Lomming[counter].x+2*Lomming[counter].dir,Lomming[counter].y);
                            Lomming[counter].x+=Lomming[Counter].dir*2;
                            Lomming[counter].y-=1;
                        ELSE
                            Lomming[counter].action=1;
                            Lomming[counter].dir=Lomming[counter].dir*-1;
                        END
                    END

                    //Stop it
                    IF(lomming[counter].fallen>=50)
                        Lomming[counter].action=1;
                    END

                END
                CASE 82..91, 92..101:
                    //Diging>
                    IF(Lomming[counter].Fallen!=16)
                        Lomming[counter].x+=Lomming[counter].dir*3;
                    END


                    //For easier working the mouse
                    Lomming[counter].Fallen=16;

                    //First drawing
                    IF(Lomming[counter].action<92)
                        map_xput(0,1,111,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    ELSE
                        map_xput(0,1,112,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    END

                    //Moving Graph
                    Lomming[counter].action++;
                    IF(Lomming[counter].action>101)
                        Lomming[counter].action=82;
                    END

                    //graben
                    IF(map_get_pixel(0,2,Lomming[counter].x+Lomming[counter].dir*3,Lomming[counter].y)!=113 AND (Lomming[counter].action==83 OR Lomming[counter].action==93))
                        Lomming[counter].x+=Lomming[counter].dir*2;
                        map_put(0,2,81,Lomming[counter].x,Lomming[counter].y);
                    ELSE
                        IF(map_get_pixel(0,2,Lomming[counter].x+Lomming[counter].dir*3,Lomming[counter].y)==113)
                            Lomming[counter].action=1;
                        END
                    END
                END
                CASE 102..111, 112..121:
                    //Diging\
                    //For easier working the mouse
                    Lomming[counter].Fallen=17;

                    //First drawing
                    IF(Lomming[counter].action<112)
                        map_xput(0,1,113,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    ELSE
                        map_xput(0,1,114,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    END

                    //Moving Graph
                    Lomming[counter].action++;
                    IF(Lomming[counter].action>121)
                        Lomming[counter].action=102;
                    END

                    //graben
                    IF(map_get_pixel(0,2,Lomming[counter].x+Lomming[counter].dir*2,Lomming[counter].y+1)!=113 AND Lomming[counter].action==112 )
                        Lomming[counter].x+=Lomming[counter].dir*2;
                        Lomming[counter].y+=1;
                        map_put(0,2,81,Lomming[counter].x,Lomming[counter].y);
                    ELSE
                        IF(map_get_pixel(0,2,Lomming[counter].x+Lomming[counter].dir*2,Lomming[counter].y+1)==113)
                            Lomming[counter].action=1;
                        END
                    END
                END
                CASE 122..131, 132..141:
                    //DigingV

                    //For easier working the mouse
                    Lomming[counter].Fallen=17;

                    //First drawing
                    IF(Lomming[counter].action<132)
                        map_xput(0,1,115,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    ELSE
                        map_xput(0,1,116,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    END

                    //Moving Graph
                    Lomming[counter].action++;
                    IF(Lomming[counter].action>141)
                        Lomming[counter].action=122;
                    END

                    //graben
                    IF(map_get_pixel(0,2,Lomming[counter].x,Lomming[counter].y+1)!=113 AND (Lomming[counter].action==122 OR Lomming[counter].action==132))
                        Lomming[counter].y+=1;
                        map_put(0,2,82,Lomming[counter].x,Lomming[counter].y);
                    ELSE
                        IF(map_get_pixel(0,2,Lomming[counter].x,Lomming[counter].y+1)==113)
                            Lomming[counter].action=1;
                        END
                    END
                END
                CASE 142..151, 152..161:
                    //Stopper

                    //First drawing
                    IF(Lomming[counter].action<152)
                        map_xput(0,1,117,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    ELSE
                        map_xput(0,1,118,Lomming[counter].x,Lomming[counter].y,0,100,(Lomming[counter].dir-1)/-2);
                    END

                    //Moving Graph
                    Lomming[counter].action++;
                    IF(Lomming[counter].action>161)
                        Lomming[counter].action=142;
                    END

                    //Turning all near lemmings
                    FOR(counterb=0; counterb<=Lommingsnumber; counterb++)
                        IF(abs(Lomming[counterb].y-lomming[counter].y)<5)
                            dist=lomming[counterb].x-lomming[counter].x;
                            IF(Lomming[counterb].dir==1)
                                IF(dist<0 AND dist>-5)
                                    Lomming[counterb].dir=Lomming[counterb].dir*-1;
                                END
                            END
                            IF(Lomming[counterb].dir==-1)
                                IF(dist>0 AND dist<5)
                                    Lomming[counterb].dir=Lomming[counterb].dir*-1;
                                END
                            END
                        END
                    END

                    //Falling
                    IF(map_get_pixel(0,2,Lomming[counter].x,Lomming[counter].y+1)==113)
                        Lomming[counter].action=1;
                    END

                END






                CASE 5000:
                    //DEAD
                    Lomming[counter].x=-5000;
                    Lomming[counter].y=-5000;
                END
                CASE 5001:
                    //Saved
                    Lomming[counter].x=-5000;
                    Lomming[counter].y=-5000;
                END
            END

            //Die Explosion durchsehen
            IF(Lomming[counter].Explode>0)
                Lomming[counter].Explode++;
                map_put(0,1,(Lomming[counter].Explode/24)+90,Lomming[counter].x,Lomming[counter].y-17);
            END
            IF(Lomming[counter].Explode>117)
                Lomming[counter].Action=5000;
                Lomming[counter].explode=0;
                map_put(0,2,83,Lomming[counter].x,Lomming[counter].y);
            END

            IF(fget_dist(Exitx,Exity,Lomming[counter].x,Lomming[counter].y)<15)
                Lomming[counter].Action=5001;
            END




        END
        IF(Counterc==speedup-1)
            map_put(0,1,2,320,95);
        END


      END      //THAT WAS THE TURBO BOOOOOST

        LOOP
            FRAME;
            IF(Pause==0)
                BREAK;
            END
        END
        map_put(0,1,2,320,95);

    END
END







PROCESS Shower()

PRIVATE
    bla; //Not used but used

BEGIN
    graph=1;
    x=320;
    y=95;
    LOOP
        IF(key(_Left) AND Levelxpos<0)
            Levelxpos+=4;
        END
        IF(key(_Right) AND Levelxpos>-320)
            Levelxpos-=4;
        END


        x=Levelxpos+320;
        FRAME;
    END
END



PROCESS Items()

BEGIN
    graph=20;
    x=160;
    y=215;
    LOOP
        FRAME;
    END
END



PROCESS Cursor()

PRIVATE
    counter;
    dist;
    shortest;
    shortestdist;
    Timecounter;
    AntiFastDig;
    AntiFastO;
    AntiFastP;

BEGIN
    graph=10;
    z=-10;
    LOOP
        x=Mouse.x;
        y=Mouse.y;

        dist=400;
        shortest=-1;
        shortestdist=500;

        FOR(counter=0; Counter<=LommingsNumber; counter++)
            dist=fget_dist(x-Levelxpos,y,Lomming[counter].x,Lomming[counter].y);
            IF(dist<shortestdist)
                shortestdist=dist;
                shortest=counter;
            END

        END
        IF(shortestdist<8)
            graph=11;
        END

        IF(mouse.left)
            IF(shortest!=-1 AND Shortestdist<8)
                IF(ClimbNR>0 AND Mouseaction==1 AND Lomming[shortest].climb!=1)
                    ClimbNR--;
                    Lomming[shortest].climb=1;
                END
                IF(UmbrellaNr>0 AND Mouseaction==2 AND Lomming[shortest].Umbrella!=1)
                    UmbrellaNr--;
                    Lomming[shortest].Umbrella=1;
                END
                IF(JumpNr>0 AND Mouseaction==3 AND Lomming[shortest].Jump!=1)
                    JumpNr--;
                    Lomming[shortest].Jump=1;
                END
                IF(ExplodeNR>0 AND Mouseaction==4 AND Lomming[shortest].Explode==0)
                    ExplodeNR--;
                    Lomming[shortest].explode=1;
                END
                IF(Antifastdig==0 AND LadderNr>0 AND Mouseaction==5 AND (Lomming[shortest].action<15 OR (Lomming[shortest].action>63 AND Lomming[shortest].action<142 AND Lomming[shortest].fallen>15)))
                    LadderNr--;
                    Lomming[shortest].action=64;
                    Antifastdig=1;
                END
                IF(StopperNR>0 AND Mouseaction==6 AND Antifastdig!=1)
                    IF(Lomming[shortest].action<15 OR (Lomming[shortest].action>63 AND Lomming[shortest].action<142))
                        StopperNR--;
                        Lomming[shortest].action=142;
                        Antifastdig=1;
                    ELSE
                        IF(Lomming[shortest].action>141 AND Lomming[shortest].action<162)
                            StopperNR--;
                            Lomming[shortest].action=1;
                            Antifastdig=1;
                        END
                    END
                END
                IF(DigFrontNr>0 AND Mouseaction==7 AND Antifastdig!=1)
                    IF(Lomming[shortest].action<15 OR (Lomming[shortest].action>63 AND Lomming[shortest].action<142))
                        IF(NOT(Lomming[shortest].action>=82 AND Lomming[shortest].action<=101))
                            DigFrontNr--;
                            Lomming[shortest].action=82;
                            Antifastdig=1;
                        END
                    END
                END
                IF(DigDiagonalNr>0 AND Mouseaction==8 AND Antifastdig!=1)
                    IF(Lomming[shortest].action<15 OR (Lomming[shortest].action>63 AND Lomming[shortest].action<142))
                        IF(NOT(Lomming[shortest].action>=102 AND Lomming[shortest].action<=121))
                            DigDiagonalNr--;
                            Lomming[shortest].action=102;
                            Antifastdig=1;
                        END
                    END
                END
                IF(DigDownNr>0 AND Mouseaction==9 AND Antifastdig!=1)
                    IF(Lomming[shortest].action<15 OR (Lomming[shortest].action>63 AND Lomming[shortest].action<142))
                        IF(NOT(Lomming[shortest].action>=122 AND Lomming[shortest].action<=141))
                            DigDownNr--;
                            Lomming[shortest].action=122;
                            Antifastdig=1;
                        END
                    END
                END
            END
        END

/*
   64- 81=Ladder
   82-101=Dig in the Earth >
  102-121=Dig in the Earth \
  122-141=Dig in the Earth V */



        IF(mouse.right)
            IF(shortest!=-1 AND Shortestdist<8)
                IF(JumpNr>0 AND Mouseaction==3 AND (Lomming[shortest].action<15 OR (Lomming[shortest].action>81 AND Lomming[shortest].action<142)))
                    JumpNr--;
                    Lomming[shortest].action=41;
                END
                IF(StopperNR>0 AND Mouseaction==6 AND Antifastdig!=1)
                    StopperNR--;
                    Lomming[shortest].dir=Lomming[shortest].dir*-1;
                    Antifastdig=1;
                END
            END
        END

        IF(key(_1))
            Mouseaction=1;
        END
        IF(key(_2))
            Mouseaction=2;
        END
        IF(key(_3))
            Mouseaction=3;
        END
        IF(key(_4))
            Mouseaction=4;
        END
        IF(key(_5))
            Mouseaction=5;
        END
        IF(key(_6))
            Mouseaction=6;
        END
        IF(key(_7))
            Mouseaction=7;
        END
        IF(key(_8))
            Mouseaction=8;
        END
        IF(key(_9))
            Mouseaction=9;
        END
        IF(key(_Backspace) AND Killcount==0)
            Killcount=1;
        END
        IF(Killcount!=0)
            IF((Killcount/4)<=Lommingsnumber)
                Lomming[Killcount/4].explode=1;
                Killcount++;
                lommingsemerge=4;
            ELSE
                Killcount=0;
            END
        END
        IF(key(_plus) AND lommingsemerge<lommingsemergemax)
            lommingsemerge++;
        END
        IF(key(_minus) AND lommingsemerge>4)
            lommingsemerge--;
        END


        IF(key(_O))
            IF(AntifastO==0)
                IF(Speedup==0)
                    speedup=4;
                ELSE
                    speedup=0;
                END
                AntifastO=1;
            END
        ELSE
            AntifastO=0;
        END

        IF(key(_P))
            IF(AntifastP==0)
                IF(Pause==0)
                    Pause=1;
                ELSE
                    Pause=0;
                END
                AntifastP=1;
            END
        ELSE
            AntifastP=0;
        END


        IF(Pause==0)
            Timecounter+=Speedup+1;
        END

        IF(Timecounter>24)
            Time--;
            Timecounter-=25;
        END




        IF(NOT mouse.right AND NOT mouse.left)
            Antifastdig=0;
        END

        FRAME;
        graph=10;

    END
END














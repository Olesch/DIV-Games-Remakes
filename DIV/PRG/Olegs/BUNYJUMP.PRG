
PROGRAM BunnyJumpers;




GLOBAL


LOCAL
    Kontakt;      //0:Nichts
                  //1:X_speed=-x_speed
                  //
                  //
                  //
                  //


BEGIN
    load_fpg("Olegs\BunyJump.fpg");  // Loads graphics' file
    //load_fnt("Olegs\Mini2.fnt");  // Loads font type

    set_mode(m1024x768);               // Sets video mode to 640x480
    set_fps(24,0);                    // Number of frames per second
    put_screen(0,1);                  // Puts background screen

    /*FROM x=0 TO 10;
        Bunny(rand(100,924),rand(100,668));
    END*/

    Bunny(418,160,_up,_down,_left,_right);
    Bunny(448,190,_w,_s,_a,_d);


    LOOP
        FRAME;
    END


END



PROCESS Bunny(x,y,up,down,left,right)

PRIVATE
    x_speed;
    y_speed;
    counter;
    Standing;
    Treffer;

BEGIN
    Graph=2;
    LOOP
        Standing=0;
        counter=0;
        REPEAT
            IF(y_speed>0)
                y++;
            END
            IF(y_speed<0)
                y--;
            END
            counter++;


            IF(map_get_pixel(0,1,x,y)==22 AND y_speed>-4)
                y--;
                y_speed=0;
                Standing=1;
            END
            IF(map_get_pixel(0,1,x,y)==41)
                y++;
                y_speed=-y_speed;
            END





            WHILE(Treffer=get_dist(TYPE Bunny))
                IF(Treffer<15)
                IF(abs(x-TREFFER.x)>abs(y-TREFFER.y)*2)
                    //SEITLICHER CRASH
                    x_speed=-x_speed;
                    TREFFER.Kontakt=1;
                    Treffer.x+=get_distx(get_angle(Treffer),3);
                    //treffer.y+=get_disty(get_angle(Treffer),3);

                    x-=get_distx(get_angle(treffer),3);
                    //y-=get_disty(get_angle(treffer),3);


                ELSE
                    IF(y<treffer.y)
                        treffer.x=100;
                        treffer.y=100;
                    END
                    //TODESCRASH

                END
                END

            END






        UNTIL (counter>abs(y_speed/2))










        counter=0;
        REPEAT
            IF(x_speed>0)
                x++;
            END
            IF(x_speed<0)
                x--;
            END
            counter++;


            IF(map_get_pixel(0,1,x,y)==54)
                x--;
                x_speed=-x_speed;
            END

            IF(map_get_pixel(0,1,x,y)==73)
                x++;
                x_speed=-x_speed;
            END

            IF(TREFFER=Collision (TYPE Bunny))
                IF(abs(x-TREFFER.x)>abs(y-TREFFER.y))
                    //SEITLICHER CRASH
                    x_speed=-x_speed;
                    TREFFER.Kontakt=1;


                ELSE
                    //TODESCRASH

                END


            END



        UNTIL (counter>abs(x_speed) OR counter>4)



        y_speed++;        //Gravitation




        IF(Key(up) and Standing==1)
            y_speed=-25;
        END


        IF(Key(left) AND x_speed>-6 AND Standing==1)
            x_speed--;
        END
        IF(Key(right) AND x_speed<6 AND Standing==1)
            x_speed++;
        END

        IF((NOT key(right)) AND (NOT key(left)) AND Standing==1)
            IF(x_speed>0)
                x_speed--;
            END
            IF(x_speed<0)
                x_speed++;
            END
        END


        IF(Kontakt==1)
            x_speed=-x_speed;
        END
        Kontakt=0;


        FRAME;
    END
END
















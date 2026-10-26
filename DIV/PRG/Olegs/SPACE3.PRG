//-------------------------------------------------------------------
// TITLE:   Siedler
// AUTHOR:  Oleg Yuschuk
// DATE:    25/1/2005
//-------------------------------------------------------------------





/*

StartMapObjects:40=Baum


StartMapTerrain:40=Gras
                55=Wasser
                120=Lehm/Ufer











*/

PROGRAM Siedler;

GLOBAL

BEGIN
    load_fpg("Olegs\Siedler.fpg");
    //load_fnt("Olegs\Space.fnt");

    set_mode(m640x480);
    set_fps(24,0);
    define_Region(1,1,1,640,480);
    cursor(320,240,1);
    start_scroll(0,0,2,0,1,0);
    draw_terrain();
    WaterAnim();
END






PROCESS cursor(x,y,graph)
BEGIN
    scroll[0].camera=id;
    ctype=c_scroll;

    LOOP
        x+=mouse.x-320;
        y+=mouse.y-240;
        mouse.x=320;
        mouse.y=240;

        new_coordinates();
        FRAME;

    END
END








PROCESS WaterAnim()
BEGIN
    LOOP
        Roll_Palette(253,3,1);
        refresh_scroll(0);
        FRAME(500);
    END
END








PROCESS Draw_terrain()

PRIVATE
    Counterx;
    Countery;

BEGIN
    LOOP


        SWITCH(Map_get_pixel(0,10,counterx,countery))

            CASE 40:  //Gras
                map_put(0,2,rand(3,7),Counterx*10,Countery*10);
            END


            CASE 55:  //Wasser
                map_put(0,2,rand(15,17),Counterx*10,Countery*10);
            END

            CASE 120:  //Lehm/Ufer
                map_put(0,2,rand(15,17),Counterx*10,Countery*10);
            END

            DEFAULT:
            END

        END

        Counterx++;
        IF(Counterx>129)
            Counterx=0;
            Countery++;
        END
        IF(Countery>97)
            BREAK;
        END


    END
    refresh_scroll(0);
END
































PROCESS new_coordinates()
BEGIN
    // If it gets out by the left, forces it to appear by the right
    // subtracting screen's wide
    IF (father.x<0) father.x=0; END
    // If it gets out by the right, forces it to appear by the left
    IF (father.x>1280) father.x=1280; END
    // If it gets out by the top, forces it to appear by the bottom
    IF (father.y<-0) father.y=0; END
    // If it gets out by the bottom, forces it to appear by the top
    IF (father.y>960) father.y=960; END
END

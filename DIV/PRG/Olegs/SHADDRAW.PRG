PROGRAM Shaddraw;

GLOBAL
    graphic1;
    //width1;
    //heigth1;
    //xcenter1;
    //ycenter1;


BEGIN
    Set_mode(m640x480);
    graphic1=load_map("Pic1.map");
    Showit();
    //width1=Graphic_info(0,graphic1,g_wide);
    //heigth1=Graphic_info(0,graphic1,g_height);
    //xcenter1=Graphic_info(0,graphic1,g_x_center);
    //ycenter1=Graphic_info(0,graphic1,g_y_center);


END


PROCESS Showit()

BEGIN
    Graph=graphic1;
    x=320;
    y=240;

    LOOP
        FRAME;
    END
END























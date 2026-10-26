





Program Mandelbrot;

GLOBAL
  zoom=100;
  xshi=0;
  yshi=0;
  stop;
  malen=1;

PRIVATE
  xpos;
  ypos;
  counter;
  over;

BEGIN
  load_pal("Mandbrot.pal");
  graph=load_map("olegs\mandbrot.map");
  over=load_map("olegs\over.map");
  x=512; y=384;
  set_mode(m1024x768);
  LOOP

    IF(Key(_F1))
      Draw(x,y,1,1);
      /*FOR(x=-512; x<512; x++)
        FOR(y=-384; y<384; y++)
          put_pixel(x+512,y+384,Rechne(x+xshi,y+yshi));
          counter++;
          IF(counter>30000) FRAME; counter=0; END
        END
      END*/
    END
    IF(Key(_F2))
      Draw(x,y,5,2);
    END
    IF(Key(_F3))
      Draw(x,y,10,3);
    END
    IF(Key(_F4))
      put(0,over,512,384);
    END

    IF(Key(_up))
      yshi-=100;
    END
    IF(Key(_down))
      yshi+=100;
    END
    IF(Key(_left))
      xshi-=100;
    END
    IF(Key(_right))
      xshi+=100;
    END
    IF(Key(_plus))
      zoom+=zoom/2;
      xshi+=xshi/2;
      yshi+=yshi/2;
    END
    IF(Key(_minus))
      zoom-=zoom/3;
      xshi-=xshi/3;
      yshi-=yshi/3;
    END



    IF(Key(_w))
      yshi-=100;
      Draw(x,y,5,6);
    END
    IF(Key(_s))
      yshi+=100;
      Draw(x,y,5,6);
    END
    IF(Key(_a))
      xshi-=100;
      Draw(x,y,5,6);
    END
    IF(Key(_d))
      xshi+=100;
      Draw(x,y,5,6);
    END
    IF(Key(_1))
      zoom+=zoom/2;
      xshi+=xshi/2;
      yshi+=yshi/2;
      Draw(x,y,5,6);
    END
    IF(Key(_q))
      zoom-=zoom/3;
      xshi-=xshi/3;
      yshi-=yshi/3;
      Draw(x,y,5,6);
    END

    IF(key(_3))
      malen++;
    END
    IF(key(_4) AND malen>1)
      malen--;
    END



    FRAME;
  END
  LOOP
    FRAME;
  END
END


PROCESS Rechne(rc,ic)

PRIVATE
  counter;
  anew;
  bnew;
  aold;
  bold;
  farbe;

BEGIN
  WHILE(anew*anew+bnew*bnew<4*zoom*zoom)
    aold=anew;
    bold=bnew;
    anew=(aold*aold-bold*bold)/zoom+rc;
    bnew=2*aold*bold/zoom+ic;
    counter++;
    IF(counter>=30) break; END
  END

  //farbe=(counter*malen+127*(1-malen))*8;
  return(counter*8);
END



Process Draw(x,y,stepp,divisor)

PRIVATE
  counter;

BEGIN
  IF(Stop==1)
    return();
  END
  stop=1;

  IF(divisor==1 AND stepp==1)
    FOR(x=-512; x<512; x+=1)
      FOR(y=-384; y<384; y+=1)
        put_pixel(x+512,y+384,Rechne(x+xshi,y+yshi));
        counter++;
        IF(counter>30000) FRAME; counter=0; END
      END
    END
  ELSE
    FOR(x=-512/divisor; x<512/divisor; x+=stepp)
      FOR(y=-384/divisor; y<384/divisor; y+=stepp)
        put_pixel(x+512,y+384,Rechne(x+xshi,y+yshi));
        IF(stepp>=2)
          put_pixel(x+511,y+384,Rechne(x+xshi,y+yshi));
          put_pixel(x+513,y+384,Rechne(x+xshi,y+yshi));
          put_pixel(x+512,y+385,Rechne(x+xshi,y+yshi));
          put_pixel(x+512,y+383,Rechne(x+xshi,y+yshi));
          put_pixel(x+513,y+385,Rechne(x+xshi,y+yshi));
          put_pixel(x+513,y+383,Rechne(x+xshi,y+yshi));
          put_pixel(x+511,y+385,Rechne(x+xshi,y+yshi));
          put_pixel(x+511,y+383,Rechne(x+xshi,y+yshi));
        END
        counter++;
        IF(counter>30000) FRAME; counter=0; END
      END
    END
  END

  stop=0;
END













Program Kochkurve;

CONST
  DEPTH=7;


GLOBAL
  over;


PRIVATE
  x0;
  y0;
  x1;
  y1;
  x2;
  y2;



BEGIN
  graph=load_map("olegs\mandbrot.map");
  over=load_map("olegs\over.map");
  x=512; y=384;
  set_mode(m1024x768);

  write(0,0,0,0,"1 - Sierpinski");
  write(0,0,8,0,"2 - Koch");

LOOP
  FRAME;

  IF(key(_f1) OR key(_1))
    //Init
    x0=512;
    x1=924;
    x2=100;
    y0=100;
    y1=668;
    y2=668;
    Draw_line(x0,y0,x1,y1);
    Draw_line(x1,y1,x2,y2);
    Draw_line(x2,y2,x0,y0);
    Sirpienski(x0,y0,x1,y1,x2,y2,DEPTH);
    LOOP
      FRAME;
    END

  END


  IF(key(_f2) OR key(_2))
    //Init
    x0=512;
    x1=924;
    x2=100;
    y0=100;
    y1=668;
    y2=668;
    Draw_line(x0,y0,x1,y1);
    Draw_line(x1,y1,x2,y2);
    Draw_line(x2,y2,x0,y0);
    Sirpienski(x0,y0,x1,y1,x2,y2,DEPTH);
    LOOP
      FRAME;
    END

  END


END


END




PROCESS Sirpienski(x0,y0,x1,y1,x2,y2,t)

PRIVATE
  mx0;
  my0;
  mx1;
  my1;
  mx2;
  my2;
BEGIN
  IF(t==0) return; END


  //Mittelpunkte rechnen
  mx0=(x0+x1)/2;
  mx1=(x1+x2)/2;
  mx2=(x2+x0)/2;
  my0=(y0+y1)/2;
  my1=(y1+y2)/2;
  my2=(y2+y0)/2;

  //Mittelpunkt verbinden
  Draw_line(mx0,my0,mx1,my1);
  Draw_line(mx1,my1,mx2,my2);
  Draw_line(mx2,my2,mx0,my0);

  Sirpienski(x0,y0,mx0,my0,mx2,my2,t-1);
  Sirpienski(x1,y1,mx1,my1,mx0,my0,t-1);
  Sirpienski(x2,y2,mx2,my2,mx1,my1,t-1);


END


PROCESS Koch(x0,y0,x4,y4,t)

PRIVATE
  x1;
  y1;
  x2;
  y2;
  x3;
  y3;

BEGIN
  IF(t==0)
    draw_line(x0,y0,x4,y4);
  END

  //Punkte errechnen
  x1=(x4+2*x0)/3;
  y1=(y4+2*y0)/3;


  x3=(2*x4+x0)/3;
  y3=(2*y4+y0)/3;

  x3=(2*x4+x0)/3;
  y3=(2*y4+y0)/3;





END














PROCESS Draw_Line(x0,y0,x1,y1)

PRIVATE
  counter;
  width;
  heigh;

BEGIN
  x=x0;
  y=y0;
  IF((width=abs(x0-x1))>(heigh=abs(y0-y1)))
    //Horizontal
    counter=width/2;
    put_pixel(x,y,15);
    LOOP
      IF(x>x1) x--; ELSE x++; END
      counter+=heigh;
      IF(counter>=width)
        counter-=width;
        IF(y>y1) y--; ELSE y++; END
      END
      put_pixel(x,y,15);
      IF(x==x1) BREAK; END

    END
  ELSE
    //Vertikal
    counter=heigh/2;
    put_pixel(x,y,15);
    LOOP
      IF(y>y1) y--; ELSE y++; END
      counter+=width;
      IF(counter>=heigh)
        counter-=heigh;
        IF(x>x1) x--; ELSE x++; END
      END
      put_pixel(x,y,15);
      IF(y==y1) BREAK; END

    END
  END
END









PROCESS Draw_lineb(x0,y0,x1,y1)

PRIVATE
  m;
  c;
  i;
  Accuracy=100;


BEGIN
//    i=x0; x0=x1; x1=i;



  IF(x0==x1)
    //F(Y) nehmen
    m=((x0-x1)*Accuracy)/(y0-y1);
    c=((x1*y0-y1*x0)*Accuracy)/(y0-y1);
    IF(y0<y1)
      FOR(i=y0; i<=y1; i++)
        put_pixel((m*i+c)/Accuracy,i,15);
      END
    ELSE
      FOR(i=y0; i>=y1; i--)
        put_pixel((m*i+c)/Accuracy,i,15);
      END
    END
    return;
  END

  IF(y0==y1)
    //F(X) nehmen
    m=((y0-y1)*Accuracy)/(x0-x1);
    c=((y1*x0-x1*y0)*Accuracy)/(x0-x1);
    IF(x0<x1)
      FOR(i=x0; i<=x1; i++)
        put_pixel(i,(m*i+c)/Accuracy,15);
      END
    ELSE
      FOR(i=x0; i>=x1; i--)
        put_pixel(i,(m*i+c)/Accuracy,15);
      END
    END
    return;
  END

  m=((y0-y1)*100)/(x0-x1);
  IF(m>-Accuracy AND m<Accuracy)
    //F(X) nehmen
    m=((y0-y1)*Accuracy)/(x0-x1);
    c=((y1*x0-x1*y0)*Accuracy)/(x0-x1);
    IF(x0<x1)
      FOR(i=x0; i<=x1; i++)
        put_pixel(i,(m*i+c)/Accuracy,15);
      END
    ELSE
      FOR(i=x0; i>=x1; i--)
        put_pixel(i,(m*i+c)/Accuracy,15);
      END
    END

  ELSE
    //F(Y) nehmen
    m=((x0-x1)*Accuracy)/(y0-y1);
    c=((x1*y0-y1*x0)*Accuracy)/(y0-y1);
    IF(y0<y1)
      FOR(i=y0; i<=y1; i++)
        put_pixel((m*i+c)/Accuracy,i,15);
      END
    ELSE
      FOR(i=y0; i>=y1; i--)
        put_pixel((m*i+c)/Accuracy,i,15);
      END
    END
  END





END









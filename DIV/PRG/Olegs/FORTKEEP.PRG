






PROGRAM Fort;

CONST
  E_NORMAL=1;
  E_ZIGZAG=2;

GLOBAL
  FESTUNG_ID;

LOCAL
  damage;

BEGIN
  load_fpg("olegs\Fortkeep.fpg");
  set_fps(24,0);
  set_mode(m800x600);
  FESTUNG_ID=Festung();
  Cursor();
  LOOP
    Enemy(E_NORMAL);
    Enemy(E_ZIGZAG);
    FRAME(1000);
  END
END



PROCESS Festung()

PRIVATE
  HIT;

BEGIN
  graph=1;
  x=400;
  y=300;
  LOOP
    WHILE(HIT=collision(TYPE enemy))
      damage++;
      signal(hit,s_kill);
    END

    FRAME;
  END
END



PROCESS Cursor()

PRIVATE
  AFC;

BEGIN
  graph=2;
  LOOP
    x=mouse.x;
    y=mouse.y;
    IF(mouse.left AND AFC==0) AFC=1; Schuss(get_angle(FESTUNG_ID)+pi); END
    IF(NOT mouse.left) AFC=0; END

    FRAME;
  END
END


PROCESS Schuss(angle)

PRIVATE
  hit;

BEGIN
  graph=3;
  resolution=100;
  x=400*100;
  y=300*100;


  WHILE (NOT out_region(id,0))
    advance(1600);

    IF(HIT=collision(TYPE enemy))
      HIT.damage++;
      RETURN();
    END
    FRAME;
  END



END


PROCESS Enemy(art)

PRIVATE
  countera;


BEGIN

  //Koordinaten
  IF(rand(0,3)==0)
    x=-20;
    y=rand(0,600);
  ELSE IF(rand(0,2)==0)
    x=820;
    y=rand(0,600);
  ELSE IF(rand(0,1)==0)
    y=-20;
    x=rand(0,800);
  ELSE
    y=620;
    x=rand(0,800);
  END
  END
  END

  IF(art==E_NORMAL)
    graph=10;
    LOOP
      angle=get_angle(FESTUNG_ID);
      advance(6);
      //advance(get_dist(FESTUNG_ID)/5+1);
      size=(get_dist(Festung_ID)/3);
      IF(damage>1)
        RETURN();
      END
      FRAME;
    END
  END




  IF(art==E_ZIGZAG)
    graph=11;
    LOOP
      IF(Countera>70)
        angle=get_angle(FESTUNG_ID)+rand(-30000,30000);
        Countera=0;
      END
      Countera+=rand(0,2);
      advance(6);
      IF(damage>1)
        RETURN();
      END
      FRAME;
    END
  END



END






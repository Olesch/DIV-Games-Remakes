








PROGRAM Viki1;

PRIVATE
  i;


BEGIN
  set_mode(m320x240);
  load_fpg("olegs\viki1.fpg");
  LOOP
    x=rand(0,319);
    y=rand(0,239);
    put_pixel(x,y,15);
    i++;
    IF(i>200)
      BREAK;
    END
  END

  ship(1);
  LOOP
    FRAME;
  END
END

PROCESS ship(player)

PRIVATE
  acc;


BEGIN
  IF(player==1)
    x=160;
    y=220;
    graph=1;
    LOOP

      IF(key(_left))
        acc--;
      END
      IF(key(_right))
        acc++;
      END
      x+=acc/2;
      IF(acc>9) acc=9; END
      IF(acc<-9) acc=-9; END

      IF(x<10) x=10; acc=-acc; END
      IF(x>309) x=309; acc=-acc; END


      FRAME;
    END
  ELSE
    LOOP
      FRAME;
    END
  END
END














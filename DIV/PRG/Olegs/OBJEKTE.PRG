/*Gib ihm die Nummer der Karte, und er malt
alle nicht durchsichtigen Felder an. Die
Gewuenschten Farben muessen selbst ein-
gestellt werden genauso die Groesse
des Bildes*/

PROCESS Graszeichner(GraphNumber)
PRIVATE


BEGIN
  LOOP
    IF(map_get_pixel(0,Graphnumber,x,y)!=0);
      map_put_pixel(0,GraphNumber,x,y,rand(32,35));
    END
    x++;
    IF(x>1024)
      x=0;
      y++;
    END
    IF(y>768)
      RETURN;
    END

  END
END











// Effekte


PROGRAM Effekte;

BEGIN
  set_mode(m1024x768);
  set_fps(30,0);
  load_fpg("olegs\Effekte.fpg");
  x=512;
  y=384;
  graph=1;
  LOOP
    IF(KEY(_A))
      Charge1_spawn(x,y,10,200);
    END

    FRAME;
  END
END



PROCESS Charge1_spawn(x,y,strength,size)

PRIVATE
  g_ini=10;   //Die Nummer des ersten Bildes, alle anderen folgen!
  vel=1;      //Ablaufgeschwindigkeit
  STRUCT g[10];       //Maximale Strength
    graph;
    size;
    angle;
  END
  effemap;    //Die effektmap
  i;
  wait;
  kill;

BEGIN
  z=-50;
  LOOP
    angle+=10000;
    graph=load_map("olegs\efektmap.map");

    //Effekte Inititalisieren
    wait++;
    IF(wait%vel==0 AND wait/vel<=strength AND wait/vel<=10)
      g[wait/vel].graph=g_ini;
      g[wait/vel].angle=rand(-pi,pi);
      g[wait/vel].size=99;
    END

    //Effekte berechnen
    FOR(i=0; i<=10; i++)
      IF(g[i].graph==g_ini)
        IF(g[i].size<100) g[i].size+=1;
        ELSE g[i].graph++; g[i].size=99; END
      END
      IF(g[i].graph==g_ini+1)
        IF(g[i].size<100) g[i].size+=1;
        ELSE g[i].graph++; g[i].size=100; END
      END
      IF(g[i].graph==g_ini+2)
        IF(g[i].size>0) g[i].size-=20;
        ELSE
          IF(i==strength OR i==10)
            kill=1;
          END
        END
      END
    END

    //Effekte malen
    FOR(i=0; i<=10; i++)
      IF(g[i].graph!=0)
        map_xput(0,graph,g[i].graph,100,100,g[i].angle,g[i].size,0);
      END
    END

    //zeigen
    FRAME;

    //Rausladen
    unload_map(graph);

    IF(kill==1) BREAK; END

  END
END

































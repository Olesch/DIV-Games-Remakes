



PROGRAM Translater;

GLOBAL
    Levelgraph;
    Availmaps[]=900,902,904,912,914,924,926;
    Counter;

    STRUCT Map[35]
        STRUCT Layer[1]
            STRUCT Xpos[39]
                Ypos[29];
            END
        END
    END


BEGIN
    load_fpg("Olegs\Castle.fpg");

    FOR (x=0; x<=39; x++)
        FOR (y=0; y<=29; y++)
            FOR (counter=0; counter<=6; counter++)
                Levelgraph=Availmaps[counter];
                Map[(Levelgraph-900)/2].Layer[0].Xpos[x].Ypos[y]=Map_get_pixel(0,Levelgraph,x,y);
                Map[(Levelgraph-900)/2].Layer[1].Xpos[x].Ypos[y]=Map_get_pixel(0,Levelgraph+1,x,y);
            END
        END
    END
    save("saves/Level1.dat",OFFSET map,sizeof(map));
    debug;
END






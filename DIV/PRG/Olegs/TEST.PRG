PROGRAM Test;

PRIVATE
    number;
    a;
    b;
    c;
    text[]="-5","-4","-3","-2","-1","0","1","2","3","4","5";

BEGIN
    /*FOR(x=-5; x<=5; x++)
        write(0,(x*10)+160,100,4,text[x+5]);
    END
    LOOP
        FRAME;
    END*/
    write_int(0,160,100,4, OFFSET number);
    write_int(0,120,120,4, OFFSET c);
    write_int(0,160,120,4, OFFSET b);
    write_int(0,200,120,4, OFFSET a);

    LOOP
        number=rand(0,999);
        a=number mod 10;
        b=((number-(number mod 10)) mod 100)/10;
        c=(number-((number-(number mod 10)) mod 100)-(number mod 10))/100;
        FRAME(2400);
    END

END









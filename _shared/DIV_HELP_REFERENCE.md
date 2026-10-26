# DIV Games Studio 1 - original help (language & functions)

Auto-extracted from DIV\HELP\HELP.DIV by _shared/tools/div_help_extract.py.
Each topic is "## [N] title". Sample programs are in ```div code blocks.

## [100] abs()

**abs(**<expression>**)**

**Returns:**

The **absolute value** of the expression.

**Description:**

Calculates the absolute value of the expression passed as a parameter. That is to say, if the result of the expression is negative, it will change its sign; if it is positive, it will not change it.

Sample program:
```div
PROGRAM example_abs;

GLOBAL
    values[15];
    n;

BEGIN
    FROM n=0 TO 15;
        values[n]=rand(-1000, 1000);
        write_int(0, 0, n*10,0, offset values[n]);
    END
    write(0, 0, 192, 0, "Press [SPACE] to execute the abs function()");
    LOOP
        IF (key(_space))
            FROM n=0 TO 15;

                values[n] = abs(values[n]); // We calculate the absolute value

            END
        END
        FRAME;
    END
END
```

This program will display a list of either positive or negative values on the screen. When the space bar is pressed, it will apply
the **abs()** function to all these values, which will all become positive.

---
See: Expression

## [101] advance()

**advance(**<distance>**)**

**Description:**

Advances the process in its angle (the one shown by the angle local variable ) as many points as  the **expression** (distance) passed as a parameter shows.

The distance can also be a negative number. In that case, the graphic
of the process will move forward (its coordinates x and y) in the direction opposite to its angle.

Sample program:
```div
PROGRAM example_advance;
BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    graph=101;
    x=160;
    y=100;
    write(0, 0, 0, 0, "Use the cursors to change direction.");
    LOOP
        IF (key(_right)) angle-=10000; END
        IF (key(_left)) angle+=10000; END

        advance(2); // We advance the process two points

        FRAME;
    END
END
```

This example will draw a triangle on the screen that will advance in the direction specified in the predefined angle local variable by using this function.

Keep in mind that the angle is specified in degree thousandths.

It will be possible to change the angle variable by using the cursor keys (adding and subtracting 10000, that is to say, 10 degrees).

---

This function is always equivalent to the two following statements:

  **x+=get_distx(angle,** <distance>**);**  
  **y+=get_disty(angle,** <distance>**);**  

That is to say, this function only modifies the coordinates of the process. It is possible to use the two previous statements when the aim is to advance the process in an angle different from the one shown by its angle variable. It will be useful when the aim is to make the graphic of the process advance in a direction without rotating.

For instance, to make the process advance 8 points in a direction (that could be obtained in a private variable like **angle2**) but rotated to
another direction, (the one showed in angle), the following statements would be used:

  **x+=get_distx(angle2, 8);**  
  **y+=get_disty(angle2, 8);**  

---
See: Use of angles in the language - get_distx() - get_disty()

## [102] change_sound()

**change_sound(**<channel>**,** <volume>**,** <frequency>**)**

**Description:**

To use this function is indispensable to have a sound card 
installed in the computer 100% compatible with the **Sound Blaster** (tm) or **Gravis Ultrasound** (tm) cards.

The use of this function only makes sense after using the sound() function, used to emit sounds.

**Change_sound()** modifies a sound that is being played through one of the  **channels**, adjusting its **volume** and its **frequency** once again.

The **channel** is the **channel code** returned by the sound()  function when it is called. The 16 channels may even sound at the same time, with the same sound or with different sounds. Therefore, every time that a sound is emitted it will possibly be emitted through a different channel.

Every **channel** has its volume and frequency levels established at all times.

The **volume** is a value between **0** (minimum volume) and **512** (maximum volume) that determines the power with which the sound of that channel will be heard.

The **frequency** is a value that affects the speed at which the sound
is heard through the channel. That is to say, it controls the bass and treble of the sound. This value ranges between **0** (bass) and **512** (treble).

Sample program:
```div
PROGRAM example_change_sound;

PRIVATE
    frequency=256;     // Average value (0..512)
    volume=256;        // Average value (0..512)

    id_sound;
    channel;

BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);

    id_sound = load_pcm("help.pcm", 1);
    channel = sound(id_sound, volume, frequency);

    write(0, 0, 0, 0, "Press right or left to change the frequency.");
    write_int(0, 0, 10, 0, offset frequency);
    write(0, 0, 20, 0, "Press up or down to change the volume.");
    write_int(0, 0, 30, 0, offset volume);
    LOOP

        // Change the sound
        change_sound(channel, volume, frequency);

        IF (key(_right)) frequency++; END
        IF (key(_left)) frequency--; END
        IF (key(_up)) volume++; END
        IF (key(_down)) volume--; END
        FRAME;
    END

END
```

In the example, a sound (included in the 
**help.pcm** file) is loaded and emitted. Inside the main loop of the program,
the frequency and the volume of this sound are changed through the function **change_sound()**. To modify these values, use the cursors' keys.

---
See: load_pcm() - sound() - unload_pcm() - STRUCT setup

## [103] clear_screen()

**clear_screen()**

**Description:**

Clears the screen background, that is to say, the graphics that would be drawn on it with the put(), xput(), put_pixel() and put_screen() functions.

Sample program:
```div
PROGRAM example_clear_screen;
BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    write(0, 0, 0, 0, "Press [SPACE] to clear the screen.");
    write(0, 0, 10, 0, "Press [ENTER] to display it again.");
    graph=100;
    x=160;
    y=100;
    LOOP
        IF (key (_space))

            clear_screen(); // Clear the graphic on the screen background

        END
        IF (key (_enter)) put_screen(0, 1); END
        FRAME;
    END
END
```

In the example, a background screen is displayed with the put_screen() function. By pressing the space bar, this screen is cleared.

By pressing the **Enter** key, the background screen is displayed again.

It can be noticed how the graphic of the process (a ball that appears 
at the center) does not disappear on using the **clear_screen()** function, because the latter only clears the screen background.

---
See: put() - xput() - put_pixel() - put_screen()

## [104] collision()

**collision(**<process type>**)**

**Returns:**

The identifying code of a process or **0**.

**Description:**

This is the function of the language **to detect collisions** between graphics.

It verifies if the current process (executed by this function) collides with one of the type showed as a parameter. That is to say, it verifies if the graphics of both processes are partially superposed, at least.

In case of collision, it will return the identifying code
of the process with which the current process is colliding. Otherwise, the function will always return **0**.

If the current process collides with several processes of the specified type, the **collision()** function will return the rest of the
identifiers in the successive calls made to it.

To obtain in this way all the identifying codes of the processes
that collide with the current one, the FRAME statement must not be used between two consecutive calls to the **collision()** statement. When a process executes a FRAME statement, this function will return all the identiying codes of collisive processes from the first one.

Something similar happens if a call to the function is executed,  specifying a different type of process. If, after that, collisions with the previous type are detected, this function will also return all the
codes from the first one.

If the aim is to obtain the identifying codes of the processes
of a specific type, even if there is no collision with them,
it is necessary to call the get_id() function.

But if the aim is to check the proximity between two processes without their graphics necessarily colliding, then
the get_dist() function will have to be used.

Sample program:
```div
PROGRAM example_collision;

PRIVATE
    id2;

BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    graph=100;
    x=160;
    y=100;
    movable_process(80, 50, 101);
    LOOP
        delete_text(all_text);
        write(0, 160, 0, 1, "Use the cursors to move the triangle");

        id2 = collision(TYPE movable_process); // The collision is detected

        IF (id2<>0)
            write(0, 160, 200, 7, "COLLISION DETECTED !");
        END
        FRAME;
    END
END

PROCESS movable_process(x, y, graph);

BEGIN
    LOOP
        IF (key(_right)) angle-=10000; END
        IF (key(_left)) angle+=10000; END
        IF (key(_up)) advance(4); END
        FRAME;
    END
END
```

In this example a ball is displayed at the center of the screen
as a graphic of the main program.
Then, a process named **movable_process** is created with the picture of a triangle that can be handled with the cursors' keys.

The main program will call the **collision()** function to verify whether 
its graphic (the circle) collides with the graphic of the process of **movable_process** type (the triangle). The result of the function is stored in the **id2** private variable of the main program. This value will be **0** when the collision does not occur and when the identifying code of the **movable_process** does occur.

The identifying codes of the processes are always odd numbers,
that in the language are evaluated as true conditions (and the even numbers correspond with false conditions ). Then, in the previous program we could have replaced the statement :

  **IF (id2<>0)** ... **END**

By the following one:

  **IF (id2)** ... **END**

For further information about it, see: Definition of a condition.

---

When the mouse pointer is being displayed in the program (assigning
the code of the corresponding graphic in the mouse structure), it is
possible to see if the pointer collides with the current process
using this function, for instance, in the following way:

  **IF (collision(TYPE mouse))**  
      // The process collides with the mouse pointer  
  **END**  

On detecting the collision with the mouse pointer, it will not be done with the whole graphic used as a pointer, but only with its main control point (number 0), usually called mouse **hotspot**.

---

This function is useful to detect collisions between graphics of the screen or of a scroll window.

It is not possible to use this function to detect collisions with
processes that have no graphic (a valid code assigned to its
graph) variable or between graphics of a mode-7 window (with its ctype variable assigned to the value c_m7).

Therefore, it is **indispensable** that both, the current process 
and the process of the specified type, have a graphic defined.

The get_dist()function must be used to detect collisions between graphics of a mode-7 window, detecting thus when the distance between the two processes is shorter than that one defined as **collision distance**.

---
See: get_id() - get_dist() - Types of processes - Ways to obtain the identifying code

## [105] convert_palette()

**convert_palette(**<file>**,** <graphic>**,** <OFFSET new_palette>**)**

**Description:**

Changes the color map of the **<graphic>** of the indicated **<file>**.

The **<**offset** new_palette>** is the address, inside the computer memory, of a 256 value table where the new order of the graphic's colors will be indicated.

If the table with the new palette is like the following one:

  new_palette[255]=0, 1, 2, 3, 4, ... , 254, 255;

then the graphic would not be transformed. If, for instance, in position 3 of the previous table (new_palette[3]) we put a 16 (instead of a 3), by calling this function with the offset of this table,
color 3 would be replaced by color 16 in the graphic.

The graphics loaded with the load_map() function will be used as if they belonged to the first file (the code 0 file).

If a process wanted to replace the colors of its graphic, it should be first necessary to create a table with the new colors order and then,
call the function with the parameters:

  **convert_palette(file, graph, **<OFFSET new_palette>**)**

A program that changes the colors of its graphic
in this way, using its predefined file and graph local variables is now shown.

Sample program:
```div
PROGRAM example_convert_palette;

PRIVATE
    new_palette[255];
    counter;

BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);

    FROM counter=1 TO 255;
        new_palette[counter]=(counter+16) MOD 256;
    END

    graph=100;
    x=160;
    y=100;

    write (0, 160, 0, 1, "Press [SPACE] to change the colors of the ball");
    LOOP
        IF (scan_code==_space)

            // We convert the palette of graphic number 100 (ball)
            convert_palette(file, graph, offset new_palette);

        END
        FRAME;
    END
END
```

At first, **a table is created with the new order of the colors**
of the palette. Color number 0 (transparent) will be not replaced by anyone
(new_palette[0] will always be equal to 0) and the rest of the colors (from 1 to 255) will be replaced by the color that is 16 positions upper in the palette
(the 1 by the 17, the 2 by the 18, etc.). The last 16 colors will be replaced 
by the first 16 ones (by running the operation **MOD 256** the values will be cut off, that is to say, 256 will become 0, 257 to 1, etc.).

Then, inside the program' s main loop, the **convert_palette()** function will be executed, so the colors of the program's graphic (a ball) will be changed every time the space bar is pressed.

---
See: load_pal() - roll_palette()

## [106] define_region()

**define_region(**<region number>**,** <x>**,** <y>**,**<width> **,**<height> **)**

**Description:**

Defines a new display region inside the screen (something similar to a window). The regions are rectangular zones of the screen inside which some specific processes, scroll or mode-7 windows will be displayed.

The **region number** must range between 1 and 31. It is possible to define up to 31 different screen regions that, later can be assigned to different processes
(establishing their region local variable at the new number) as their display window. They can also be used as a framework for a scroll or mode-7 window, indicating it in the corresponding parameter of the start_scroll() or start_mode7() functions.

The **region number 0** must not be redefined, as it will always be the entire screen, a window at the (0, 0) coordinates, of the same width and height of the screen. This is the region in which all the processes will be displayed by default, as its region local variable is always equivalent to 0 by default.

Sample program:
```div
PROGRAM example_define_region;

PRIVATE
    counter;

BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);

    define_region(1, 0, 0, 160, 200);   // We define region 1
    define_region(2, 160, 0, 160, 200); // We define region 2

    write(0, 0, 0, 0, "Region 1");
    write(0, 320, 0, 2, "Region 2");

    FROM counter=1 TO 20;
        movable_process(rand(0, 319), rand(0, 159), rand(-8, 8), rand(-8, 8), rand(1, 2));
    END
END

PROCESS movable_process(x, y, increment_x, increment_y, region);

BEGIN
    graph=100;
    LOOP
        IF (x<0 OR x>320) increment_x=-increment_x; END
        IF (y<0 OR y>200) increment_y=-increment_y; END
        x+=increment_x;
        y+=increment_y;
        FRAME;
    END
END
```

First, the two regions are defined as screen side divisions.
Then, 20 processes of the **movable_process** type are created with a loop, at random coordinates and offset, in one of the two regions.

During their execution, it can be noticed how every process is only seen in one of the two screen halves (only in its region).

---
See: out_region() - start_scroll() - start_mode7() - Region variable

## [107] delete_text()

**delete_text(**<text identifier>**)**

**Description:**

Definitively deletes a text from the screen if the **text identifier** is specified as a parameter. This identifier is a numeric code returned by the write() and write_int() functions when they are asked to write a text.

If all_text is specified as a parameter, all the texts will be deleted from the screen.

Sample program:
```div
PROGRAM example_delete_text;

PRIVATE
    text_identifier;

BEGIN
    write(0, 160, 10, 1, "Press [ENTER] to make the upper text appear.");
    LOOP
        text_identifier=write(0, 160, 0, 1, "Pulse [SPACE] to make this text disappear.");
        WHILE (NOT key(_space))
            FRAME;
        END

        delete_text(text_identifier); // We delete the text

        WHILE (NOT key(_enter))
            FRAME;
        END
    END
END
```

In the previous example, two texts are displayed on the screen. When the spacebar is pressed, one of them is deleted with the **delete_text()** function,
and when the Enter key is pressed, that text will reappear, being
displayed again with the write() function, which returns the text identifier.

---
See: write() - write_int() - move_text()

## [108] end_fli()

**end_fli()**

**Description:**

Finishes a **FLI/FLC** animation displayed on the screen and frees up the computer's memory that it was occupying.

The **FLI/FLC** animations start with the start_fli() function.

Only one animation can be loaded in the computer's memory.

Sample program:
```div
PROGRAM example_end_fli;
BEGIN
    LOOP
        start_fli("help.fli", 0, 0);
        WHILE (frame_fli()<>0)
            FRAME;
        END

        end_fli(); // We unload the animation from the memory

    END
END
```

In the example, the animation is, at first, loaded with the
start_fli() function and then, it is displayed with frame_fli()
until it finishes (when the last function returns 0). At this
moment, it is unloaded from the memory by using **end_fli()**.

The program continues to repeat this operation (loading and unloading the **FLI/FLC** animation) indefinitely.

It is not necessary to wait for the animation to be finished in order to unload it from the memory.

---
See: start_fli() - frame_fli() - reset_fli()

## [109] exit()

**exit(**<message>**,** <return code>**)**

**Description:**

The game finishes by killing all the processes immediately and
going back to the operative system (or to the DIV environment) with a **message** and a **numeric code** (the one indicated in the expression of the second parameter).

The message is a text in inverted commas that will appear as a farewell message for the player when the game is over.

The **return code** is valid to use programs external to DIV Games
Studio (such as BAT batch processing files), to determine the action that must be performed after the game has been executed.

When the **exit()** function is used, it is not necessary to have previously unloaded any resource, such as files, maps, sounds, etc., since the system
automatically finishes all the resources.

Sample program:
```div
PROGRAM example_exit;
BEGIN
    write(0, 160, 0, 1, "Press [SPACE] to finish the program.");
    LOOP
        IF (key (_space))
            fade_off();

            exit("Thanks for using me!", 0); // We exit the program

        END
        FRAME;
    END
END
```

In this example, a message is displayed, then waiting for the spacebar to be pressed in order to exit the program with the **exit()** function.

The use of the fade_off() function to fade the screen off is not
necessary.

---

All the programs will stop running if the **[ESC]+[CONTROL]** key combination is
pressed at any moment. This operation is equivalent to forcing the execution of the **exit()** function, but without displaying any message and with the return code 0.

---
See: let_me_alone() - fade_off()

## [110] fade()

**fade(**<% red>**,** <% green>**,** <% blue>**,** <speed>**)**

**Description:**

Starts a fading of the game's palette colors until the display percentages (from 0% to 200%) of the **red**, **green** and **blue** components, shown as parameters, are obtained.

The last parameter indicates the speed at which the colors' fading will be performed. It is normally defined by a number, from 1 (very slowly) to 10 (very quickly).

If a number bigger than 64 or equal to it is indicated as speed, the fading will be performed instantaneously.

The fading will gradually be performed in the successive displays of the game (in the following frames).

If the three components are set at 0, a fading to black is carried out. If they are set at 200, a fading to white will be carried out. Finally, the original colors of the game palette will be recovered if the components are set at 100.

A value less than 100 in a component will fade its color, whereas a value higher than 100 will saturate the color.

Keep in mind that the fading is not carried out by executing the **fade()** function, but it is carried out in the following FRAME statements. While a fading is carried out, the predefined fading global variable will be equivalent to **true** (an odd number that, in this case, will be 1) and when the fading is over (finally obtaining the specified color display values), this variable will become equivalent to **false** (an even number, number 0).

Sample program:
```div
PROGRAM example_fade;
BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    write (0, 0, 0, 0, "Press [SPACE] to produce the effects.");
    LOOP
        IF (NOT fading AND key(_space))

            fade(rand(0, 200), rand(0, 200), rand(0, 200), 5);

        END
        FRAME;
    END
END
```

In the example, a background screen is loaded and a message is displayed. Then, every time that the spacebar is pressed and if a fading is not taking place (**IF (NOT fading ...**), a fading will start with the **fade()** function with the three color components chosen at random between 0% and 200% (with the rand() function) and at a speed of 5.

---
See: fading - fade_off() - fade_on() - load_pal()

## [111] fade_off()

**fade_off()**

**Description:**

Carries out a fading of the screen's colors to black. The game stops until the screen becomes completely black. Carrying out a fading to black is called **to fade the screen off**.

The fade_on() function is used to fade the screen on again (undo the fading to black).

Sample program:
```div
PROGRAM example_fade_off;
BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    write (0, 0, 0, 0, "Press [SPACE] to fade the screen off and on.");
    LOOP
        WHILE (NOT key(_space))
            FRAME;
        END

        fade_off(); // We fade the screen off

        fade_on();
    END
END
```

In this example, a background screen is displayed, waiting for the spacebar to be pressed to fade the screen off and on.

The fade() function can fulfil the same function without stopping the program or at different speeds. At the same time, it can produce other more advanced palette's effects.

---
See: fade() - fade_on()

## [112] fade_on()

**fade_on()**

**Description:**

Carries out a screen colors' fading to its natural situation. In the successive displays of the game (on reaching the FRAME statement) the colors will gradually be appearing until they are perfectly seen. This action is called **to fade the screen on**.

The fade_off() function is used to fade the screen off (to carry out a fading to black).

Sample program:
```div
PROGRAM example_fade_off;
BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    write (0, 0, 0, 0, "Press [SPACE] to fade the screen off and on.");
    LOOP
        WHILE (NOT key(_space))
            FRAME;
        END
        fade_off();

        fade_on(); // The screen is faded on

    END
END
```

In the first example, a background screen is put, waiting for the spacebar to be pressed in order to fade the screen off and on.

The fade() function can fulfil the same function at different speeds. At the same time, it can produce other more advanced palette's effects.

---

All the games automatically carry out a **fade_on()** at the beginning of the execution.

---
See: fade() - fade_off()

## [113] fget_angle()

**fget_angle(**<x0>**,** <y0>**,** <x1>**,** <y1>**)**

**Returns:**

The angle between two points.

**Description:**

Returns the angle existing from **point 0** (x0, y0) to **point 1** (x1, y1).

Keep in mind that the angle is specified in degree thousandths. The function always returns a value between** -180000** and **180000** (an angle between
-180 and 180 degrees).

Any valid numeric expression can be defined as coordinates of both points (x0, y0, x1, y1).

Sample program:
```div
PROGRAM example_fget_angle;

PRIVATE
    coordinate_x0, coordinate_y0;
    coordinate_x1, coordinate_y1;
    result;

BEGIN
    write(0, 0, 0, 0, "Point 1 coordinates");
    write(0, 0, 10, 0, "X:");
    write_int(0, 20, 10, 0, offset coordinate_x0);
    write(0, 0, 20, 0, "Y:");
    write_int(0, 20, 20, 0, offset coordinate_y0);
    write(0, 0, 40, 0, "Point 2 coordinates");
    write(0, 0, 50, 0, "X:");
    write_int(0, 20, 50, 0, offset coordinate_x1);
    write(0, 0, 60, 0, "Y:");
    write_int(0, 20, 60, 0, offset coordinate_y1);
    write(0, 0, 80, 0, "Angle from point 1 to point 2:");
    write_int(0, 0, 90, 0, offset result);
    write(0, 0, 200, 6, "Press [SPACE] to calculate other two points.");
    LOOP
        clear_screen();
        coordinate_x0=rand(0, 319);
        coordinate_y0=rand(0, 199);
        coordinate_x1=rand(0, 319);
        coordinate_y1=rand(0, 199);
        put_pixel(coordinate_x0, coordinate_y0, 22);
        put_pixel(coordinate_x1, coordinate_y1, 22);

        //We calculate the angle between the two points
        result = fget_angle(coordinate_x0, coordinate_y0, coordinate_x1, coordinate_y1);

        scan_code=0;
        WHILE (scan_code<>_space)
            FRAME;
        END
    END
END
```

In the example, after having displayed the necessary messages, the **x** and **y** coordinates of two points chosen at random are calculated and they are stored in the variables defined to this purpose, calculating the angle between these points with the **fget_angle()** function. This process will be repeated every time that the spacebar is pressed.

The get_angle() function is used to obtain the **angle from a process to another one**, instead of between two points.

The fget_dist() function is used to obtain the **distance between two points**, instead of the angle.

---
See: Use of angles in the language - get_angle() - fget_dist()

## [114] fget_dist()

**fget_dist(**<x0>**,** <y0>**,** <x1>**,** <y1>**)**

**Returns:**

The distance between two points.

**Description:**

Returns the distance existing from **point 0** (x0, y0) to **point 1** (x1, y1).

Any valid numeric expression can be specified as coordinates of both points (x0, y0, x1, y1).

Sample program:
```div
PROGRAM example_fget_dist;

PRIVATE
    coordinate_x0, coordinate_y0;
    coordinate_x1, coordinate_y1;
    result;

BEGIN
    write(0, 0, 0, 0, "Point 1 coordinates");
    write(0, 0, 10, 0, "X:");
    write_int(0, 20, 10, 0, offset coordinate_x0);
    write(0, 0, 20, 0, "Y:");
    write_int(0, 20, 20, 0, offset coordinate_y0);
    write(0, 0, 40, 0, "Point 2 coordinates");
    write(0, 0, 50, 0, "X:");
    write_int(0, 20, 50, 0, offset coordinate_x1);
    write(0, 0, 60, 0, "Y:");
    write_int(0, 20, 60, 0, offset coordinate_y1);
    write(0, 0, 80, 0, "Distance between point 1 and point 2");
    write_int(0, 0, 90, 0, offset result);
    write(0, 0, 200, 6, "Press [SPACE] to calculate another distance.");
    LOOP
        clear_screen();
        coordinate_x0=rand(0, 319);
        coordinate_y0=rand(0, 199);
        coordinate_x1=rand(0, 319);
        coordinate_y1=rand(0, 199);
        put_pixel(coordinate_x0, coordinate_y0, 22);
        put_pixel(coordinate_x1, coordinate_y1, 22);

        //We find the distance between the two points
        result = fget_dist(coordinate_x0, coordinate_y0, coordinate_x1,
coordinate_y1);

        scan_code=0;
        WHILE (scan_code<>_space)
            FRAME;
        END
    END
END
```

In the example, after having displayed the necessary messages, the coordinates of two points randomly calculated are stored in the variables defined to this purpose, obtaining the distance between them with the **fget_dist()** function. This process will be repeated every time that the spacebar is pressed.

The get_dist() function is used to obtain the **distance of a process to another one**, instead of between two points.

The fget_angle() function is used to obtain the **angle between two points**, instead of the distance.

---

This function may be used to detect collisions between processes due to their proximity, even if the collision() function is normally used to this purpose. The last function detects when two processes have their graphics superposed.

For instance, with the processes displayed inside a mode-7 window 
(see start_mode7()), the collision() function can not be used, being necessary to obtain the distance between the processes (normally withget_dist()) to verify if they collide with each other (if their distance is less than a distance already determined).

---
See: get_dist - fget_angle - collision()

## [115] frame_fli()

**frame_fli()**

**Returns:**

**True** if the animation goes on and **false** if it has finished.

**Description:**

Shows the following frame of a **FLI/FLC** animation started with
the start_fli()function. This function returns **0** if the animation has already finished.

During the program's execution, it will be possible to execute but one **FLI/FLC** animation at the same time. That is to say, it will not be possible to execute two animations simultaneously.

The animation frame will only be displayed in the following frame of the game (when the FRAME statement is reached). Therefore, if a loop is made and inside it the **frame_fli()** function (but not the FRAME statement) is called, the animation will not be displayed on the screen. 

Sample program:
```div
PROGRAM example_frame_fli;
BEGIN
    start_fli("help.fli", 0, 0);
    LOOP

        frame_fli(); // We show the following frame

        FRAME;
    END
END
```

In the example, the **FLI/FLC** animation is loaded and then it is
indefinitely executed with the **frame_fli()** function.

---
See: start_fli() - reset_fli() - end_fli()

## [116] get_angle()

**get_angle(**<identifying code>**)**

**Returns:**

The angle towards another process.

**Description:**

Returns the angle from the current process (the one that called this
function) to the process whose identifying code is passed to it as a parameter.

For further information, see ways to obtain the identifying code.

Keep in mind that the angle is specified in degree thousandths. The function always returns a value between** -180000** and **180000** (an angle between
-180 and 180 degrees).

Sample program:
```div
PROGRAM example_get_angle;

PRIVATE
    resultant_angle;
    process_identifier;

BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    graph=100;
    x=160;
    y=100;

    process_identifier = movable_process(80, 50, 101);

    write(0, 160, 200, 7, "Use the cursors to move the triangle.");
    write(0, 0, 0, 0, "Angle from the ball towards the triangle:");
    write_int(0, 0, 10, 0, offset resultant_angle);
    LOOP

        // We calculate the angle between the two processes
        resultant_angle = get_angle(process_identifier);

        FRAME;
    END
END

PROCESS movable_processl(x, y, graph);
BEGIN
    LOOP
        IF (key(_right)) angle-=10000; END
        IF (key(_left)) angle+=10000; END
        IF (key(_up)) advance(4); END
        FRAME;
    END
END
```

At the beginning, the screen background is put and the main program defines its graphic as a ball placed at the center of the screen.

Then, a process of the **movable_process** type is created, which may be controlled through the cursors. The identifying code is taken from this process.

Inside the main loop, the angle between the two processes is calculated and
continuously shown on the screen.

The fget_angle() function is used to obtain the **angle between two points**, instead of between two processes. If the identifying code of the process is stored, for instance, in a variable called **id2**, then the call to the function:   

    **get_angle(id2)**

Would be equivalent to:

    **fget_angle(x, y, id2.x, id2.y)**

Obtaining the angle from the (x, y) coordinates of the current process, to the(x, y) coordinates of the process whose identifying code is **id2**.

The get_dist() function is used to obtain the **distance to another process**, instead of the angle.

---
See: Use of angles in the language - fget_angle() - get_dist()

## [117] get_dist()

**get_dist(**<identifying code>**)**

**Returns:**

The distance to another process.

**Description:**

It returns the distance between the current process (the one that called this function) to the process whose identifying code is passed to it as a parameter.

For further information, see ways to obtain the identifying code.

If the process has defined its local variable resolution, it is important that the process to which the aim is to obtain the distance has it defined at the same value. That is to say, if both processes use the coordinates in hundreds instead of units (with resolution=100), the distance between both
will also be obtained in hundreds. But if the value of that variable differs in both processes, the result of the **get_dist()** function will make no sense.

Sample program:
```div
PROGRAM example_get_dist;

PRIVATE
    resulting_distance;
    process_identifier;

BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    graph=100;
    x=160;
    y=100;

    process_identifier = movable_process(80, 50, 101);

    write(0, 160, 200, 7, "Use the cursors to move the triangle.");
    write(0, 0, 0, 0, "Distance from the ball to the triangle:");
    write_int(0, 0, 10, 0, offset resulting_distance);
    LOOP

        // We calculate the distance between the two processes
        resulting_distance = get_dist(process_identifier);

        FRAME;
    END
END

PROCESS movable_process(x, y, graph)
BEGIN
    LOOP
        IF (key(_right)) angle-=10000; END
        IF (key(_left)) angle+=10000; END
        IF (key(_up)) advance(4); END
        FRAME;
    END
END
```

At the beginning, the screen background is set and the main program defines its graphic as a ball placed at the center of the screen.

Then, a process of the **movable_process** type is created, which may be controlled through the cursors. The identifying code is taken from this process.

Inside the main loop, the distance between the two processes is calculated and continuously shown on the screen.

The fget_dist() function is used to obtain the **distance between two points**, instead of between two processes. If the identifying code of the process is stored, for instance, in a variable called **id2**, then the call to the function:

    **get_dist(id2)**

Would be equivalent to:

    **fget_dist(x, y, id2.x, id2.y)**

Obtaining the distance from the (x, y) coordinates of the current
process, to the (x, y) coordinates of the process whose identifying code is **id2**.

The get_angle() function is used to obtain the **angle to another process**, instead of the distance.

---

This function may be used to detect collisions between processes due to their proximity, even if the collision() function is normally used to this purpose. The last function detects when two processes have their graphics superposed.

For instance, with the processes displayed inside a mode-7 window (see start_mode7()) the collision() function can not be used, being necessary to obtain the distance between the processes to verify if they collide with each other (if their distance is less than the distance already determined).

---
See: fget_dist() - get_angle() - get_distx() - get_disty()

## [118] get_distx()

**get_distx(**<angle>**,** <distance>**)**

**Returns:**

The horizontal offset of the vector (angle, distance).

**Description:**

Returns the horizontal distance (in the axis of the **x** coordinate) from the angle and **distance** (over this angle) passed as parameters. That is to say, it returns the distance covered in horizontal by the vector made by the angle and
**length** (distance or vector module) indicated.

Keep in mind that the angle is specified in degree thousandths and any valid numeric expression may specify the distance.

The function used to calculate the vertical distance, instead of the horizontal one, is get_disty().

Sample program:
```div
PROGRAM example_get_distx;

GLOBAL
    distance;
    horizontal_distance;
    vertical_distance;

BEGIN
    load_fpg("help.fpg");
    put_screen(0, 3);
    write(0, 160, 200, 7, "Use the cursors to move the triangle.");
    write(0, 0, 0, 0, "Horizontal distance:");
    write_int(0, 0, 10, 0, offset horizontal_distance);
    graph=101;
    LOOP
        IF (key(_up)) distance+=2; END
        IF (key(_down)) distance-=2; END
        IF (key(_right)) angle-=2000; END
        IF (key(_left)) angle+=2000; END

        // We calculate the horizontal distance
        horizontal_distance = get_distx(angle, distance);

        vertical_distance = get_disty(angle, distance);
        x=160+horizontal_distance;
        y=100+vertical_distance;
        FRAME;
    END
END
```

In the example, a circular graphic is put as screen background. Over it, a triangle will be controlled with the cursors, modifying its distance and angle to the center of the graphic.

The program calculates the horizontal and vertical distance to place the triangle from the coordinates of the center of the screen (160, 100), showing the horizontal distance in the upper left corner all the times.

---

If the aim is to advance the coordinates of the process a **distance** in a specific angle, the following statements may be used:

  **x+=get_distx(**<angle>**,** <distance>**);**  
  **y+=get_disty(**<angle>**,** <distance>**);**  

If the angle in which the aim is to move the process is the one contained in its
angle local variable, then this operation could be performed with the
advance() function in the following way:  

  **advance(**<distance>**);**

---

The **get_distx()** function is equivalent to calculating the **cosine** of the angle and multiplying it by the **distance**.

---
See: Use of angles in the language - get_disty() - advance()

## [119] get_disty()

**get_disty(**<angle>**,** <distance>**)**

**Returns:**

The vertical offset of the vector (angle, distance).

**Description:**

Returns the vertical distance (axis of the **y** coordinate) from the angle and **distance** (over this angle) passed as parameters. That is to say, it returns the distance covered in vertical by the vector made by the angle and **length** (distance) indicated.

Keep in mind that the angle is specified in degree thousandths. Any valid numeric expression can specify the distance.

The function used to calculate the horizontal distance, instead of the vertical one, is get_distx().

Sample program:
```div
PROGRAM example_get_disty;

GLOBAL
    distance;
    horizontal_distance;
    vertical_distance;

BEGIN
    load_fpg("help.fpg");
    put_screen(0, 3);
    write(0, 160, 200, 7, "Use the cursors to move the triangle.");
    write(0, 0, 0, 0, "Vertical distance:");
    write_int(0, 0, 10, 0, offset vertical_distance);
    graph=101;
    LOOP
        IF (key(_up)) distance+=2; END
        IF (key(_down)) distance-=2; END
        IF (key(_right)) angle-=2000; END
        IF (key(_left)) angle+=2000; END

        // We calculate the vertical distance
        vertical_distance = get_disty(angle, distance);

        horizontal_distance = get_distx(angle, distance);
        x=160+horizontal_distance;
        y=100+vertical_distance;
        FRAME;
    END
END
```

In the example, a circular graphic is set as screen background. Over it, a triangle will be controlled with the cursors, modifying its distance and angle to the center of the graphic.

The program calculates the horizontal and vertical distance to place the triangle from the coordinates of the center of the screen (160,100), showing the vertical distance in the upper left corner all the times.

---

If the aim is to advance the coordinates of the process a **distance** in a specific angle, the following statements may be used:

  **x+=get_distx(**<angle>**,** <distance>**);**  
  **y+=get_disty(**<angle>**,** <distance>**);**  

If the angle in which you want to move the process is the one contained in its
angle local variable, then this operation could be performed with the
advance() function in the following way:

  **advance(**<distance>**);**

---

The **get_disty()** function is equivalent to calculating the **sine** of the angle and multiplying it by the **distance**, changing this result of sign, because the screen **Y** axis advances downwards (unlike the sine function).

---

---
See: Use of angles in the language - get_distx() - advance()

## [120] get_id()

**get_id(**<process type>**)**

**Returns:**

Either the identifying code of a process or **0**.

**Description:**

Verifies if there are active processes of the specified type. If there are, then this function will return the identifying code of one of them. If there are not, it will return 0.

If there are several processes of the specified type, the **get_id()** function will return the rest of the identifiers in the successive calls made to it.

Once all the identifying codes have been returned, the function will return 0, until a FRAME statement is executed again. From this moment, this function will return all the identifying codes of the processes of the specified type again.

To obtain all the identifying codes of the processes in this way, the
FRAME statement will not be used between two consecutive calls to the **get_id()** statement. In case that a FRAME statement is executed, this function will return all the identifying codes of processes again, from the first one.

Something similar happens if a call to the function is executed, specifying a different type of process. If, after this, identifiers of the previous type of process are asked again, this function will also return them from the first one.

Sample program:
```div
PROGRAM example_get_id;

PRIVATE
    process_identifier;
    counter;

BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    FROM counter=1 TO 20;
        movable_process(rand(0, 319), rand(0, 199), 101);
    END
    LOOP
        FROM counter=1 TO 20;

            // We take the processes' identifiers
            process_identifier = get_id(TYPE movable_process);

            process_identifier.angle+=rand(-5000, 5000);
        END
        FRAME;
    END
END

PROCESS movable_process(x, y, graph);
BEGIN
    LOOP
        FRAME;
    END
END
```

In the example, after having loaded the file with graphics and set the background screen, 20 **movable_process** type processes are
created with their positions randomly chosen and with a triangle-shaped graphic.

These processes will only execute FRAME statements inside a loop, in order to be displayed.

From the main program, the identifiers of the **movable_process** type processes are taken with the **get_id()** function (storing them in the **process_identifier** variable) and using them to modify their angle (their angle local variable).

On having the identifying code of a process, it is possible to consult or modify its local variables (like angle in this example) or else, to send signals to the process with the signal() function.

---

The collision() function is used to obtain the identifying codes of  processes of a specific type that, moreover, collide with the current process.

---
See: Ways to obtain the identifying code - Types of processes - Identifying codes

## [121] get_joy_button()

**get_joy_button(**<number of button>**)**

**Returns:**

**True** (1) if the button is pressed, **False** (0) if it is not.

**Description:**

This function requires the joystick number button (from 0 to 3) as a parameter, and returns **true** (an odd numerical value) if it is pressed at that moment.

If the button is not pressed, the function returns **false** (an even numeric value).

Some joysticks have only 2 buttons. In this case, they will be number 0 and 1 buttons. In computers with two connected joysticks, the second joystick will have buttons number 2 and 3.

Sample program:
```div
PROGRAM example_get_joy_button;

PRIVATE
    counter;
    buttons[3];

BEGIN
    write(0, 160, 200, 7," Press the joystick's buttons.");
    write(0, 0, 0, 0, "Buttons (0..3):");
    write_int(0, 100, 0, 0, offset buttons[0]);
    write_int(0, 120, 0, 0, offset buttons[1]);
    write_int(0, 140, 0, 0, offset buttons[2]);
    write_int(0, 160, 0, 0, offset buttons[3]);
    LOOP
        FROM counter=0 TO 3;

            // We take the value of the joystick's button
            buttons[counter] = get_joy_button(counter);

        END
        FRAME;
    END
END
```

An explanatory message is displayed in the lower part and the state of the four possible buttons is displayed in the upper part. Then, the program remains
inside a loop, continuously updating the state of the four buttons with the
**get_joy_button()** function.

---

There are other ways to use the joystick. The easiest one is to use the joy structure, since in it there are four records that continuously show the state of the joystick buttons.

---
See: get_joy_position() - Joy structure

## [122] get_joy_position()

**get_joy_position(**<axis number>**)**

**Returns:**

The position of the joystick axis.

**Description:**

This function returns the coordinate in which the axis specified (with a number from **0** to **3**) of the analog joystick is placed.

**0** axis - Main **X** axis.  
**1** axis - Main **Y** axis.  
**2** axis - Secondary **X** axis.  
**3** axis - Secondary **Y** axis.  

The joystick coordinate may vary, depending on the type of joystick
and on the computer in which it is executed. Anyhow, it is a number that usually ranges from **4** to **200**, approximately.

The **main** and **secondary** axes may be integrated in a single joystick, on some occasions (flight commands with a **hat**, **pedals**, etc.). In computers
having two connected joysticks, joystick 1 will be the main axis and joystick 2 will be the secondary one.

Sample program:
```div
PROGRAM example_get_joy_position;

PRIVATE
    axis_joystick[3];
    counter;

BEGIN
    write (0, 160, 200, 7, "Move the joystick");
    write (0, 0, 0, 0, "Main X coordinate.");
    write_int(0, 0, 10, 0, offset axis_joystick[0]);
    write (0, 0, 40, 0, "Main Y coordinate.");
    write_int(0, 0, 50, 0, offset axis_joystick[1]);
    write (0, 0, 80, 0, "Secondary X coordinate X.");
    write_int(0, 0, 90, 0, offset axis_joystick[2]);
    write (0, 0, 120, 0, "Secondary Y coordinate.");
    write_int(0, 0, 130, 0, offset axis_joystick[3]);
    LOOP
        FROM counter=0 TO 3;

            // We take the value of the joystick's axes
            axis_joystick[counter] = get_joy_position(counter);

        END
        FRAME;
    END
END
```

First, the messages are displayed and then, the program remains inside
a loop, continuously updating the state of the four axes with the **get_joy_button()** function (in this case, they are stored in the private **axis_joystick** table).

---

There are other ways to use the joystick. The easiest one is to use the joy structure, when an analog reading of the joystick (its coordinates) is not required. That is to say, when it is enough to know if the joystick is at the center, to the right, down, etc.

---
See: get_joy_button() - Joy structure

## [123] get_pixel()

**get_pixel(**<x>**,** <y>**)**

**Return:**

The color of the pixel (0..255).

**Description:**

Returns the color that the **background screen** pixel placed in the coordinates indicated as parameters has.

The returned number is the color's order inside the colors palette active in the program. It ranges from 0 to 255, as the palettes have 256 colors.

The pixel is exclusively taken from the background screen picture, without having into account the graphics of the processes, texts, scroll regions, etc. That is to say, only the colors put by the put(),xput(),
put_pixel() and put_screen() functions will be read. 

Sample program:
```div
PROGRAM example_get_pixel;

PRIVATE
    color_pixel;

BEGIN
    load_fpg("help.fpg");
    put_screen(0, 2);
    mouse.graph=200;
    write (0, 0, 190, 0, "Color of the screen background's pixel:");
    write_int(0, 256, 190, 0, offset color_pixel);
    LOOP

        // We take the color of the screen background's pixel 
        color_pixel = get_pixel(mouse.x, mouse.y);

        FRAME;
    END
END
```

In the example, the background screen is set with the put_screen function as a series of squares of different colors, and a cross is assigned as mouse pointer.

Then, the color that is in the position marked by the mouse pointer will be shown in the lower part of the screen. The mouse reads this color with the **get_pixel()** function in every iteration of the program's main loop.

---
See: put_pixel() - map_get_pixel() - map_put_pixel() - get_point()

## [124] get_point()

**get_point(**<file>**,** <graphic>**,** <number>**,** <OFFSET x>**,** <OFFSET y>**)**

**Returns:**

The position of the control point (in the variables whose
offset is indicated as the last two parameters).

**Description:**

This function returns the control point, whose **number** is indicated as third parameter, to the position where it was placed in a **graphic** (of the indicated **file**).

A control point is a point that can be defined in the graphic editor (painting tool), in the option designed for this function.

The function needs the **address** (that is obtained with the offset operator) in the computer's memory **of two variables** in which it will return the **x** and **y** position of the control point.

The graphics loaded with the load_map() function will be used as if they belonged to the first file (the file with the 0 code).

Sample program:
```div
PROGRAM example_get_point;

GLOBAL
    file1;
    point=1;
    x_point;
    y_point;

BEGIN
    file1=load_fpg("help.fpg");
    put_screen(0, 4);
    graph=101;
    LOOP
        IF (fget_dist(x, y, x_point, y_point)<6)
            IF (point++==50) point=1; END
        END

        // We take the control point
        get_point(file1, 4,point, offset x_point, offset y_point);

        angle=fget_angle(x, y, x_point, y_point);
        advance(6);
        FRAME;
    END
END
```

In the example, a circuit with a bitmap that goes all over the screen is
put as background. This bitmap (graphic **4** of the file) has 50 control points (from 1 to 50) defined along the circuit route.

The main process appears as a triangle that goes all over the circuit.

This is obtained having in the **point** variable the number of the
control point for which the triangle must be heading, (point number 1, at the beginning).

The coordinates of every control point, obtained with the **get_point()** function, are stored in the **x_point** and **y_point** variables and they are useful for the process to head for that position with the following functions: fget_angle() (to obtain the angle towards the point in the **angle** variable) and advance() (to advance 6 points in that direction).

Being near the control point, the fget_dist() function checks whether the point number increases, to head the triangle for the following one (when point number 50 has been reached, we will return to 1).

---

This function returns the exact coordinates in which that control point was
placed inside the graphic, without considering how this graphic is now (scaled, rotated, etc.). The get_real_point() function must be used to obtain the position of a control point in a scaled, rotated... graphic and referred to the screen coordinates (and not to those of the original graphic).

That is to say, this last function returns the position where a control point is at a specific moment, and **get_point()** returns the place where this point was originally located.

---
See: Control points - get_real_point() - get_pixel()

## [125] get_real_point()

**get_real_point(**<number>**,** <OFFSET x>**,** <OFFSET y>**)**

**Returns:**

The current coordinates of the control point (in the variables whose offset is indicated as the last two parameters).

**Description:**

This function returns where, at that moment, a control point of the current process' graphic is in the system of coordinates used by the process itself (see  ctype local variable), evaluating the original location of the point, the current coordinates of the process, their size, angle, etc.

A control point is a point that can be defined in the graphic editor (painting tool), in the option designed for this function.

The function needs the **address** (that is obtained with the offset operator) in the computer's memory **of two variables** in which it will return
the **x** and **y** position of the control point.

The graphics loaded with the load_map() function will be used as if they belonged to the first file (the file with the 0 code).

Sample program:
```div
PROGRAM example_get_real_point;

PRIVATE
    point;
    x_point;
    y_point;

BEGIN
    load_fpg("help.fpg");
    graph=4;
    x=160;
    y=100;
    LOOP
        FROM point=1 TO 50;

            // We take the coordinates from where the control point is now
            get_real_point(point, offset x_point, offset y_point);

            process_marker(x_point, y_point, 200);
        END
        angle+=1000;
        FRAME;
    END
END

PROCESS process_marker(x, y, graph);
BEGIN
    FRAME;
END
```

In the example, a circuit that goes all over the screen is defined as a graphic of the main process. This graphic has 50 control points (from 1 to
50) defined.

The program remains in a loop inside which this graphic keeps on rotating (adding to it a degree with the **angle+=1000;** statement) and creating 50  cross-shaped processes (one cross in every graphic's control points).

It is possible to verify how the relative position of the control points does not vary, even if the graphic of the circuit rotates.

---

This function is normally used  to have some important points of a graphic located. For instance, if we have defined a process whose graphic is a man with a gun that can be scaled, rotated or that can perform different animations, we could define a control point in the barrel gun's point to know at any time from where the bullets must leave when shooting.

If the original graphic was inside a scroll region (seestart_scroll()), then the returned coordinates will also refer to that scroll region.

---

The get_point() function returns the position where a control point was
originally placed in the graphic, unlike the **get_real_point()** function, that returns its current position.

---
See: Control points - get_point() - get_pixel()

## [126] graphic_info()

**graphic_info(**<file>**,** <graphic>**,** <information>**)**

**Returns:**

The required information about the graphic.

**Description:**

Returns the required information about a **graphic** of a **file**.

Information:

**g_wide** - The function will return the **original width** of this graphic if g_wide is put as third parameter.

**g_height** - The function will return the **original height** of the graphic.

**g_x_center** - The function will return the **x coordinate** of the graphic's center.

**g_y_center** - The function will return the **y coordinate** of the graphic's center.

The graphics loaded with the load_map() function will be used as if they belonged to the first file (the file with the code 0).

Sample program:
```div
PROGRAM example_graphic_info;

PRIVATE
    file1;
    height;
    width;
    x_center;
    y_center;

BEGIN
    file1=load_fpg("help.fpg");
    put_screen(file1, 1);
    graph=100;
    x=160;
    y=100;

    // We take the information about the graphic's height
    height = graphic_info(file1, 100, g_height);

    // We take the information about the graphic's width
    width = graphic_info(file1, 100, g_wide);

    // We take the information about the x coordinate of the graphic's center
    x_center = graphic_info(file1, 100, g_x_center);

    // We take the information about the y coordinate of the graphic's center
    y_center = graphic_info(file1, 100, g_y_center);

    write(0, 0, 0, 0, "Graphic's height:");
    write_int(0, 0, 10, 0, offset height);
    write(0, 0, 20, 0, "Graphic's width:");
    write_int(0, 0, 30, 0, offset width);
    write(0, 0, 40, 0, "Graphic's horizontal center:");
    write_int(0, 0, 50, 0, offset x_center);
    write(0, 0, 60, 0, "Graphic's vertical center:");
    write_int(0, 0, 70, 0, offset y_center);
    LOOP
        FRAME;
    END
END
```

In the example, information about graphic number 100 of the
**help.fpg** file is required. This graphic is a 32 by 32 pixel ball, with its
center at (16, 16).

To obtain this information, it will be necessary to call the
**graphic_info()** function 4 times, as it returns just one value every time, depending on the third call parameter (<information>).

---
See: g_wide - g_height - g_x_center - g_y_center

## [127] is_playing_cd()

**is_playing_cd()**

**Returns:**

**True** (1) if the CD is playing, or **false** (0) if it is not.

**Description:**

This function is used to determine whether the CD is playing a song.

It returns **True** (an odd number) if the CD is playing a song. Otherwise, it returns **False** (an even number).

Its most widespread use is to play a song indefinitely, as it is shown in the following example.

Sample program:
```div
PROGRAM example_is_playing_cd;
BEGIN
    play_cd(1, 0);
    LOOP

        IF (NOT is_playing_cd()) // It checks whether the song has already finished

            play_cd(1, 0);
        END
        FRAME;
    END
END
```

The previous example (for which it is necessary to have an audio **Compact disc** inserted in the **CD-ROM** device) uses the play_cd() function to play the first song of the cd.

Then, in a loop, it is checked whether this song is over, to play it again.

---

The volume of cd-audio reproduction may be controlled with the setup structure and the set_volume() function.

---
See: play_cd() - stop_cd() - set_volume() - Setup structure

## [128] key()

**key(**<keyboard code>**)**

**Returns:**

**True** (1) if the key is pressed and **false** (0) if it is not.

**Description:**

Returns **true** (an odd number) if the key, indicated as parameter,
is pressed at that moment. Otherwise, it returns **false** (an even number).

The input parameter will normally be the name of the key with the **_** (underlining) symbol ahead. For instance, to read the [**A**] key, the function must be called **key(_a)**.

Access the keyboards codes to see the whole list of the keyboard codes that may be used as parameter of the **key()** function.

Sample program:
```div
PROGRAM example_key;
BEGIN
    LOOP
        delete_text(all_text);

        IF (key(_space)) // We check whether the spacebar is pressed

            write(0, 0, 0, 0, "You are pressing the [SPACE] key.");
        ELSE
            write(0, 0, 0, 0, "You are not pressing the [SPACE] key.");
        END
        FRAME;
    END
END
```

In the example, the kind of message that is displayed depends on whether the spacebar is pressed or not.

---

There are three predefined global variables that can also be used to control the keyboard, and they are the following ones:

scan_code - Code of the latest key that has been pressed. This code is a numeric value that directly corresponds with the constants of keyboard codes, used as parameters of the **key()** function.

ascii - ASCII code of the latest pressed key.

shift_status - variable that shows a number depending on the special or lock keys (shift, alt, control, ...) pressed at that moment.

---
See: keyboard codes - scan_code - ascii - shift_status

## [129] let_me_alone()

**let_me_alone()**

**Description:**

Sends a s_kill signal to all the processes, except the one executed by this function. Therefore, all the processes, except the current one, will be eliminated.

This function is normally used from the main process, when a game is over, to delete all the processes (shots, enemies...) that will remain active, and to recover the control of the program.

A call to **let_me_alone()** could always be replaced by a series
of calls to the signal() function with the s_kill signal. For that, it would be necessary to know either the types of processes intended to be deleted or their identifying codes.

Sample program:
```div
PROGRAM example_let_me_alone;
BEGIN
    load_fpg("help.fpg");
    null_process (160, 100, 100);
    write (0, 160, 0, 1, "Press [SPACE] to delete the process");
    WHILE (NOT key (_space))
        FRAME;
    END

    let_me_alone(); // The rest of the processes are deleted

    LOOP
        FRAME;
    END
END

PROCESS null_process(x, y, graph)
BEGIN
    LOOP
        FRAME;
    END
END
```

In the example, after having created a process of the **null_process** type, waiting for the spacebar to be pressed to use the **let_me_alone()** function,
which deletes all the existing processes (except the main one, which called the function). In this case, the process of the **null_process** type will be deleted.

---

To check the active processes of a program at a specific moment, you must access the debugger by pressing the [**F12**] key.

---

The exit() function is also used to immediately finish a program,
returning to the system.

---
See: exit() - signal()

## [130] load()

**load(**<archive name>**,** <OFFSET data>**)**

**Description:**

Loads a data block from an archive in the disk to the program's memory.

For that, the function requires the **archive name** and the offset, inside the computer's memory, of the variable, table or structure stored in the disk (the datum offset may be obtained with the OFFSET operator).

The offset of the same datum specified when the archive was stored with the save() function must be specified.

The archive names may be given by specifying a path, **which must be the same as that used with the** save() **function** to store the archive. Nevertheless, **it is not necessary** to specify a path.

It is important that the archive intended to be loaded has been previously created, as an error will occur if the aim is to load a nonexistent archive (even if this can be ignored, continuing the program's execution).

Sample program:
```div
PROGRAM example_load;

PRIVATE
    table[9];
    counter;

BEGIN
    write (0, 0, 0, 0, "Press [ENTER] to delete the data.");
    write (0, 0, 10, 0, "Press [SPACE] to load the disk data");
    write (0, 0, 30, 0, "Current values of the data:");
    FROM counter=0 TO 9;
        table[counter]=rand(0, 100);
        write_int(0, 0, 40+(counter*10), 0, offset table[counter]);
    END
    save("help.dat", offset table, sizeof(table));
    LOOP
        IF (key(_enter))
            FROM counter=0 TO 9;
                table[counter]=0;
            END
        END
        IF (key(_space))

            load("help.dat", offset table); // The disk data are loaded

        END
        FRAME;
    END
END
```

At the beginning of the example, a table of 10 positions (from 0 to 9)
with random values, is created. This table is saved in the disk with the
save() function.

When the ENTER key is pressed, the values of the table are cleared (the 10 positions are put at 0).

When the spacebar is pressed, the table values of the disk are loaded with the **load()** function.

---
See: save() - sizeof()

## [131] load_fnt()

**load_fnt(**<archive name>**)**

**Returns:**

The loaded **font code**.

**Description:**

Loads an archive with a new characters font (*.FNT) of the disk
(a "font" with a new set of graphic characters).

The function returns the **font code** that can be used by the write() and write_int() functions to write a text.

The archives' path can be specified with the font. Nevertheless, it won't be necessary if the archive with the letter font has been generated in the directory by default (\FNT).

The archive with the new font has to be created with the game's color palette to be displayed correctly. Otherwise, the colors will appear changed.

Sample program:
```div
PROGRAM example_load_fnt;

PRIVATE
    font1;

BEGIN

    font1=load_fnt("help.fnt"); // The font for the text is loaded

    write(0, 160, 0, 1, "Text written with the system font.");
    write(font1, 160, 10, 1, "FONT OF THE ARCHIVE IN DISK");
    LOOP
        FRAME;
    END
END
```

In the example, a font is loaded with the **load_fnt()** function and then, two texts are written with different fonts. The first one, with the system font, and the second one, with the font loaded in the **help.fnt** archive.

---

To unload the loaded font from the computer's memory (freeing up the space that the font occupies in the memory) the unload_fnt() function must be loaded, passing as a parameter the **font code**.

**It is not necessary** to unload the font with this last function, unless you need
the occupied space to load more graphics or fonts, since the system will automatically free up the font when the program is over.

---
See: unload_fnt() - write() - write_int() - load_pal()

## [132] load_fpg()

**load_fpg(**<archive name>**)**

**Returns:**

The loaded **file code**.

**Description:**

Loads an archive with a (*.FPG) file of the disk.  A file means a graphics library (or collection).

An FPG archive with a graphics library may contain from no graphic to 999 graphics. Every graphic included in the library will have a numeric code, the **graphic code**, a number that ranges from **1** to **999**, and that is used to identify the graphic inside the file.

It is possible to load as many graphics' files as necessary, providing there is available memory ( this function has to be called several times to load several files).

The function returns the **file code**, that can be used by many functions that require a graphic. For that, it is necessary to indicate to them the **file code** in which the graphic is and the **graphics code** inside the file.

The archives' path can be specified with the graphics file. Nevertheless, it won't be necessary if the file is in the directory by default (\FPG).

---

When different files have been loaded, take into account that if they have different palettes, every palette has to be activated previously with the load_pal() function, indicating the (FPG) file name as a parameter before using its graphics.

Sample program:
```div
PROGRAM example_load_fpg;

PRIVATE
    file1;

BEGIN

    file1 = load_fpg("help.fpg"); // The graphics' file is loaded

    put_screen(file1, 1); // We use graphic 1 of the file
    write(0, 160, 0, 1, "Graphics' file successfully loaded");
    LOOP
        FRAME;
    END
END
```

In the example, the graphics' file that is going to be used in the program is loaded with the **load_fpg()** function. Then, its graphic number 1 is used to put it as screen background (with the put_screen() function).

---

The unload_fpg() function allows us to free up the computer's memory occupied by the graphics' file when it is not going to be used any longer. For that, it also requires the **file code**, in order to know which file we want to unload from the memory.

**It is not necessary to unload the file from the memory** before finishing the program, since the system will do it automatically.

---
See: unload_fpg() - load_map() - load_pal() - file

## [133] load_pal()

**load_pal(**<archive name>**)**

**Description:**

Loads a color palette of the disk (from a PAL, FPG, MAP or FNT archive) defining the **256 colors** displayed on the screen.

From that moment, the game will be seen with the colors set indicated by that palette.

If, at the moment of loading the palette, the program had already another different one assigned, then a fading of the screen colors to black will be carried out. Then, the new color palette will gradually appear in the following frames of the game.

The archive path may be specified with the palette. Nevertheless, it will not be necessary if the file is, by default, in the directory (that, depending on the type of archive, will be: \PAL, \FPG, \MAP or \FNT).

The program will automatically read the palette of the first of these types of archives loaded in the program, even if the **load_pal()** function is not used. Then, this function will be used when the program uses several different palettes to change from one to another.

Sample program:
```div
PROGRAM example_load_pal;
BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    write(0, 160, 0, 1, "Press [SPACE] to load a different palette.");
    write(0, 160, 10, 1, "Press [ENTER] to load the original palette.");
    LOOP
        IF (key(_space))

            load_pal("help2.pal"); // A palette of a .pal file is loaded

        END
        IF (key(_enter))

            load_pal("help.fpg");  // A palette of a .fpg file is loaded

        END
        FRAME;
    END
END
```

At the beginning of the example, a graphics' file is loaded, a screen background is set and the necessary messages are displayed.

In the main loop of the program, a different palette is loaded (from the **help2.pal** archive) when the spacebar is pressed, and the original palette is loaded (from the **help.fpg** archive) when the ENTER key is pressed.

---

A palette can not be unloaded from the computer's memory, since it does not occupy any space in the memory.

---
See: load_map() - load_fpg() - load_fnt()

## [134] load_pcm()

**load_pcm(**<archive name>**,** <cyclic>**)**

**Returns:**

The loaded **sound code**.

**Description:**

Loads a sound effect from a PCM archive of the disk. The archive name must be replaced by the sound effect as a first parameter. As a second parameter, the <cyclic> must be replaced by **1** if the sound must indefinitely be repeated, or **0** if it must be played only once (when it is required with the sound() function).

The function returns the **sound code** that must be used by the sound() function to play that sound through a channel.

The archive path may be specified with the sound. Nevertheless, it will not be necessary if the sound is in the directory by default (\PCM).

Sample program:
```div
PROGRAM example_load_pcm;

PRIVATE
    id_sound;

BEGIN

    id_sound = load_pcm("help.pcm", 0); // Loads a sound from the hard disk

    write(0, 160, 0, 1, "Press [SPACE] to execute the sound.");
    LOOP
        IF (scan_code==_space)
            sound(id_sound, 100, 256);
        END
        FRAME;
    END
END
```

At the beginning of the example, a sound is loaded with the **load_pcm()** function. Then, every time the spacebar is pressed, that sound is executed in the main loop with the sound() function.

---

The unload_pcm() function allows us to free up the computer's memory occupied by the sound when it is not going to be used any longer. For that, it also requires the **sound code** in order to know which sound we want to unload from the memory.

**It is not necessary to unload the sound from the memory** before finishing the program, since the system will do it automatically.

---
See: unload_pcm() - sound() - change_sound() - Setup structure

## [135] map_block_copy()

**map_block_copy(**<file>**,** <destination graphic>**,** <x destination>**,** <y destination>**,** <origin graphic>**,** <x>**,** <y>**,** <width>**,** <height>**)**

**Description:**

The **map_block_copy()** function allows us to transfer a rectangular block from a graphic to another one.

The graphic from which the rectangular region is taken is called <origin graphic> and  the **destination graphic** is the one in which this block will be copied. That is to say, this function allows us to copy a part of a graphic (origin) to another one (destination). The parameters are the following ones, in order:

**<file>** - Both graphics must come from the same graphics file. The **file code** must be specified as first parameter (see load_fpg()). The graphics loaded with the load_map() function will be used as if they belonged to the first file (the file with the code 0).

**<destination graphic>** - **code of the graphic** in which the block is going to be put.

**<x destination>, <y destination>** - (**x**, **y**) coordinates at which the aim is to put the block inside the destination graphic.

**<origin graphic>** - **code of the graphic** from which the block is going to be taken.

**<x>, <y>** - **starting** coordinates of the block inside the origin graphic.

**<width>, <height>** - **dimensions** of the block that is going to be transferred.

This function will modify the indicated graphic, but only its copy that has been loaded in the computer's memory. The original graphic, that is stored in the **FPG** or **MAP** archives of the disk, **will remain unchangeable**.
For that, if at a specific moment of the game the aim is to recover the original state of the graphic, it is necessary to unload it from the memory (with the unload_fpg() or unload_map() functions) and then, load it again.

Sample program:
```div
PROGRAM example_map_block_copy;

PRIVATE
    x_destination, y_destination;
    x_origin, y_origin;
    width, height;
    file1;

BEGIN
    file1=load_fpg("help.fpg");
    graph=1;
    x=160;
    y=100;
    LOOP
        x_destination=rand(0, 320);
        y_destination=rand(0, 200);
        width=rand(1, 32);
        height=rand(1, 32);
        x_origin=rand(0, 32-width);
        y_origin=rand(0, 32-height);

        map_block_copy(file1, 1, x_destination, y_destination, 100, x_origin, y_origin, width, height);

        FRAME;
        angle+=1000;
    END
END
```

In the example, after having loaded the graphics file and put one (graphic number 1), the center of the screen is continuously rotating. 
In the main loop, the graphic of a ball (graphic number 100) is copied inside the destination graphic (number 1) at some coordinates randomly chosen.

---

When a graphic is put inside another one that is being used as a scroll region's background, it will not automatically appear on screen unless the refresh_scroll() function is used.

---
See: map_xput() - map_put() - map_put_pixel()

## [136] map_get_pixel()

**map_get_pixel(**<file>**,** <graphic>**,** <x>**,** <y>**)**

**Returns:**

The color of the pixel (0..255).

**Description:**

Allows us to obtain the color of a graphic's specific pixel, as a return value of the function. For that purpose, it requires the <file code> in which the graphic is stored, the <graphic code> inside the file and the (**x**, **y**) coordinates of the graphic's pixel whose color intended to be obtained.

The graphics loaded with the load_map() function will be used as if they belonged to the first file (the file with the code 0).

Sample program:
```div
PROGRAM example_map_get_pixel;

PRIVATE
    file1;
    figure;

BEGIN
    file1=load_fpg("help.fpg");
    put_screen(0, 7);
    mouse.graph=200;
    write(0, 0, 0, 0, "FIGURE:");
    write_int(0, 42, 0, 0, offset figure);
    LOOP

        // We take the color of the bitmap's pixel
        figure = map_get_pixel(file1, 8, mouse.x, mouse.y);

        FRAME;
    END
END
```

In the example, a frame with 6 different geometrical figures, all of them of the same color, are put as background screen, and the mouse graphic is defined as a little cross.

The background frame directly corresponds to another graphic (graphic number 8 in the file), which has the same figures but every one of a different color (the first one of color 1, the second one of color 2, etc.).

In the main loop, with the **map_get_pixel()** function a color will be taken from the second graphic's coordinates, indicated by the mouse cursor.

The value obtained with the function will be shown in the upper left corner of the screen. This value will indicate the number of the figure.

---

This function is normally used to detect zones inside the graphics.
This technique is called **hardness maps** and it allows us to use two different graphics, one with the picture and the second with the zones to detect, painted in different colors.

For instance, in a game with spacecraft, the zones that take energy away from the spacecraft when passing over it with a specific color (for instance, color 32) could be painted in this **hardness map**. Then, the color would be obtained from the **hardness map** over which the spacecraft is and, if it is 32, energy would be taken away from it.

That is to say, there would be two different pictures: one of them visible, with colors (the background picture over which the spacecraft moves in the game, and the other, the **hardness map** that would only be used to obtain colors from it with the **map_get_pixel()** function, identifying so the zone of the original picture over which the spacecraft is.

---
See: get_pixel() - map_put_pixel()

## [137] map_put()

**map_put(**<file>**,** <destination graphic>**,** <origin graphic>**,** <x>**,** <y>**)**

**Description:**

Puts a graphic inside another one. The graphic that is going to be copied is called <origin graphic> and the **destination graphic** is that inside which the origin will be copied. That is to say, this function allows us to copy a graphic (origin) inside another one (destination).

Both graphics must be in the same file. The parameters are the following ones, in order:

**<file>** - **file code** with the graphics library that contains both graphics. The graphics loaded with the load_map() function will be used as if they belonged to the first file (the file with the code 0).

**<destination graphic>** - **code of the graphic** inside which the other one is going to be put.

**<origin graphic>** - **code of the graphic** that is going to be copied in the destination.

**<x>, <y>** - **coordinates inside the destination graphic** where the aim is to put the origin graphic. The center (or control point number 0) of the origin graphic will be located in these coordinates.

This function will modify the indicated graphic, but only its copy that has been loaded in the computer's memory. The original graphic, that is stored in the **FPG** or **MAP** archives of the disk, **will remain unchangeable**.
For that, if at a specific moment of the game the aim is to recover the original state of the graphic, it is necessary to unload it from the memory (with the unload_fpg() or unload_map() functions) and then, load it again.

Sample program:
```div
PROGRAM example_map_put;

PRIVATE
    x_destination;
    y_destination;
    file1;

BEGIN
    file1=load_fpg("help.fpg");
    graph=1;
    x=160;
    y=100;
    LOOP
        x_destination=rand(0, 320);
        y_destination=rand(0, 200);

        map_put(file1, 1, 100, x_destination, y_destination);

        angle+=1000;
        FRAME;
    END
END
```

In the example, graphic number 1 is put at the center of the screen.

In every step of the main loop, this graphic rotates and a graphic number 100 (a ball) is put inside the graphic 1 (the central graphic) with the **map_put()** function.

---

The map_xput() function is a version a little more complex than the **map_put()** function, but with much more utilities. Thus, the latter allows us, moreover, to put rotated, scaled, mirror and transparent graphics.

The map_block_copy() function must be used to put a part of a graphic (instead of the full graphic) inside another one.

---

**Note:** When the **map_put()** function (or any other similar) is used to modify a graphic that is being used as background of a **scroll** window, it is possible that the graphic you have put does not immediately appear on screen. To solve this problem, you must use the refresh_scroll() function.

---
See: map_xput() - map_put_pixel() - refresh_scroll() - map_block_copy()

## [138] map_put_pixel()

**map_put_pixel(**<file>**,** <graphic>**,** <x>**,** <y>**,** <color>**)**

**Description:**

Allows us to modify the color of a specific pixel of a graphic.
For that, the <file code> where the graphic is stored, the <graphic's code> inside the file and the (**x**, **y**) coordinates of the pixel whose <color> is intended to set are required.

The graphics loaded with the load_map() function will be used as if they belonged to the first file (the file with the code 0).

This function will modify the indicated graphic, but only its copy that has been loaded in the computer's memory. The original graphic, that is stored in the **FPG** or **MAP** archives of the disk, **will remain unchangeable**.
For that, if at a specific moment of the game the aim is to recover the original state of the graphic, it will be necessary to unload it from the memory (with the unload_fpg() or unload_map() functions) and then, load it again.

Sample program:
```div
PROGRAM example_map_put_pixel;
PRIVATE
    file1;
    coord_x;
    coord_y;
    color;

BEGIN
    file1=load_fpg("help.fpg");
    graph=5;
    x=160;
    y=100;
    size=180;
    LOOP
        coord_x=rand(0, 199);
        coord_y=rand(0, 199);
        color=rand(0, 15);

        // Pixels are put in graphic number 5 of file1
        map_put_pixel(file1, 5, coord_x, coord_y, color);

        angle+=2000;
        FRAME;
    END
END
```

In the example, graphic number 5 is put at the center of the screen, continuously rotating. This graphic is a completely black background. For that reason, nothing will initially be seen on screen.

But then, in every step of the loop, pixels of a color randomly chosen between 0 and 15 (greys) are put in this graphic, at a pair of coordinates randomly chosen too.

These pixels are put using the **map_put_pixel()** function.

Notice how it seems that there are more and more pixels rotating on screen, when the only thing that really rotates is graphic number 5.

---

The map_put() or map_xput() functions may be used to put a full graphic inside another one (and not only at one pixel). The map_block_copy() function may be used to put just a part of a graphic inside another one.

---

**Note:** When the **map_put_pixel()** function is used to put a pixel in a graphic that is being used as background of a **scroll** window, it is possible that this pixel does not immediately appear on screen. To solve this problem, you must use the refresh_scroll() function.

---
See: map_put() - map_xput() - refresh_scroll() - map_block_copy()

## [139] map_xput()

**map_xput(**<file>**,** <destination graphic>**,** <origin graphic>**,** <x>**,** <y>**,**
           <angle>**,** <size>**,** <flags>**)**

**Description:**

Extended version of the map_put() function.

Puts a graphic inside another one. The graphic that is going to be copied is called <origin graphic> and the **destination graphic** is that inside which the origin will be copied. That is to say, this function allows us to copy a graphic (origin) inside another one (destination).

Both graphics must be in the same file. The parameters are the following ones, in order:

**<file>** - **file code** with the graphics library that contains both graphics. The graphics loaded with the load_map() function will be used as if they belonged to the first file (the file with the code 0).

**<destination graphic>** - **code of the graphic** inside which the other one is going to be put.

**<origin graphic>** - **code of the graphic** that is going to be copied in the destination.

**<x>, <y>** - coordinates inside the destination graphic where the aim is to put the origin graphic. The origin graphic is going to be copied at these coordinates, from its upper left corner.

**<angle>** - angle (in degree thousandths) in which the origin graphic is going to be copied; the normal angle is **0**.

**<size>** - size (in percentages) in which the original graphic is going to  be copied; the normal size is **100**.

**<flags>** - Indicates the mirrors and transparencies with which the original graphic will be copied in the destination; the values are the following ones:

 **0**-Normal graphic.  
 **1**-Horizontal mirror.  
 **2**-Vertical mirror.  
 **3**-Horizontal and vertical (180°) mirror.  
 **4**-Transparent graphic.  
 **5**-Horizontal transparent and mirror.  
 **6**-Vertical transparent and mirror.  
 **7**-Horizontal and vertical transparent, mirror.  

This function will modify the indicated graphic, but only its copy that has been loaded in the computer's memory. The original graphic, that is stored in the **FPG** or **MAP** archives of the disk, **will remain unchangeable**.
For that, if at a specific moment of the game the aim is to recover the original state of the graphic, it will be necessary to unload it from the memory (with the unload_fpg() or unload_map() functions) and then, load it again.

Sample program:
```div
PROGRAM example_map_xput;
PRIVATE
    x_destination;
    y_destination;
    file1;
    angle1;
    size1;
    flags1;

BEGIN
    file1=load_fpg("help.fpg");
    graph=1;
    x=160;
    y=100;
    LOOP
        x_destination=rand(0, 319);
        y_destination=rand(0, 199);
        angle1=rand(-pi, pi);
        size1=rand(10, 200);
        flags1=rand(0, 7);

        map_xput(file1, 1, 101, x_destination, y_destination, angle1, size1, flags1);

        angle+=2000;
        FRAME;
    END
END
```

In the example, graphic 1 is put at the center of the screen,
continuously rotating (this graphic is a decorative background in grey tonalities).

In every step of the loop, a triangle-shaped graphic (with number 100) will be put inside graphic 1. This new graphic will be put with coordinates,
angle, size and flags (see flags variable) randomly chosen.

Notice how brown triangles with different applied effects are continuously appearing in the background graphic.

---

The **map_xput()** function is a version a little more complex than the map_put() function, which is easier to use when it is not required to put rotated, scaled, mirror and transparent graphics.

The map_block_copy() function must be used to put a part of a graphic (instead of the full graphic) inside another one.

---

**Note:** When the **map_put()** function (or any other similar) is used to modify a graphic that is being used as background of a **scroll** window, it is possible that the graphic you have put does not immediately appear on screen. To solve this problem, you must use the refresh_scroll() function.

---
See: map_put() - map_put_pixel() - refresh_scroll() - map_block_copy()

## [140] move_scroll()

**move_scroll(**<scroll number>**)**

**Description:**

Forces to scroll automatically and immediately. This function is rather advanced and, for that reason, it could be difficult to understand its purpose.

As a parameter, the function requires the <scroll number> from 0 to 9 that was indicated in the start_scroll() function as first parameter when the scroll started.

This function is used when a scroll region is automatically controlled, as the **camera** field of the scroll structure corresponding to the identifier of a process has been defined.

The purpose is to force the (**x0**, **y0**, **x1** and **y1**) values of that structure to be updated. If this function is not used, these values won't be updated until the following game's frame.

That is to say, when a scroll is automatically controlled and another process needs to know the value of the coordinates of that scroll before the next frame (normally to be located in a position in keeping with the background movement), do as follows:

**1** - The scroll starts with start_scroll().

**2** - The process that will be used as camera is created and its identifying code is put in the **camera** field of the scroll structure.

**3** - A very high priority must be set for this process, for it to run before the rest of the processes (putting in its priority local variable a positive whole value like, for instance, 100).

**4** - The **move_scroll()** function will be called just before the FRAME statement of the process' loop used as camera.

Thus, you will guarantee the previous execution of this process and, just at the end, the updating of the values (**x0**, **y0**, **x1** and **y1**) of the
scroll structure, so the rest of the processes may use these variables already updated.

The most widespread use of this function is when it is aim to have more than two backgrounds in a scroll window. For that, a series of processes simulating a third or fourth plane are created. The position of their coordinates will depend on the exact position of the scroll in every frame. A program doing so is shown below.

Sample program:
```div
PROGRAM example_move_scroll;

PRIVATE
    file1;
    counter;

BEGIN
    set_fps(100, 0);
    file1=load_fpg("help.fpg");
    start_scroll(0, file1, 103, 102, 0, 15);
    scroll.camera=id;
    priority=100;
    FROM counter=-2000 TO 2000 step 100;
        movable_process(counter);
    END
    write(0, 160, 0, 1, "Use the right and left cursors to move");
    graph=101;
    ctype=c_scroll;
    LOOP
        if (key(_right))
            x+=2;
            flags=0;
        END
        if (key(_left))
            x-=2;
            flags=1;
        END

        move_scroll(0); // Updates the scroll structure[]

        FRAME;
    END
END

PROCESS movable_process(x_scroll)
BEGIN
    ctype=c_scroll;
    z=100;
    graph=104;
    LOOP
        x=x_scroll-scroll.x0;
        FRAME;
    END
END
```

This example starts a scroll at full screen with two planes. Then, it moves a triangle to the right and left with the cursors. This process will function as a scroll camera, automatically focusing the vision on it (by putting **scroll.camera=**id**;**).

But, at the same time, it creates a total of 40 processes (from -2000 to 2000, every 100 pixels) with the picture of a vertical band with moving colors as if they were a third scroll plane (processes of the type **movable_process**).

For that, it is important that their **z** coordinate is greater than the rest of the processes (**z=100;**) and that the priority of the process that controls the camera is higher than (**priority=100;**) and that the latter uses the **move_scroll()** function before every frame (**FRAME;**).

The processes simulated by the third plane (**movable_process**), place their **x** coordinate at a point depending on the **scroll's x** and its original position.

The difference lies in the fact that, if **move_scroll()** had not been used, the processes, by using the **scroll.x0** variable without being updated, would move with a certain slowness that detracted from the credibility  of the game.

---
See: start_scroll() - Scroll structure - priority - z

## [141] move_text()

**move_text(**<identifier of the text>**,** <x>**,** <y>**)**

**Description:**

Moves a text towards other screen coordinates. The ** text identifier** and the (**x**, **y**) screen coordinates towards which the text must be moved are specified as parameters. The identifier of the text is a numeric code returned by the write() and write_int() functions when they are required to write a text.

The **centering code** specified in the write() or write_int() functions will remain when this function is used.

The specified coordinates always dealt with the screen and may be inside it or out from it. It is necessary to use the text_z global variable to modify the **z coordinate of the texts** (the depth plane in which they appear).

Sample program:
```div
PROGRAM example_move_text;

PRIVATE
    id_text1;
    id_text2;
    coord_x;
    coord_y;
    angle1;

BEGIN
    id_text1=write(0, 160, 100, 4, "MOVING TEXT");
    id_text2=write(0, 160, 100, 4, "MOVE THE MOUSE");
    LOOP
        coord_x=160+get_distx(angle1, 100);
        coord_y=100+get_disty(angle1, 90);

        // We move the texts
        move_text(id_text1, coord_x, coord_y);
        move_text(id_text2, mouse.x, mouse.y);

        angle1+=1000;
        FRAME;
    END
END
```

In the example, two texts are displayed at the center of the screen with the write() function. This function returns the identifiers of those texts, that are stored in the **id_text1** and **id_text2** variables.

In every step of the loop, the first text moves along a circular path obtained by increasing an angle (**angle1**) and using the get_distx() and get_disty() functions. The second text will be placed at the coordinates of the mouse pointer.

Both texts move in every frame with the **move_text()** function.

---

To delete a text definitively, the **text identifier** is also required, and the delete_text() function must be used for that.

---
See: write() - write_int() - delete_text()

## [142] near_angle()

**near_angle(**<angle>**,** <final angle>**,** <increment>**)**

**Returns:**

A new angle nearer the final angle.

**Description:**

Brings an angle nearer another one at the given increment. The function returns the new angle.

It is used when the aim is that an angle (<angle>) gradually varies
until it becomes another angle (<final angle>). For that, the  function needs the original angle, the **final angle** and the angular **increment** that is going to be added to or subtracted from the original angle.

Keep in mind that all the angles are specified in degree thousandths. The angular **increment** is but a small angle (such as one degree (**1000**) or five (**5000**).

Sample program:
```div
PROGRAM example_near_angle;

PRIVATE
    angle2;

BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    mouse.graph=200;
    graph=101;
    write(0, 160, 200, 7, "Move the mouse cursor");
    LOOP
        angle2=fget_angle(x, y, mouse.x, mouse.y);

        // Brings the current angle closer to the final one in 10 degrees at the most
        angle = near_angle(angle, angle2, 10000);

        advance(6);
        FRAME;
    END
END
```

In the example, the mouse cursor is defined as a little cross that can be moved by the user.

The main program defines its graphic as a triangle (**graph=101;**)
that, in every loop's iteration, obtains the angle towards the mouse cursor with the fget_angle() function. Then, it modifies its angle
to move 10 degrees (10000) at the most towards the cursor angle, using the **near_angle()** function. Finally, it advances 6 points
in that direction by using the advance() function.

Notice how the triangle continuously pursues the mouse cursor without making any abrupt turn (bigger than 10 degrees).

---
See: Use of angles in the language - angle - get_angle() - fget_angle()

## [143] out_region()

**out_region(**<identifier code>**,** <region number>**)**

**Returns:**

**True** if the process is out of the region or **False** if it is not.

**Description:**

This function determines whether a process is out of a screen region. For that, the function requires the identifying code of the process and a number of region.

The screen regions can be defined with the define_region() function and they are simply rectangular zones of screen.

Region number **0** can not be defined, as it will always be equivalent to the entire screen. Therefore, if **0** is specified as a second parameter, this function determines whether a process is out of the screen (if it is not seen).

In case that the process' graphic is out of the specified region, the function returns **True** (an odd number). Otherwise, if the graphic is seen in that region, even partially, the function returns **False** (any even number).

The process whose identifying code is indicated must have its graphic correctly defined (normally in its graph variable). Otherwise,
the system will notice an error, since it is not possible to calculate the dimensions of a graphic if the process lacks it.

Sample program:
```div
PROGRAM example_out_region;
BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    y=100;
    x=160;
    graph=101;
    LOOP
        advance(8);

        IF (out_region(id, 0)) // It is checked whether it is out of the screen

            x=160;
            y=100;
            angle=rand(-pi, pi);
        END
        FRAME;
    END
END
```

In the example, a background graphic is put and the main program creates a triangle-shaped graphic at the center of the screen with an angle randomly chosen.

In every step of the loop, the triangle advances and it is checked whether it has exceeded from the screen (region 0) with the **out_region()** function. If so, it is put once again at the center of the screen with another angle, also randomly chosen.

---
See: define_region() - region - Identifying codes

## [144] play_cd()

**play_cd(**<track number>**,** <mode>**)**

**Description:**

Starts playing a cd-audio track. The track number (from 1 to the number of songs contained in the cd) must be indicated. The way to do it is as follows:

**Mode.**

 **0** - Play the song and then stop.  
 **1** - Play this song and then the following ones.  

Sample program:
```div
PROGRAM example_play_cd;
BEGIN
    write(0, 160, 0, 1, "Press [SPACE] to turn the CD on.");
    LOOP
        IF (scan_code==_space)

            play_cd(1, 1); // It plays the 1st. song and then, the rest.

        END
        FRAME;
    END
END
```

In the previous example (for which it is necessary to have a music **Compact disc** inside the **CD-ROM** device) an information message is displayed and in every iteration of the loop it is checked whether the spacebar was pressed to play the first song with the **play_cd()** function.

---

To have a song indefinitely playing, a loop must be implemented, using 
the is_playing_cd() function to determine when the song is over.

The cd-audio reproduction volume can be controlled with the setup structure and the set_volume() function.

---
See: is_playing_cd() - stop_cd() - set_volume() - Setup structure

## [145] pow()

**pow(**<expression>**,** <expression>**)**

**Returns:**

The first expression **raised** to the second one.

**Description:**

Calculates the result when the first expression is raised to the second one.

For instance, **pow(3, 2)** will return **9**, which is **3** squared,
that is to say, **3²**, or **3*3**.

Sample program:
```div
PROGRAM example_pow;
GLOBAL
    values[15];
    n;
BEGIN
    FROM n=0 TO 15;
        values[n]=rand(-100, 100);
        write_int(0, 0, n*10, 0, offset values[n]);
    END
    write(0, 0, 192, 0, "Press [SPACE] to square these numbers");
    LOOP
        IF (scan_code==_space)
            FROM n=0 TO 15;

                values[n] = pow(values[n], 2); // It is squared.

            END
        END
        FRAME;
    END
END
```

This program will display a list of numbers randomly chosen between -100 and 100 on the screen. When the spacebar is pressed, these numbers will square.

Take into account that in the language **it is only possible to use integers within the** (min_int ... max_int) **range**. Therefore, when the result of the function exceeds this range, **incorrect results will be shown**. In this case, the system won't notice any error, so much care must be taken.

---
See: Expression

## [146] put()

**put(**<file>**,** <graphic>**,** <x>**,** <y>**)**

**Description:**

Puts a graphic in the screen background. The function requires the **file code** in which the graphic is stored, the **graphic code** inside the same file and the (**x**, **y**) coordinates at which the graphic is intended to be put.

The graphics loaded with the load_map() function will be used as if they belonged to the first file (the file with the code 0).

If the center graphic was not specified (setting its control point
number 0 from the painting tool), the coordinates will be referred to the position on the screen in which the graphic **center** will be located.

The graphics displayed on the screen background like this will be within the game's display **under all the processes, scroll regions, texts, etc.**

If the aim is to have a graphic over some others, it must be **created as a new process** and its z variable must be established, indicating the priority of its display.

The clear_screen() function must be used to clear the screen background.

Sample program:
```div
PROGRAM example_put;

PRIVATE
    file1;
    coord_x;
    coord_y;

BEGIN
    file1=load_fpg("help.fpg");
    LOOP
        coord_x=rand(0, 319);
        coord_y=rand(0, 199);

        put(file1, 100, coord_x, coord_y); // Graphic 100 is put.

        FRAME;
    END
END
```

In the example, the file with the graphics is loaded and in every iteration
of the loop graphic number 100 (a ball) is put, with the **put()** function, at random coordinates (randomly chosen with the rand() function).

---

If the graphic that is intended to be put is merely a background screen, it is easier to use the put_screen() function, since it does not require the screen coordinates, because it will automatically center the graphic on the screen.

---

The xput() function is a version a little more complex than the **put()** function, but with much more utilities since, at the same time, it allows us to put rotated, scaled, mirror and transparent graphics.

To put a graphic inside another one (instead of in the screen background), the map_put() or map_xput() functions must be used.

---
See: put_screen() - xput() - map_put() - map_xput() - put_pixel()

## [147] put_pixel()

**put_pixel(**<x>**,** <y>**,** <color>**)**

**Description:**

Establishes the **color** of the pixel located in the background screen's (**x**, **y**) coordinates. That is to say, it sets a pixel of the indicated color in the indicated
coordinates.

The pixels put with this function in the background screen will be displayed in the game **below all the processes, scroll regions, texts, etc.**

If the aim is to see a pixel over other graphics, you must create a new process, assigning the picture of a point (in its graph variable) as a graphic and fixing its **z** variable with the priority of its printing.

To clear the background screen, the clear_screen() function must be used.

Sample program:
```div
PROGRAM example_put_pixel;

PRIVATE
    x_pixel;
    y_pixel;
    color;

BEGIN
    LOOP
        x_pixel=rand(0, 319);
        y_pixel=rand(0, 199);
        color=rand(0, 15);

        // The pixels are put in the background screen at random
        put_pixel(x_pixel, y_pixel, color);

        FRAME;
    END
END
```

In the example, in every step of the loop the pixels are put with the
**put_pixel()** function, with coordinates and color chosen at random with the rand() function.

---

To read the color of a specific background screen color, the get_pixel() function must be used, returning a number between 0 and 255 corresponding to the order of the color inside the palette.

The put() function must be used to set a graphic on the screen, instead of a simple pixel.

It is also possible to set the color of a pixel in a specific graphic, instead of in the background screen, by using the map_put_pixel() function.

---
See: get_pixel() - put() - map_put_pixel() - map_get_pixel()

## [148] put_screen()

**put_screen(**<file>**,** <graphic>**)**

**Description:**

Establishes the background screen. The function requires the **file code** in which the graphic is, and the own **code of the graphic** intended to be displayed in the background screen inside the file.

The graphics loaded with the load_map() function will be used as if they belonged to the first file (the file with the code 0).

The function does not require any coordinate as a parameter since, if the graphic size (in pixels) is different from that of the screen, the former will simply be displayed centered in the latter.

The clear_screen() function must be used to clear the screen background.

Sample program:
```div
PROGRAM example_put_screen;

PRIVATE
    file1;

BEGIN
    file1=load_fpg("help.fpg");

    put_screen(file1, 1); // Graphic 1 is established as background.

    LOOP
        FRAME;
    END
END
```

In the example, the graphics' file is loaded and a background graphic (contained in the file with the graphic code number 1) is set with the put_screen() function.

---

If the aim is to display a graphic on a specific part of the screen or a graphic **that is not centered**, the put() may be used. Moreover, the xput() function allows us to display rotated, scaled, mirror and/or transparent graphics in any screen region.

---
See: put() - xput() - put_pixel() - clear_screen()

## [149] rand()

**rand(**<minimum value>**,** <maximum value>**)**

**Returns:**

A random numeric value.

**Description:**

Returns a random number (chosen at random) between the **minimum value** and the **maximum value**, both included.

This function is normally used to set all the parameters intended to be varied in a game when it is restarted. For instance, the coordinates of an enemy may be initialized with random numbers, so it may appear in a different position in every game.

This function has another utility. Thus, if we want that an action does not always occur, but that it has a certain probability to occur, we normally use a statement of the following type:

  **IF (rand(0, 100)<25)**  
     ** // Action ...**  
  **END**  

In this case, the **action** will take place, on average, 25 per cent of the times the IF statement would be executed. The reason for that is that, on obtaining a random number between 0 and 100, this number would be less than 25 in a fourth of times, approximately.

Sample program:
```div
PROGRAM example_rand;

PRIVATE
    table[15];
    counter;

BEGIN
    write (0, 0, 192, 0, "Press [SPACE] to calculate random values.");
    FROM counter=0 TO 15;
        write_int(0, 0, counter*10, 0, offset table[counter]);
    END
    LOOP
        IF (scan_code==_space)
            FROM counter=0 TO 15;

                // Random values between -100 and 100 are chosen
                table[counter] = rand(-100, 100);

            END
        END
        FRAME;
    END
END
```

In the example, a table with 16 data (from 0 to 15) is created. In every
iteration of the main loop it is checked whether the spacebar has been pressed. If so, the 16 data of the table will be filled with random values between -100 and 100, chosen with the **rand()** function.

---

By default, the values returned by the **rand()** function will completely be different in every execution of the program. If we want to have always the same series of numbers, we may use the rand_seed() function, specifying a number behind which the series of numbers returned by the **rand()** function will always be predetermined.

---
See: rand_seed()

## [150] rand_seed()

**rand_seed(**<numeric value>**)**

**Description:**

This function sets a seed for the generator of random numbers
(the numbers generated by the rand() function).

The seed can be any integer within the range (min_int ... max_int). If the seed is set, all the numbers generated by the rand() function will be the same in every execution of the program.
That is to say, after having been established an origin seed, the rand() function will return a series of numbers predetermined for this seed.

Sample program:
```div
PROGRAM example_rand_seed;

PRIVATE
    table[15];
    counter;

BEGIN
    write (0, 0, 184, 0, "Press [ENTER] to set 1234 as a seed.");
    write (0, 0, 192, 0, "Press [SPACE] to calculate random values.");
    FROM counter=0 TO 15;
        write_int(0, 0, counter*10, 0, offset table[counter]);
    END
    LOOP
        IF (scan_code==_space)
            FROM counter=0 TO 15;
                table[counter] = rand(-100, 100);
            END
        END
        IF (scan_code==_enter)

            rand_seed(1234); // A seed is set to generate the random numbers.

        END
        FRAME;
    END
END
```

In the example, a table with 16 data (from 0 to 15) is created. In every iteration
of the main loop,  the data will be filled with random values from -100 and 100 (chosen with the rand() function) every time the spacebar is pressed.

And when the ENTER key is pressed, then the seed of the random numbers will be defined as 1234 with the **rand_seed()** function.

Notice how, every time the ENTER key is pressed and then, by pressing the space bar, the same series of random numbers (17, 94, -38, ...) is obtained. This series will be different for every possible seed.

---
See: rand()

## [152] refresh_scroll()

**refresh_scroll(**<scroll number>**)**

**Description:**

This function is used when a graphic that is being used as a **background of a scroll region** has been modified with the map_put(), map_xput(), map_block_copy() or map_put_pixel() functions, in order to update it.

The parameter required by the function is the <scroll number> that was specified when the scroll started with the start_scroll() function.

When a graphic that is being used as background of a scroll is modified, it is not automatically updated on the screen. On the contrary, it is necessary to call this function for that purpose.

Once the graphic has been modified, it will remain like this during the rest of the program execution, unless the graphic is unloaded from the memory (with the unload_fpg() or unload_map() functions) and loaded again. In this case, the original state of the graphic will be restored.

Sample program:
```div
PROGRAM example_refresh_scroll;

BEGIN
    load_fpg("help.fpg");
    start_scroll(0, 0, 103, 102, 0, 15);
    scroll.camera=id;
    write(0, 160, 192, 7, "Press [ENTER] to put a graphic in the scroll.");
    write(0, 160, 200, 7, "Press [SPACE] to update scroll.");
    LOOP
        IF (scan_code==_enter)
           map_put(0, 103, 100, rand(16, 48), rand(16, 48));
        END
        IF (scan_code==_space)

            refresh_scroll(0); // We refresh the scroll 0.

        END
        x+=2;
        y+=1;
        FRAME;
    END
END
```

In the example, a scroll (number 0) is created as a scroll of two planes:
the foreground with graphic number 103 and the background with graphic number 102.

Inside the main loop, a ball will be displayed over graphic 103 (foreground of the scroll) when the ENTER key is pressed. But it won't appear on-screen, unless we await until the scroll gradually appears on-screen (with graphic 103 already modified), or until the spacebar is pressed. In this case, the call to the **refresh_scroll()** function will update the scroll window with the graphic already modified.

If, in the previous example, the **refresh_scroll()** function had been called just after the map_put() one, the graphics displayed on the foreground would instantaneously appear by pressing the spacebar.

In the example, every time that a ball is displayed, many of them appear. The reason for this is that graphic 103 used as a foreground in the scroll
is a small graphic and it is shown on many occasions tile, to fill all the scroll zone.

---

**Note:** It can be noticed that, if the displaying graphic is at some coordinates out of the screen, it won't be necessary to call this function, because the parts of the scroll that are gradually appearing on-screen are automatically refreshed.

---
See: start_scroll() - move_scroll() - Scroll structure

## [153] reset_fli()

**reset_fli()**

**Description:**

This function **rewinds** an **FLI/FLC** animation to the beginning. This animation started with the start_fli() function.

After having called this function, the animation will entirely be displayed again from the beginning (to display every frame of the animation, you must call the frame_fli() function).

The utility of this function deals with the possibility of stopping an animation and repeating it again from the beginning, without unloading it (end_fli()) and loading it again.

If the aim is to perform an animation indefinitely, restarting when it is over, then **it is not necessary to use this function**, since it will automatically be done with frame_fli(), if you keep on calling once the animation is over.

Only one animation can exist at the same time. Thus, it is not necessary to specify any parameter for this function.

Sample program:
```div
PROGRAM example_reset_fli;
BEGIN
    start_fli("help.fli", 0, 0);
    write(0, 160, 0, 1, "Press [SPACE] to restart the animation.");
    LOOP
        frame_fli();
        IF (scan_code==_space)

            reset_fli(); // The animation is initialized

        END
        FRAME;
    END
END
```

In the example, an animation is loaded with the start_fli() function and
then, it is indefinitely performed with the frame_fli() function.

In the loop, it is checked whether the spacebar has been pressed. If so, the animation is reinitialized with the **reset_fli()** function.

---
See: start_fli() - frame_fli() - end_fli()

## [154] roll_palette()

**roll_palette(**<initial color>**,** <number of colors>**,** <increment>**)**

**Description:**

Rotates a range of palette colors. This function is used to create movement effects in static graphics, like the effect of flowing water.

To use this function, it is first necessary to create graphics that use a range of consecutive colors of the original palette, in a perpetual cycle
(for instance, colors ranging from **0** to **15**, painting something with the colors 0, 1, 2, 3, ... , 14, 15, 0, 1, 2, ...).

Then, it is necessary to take care that those colors are not used by other graphics that are going to appear on the screen at the same time, if you do not want to implement the effects on them.

The **increment** (third parameter) is normally **1** to perform the rotation in a direction and** -1** to perform it in the opposite direction, but other values may be used to perform the colors cycle at higher speed.

To perform a cycle of colors from **0** to **15**, it would be necessary to specify **0** as <initial color> and **16** as <number of colors>.

Sample program:
```div
PROGRAM example_roll_palette;
BEGIN
    load_fpg("help.fpg");
    put_screen(0, 2);
    write(0, 160, 0, 1, "Press [SPACE] to rotate the entire palette.");
    LOOP
        IF (scan_code==_space)

            roll_palette(0, 256, 1); // The 256 colors rotate.

        END
        FRAME;
    END
END
```

In the example, a multicolor screen is put as background and, inside the program's main loop, the 256 colors of the palette will rotate every time that the spacebar is pressed.

---

To perform other palette effects without replacing some colors by other ones in cycles, the fade() function must be used. This function allows us to perform many colors fading and saturations at different speeds.

There are two simplified versions of this last function that allow us to carry out a fading to black (fade_off()) and undo it (fade_on()).

---
See: load_pal() - fade() - fade_off() - fade_on()

## [155] save()

**save(**<file name>**,** <OFFSET data>**,** <sizeof(data)>**)**

**Description:**

Saves a data block from the program memory to a file in the disk, to recover it later, when it is required, with the load() function.

For that, the function requires the **file name**, the offset (inside
the computer memory) of the variable, table or structure stored in
the disk (the datum offset is obtained with OFFSET  
**<datum name>**) and the number of memory positions that this datum occupies (which may be obtained with sizeof**(<file name>)**).

It is possible to save several data (variables, tables or structures) if they have consecutively been defined inside the same section (GLOBAL, LOCAL or PRIVATE). In this case, the OFFSET of the first datum must be indicated as a **second parameter**, and the addition of the sizeof() of all the data must be indicated as a **third parameter**.

It is not necessary to specify a path together with the file name.

Sample program:
```div
PROGRAM example_load;

PRIVATE
    table[9];
    counter;

BEGIN
    write (0, 0, 0, 0, "Press [ENTER] to reset the data.");
    write (0, 0, 10, 0, "Press [SPACE] to load the disk data");
    write (0, 0, 30, 0, "Current values of the data:");
    FROM counter=0 TO 9;
        table[counter]=rand(0, 100);
        write_int(0, 0, 40+(counter*10), 0, offset table[counter]);
    END

    save("help.dat", offset table, sizeof(table)); // The file is saved.

    LOOP
        IF (key(_enter))
            FROM counter=0 TO 9;
                table[counter]=0;
            END
        END
        IF (key(_space))
            load("help.dat", offset table);
        END
        FRAME;
    END
END
```

At the beginning of the example, a table of 10 positions (from 0 to 9) is created with random values. This table is saved in the disk with the **save()** function.

When the ENTER key is pressed, the table values are reset (the 10 positions are put at 0).

When the spacebar is pressed, the table's values stored in the disk are loaded with the load() function.

---

To save the **table[9]** and the **counter** variable in the same file, the **save()** function should have been called in the following way:

  **save("help.dat", offset table, sizeof(table)+sizeof(counter));**

Do not vary the load statement (**load("help.dat", offset table);**), as it does not require the number of data.

The value returned by sizeof() for any variable (like **counter**)
will always be 1. For a table, this function returns the number of positions that it has. Then, considering that 11 data (10 of the table and 1 of the variable) are going to be saved, the statement to save them could be as follows:

  {save("help.dat", offset table, 11);

---
See: load() - OFFSET - sizeof()

## [156] set_fps()

**set_fps(**<no. of frames per second>**,** <no. of allowed omissions>**)**

**Description:**

This function regulates the games' speed; it defines the game's number of frames per second that will be displayed.

By default, the display will be regulated at 18 frames per second, which means
that if a process moves a pixel per every (**FRAME**),
it will move on-screen at a speed of 18 pixels per second.

This function may establish the number of Frames Per Second (**FPS**) from a minimum of **4** to a maximum of **200**; in general, no more than
24 frames per second are necessary to obtain a fluid and slight movement.

The second parameter, **maximum number of allowed omissions**, is referred to how the program must preferably work when it is executed in a computer fast enough to calculate the required number of frames per second. It works as follows.

**Number of allowed omissions.**

**0** - The game will go at slower speed when it is executed in a computer too slow. That is to say, it will display the frames per second that the computer has had time to calculate.

**1** - If the computer can not calculate all the frames, it is allowed to occasionally omit any frame to try to keep the game's relative speed. The game movements will become a little more abrupt, but faster.

**2 or more** - The game is allowed to omit as many consecutive frames as it is indicated in this parameter to maintain the original relative speed of the game. For instance, if the number of omissions is set at **4** and in the game a process moved one pixel by one, in a very slow computer it could move even in four pixels at a time.

Sample program:
```div
PROGRAM example_set_fps;

PRIVATE
    frames=24;
    omissions=4;

BEGIN
    load_fpg("help.fpg");
    graph=1;
    x=160;
    y=100;
    write(0, 0, 0, 0, "Frames per second: Up(+) / Down(-)");
    write_int(0, 0, 10, 0, offset frames);
    write(0, 0, 20, 0, "Allowed omissions: Right(+) / Left(-)");
    write_int(0, 0, 30, 0, offset omissions);
    write(0, 160, 200, 7, "Use the CURSORS to change the values.");
    LOOP

        // The number of frames per second is chosen
        set_fps(frames, omissions);

        IF (key(_up) AND frames<200) frames++; END
        IF (key(_down) AND frames>4) frames--; END
        IF (key(_right) AND omissions<20) omissions++; END
        IF (key(_left) AND omissions>0) omissions--; END
        angle+=4000;
        FRAME;
    END
END
```

In the example, the necessary messages are displayed and the main process
creates a graphic, which is indefinitely rotating at the center of the screen.

In every step of the loop the cursor keys are detected, the number of frames per second (**frames**) is changed with **up/down** and
the maximum number of allowed **omissions** is changed with **right/left**.

At the beginning of every iteration of the loop, the speed is set with the  **set_fps()** function, according to the values of both variables.

---
See: FRAME - max_process_time -set_mode()

## [157] set_mode()

**set_mode(**<new videomode>**)**

**Description:**

Establishes a new video mode for the game execution. The allowed videomodes that may be specified as a parameter are the following ones:

  **m320x200**  - VGA standard  
  **m320x240**  - X Mode  
  **m320x400**  - X Mode  
  **m360x240**  - X Mode  
  **m360x360**  - X Mode  
  **m376x282**  - X Mode  
  **m640x400**  - SVGA VESA  
  **m640x480**  - SVGA VESA  
  **m800x600**  - SVGA VESA  
  **m1024x768** - SVGA VESA  

When a change of the videomode in the program is made, a fading to black (of the program's colors palette) will automatically be performed and in the following displays, the colors palette will gradually be restored. That is to say, **set_mode()** always performs a fade_off() just before changing the videomode and a fade_on() just after having changed it.

By default, all the programs start with the 320 by 200 pixel activated mode (**set_mode(m320x200)**).

Sample program:
```div
PROGRAM example_set_mode;

PRIVATE
    modes[]=
        m320x200, m320x240, m320x400, m360x240, m360x360,
        m376x282, m640x400, m640x480, m800x600, m1024x768;
    videomode=0;

BEGIN
    load_fpg("help.fpg");
    write (0, 0, 0, 0, "Press [SPACE] to change the videomode");
    LOOP
        IF (scan_code==_space)
            videomode=videomode+1;
            IF (videomode==10) videomode=0; END

            set_mode(modes[videomode]);

        END
        FRAME;
    END
END
```

In the example, a screen background and an explanatory text are displayed.

In the iteration of the main loop, if the space bar is pressed, a new videomode will be activated with the **set_mode()** function.

---

**Important:** By using the **set_mode()** function, all the scroll and mode 7 windows that were activated in the game, as well as all the processes displayed inside them, will be deleted.

---
See: set_fps() - max_process_time - Constants m320x200 ... m1024x768

## [158] signal()

**signal(**<id>**,** <signal>**)**

**Description:**

Sends a signal to a process (an object of the game). This function is mainly (but not only) used to destroy (to kill) a process from another one, sending it 
a s_kill signal.

If you do not know what we mean when we refer to a father, son, **brother**, **orphan**, etc. process, then see Processes hierarchy.

If you do not know the alive, **dead**, **asleep**, etc. terms referred to processes, see States of a process.

Sample program:
```div
PROGRAM my_game;
PRIVATE id2;
BEGIN
    id2=my_process();
    // ...
    signal(id2, s_kill);
END
PROCESS my_process()
BEGIN
    // ...
    LOOP
        FRAME;
    END
END
```

This program would create a **my_process** type process and then it would delete it with the **signal(id2,s_kill)** statement (id2 is a variable of the main program that contains the identifying code of the process that is going to be deleted).

Any process may send a signal to another one, provided that the former has the identifying code of the latter. See:

  Identifying codes of processes  
  Ways to obtain the identifying code of a process  

Nevertheless, there are other **signal types** that may be sent to a process,
and they are the following ones:

s_kill - Order to **kill** the process. The process will not appear in the following frames of the game any longer.

s_sleep - Order to **make** the process **dormant**. The process will remain paralyzed, without executing its code and without being displayed on screen (nor being detected by the rest of the processes), as if it had been killed. But the process will continue to exist in the computer's memory (see **s_wakeup**).

s_freeze - Order to **freeze** the process. The process will remain moveless without running its code. But it will continue being displayed on screen and it will be possible to detect it (in the collisions) by the rest of the processes. The process will continue to exist in the computer's memory, even if its code is not executed (see **s_wakeup**).

s_wakeup - Order to **wake up** the process. It returns a **slept** or **frozen** process to its normal state. The process will be executed and displayed again from the moment that it receives this signal normally.
A process that has been deleted (killed) can not be returned to its normal state, since it does not exist in the computer's memory any longer.

A process can also send these signals to itself, taking into account that the identifying code of a process is always ID (word reserved in the  language to this purpose). The statement would be as follows:

**signal(**id**,** <signal>**)**

Self-deleting a process in this way, sending a s_kill signal to itself, will not instantaneously destroy the process, but in the following (FRAME) display. The RETURN statement can be used to immediately delete a process.

**All the signals sent to processes will be implemented just before the next display of the game**, that is to say, in the next FRAME of the game (not instantaneously).

Together with these four signals, there are other four signals that directly correspond to the previous ones. They are: s_kill_tree, s_sleep_tree, s_freeze_tree and s_wakeup_tree.

These signals are sent not only to the indicated process, but also **to all the processes that it has created**. That is to say, if a s_kill_tree signal is sent to a process, the latter and all its descendants (sons, grandsons, ...) will be deleted as well as all the processes created by it and the processes created by the latter.

An exception to these last four signals is when there is an **orphan process**, that is to say, a process whose father (the process that called it) is already dead. The orphan processes will not receive the signal when it is sent to a process from which they are descended as, on having disappeared their father, it won't be able to send the signal to the processes it created.

Sample program:
```div
PROGRAM example_signal;
PRIVATE
    id_text;
BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    write(0, 0, 0, 0, "1 - create the process");
    write(0, 0, 10, 0, "2 - kill the process");
    write(0, 0, 20, 0, "3 - make the process dormant");
    write(0, 0, 30, 0, "4 - freeze the process");
    write(0, 0, 40, 0, "5 - wake up the process");
    id_text=write(0, 0, 190, 0, "There is no process");
    LOOP
        IF (key(_1) AND NOT son)
            delete_text(id_text);
            my_process();
            id_text=write(0, 0, 190, 0, "Alive process");
        END
        IF (key(_2) AND son)
            delete_text(id_text);
            signal(son, s_kill);
            id_text=write(0, 0, 190, 0, "There is no process");
        END
        IF (key(_3) AND son)
            delete_text(id_text);
            signal(son, s_sleep);
            id_text=write(0, 0, 190, 0, "Asleep process");
        END
        IF (key(_4) AND son)
            delete_text(id_text);
            signal(son, s_freeze);
            id_text=write(0, 0, 190, 0, "Frozen process");
        END
        IF (key(_5) AND son)
            delete_text(id_text);
            signal(son, s_wakeup);
            id_text=write(0, 0, 190, 0, "Alive process");
        END
        FRAME;
    END
END

PROCESS my_process()
BEGIN
    graph=100;
    LOOP
        x=160+get_distx(angle, 140);
        y=100+get_disty(angle, 80);
        angle+=5000;
        FRAME;
    END
END
```

With the **1** key, this program will create a process (**my_process**) that rolls around the screen; with the keys from **2** to **5**, different signals will be sent to this process, by using this function. The identifying code
of **my_process** is located in the **son** local variable of the main program by default.

When a process is created, the system defines the son variable of the father with the identifying code of the son, and the father variable of the son with the identifying code of the father.

---

**signal(**TYPE <process name>**,** <signal>**)**

**Description:**

This second meaning of the **signal** function is similar to the previous one, with the exception that, instead of sending a signal to a process from its identifying code, it allows us to send a signal {to all the processes
of a specific type} or to them and their descendants, when the used signals are
of the type **s_kill_tree** (see: Types of processes).

For instance, if several processes of the **enemy** type exist or may exist in a game, and the aim is to freeze these processes (without freezing their descendants), the following statement will be used:

  **signal(TYPE enemy, s_freeze);**

As it can be noticed, it is necessary to have the identifying code of a specific process in order to send a signal to it. To delete a group of processes, it is necessary either that they are of the same kind, that this group is made up of a process and its descendants, or that all their identifiers are known ( in order to send them the signal one by one).

It is possible to send a signal to a type of processes, even if no process of this type is being executed in the game. But if a signal is sent to a process that has already been killed, with its identifying code (first meaning of the **signal** statement), there is a risk that the identifying code is now used by another process, which is going to receive the signal. This happens, for instance, when the aim is to kill a process that has already been killed, as it is possible that another different one is being killed.

---

**Note:** If the aim is to delete all the processes except the current one, the let_me_alone() function may be used. This function sends a **s_kill** signal  to all the processes, except the one that executed this function.

---
See: let_me_alone() - Identifying codes - Types of processes

## [159] sound()

**sound(**<sound code>**,** <volume>**,** <frequency>**)**

**Returns:**

The **channel number** through which the sound is played.

**Description:**

Plays the effect whose **sound code** is specified as first parameter.
At first, the sound must have been loaded from a PCM archive with the load_pcm() function. This function returns the **sound code** corresponding to this effect.

As a second parameter, it is necessary to specify the **volume** at which the sound is intended to be reproduced, taking into account that **0** is the minimum volume, and **256** the maximum volume.

As third parameter, you must specify the **frequency** (speed) at which the sound is intended to be reproduced, being **256** the standard frequency that will reproduce the original sound. With lesser values, the sound will be reproduced with more accentuated bass. On the contrary, with higher frequency values, it will be reproduced with more accentuated treble.

The function returns the **channel number** that can be used by the
stop_sound() function to stop the sound and by the change_sound() function to modify its volume or frequency.

There are 16 sound channels. Thus, up to 16 sounds may simultaneously be played.

Sample program:
```div
PROGRAM example_sound;

PRIVATE
    volume=128;        // Averagevalue (0..256)
    frequency=256;     // Averagevalue (0..512)
    id_sound, channel;

BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    write(0, 0, 0, 0, "Volume: Up(+) / Down(-)");
    write_int(0, 0, 10, 0, offset volume);
    write(0, 0, 20, 0, "Frequency: Right(+) / Left(-)");
    write_int(0, 0, 30, 0, offset frequency);
    write(0, 160, 180, 1, "Press [SPACE] to play the sound.");
    write(0, 160, 190, 1, "Use the cursors to change the values.");

    id_sound = load_pcm("help.pcm", 0);

    LOOP
        IF (scan_code==_space)

            // Plays it
            channel = sound(id_sound, volume, frequency);

        END
        IF (key(_up) AND volume<256) volume++; END
        IF (key(_down) AND volume>0) volume--; END
        IF (key(_right) AND frequency<512) frequency++; END
        IF (key(_left) AND frequency>0) frequency--; END
        FRAME;
    END
END
```

In the example, a background screen and an explanatory text are displayed,
and a sound is loaded with the load_pcm() function. This function returns the **identifier of the sound**, that is stored in the **id_sound** variable.

In the main loop, at every keystroke of the spacebar, the sound is played with the **sound()** function with the parameters defined in the **volume** and **frequency** variables.

These values can be manipulated with the cursors keys, in order to understand better how it works.

The **channel number** returned by **sound()**, that is stored in the **channel** variable, could have been used to modify the sound with change_sound()
or to stop it with stop_sound().

---
See: load_pcm() - unload_pcm() - change_sound() - stop_sound()

## [160] sqrt()

**sqrt(**<expression>**)**

**Returns:**

The entire square root of the expression.

**Description:**

Calculates the square root of the expression passed as a parameter, **truncated to an integer**.

For instance, as a result, **sqrt(10)** will return **3** and not **3.1623**, which is the real value (approximately) of the square root of ten.

Sample program:
```div
PROGRAM example_sqrt;

GLOBAL
    values[15];
    n;

BEGIN
    FROM n=0 to 15;
        values[n]=rand(0, 100000);
        write_int(0, 0, n*10, 0, offset values[n]);
    END
    write(0, 0, 192, 0, "Press [SPACE] to calculate its square root");
    LOOP
        IF (scan_code==_space)
            FROM n=0 TO 15;

                values[n] = sqrt(values[n]);

            END
        END
        FRAME;
    END
END
```

This program will display a list of randomly chosen values on-screen. When the spacebar is pressed, the program will apply the **sqrt()** function to all these values, calculating their square root.

---
See: Expression

## [161] start_fli()

**start_fli(**<archive name>**,** <x>**,** <y>**)**

**Returns:**

The animation's number of frames.

**Description:**

Starts a **FLI/FLC** animation contained in the specified **archive**, in the
coordinates (**x**, **y**) (the upper left coordinate of the display window
must be specified).

The path can be specified in the <archive name>. The path is not necessary if the archive is in the DIV Games Studio directory or in a subdirectory whose name coincides with archive extension (for instance, "fli\anima.fli").

The screen must hold the whole animation. That is to say, if the animation
occupies the whole screen, the videomode must be fixed at first with the
set_mode() function, starting then the animation at the (0, 0) coordinate with the **start_fli()** function.

For your information, the function returns the number of frames that the whole animation comprises.

The system will automatically activate the color palettes that the **FLI/FLC** animation could have. This can cause problems dealing with the representation
of other graphics or fonts of the program, if they had been drawn with a different palette.

If the aim is to combine other graphics with animation on-screen, the latter must have just one color palette (which is normally called "**palette low FLI/FLC**")
and the graphics must have been drawn with that same palette.

Once the animation has started, its frames will gradually be shown with respective calls to frame_fli().

**It is possible to have but one active animation at every time**. Therefore, after having started an animation with **start_fli()** and having been displayed with frame_fli(), this animation must finish with the end_fli() function before starting another different animation.

Sample program:
```div
PROGRAM example_start_fli;
BEGIN

    start_fli("help.fli", 0, 0); // An animation is started.

    LOOP
        frame_fli();
        FRAME;
    END
END
```

In the example, the animation contained in the **help.fli** archive is started with the **start_fli()** function at the (0, 0) coordinates and this animation is indefinitely executed.

---

The frame_fli() function, used to show every frame, will return 0 when the animation is over. Therefore, to show the animation just one time you should have done as follows:

Sample program:
```div
PROGRAM example_start_fli;

PRIVATE
    value;

BEGIN
    start_fli("help.fli", 0, 0);
    REPEAT
        value=frame_fli();
        FRAME;
    UNTIL (value==0);
    end_fli();
END
```

The reset_fli() function allows us **to rewind** the animation, so that the frame_fli() function continues to execute it from the beginning.

---
See: end_fli() - reset_fli() - frame_fli()

## [162] start_mode7()

**start_mode7(**<m7 number>**,** <file>**,** <graphic>**,** <external graphic>**,**
              <region number>**,** <height of horizon>**)**

**Description:**

This is an advanced function whose use requires special skill of its user.

Creates a mode-7 display window. That is to say, it displays a **three-dimensional** graphic in a folded plane. In order to obtain this effect, this function will be called with the following parameters:

**<m7 number>** - Up to 10 mode-7 windows can be created on-screen,
numbered from **0** to **9**. If the aim is to create but one, the best thing is to define window number **0**. This number will be necessary later to modify the window parameters, as the system will need to know which one of the possible **10** mode-7 windows is intended to modify.

**<file>** - The graphics intended to be folded in the window must be in a file whose **file code** must be specified here, as a second parameter of the function. The graphics loaded with the load_map() function will be used as if they belonged to the first file (the file with the code 0).

**<graphic>** - The third parameter must be the **code of the main graphic** that is going to be folded in the window and it must belong to the file previously indicated.

**<external graphic>** - Here, it is possible to indicate either a **0**, if the aim is not to see any graphic beyond the graphic folded in the perspective, or a **graphic code** of the same file that will be shown in the perspective beyond the **main graphic**, until it gets the horizon. The height and width of this graphic must be powers of two, not higher than **8192** (these powers of two are: 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096 y 8192). For instance, it can be a 64 pixel width by 32 pixel height graphic. This graphic will also be shown folded.

**<region number>** - Here, the rectangular screen region in which the mode-7 is going to be shown, will be indicated. If **0** is indicated as a region number,
this region will be shown on the whole screen. The rest of regions must previously be defined with the define_region() function (a **region** is but a rectangular zone of the screen).

**<Height of the horizon>** - The last parameter to indicate will be the distance, in pixels, from the upper part of the window, where the horizon line is intended to be put. If the camera is placed above the folded plane, then nothing will be displayed above the horizon line (this space is normally filled with another  scroll or mode-7 window). Otherwise, if the camera is placed below the plane, then nothing will be shown below this horizon line. 

---

**Besides the call to the function, some values of the** global structure m7 **must be initialized** **for the correct window's working**.
This is a structure of 10 records (one for every possible mode-7 window)
and every record has the following fields:

  **camera**   - Identifying code of the camera  
  **height**   - Height of the camera  
  **distance** - Distance of the camera  
  **horizon**  - Height of the horizon  
  **focus**    - Focus of vision  
  **z**        - Depth plane  
  **color**    - Exterior color  

**Important:** In order to activate the mode 7 window it is **indispensable**  to start the **camera** field as, without this field, the window can not determine from where the folded plane must  **be seen**.

The camera will be placed in the folded plane, at the indicated **distance** of the process whose identifying code has been set in **camera**, orientated at its angle itself (the one indicated by its angle local variable). The height at which the camera is located with respect to the bottom will be that indicated in the **height** field.

See the help about the m7 structure for further information about these issues, or about how to access them.

---

Sample program:
```div
PROGRAM example_start_mode7;

PRIVATE
    file1;

BEGIN
    file1=load_fpg("help.fpg");

    start_mode7(0, file1, 4, 0, 0, 64);

    m7.height = 64;
    m7.distance = 32;
    m7.color = 162;
    m7.camera = id;

    write(0, 160, 0, 1, "Use the cursors to move");
    LOOP
        IF (key(_right)) angle-=8000; END
        IF (key(_left)) angle+=8000; END
        IF (key(_up)) advance(6); END
        FRAME;
    END
END
```

In the example, the graphics file is loaded and then, a three-dimensional mode 7 is created with the **start_mode7()** function. This function is passed the following parameters:

**0** - Number of mode 7 window (the first one, as just one window of this kind will be created).

**file1** - Code of the file from which the graphics must be taken. This is the code of the **help.fpg** archive, that was loaded with the load_fpg() function.

**4** - Code of the main graphic to fold inside the mode 7. To see this graphic, the file must be loaded with the **Files menu**. Thus, it is possible to observe which one is the graphic with **code 4**.

**0** - Code of the secondary graphic. A 0 indicates that no secondary (external) graphic will appear in the mode 7, so the external graphic will be displayed in the color indicated by the **m7[0].color** variable. In order to observe the effect of putting an **external graphic**, this parameter can be replaced, for instance, by  **100** (that is the code of a 32 by 32 pixel brown ball stored in the **help.fpg** file).

**0** - Region number of the screen on which the mode 7 must be **placed**.
A 0 indicates that it must be placed on the entire screen.

**64** - Height of the horizon. This last parameter indicates that the horizon line will be placed at 64 pixels from the upper part of the window.

After having called the **start_mode7()** function, the program defines the following values of the global structure m7:

**m7.height=64;** - To show that the camera must be placed at 64 pixels from the bottom.

**m7.distance=32;** - To show that the camera must be placed at 32 pixels behind the camera process.

**m7.color=162;** - To indicate that the external part must be displayed in color number 162 of the palette.

**m7.camera=**id**;** - To indicate that the current process will be the camera process.

The camera will be placed 32 pixels behind the main process, at 64 pixels height, orientated at the angle indicated by its angle variable.

After these initializations, the sample program will remain in a loop that simply controls the angle of the main process with the cursors. This angle will be that of the camera and, when the **up cursor** key is pressed, the advance() function will be called for the main process (and, consequently, the mode 7 camera) to advance 6 pixels.

---
**How to visualize processes graphics in mode 7.**

---

To create a process whose graphic is displayed in the mode 7, its ctype local variable must be defined as c_m7 (**type of coordinate**
as **mode 7 coordinate**), which will be done with the following statement:

  **ctype=c_m7;**

After this, the process will be displayed in the mode 7 with its graphic (graph) scaled depending on the distance at which it is. The process must only modify its x and y variables to move through the folded plane.

---

**When a process belongs to the mode-7 (that is to say, the value c_m7 has been assigned to its local variable** ctype**):** 

  - Its x and y variables will  be referred to the folded main graphic's point above which the process graphic will be placed.

  - Its z variable will lose its effect, as the graphics will appear in strict order of depth. This variable will only be useful to indicate display priorities in graphics exactly placed in the same depth plane.

  - The process will automatically be deleted when the mode 7 window, to which the process belongs, is deleted with the stop_mode7() function,
or when the videomode is changed with the set_mode() function as, by doing so, the mode 7 windows will also be deleted.

---

If there were several **mode 7** windows, the process would be displayed in all of them by default. If the process had to be displayed just in one of them, its cnumber local variable should be then defined. For instance, if there were 6 mode 7 windows (from number 0 to number 5) and the aim was to display a process only in windows 0 and 2, the following statement should be included in it:

  **cnumber=c_0+c_2;**

---

For a process to have several graphics (several views), depending on the
angle from which it is observed, its graphic must be defined with the xgraph local variable (instead of the graph variable).
To define this variable, it is necessary, at first, to create a table (of any name), first indicating the graphic's **number of views** and then the **graphics codes** for these views, starting with **angle 0** and in an anticlockwise direction. For instance:

  **GLOBAL**  
    **views_car[]=4, 100, 101, 102, 103;**  

The table **views_car** would define 4 views: graphic 100 for angles
near 0 degrees, graphic 101 for angles near 90 degrees,
graphic 102 for angles near 180 degrees, etc.

And then, the xgraph variable must be initialized in the process code with the following statement:

  **xgraph=OFFSET views_car;**

To get an example about what we have just seen, examine some of the DIV Games Studio's sample games that use this technique. Thus, read the comments about these programs (for instance, see **Speed for dummies**).

---
See: stop_mode7() - Structure m7

## [163] start_scroll()

**start_scroll(**<scroll number>**,** <file>**,** <graphic>**,** < background graphic>**,**
               <region number>**,** <locking indicator>**)**

**Description:**

This function has a certain complexity, requiring a special skill of the user, who (should have previously programmed) to use it.

Creates a scroll window, in which it will perform a view against a background graphic (the décor of the game). That is to say, by using a graphic bigger than the display window as a game background, a part of this graphic can be showed and shifted in any direction.

To obtain this effect, this function will be called with the following parameters:

**<scroll number>** - Up to 10 scroll windows can be created on screen,
numbered from **0** to **9**. If the aim is to create only one, the best thing is to define window number **0**. This name will later be necessary to modify the parameters of the window, as the system will need to know which one of the **10** possible scroll windows is intended to change.

**<file>** - The graphics that are intended to be shown as a background or décor in that window must be in a file whose **file code** must be specified here, as a second parameter of the function. The graphics loaded with the load_map() function will be used as if they belonged to the first file (the file with the code 0).

**<graphic>** - The third parameter must be the **code of the** main **graphic** that is going to be displayed as a background in the window and that must belong to the file previously indicated. This graphic is normally the main décor of the game on which the action will be developed. It is a graphic bigger than the display window, that will be shifted in one or several directions and on which the graphics of the game will be placed.

The scroll window will be initially placed with the control point
number **0** of this graphic in the upper left corner, when this point has been defined in the **graphic editor**.

**<background graphic>** - Here, **0** will be indicated if the aim is to obtain a single scroll plane (a single background graphic), or another **graphic code** if it is intended that it appears as scroll background (deeper),
behind the foreground. In order to see this background plane, it is indispensable that the **main graphic** (foreground) has parts painted in color number 0 of the palette, as these transparent zones will allow us to see the **background graphic** through them.

**<region number>** - The rectangular screen region in which the scroll is going to be shown will be here indicated. If **0** is indicated as a region number,
it will be shown on full screen. The rest of regions must previously be defined with the define_region() function (a **region** is but a rectangular zone of the screen).

**<locking indicator>** - A value defining whether each of the two scroll planes is horizontally and vertically cyclical will be here indicated. For instance,
a plane is horizontally cyclical when, on leaving the picture on the right, the picture appears on the left. To obtain this value, the following quantities must be added:

 ** + 1** - If the foreground is horizontally cyclical.  
 ** + 2** - If the foreground is vertically cyclical.  
 ** + 4** - If the background is horizontally cyclical.  
 ** + 8** - If the background is vertically cyclical.  

That is to say, **0** if none of the two planes must be cyclical, **15** (**1**+**2**+**4**+**8**)
if both planes must be cyclical in both axes, **12** (**4**+**8**) if only the background must be cyclical, etc.

When a (foreground or background) graphic is smaller than the display window,
the system will force it to have a cyclical scroll plane. Otherwise, the scroll window could not be completely filled, without **cyclically** repeating
the graphic (tile).

---

**Besides the call to the function, some values of the** scroll global structure **must be initialized** **for the correct working of the window**.
This is a structure of 10 records (one for each possible scroll window)
and every record has the following fields:

  **x0, y0**  - Foreground coordinates  
  **x1, y1**  - Background coordinates  
  **z**       - Depth plane  
  **camera**  - identifying code of the camera  
  **ratio**   - Background's relative speed  
  **speed**   - Foreground's maximum speed  
  **region1** - First screen region  
  **region2** - Second screen region  

There are two ways to program the movement of the scroll windows:

- Manually, modifying in each frame of the game the fields **x0**, **y0**,
**x1** and **y1** of this structure (the scroll planes' coordinates).

- Automatically, for what the identifying code of a process is needed in the field **camera** of this structure. From then, the system will be in charge of following the graphic of this process in the scroll window.

See the help about the scroll structure either for further information about these fields, or to know how to access them.

---

Sample program:
```div
PROGRAM example_start_scroll;

PRIVATE
    file1;

BEGIN
    file1=load_fpg("help.fpg");

    start_scroll(0, file1, 103, 102, 0, 15);

    scroll.camera=id;

    ctype=c_scroll;
    graph=100;
    write(0, 160, 0, 1, "Use the cursors to move");
    LOOP
        IF (key(_right)) x+=2; END
        IF (key(_left)) x-=2; END
        IF (key(_down)) y+=2; END
        IF (key(_up)) y-=2; END
        FRAME;
    END
END
```

In the example, the graphics file is loaded and then, a scroll window is created with the **start_scroll()** function. The latter is passed the following parameters:

**0** - Number of scroll window (the first one, as only a window of this kind will be created).

**file1** - Code of the file from which the graphics must be taken. This is the code of the archive **help.fpg** loaded with the load_fpg() function.

**103** - Code of the main graphic (foreground) of the scroll. In order to see this graphic, the file must be loaded with the **Files menu**, being then possible to observe which is the graphic with **code 103**.

**102** - Code of the secondary graphic (background). This graphic will be shown in the scroll window **behind** the main graphic.

**0** - Number of the screen's region in which the scroll must **be placed**. 0 indicates that it must be put on the entire screen.

**15** - Lock indicator; 15 (1+2+4+8) indicates that the foreground as well as the background will be cyclical in both axes (horizontal and vertical).

After having called the **start_scroll()** function, the program defines the field **camera** of the scroll structure, assigning the identifying code
of the main process to it (with the **scroll.camera=**id**;** statement). Thus, the scroll becomes **automatic**, following the graphic of the main process from that moment.

The program continues to define its **type of coordinate** as a **scroll coordinate** (with the **ctype=c_scroll;** statement), defining its graphic as number 100, that is a brown ball (with **graph=100;**), and displaying a message. Then, it will stay in a loop in which the coordinates of this process (the x and y variables) may vary with the cursor keys.

---

Sample program:
```div
PROGRAM example_start_scroll;

PRIVATE
    file1;

BEGIN
    file1=load_fpg("help.fpg");

    start_scroll(0, file1, 103, 102, 0, 15);

    write(0, 160, 0, 1, "Use the cursors to scroll");
    LOOP
        IF (key(_right))
            scroll.x0+=2;
            scroll.x1+=1;
        END
        IF (key(_left))
            scroll.x0-=2;
            scroll.x1-=1;
        END
        IF (key(_down))
            scroll.y0+=2;
            scroll.y1+=1;
        END
        IF (key(_up))
            scroll.y0-=2;
            scroll.y1-=1;
        END
        FRAME;
    END
END
```

In the example, the graphics file is loaded and then, a scroll window is created with the **start_scroll()** window. The latter is passed exactly the same parameters as in the previous example.

After that, the program will stay inside a loop in which, on detecting the cursor keys, the fields **x0**, **y0**, **x1** and **y1** of the scroll global structure will vary. These fields define the coordinates of the two planes of the scroll (**x0**, **y0** are the coordinates of the foreground and **x1**, **y1** those of the background).

The difference between both methods can be noticed. The latter can directly manipulate the coordinates of both planes, as it has not initialized the field **camera** of the structure.

---
**How to display processes' graphics in the scroll.**

---

In order to create a process whose graphic is displayed in the scroll window, it is necessary to define its ctype local variable as c_scroll (**type of coordinate** as **scroll coordinate**), which will be done with the following statement:

  **ctype=c_scroll;**

After that, the process will be displayed in the scroll with its graphic (defined in the graph local variable). The process must modified only its x and y variables to scroll.

---

{When a process belongs to the scroll (assigning the value c_scroll to its
local variable} ctype**):**

  - Its x and y variables will be referred to the point of the foreground's graphic on which the graphic of the process will be placed.

  - Its z variable will be now referred to the **variables z** of the
processes that also belong to the same scroll window. That is to say,
each time that a scroll window is displayed, all the graphics that belong to it (ranged by their **z**) will be displayed just after it. Then, the processes that **don't belong to that scroll window** will continue to be displayed.

  - The process will be automatically eliminated when the scroll window to which the process belongs is eliminated with the stop_scroll() function.
Or when the videomode is changed with the set_mode() function as, on doing so, the scroll windows will be also eliminated.

---

If there were several **scroll** windows, the process would be displayed by default in all of them. If it had to be displayed only in some of them, its cnumber local variable should be defined. For instance, if there were 6 scroll windows (numbered from 0 to 5) and the aim was to display a process only in windows 0 and 2, the following statement should be included in it:

  **cnumber=c_0+c_2;**

In order to observe an example of what it has been said, the best thing is to examine some of the sample games of DIV Games Studio that use this technique. Thus, the reader is directly referred to the comments of these programs (for instance, see the example **Helioball**).

---
See: stop_scroll() - refresh_scroll() - move_scroll() - Scroll structure

## [164] stop_cd()

**stop_cd()**

**Description:**

Turns the CD-Audio off, stopping the song that was playing.
The songs are reproduced with the play_cd() function.

Sample program:
```div
PROGRAM example_stop_cd;
BEGIN
    write(0, 160, 0, 1, "Press [ENTER] to turn the CD on.");
    write(0, 160, 10, 1, "Press [SPACE] to turn the CD off.");
    LOOP
        IF (scan_code==_space)

            stop_cd(); // Stops the CD

        END
        IF (scan_code==_enter)
            play_cd(2, 0);
        END
        FRAME;
    END
END
```

In the example, the necessary messages are displayed. In every step of the loop, the CD will stop with the **stop_cd()** function if the spacebar is pressed.

If the Enter key is pressed, the CD will start playing with the play_cd() function.

The cd-audio reproduction volume may be controlled with the setup structure and the set_volume() function.

---
See: play_cd() - is_play_cd() - set_volume() - Setup structure

## [165] stop_mode7()

**stop_mode7(**<m7 number>**)**

**Description:**

Deletes the mode 7 window whose number (from 0 to 9) is passed as a parameter. This <m7 number> was indicated as first parameter in the
start_mode7() function, and it is necessary as there can be up to 10 different mode 7 windows, and the system needs to know which one is finishing.

On deleting a mode 7 window, all the processes that exclusively belong to that window will be killed automatically. These processes have their ctype variable with the c_m7 value and they are not displayed in any other mode 7 window.

**Important:** On changing the videomode with the set_mode() function, all the mode 7 windows (and their processes) will also be deleted. In this case, it is not necessary to use this function (**stop_mode7()**).

Sample program:
```div
PROGRAM example_stop_mode7;
BEGIN
    load_fpg("help.fpg");
    write(0, 160, 0, 1, "Press [ENTER] to put the mode 7.");
    write(0, 160, 10, 1, "Press [SPACE] to remove the mode 7.");
    write(0, 160, 190, 1, "Use the mouse to move through the mode 7.");
    angle=90000;
    LOOP
        IF (scan_code==_space)

            stop_mode7(0); // The mode 7 is stopped

        END
        IF (scan_code==_enter)
            start_mode7(0, 0, 4, 0, 0, 64);
            m7.camera=id;
        END
        x=mouse.x;
        y=mouse.y;
        FRAME;
    END
END
```

In the example, the graphics file is loaded and the instructions of the program are shown on screen. Then, the coordinates of the main process (which will be used as a mode 7 camera), will be controlled with the mouse (through the **x=mouse.x;** and **y=mouse.y** statements).

When the ENTER key is pressed, a mode 7 window will be created with a graphic of a folded circuit, and controlled by the main process.

The **stop_mode7()** function will be called on pressing the spacebar. This
function will eliminate the mode 7 window.

---

The creation of a mode 7 window is a somewhat advanced process and it requires the start of several parameters, (like that of the camera, in this case), some of them required by the start_mode7() function and some others contained in the m7 global structure (like the **m7.camera** variable, used in the example).

---
See: start_mode7() - m7 structure

## [166] stop_scroll()

**stop_scroll(**<scroll number>**)**

**Description:**

Deletes the scroll window whose number (from 0 to 9) is passed as a parameter. This <scroll number> was indicated as first parameter in the
start_scroll() function and it is necessary since there can be up to 10 different scroll windows, and the system needs to know which one is finishing.

On deleting a scroll window, all the processes that exclusively belong to that window will automatically disappear. These processes have their ctype variable with the c_scroll value and they are not displayed in any other scroll window.

**Important:** On changing the videomode with the set_mode() function, all the scroll windows (and their processes) will also be deleted. In this case, it is not necessary to use this function (**stop_scroll()**).

Sample program:
```div
PROGRAM example_stop_scroll;
BEGIN
    load_fpg("help.fpg");
    write(0, 160, 0, 1, "Press [ENTER] to activate the scroll window.");
    write(0, 160, 10, 1, "Press [SPACE] to stop the scroll.");
    LOOP
        IF (scan_code==_space)

            stop_scroll(0); // The scroll is stopped.

        END
        IF (scan_code==_enter)
            start_scroll(0, 0, 103, 102, 0, 15);
        END
        scroll.x0+=1;
        scroll.y0+=1;
        scroll.x1-=1;
        FRAME;
    END
END
```

In the example, the graphics' file is loaded and the instructions of the program are shown on screen.

When the ENTER key is pressed, a scroll window will be created, and the **stop_scroll()** function will be called on pressing the spacebar. This function will
delete the scroll window.

Inside the main loop, it is possible to access the scroll coordinates contained
in the scroll global structure to manually move the scroll window (**scroll.x0+=1; ...**).

---

The creation of a scroll window is a somewhat advanced process and it requires the start of several parameters, some of them required by the start_scroll() function and some others contained in the scroll global structure (like the **scroll.x0** variable, used in the example).

---
See: start_scroll() - Scroll structure

## [167] stop_sound()

**stop_sound(**<channel number>**)**

**Description:**

Stops the sound that is being played through the channel, passed as a parameter.

The required <channel number> is the value returned by the sound() function when the reproduction of a sound effect starts.

There are 16 sound channels. Thus, up to 16 sounds may simultaneously be played.

Sample program:
```div
PROGRAM example_stop_sound;

PRIVATE
    id_sound;
    channel;
    playing=FALSE;

BEGIN
    load_fpg("help.fpg");
    put_screen(0, 1);
    write(0, 160, 0, 1, "Press [SPACE] to start the reproduction.");
    write(0, 160, 10, 1, "Press [ENTER] to stop the sound channel.");
    id_sound = load_pcm("help.pcm", 1);
    LOOP
        IF (scan_code==_space AND NOT playing)
            channel = sound(id_sound, 128, 256);
            playing=TRUE;
        END
        IF (scan_code==_enter)

            stop_sound(channel); // The sounds stops playing

            playing=FALSE;
        END
        FRAME;
    END
END
```

In the example, a background graphic is put and the necessary messages are displayed. At the same time, the sound effect stored in the **help.pcm** archive is loaded with the load_pcm() function, that returns the sound identifier that is stored in the **id_sound** variable. Notice that, in this example, **1** is passed to this function as a second parameter. That is done to indicate that the loaded sound effect must indefinitely be repeated every time it is initialized (stressing thus the effect of the **stop_sound()** function).

In every step of the loop, it is checked whether the spacebar is pressed. In this case, the reproduction of the sound effect will start with the sound() function, which will return the channel number that will be stored in the **channel** variable.

If the ENTER key is pressed, the sound will be stopped with the **stop_sound()** function.

---

To gradually stop a sound, turning its volume down little by little, several calls to the change_sound() function must be made to slightly reduce the channel volume until it reaches level 0. Then, the **stop_sound()** can be called to definitively stop the sound.

---
See: sound() - change_sound() - load_pcm() - unload_pcm()

## [168] system()

**system(**<"external command">**)**

**Description:**

Executes the operative system's command passed as a parameter.

Sample program:
```div
PROGRAM example_system;
BEGIN
    write(0, 160, 0, 1, "Press [SPACE] to execute a DIR.");
    LOOP
        IF (scan_code==_space)

            system("dir"); // A command of MS-DOS is executed.

        END
        FRAME;
    END
END
```

In the example, after the display of a text, you enter inside the main loop in which the **DIR** command of the MS-DOS operative system will be executed every time the spacebar is pressed.

---

One of the utilities of this command is, for instance, to delete a temporary archive that has been created in the program, calling the command of the
system **DEL <**archive name**>**.

---

**Note:** The system can be blocked depending of the executed commands. In these cases you must reset the computer. There is no guarantee dealing with this function running, due to the multiple incompatibilities that can appear between the external commands and the manager of internal processes of DIV Games Studio.

---

**system("COMMAND.COM")**

**Description:**

Executes a session of the MS-DOS operative system from the program itself.
On typing EXIT from it, you will return to the program at the point in which this statement was executed.

---
See: exit()

## [169] unload_fpg()

**unload_fpg(**<file code>**)**

**Description:**

Unloads the graphics file whose code is passed as parameter from the memory. This <file code> is the value returned by the load_fpg() function when a new graphics file is loaded in the memory.

After having unloaded a graphics' file, **much care must be taken** not to go on using in the program any graphic that was in that file. Otherwise, the program could become blocked.

**It is not necessary to unload the file from the memory** before finishing the program, as the system will do it automatically.

Therefore, a file must be unloaded from the memory only when it is not going to be used for a while and when the aim is to free up space occupied in the computer's memory in order to load other resources (other graphics files, sounds, fonts, etc.).

Sample program:
```div
PROGRAM example_unload_fpg;

PRIVATE
    file1;

BEGIN
    file1=load_fpg("help.fpg");
    put_screen(file1, 1);
    write(0, 160, 0, 1, "Press [ENTER] to unload the file and finish");
    REPEAT
        FRAME;
    UNTIL (key(_enter));

    unload_fpg(file1); // The file is loaded.

END
```

The example loads the graphics file contained in the **help.fpg** archive
with the load_fpg() function, storing the **file code** in the
**file1** private variable.

The program will remain in a loop until the ENTER key is pressed. At that moment, the file will be unloaded from the memory with **unload_fpg()**
and the program will finish.

---

The graphics individually loaded with the load_map() function will not be unloaded when file number 0 (with code 0) is loaded , even if they were used as if they belonged to it. These graphics will have to be unloaded by using the unload_map() function.

---
See: load_fpg() - load_map() - unload_map()

## [170] unload_pcm()

**unload_pcm(**<sound code>**)**

**Description:**

Unloads the sound whose code is passed as a parameter from the memory.
This <sound code> is the value returned by the load_pcm() function when a new sound effect is loaded in the memory.

After having unloaded a sound effect, **much care must be taken** not to go on using in the program this effect (its code) for the sound() or **unload_pcm()** functions. Otherwise, the program could become blocked.

**It is not necessary to unload the sound from the memory** before finishing the program, as the system will do it automatically.

Therefore, a sound must be unloaded from the memory only when it is not going to be used for a while and when the aim is to free up space occupied in the computer's memory to load other resources (other graphics files, sounds, fonts, etc.), which will be logical just with sound effects of a certain length, that is to say, big enough so as to be worth freeing up the space they occupy.

Sample program:
```div
PROGRAM example_unload_pcm;

PRIVATE
    sound1;

BEGIN
    sound1=load_pcm("help.pcm");
    write(0, 160, 0, 1, "Press [ENTER] to unload the sound and finish");
    REPEAT
        FRAME;
    UNTIL (key(_enter));

    unload_pcm(sound1); // The sound is unloaded.

END
```

The example loads the sound effect stored in the **help.pcm** archive
with the load_pcm() function, storing the **sound code** in the
**sound1** private variable.

The program will remain in a loop until the ENTER key is pressed. At that moment, the file will be unloaded from the memory with **unload_pcm()**
and the program will finish.

---

The stop_sound() function must be used to stop a sound effect, but keeping it in the memory in order to be played again when desired.

---
See: load_pcm() - sound() - change_sound() - stop_sound()

## [171] write()

**write(**<font>**,** <x>**,** <y>**,** <centering code>**,** <text>**)**

**Returns:**

The identifying code of the text that has been written.

**Description:**

This function is used to show an alphanumeric text on-screen. For that, it requires the following parameters:

**<font>** - The **font code** or **type of letter** that is going to be used.
Here, you must put either 0 when the aim is to use the system's font
(white, small font, 6 by 8 pixels), or the **font code** returned by the load_fnt() function when a new font is loaded in the program.

**<x>**, **<y>** - The coordinates referred to the screen in which the text is going to be displayed, first in the horizontal axis and then in the vertical one.

**<centering code>** - This code determines the position of the text specified by the previous coordinates. Its values are:

  **0**-Up left **1**-Up **2**-Up right  
  **3**-Left        **4**-Center **5**-Right  
  **6**-Down left  **7**-Down  **8**-Down right  

For example, if a text is written at the 160, 0 coordinates and with the centering code 1 (Up), then the text will center in the column 160 and it will be displayed from line 0 downwards. Or, if the aim is to have a text in the upper left corner, it must be displayed at the 0, 0 coordinates and with centering code 0 (Up left).

**<text>** - The text to be written as a literal (that is to say, a text in inverted commas) will be specified as last parameter (see the literals' specifying symbols).

---

The displayed text will remain on-screen until it is deleted with the delete_text() function, that requires as parameter the **identifying code**
returned by **write()**.

The write_int() function must be used to display the numeric value of a variable (such as the score of the player).

The texts will remain unchangeable on screen even if graphics are displayed on it or processes' graphics pass before or behind them.

Sample program:
```div
PROGRAM example_write;

PRIVATE
    font1;

BEGIN
    font1 = load_fnt("help.fnt");

    write(0, 160, 100, 4, "Sample text with the system font.");
    write(font1, 0, 0, 0, "LEFT UP");
    write(font1, 320, 200, 8, "RIGHT DOWN");

    LOOP
        FRAME;
    END
END
```

In the previous example, the font contained in the **help.fnt** archive is loaded
with the load_fnt() function (whose font code is stored in the **font1** variable), and then three texts are written:

The first one with the system font (0), being placed at the 160, 100 coordinates
(screen center) the **center** of the text (centering code 4).

The second one with the loaded font (whose **font identifier** is stored in the **font1** variable), being placed at the 0, 0 coordinates the
upper left corner of the text (centering code 0).

And finally, the third text, also with the loaded font, being placed at the 320, 200 coordinates the lower right corner of the text (centering code 8).

After that, the program will indefinitely remain waiting inside a loop.

---

The depth plane in which the written texts appear is controlled through the text_z global variable, that is useful to regulate which graphics must be seen above the texts and which ones must be seen below them.

Then, it will be possible to move the texts towards another position if necessary, by using the move_text() function, which also requires the **identifying code** returned by **write()** as parameter.

---

When fonts loaded from **archives FNT** are used, the colors' palette used to generate these fonts must be activated (see load_pal()). Otherwise, the colors may appear changed, being the text incorrectly displayed.

---
See: write_int() - move_text() - delete_text() - load_fnt() - text_z

## [172] write_int()

**write_int(**<font>**,** <x>**,** <y>**,** <centering code>**,** <OFFSET variable>**)**

**Returns:**

The identifying code of the text that has been written.

**Description:**

This function is used to show the numeric value of a variable. For that, it requires the following parameters:

**<font>** - The **font code** or **type of letter** that is going to be used.
Here, it is necessary to put either 0 when the aim is to use the system's font
(white, small font, 6 by 8 pixels), or the **font code** returned by the load_fnt() function when a new font is loaded in the program.

**<x>**, **<y>** - The coordinates referred to the screen in which the numeric value is going to be displayed, first in the horizontal axis and then in the vertical one.

**<centering code>** - This code determines the position of the numeric value specified by the previous coordinates. Its values are:

  **0**-Up left **1**-Up **2**-Up right  
  **3**-Left        **4**-Center **5**-Right  
  **6**-Down left  **7**-Down  **8**-Down right  

For example, if a numeric value is written at the 160, 0 coordinates and with the centering code 1 (Up), then the numeric value will be centered in the column 160 and it will be displayed from line 0 downwards. Or, if the aim is to have a numeric value in the upper left corner, it must be displayed at the 0, 0 coordinates and with centering code 0 (Up left).

**<OFFSET variable>** - The offset inside the computer's memory of the variable whose value is intended to be displayed, must be specified as last parameter (the offset of the data is obtained with the OFFSET operator).

---

The displayed numeric value will remain on-screen until it is deleted with the delete_text() function, that requires as parameter the **identifying code**
returned by **write_int()**.

**Important:** During the time that the value of the variable appears on screen, this value will automatically be updated every time the variable is modified. For that, new calls to **write_int()** are not necessary.

The write() function must be used to display any kind of alphanumeric text (a fixed text).

The texts will remain unchangeable on screen even if graphics are displayed on it or processes graphics pass before or behind them.

Sample program:
```div
PROGRAM example_write_int;

PRIVATE
    variable;

BEGIN
    write(0, 160, 190, 1, "Press [SPACE] to change the value of the variable.");

    write_int(0, 160, 100, 4, OFFSET variable); // A variable is displayed.

    LOOP
        IF (scan_code==_space) variable=rand(-100, 100); END
        FRAME;
    END
END
```

In the example, a text is displayed by using write() and the value of a variable with the **write_int()** function. This last function is passed the following
parameters:

  **0** - As **font** (0 is the system font).  
  **0, 10** - As screen coordinates.  
  **0** - As centering code (Up/Left).  
  **OFFSET variable** - As the offset of the variable in the memory.  

In every step of the loop, if the spacebar is pressed, the value of the variable is changed, assigning it one randomly chosen with the rand() function.

---

The depth plane in which the written texts appear is controlled through the text_z global variable, that is useful to regulate which graphics must be seen above the texts and which ones must be seen below them.

Then, it will be possible to move the texts towards another position if necessary, by using the move_text() function, which also requires the **identifying code** returned by **write()** as parameter.

---

When fonts loaded from **archives FNT** are used, the color palette used to generate these fonts must be activated (see load_pal()). Otherwise, the colors may appear changed, being the text incorrectly displayed.

---

**Warning:**

It is not possible to display an expression, as it is shown below:

  **write_int(0, 0, 0, 0, offset variable + 1);**

To display the value of the variable plus 1. That is to say, if the aim was to display this value, it would be necessary either to add 1 to the variable or to create another variable, assigning it the value of the original variable plus 1, for
instance:

  **variable2 = variable + 1;**  
  **write_int(0, 0, 0, 0, offset variable2);**  

In this case, you should take into account that you had to update the value of the **variable2** at least once per every FRAME of the game, as by changing **variable** the value of **variable2** will not automatically be updated unless the **variable2 = variable + 1;** statement is again executed.

---
See: write() - move_text() - delete_text() - load_fnt() - text_z

## [173] xput()

**xput(**<file>**,** <graphic>**,** <x>**,** <y>**,** <angle>**,** <size>**,** <flags>**,** <region>**)**

**Description:**

Advanced version of the put() function to put a graphic on the screen background. This function requires the following parameters, in order:

**<file>** - **file code** with the graphics library that contains both graphics. The graphics loaded with the load_map() function will be used as if they belonged to the first file (the file with the code 0).

**<graphic>** - **code of the graphic** inside the file that is going to be displayed on screen.

**<x>, <y>** - coordinates dealing with the screen where the graphic is intended to be put. These coordinates reveal the position in which the graphic center (or the control point number 0, if it is defined) will be placed. 

**<angle>** - angle (in degree thousandths) in which the graphic is going to be displayed; the normal angle is **0**.

**<size>** - size (in percentage) in which the graphic is going to  be displayed; the normal size is **100**.

**<flags>** - Indicates the mirrors and transparencies with which the graphic will be displayed; the possible values are the following ones:

 **0**-Normal graphic.  
 **1**-Horizontal mirror.  
 **2**-Vertical mirror.  
 **3**-Horizontal and vertical (180°) mirror.  
 **4**-Transparent graphic.  
 **5**-Horizontal transparent and mirror.  
 **6**-Vertical transparent and mirror.  
 **7**-Horizontal and vertical transparent, mirror.  

**<region>** - Number of region (window inside the screen) in which the graphic must be displayed. This value will normally equal **0** to display the graphic at any position of the screen. The define_region() function must be used to define a region.

---

The graphics displayed in this way on the background screen will be in the game display **below all the processes, scroll regions, texts, etc.**

If the aim is that a graphic is above others, it is necessary to **create it as a new process**  and fix its z variable with the priority of its display.

The clear_screen() function must be used to clear the screen background.

Sample program:
```div
PROGRAM example_put;

PRIVATE
    file1;
    coord_x;
    coord_y;
    angle1;
    size1;
    flags1;

BEGIN
    file1=load_fpg("help.fpg");
    LOOP
        coord_x=rand(0, 319);
        coord_y=rand(0, 199);
        angle1=rand(-pi, pi);
        size1=rand(10, 200);
        flags1=rand(0, 7);

        // The graphic 101 is put
        xput(file1, 101, coord_x, coord_y, angle1, size1, flags1, 0);

        FRAME;
    END
END
```

In the example, the file is loaded with the graphics and, in every iteration of the loop, graphic number 101 (a triangle) is put with the **xput()** function at coordinates randomly chosen with the rand() function, with random angle, size and value of **flags**, and in region number 0 (entire screen).

---

The put() function is a simplified version of the **xput()** function, and it is useful when you do not want to rotate, scale, mirror
or display the graphic with transparencies.

The map_put() or map_xput() functions must be used to put a graphic inside another one (instead of the screen background).

---

If the graphic intended to be put is just a screen background,
it is easier to use the put_screen() function, as it does not require the screen coordinates because it will automatically center the graphic on screen.

---
See: put() - map_put() - map_xput() - put_screen()

## [174] load_map()

**load_map(**<archive name>**)**

**Returns:**

The loaded **graphic code**.

**Description:**

Loads a **MAP archive** with a graphic in the computer's memory . The function requires the archive name as a parameter, in inverted commas.

The **graphic code** is returned as return value, which is a numeric value that must be specified to use the graphic, in the graph variable or, in general, in all the functions requiring a **graphic code** among their parameters.

It is possible to load as many graphics as necessary. Every time one is loaded, the function will return the corresponding code (the first graphic loaded will have the code **1000**, the following one the code **1001**, etc.)

It is possible to specify the path to the archive with the graphics' file. Nevertheless, if the file is in the directory by default (\MAP), it won't be
necessary.

---

**Important:**

When the **file code** to which that graphic belongs is required inside a function, the code **0** (which is the code of the first **file FPG** that is loaded in the program) must be indicated.

---

When different graphics have been loaded, keep in mind that if they have different palettes, every one of them must previously be activated with the load_pal() function, indicating the name of the file (MAP) as a parameter, before using the graphic.

Graphics created with different palettes can not simultaneously be used.

Sample program:
```div
PROGRAM example_load_map;

PRIVATE
    map1;

BEGIN

    map1 = load_map("help.map"); // A graphic map's file is loaded.

    put_screen(0, map1);
    LOOP
        FRAME;
    END
END
```

In the example, a graphic map is loaded with the **load_map()** function, storing the **graphic code** that returns in the **map1** private variable.

This code is later used as a parameter of the put_screen() function
to put the graphic on the background screen.

---

The unload_map() function allows us to free up the computer's memory used by the graphic when it is not going to be used for a specific time. For that purpose, it also requires the **graphic code** to know which is the graphic to be unloaded from the memory.

**It is not necessary to unload the graphic from the memory** before finishing the 
program, as the system will do it automatically.

---

To load several graphics all at once in a program, they must be included inside a graphics file (FPG) and loaded with the load_fpg() function.

---
See: unload_map() - load_fpg() - load_pal() - graph

## [175] reset_sound()

**reset_sound(****)**

**Description:**

Advanced function, only for very expert users. Resets the sound system.

This function is used to activate new parameters of the sound hardware.

The following values of the setup global structure must be established:

    **setup.card**  
    **setup.port**  
    **setup.irq**  
    **setup.dma**  
    **setup.dma2**  

This function is normally used inside the sound setup programs (see setup_program).

---

To activate the rest of the values of the setup structure, those referred to the **mixer** volume, the set_volume() function must be called. The values to establish the volume are the following ones:

    **setup.master**  
    **setup.sound_fx**  
    **setup.cd_audio**  

---
See: set_volume() - Setup structure - setup_program

## [176] unload_map()

**unload_map(**<graphic code>**)**

**Description:**

Unloads the graphic whose code is passed as a parameter from the memory.
This <graphic code> is the value returned by the load_map() function
by loading a new graphic stored in a **archive MAP** in the computer's memory.

After having unloaded a graphic, **much care must be taken** not to go on using this graphic in the program. Otherwise, the program would risk to become blocked.

**It is not necessary to unload the graphic** before finishing the 
program, as the system will do it automatically.

Then, a graphic must be unloaded from the memory only when it is not going to be used for a specific time and when the aim is to free up the occupied space in the computer's memory to load other resources (other graphics files, sounds, fonts, etc.), which will make sense only with graphics of a certain size, that is to say, big enough so as to be worth freeing up the space they occupy.

Sample program:
```div
PROGRAM example_unload_map;

PRIVATE
    map1;

BEGIN
    map1=load_map("help.map");
    put_screen(0, map1);
    write(0, 160, 0, 1, "Press [ENTER] to unload the graphic and finish");
    REPEAT
        FRAME;
    UNTIL (key(_enter));

    unload_map(map1); // The graphic is unloaded.

END
```

In the example, a graphic map is loaded with the load_map() function, storing the **graphic code** returned by it in the **map1** private variable.

This code is later used as a parameter of the put_screen() function
to put the graphic on the background screen.

Then, the program will display a message and wait in a loop for the ENTER key to be pressed. At that moment, the graphic will be unloaded by using the **unload_map()** function.

---

The graphics individually loaded with the load_map() function will not be unloaded when file number 0 (with code 0) is unloaded with the unload_fpg() function, even if these graphics are used as if they belonged to it.

---
See: load_map() - unload_fpg()

## [177] unload_fnt()

**unload_fnt(**<font code>**)**

**Description:**

Unloads from the memory the **font** (the **kind of letter** or the **set of graphic characters**) whose code is passed as a parameter.

This <font code> is the value returned by the load_fnt() function by 
loading a new letter font stored in a **archive FNT** in the computer's memory.

After having unloaded a font, **much care must be taken** not to go on using this font in the program. Otherwise, the program would risk to become blocked.

**It is not necessary to unload the font** before finishing the 
program, as the system will do it automatically.

Then, a font must be unloaded from the memory only when it is not going to be used for a specific time and when the aim is to free up the occupied space in the computer's memory to load other resources (other graphics files, sounds, fonts, etc.).  

Sample program:
```div
PROGRAM example_unload_fnt;

PRIVATE
    font1;

BEGIN
    font1=load_fnt("help.fnt");
    write(fuente1, 160, 0, 1, "FONT OF THE ARCHIVE IN DISK");
    write(0, 160, 190, 1, "Press [ENTER] to unload the font and finish");
    REPEAT
        FRAME;
    UNTIL (key(_enter));

    unload_fnt(font1); // The font is unloaded
END
```

In the example, the font stored in the **help.fnt** archive is loaded with the load_fnt() function, storing the **font code** returned by it in the **font1** private variable.

This code is later used as a parameter of the write() function
to put a text on screen with that font.

Then, the program will wait in a loop for the ENTER key to be pressed. At that moment the font will be unloaded by using the **unload_fnt()** function and the program will finish.

---

Font number 0, (the system font having 0 as font code),
**can not be unloaded**.

---
See: load_fnt() - write() - write_int()

## [178] set_volume()

**set_volume(****)**

**Description:**

Advanced function, only for very expert users.
Adjusts the different volume controls managed by the **mixer** of the system sound.

To adjust the volume, the following values of the setup global structure must be set:

    **setup.master**   - General volume  
    **setup.sound_fx** - Sound effects volume  
    **setup.cd_audio** - Cd-audio music volume  

This function is normally used inside the sound setup programs (see setup_program), or even in the rest of the programs, normally to adjust the CD_Audio music volume.

---

To activate the rest of the values of the setup structure (those referred to the sound card's parameters) the reset_sound() function must be called with the following defined values of the structure:
 
    **setup.card**  
    **setup.port**  
    **setup.irq**  
    **setup.dma**  
    **setup.dma2**  

---
See: reset_sound() - Setup structure - setup_program

## [1000] Syntax of a program.

Now, the general structure of a program is shown in the language. To see the corresponding syntactic definition, click on the section of your interest with the mouse.

<Program's head>  
<Declaration of constants>  
<Declaration of global data>  
<Declaration of local data>  
<Declaration of libraries>  
<Declaration of private data>  
<Main code>  
<Declaration of processes>  

All the programs must respect the previous structure with an exception: it is possible to put explanatory comments
in any point of the program.

---
See: Index - Glossary

## [1001] Definition of a name.

A name is a sequence of alphanumeric characters used to **identify** an object of the program, such as the name of a process, constant or variable.

These names can be made up of the following characters:

  Symbols:  
  **_ # ª º $ ₧ ƒ £ ¥ ¢**  
  Digits:  
  **0123456789**  
  Letters:  
  **abcdefghijklmnopqrstuvwxyz**  
  Letters (extended):  
  **ñ ç æ âäàåá êëèé îïìí ôöòó ûüùú ÿ**  

provided that the following rules to create new names are respected:

- The sequence of characters must not contain characters that are not in the previous list (except **capital** letters corresponding to lower case letters included in the list).

- Inside the sequence, it is not possible to put blanks. That is to say, **enemy spacecraft** is not a valid name as, for the compiler, it would imply two names. In 
this case, the name can be declared as **enemy_spacecraft**.

- A name can not start with a numeric digit. That is to say, **0a** is not a valid name. Nevertheless, all the necessary digits can be included in the name after the first character (**a0** is indeed a valid name).

- The name must not coincide either with any of the language's reserved words or with any of the objects (constants, variables, etc.)
predefined in the language. To check it, see the list of reserved words and predefined objects, being possible to access the Glossary at any moment. The reserved words appear in capital letters and the predefined objects in lower case letters.

- There is no difference between the capital and lower case letters (for the compiler, **ABc** and **abC** are the same name).

- The same name can not be used for two different objects.
For instance, it is not possible to name a constant **value** and then, to declare
a process **PROCESS value(x, y);**.

---
See: Syntax - Glossary

## [1002] Definition of comments.

A comment is an explanatory note about the program. The comments are not
necessary for the program's correct working.

There are two kinds of comments:

- Of a single line: they start with the symbol** //** and finish at the end of the line in which they are defined.

- Of several lines: they start with the symbol** /*** and finish with the symbol ***/**.

Sample program:
```div
/*
    This is an example of a comment
    of several lines in which explanations
    about the program can be given
*/

PROGRAM my_game; // Example of a single line comment.
BEGIN             // The main program starts.
    FRAME;
END               // The main program finishes.
```

All the texts included in a comment are ignored by the compiler.
As many comments as necessary can be put, in any point of the program.

The comments starting with** /*** and finishing with** */** (comments of several lines) can also start and finish in the same line.

---
See: Syntax

## [1003] Program's head.

**PROGRAM** <name> **;**

All the programs must start with the reserved word **PROGRAM** followed by the name of the program and a symbol ; (semicolon).

This head is obligatory in all the programs. Before it, only one or several comments (explanatory texts preceded by the symbol** //**, or between the symbols** /*** and** */**) can optionally appear.

In the names and reserved words there is no difference between capital and lower case letters, so **PROGRAM**, **program**, **Program**, ... are valid words.

Sample program:
```div
// -------------------
// Listing of my game
// -------------------

PROGRAM name_of_my_game;
BEGIN
    //...
END
```

---
See: Syntax

## [1004] Declaration of constants.

**CONST**  
    <name> **=** <constant> **;**  
    ...

This section of the programs is optional, as its utility deals with setting a series of synonymous for some numeric values.

In a game, for instance, number 3 has been set in one or several points of the program as the maximum lives of the protagonist. If the aim is to modify this number, increasing or decreasing it, it will be necessary to look for this number and to replace it in the program. But there is a risk of replacing other '3' numbers appearing in the program with different aims.

An alternative is to declare a constant called, for instance,
**maximum_lives** as a synonymous of the numeric value 3 and use that constant in the program instead of the number. Now, if the aim is to replace this value by another one, it is done simply in the declaration of the constant **maximum_lives**.

This section then establishes a list of names that are going to represent a series of numeric constants.

This section must obligatory start with the reserved word **CONST** and then, for every declared constant, its name followed by the symbol = (assignment symbol) and a constant expression (numeric value) must appear. After the declaration of every constant, the symbol ; (semicolon) must appear.

Sample program:
```div
PROGRAM my_game;
CONST
    maximum_lives=3;
BEGIN
    //...
END
```

Once a value has been assigned to a constant, it won't later be possible to modify the former in the program.

---
See: Syntax - Glossary

## [1005] Definition of a constant.

A constant is a constant value or a numeric expression.

As values, only integers within the range (min_int ... max_int) can be used.

The constant numeric expressions are mathematical formulas in which it is possible to use:

    - **Constants** previously defined.  
    - **Numeric values**.  
    - Arithmetic or logical **operators**.  
    - **Literals** (texts in inverted commas).  
    - The sizeof() function.  

These expressions will be evaluated when the program is compiled and their result will be used in the program's execution.

The **operators** that can be used in a constant expression are the following ones (the synonymous of the operator, if they exist, are shown in brackets).

     +    Addition  
     -    Subtraction (or negative sign)  
     *    Multiplication  
     /    Division  
     MOD  Module (%)  
     <<   Rotation to the right  
     >>   Rotation to the left  
     NOT  Binary and logical negation (**!**)  
     AND  AND binary and logical (**&**,**&&**)  
     OR   OR binary and logical (**|**,**||**)  
     XOR  Exclusive OR (**^**, **^^**)  
     ==   Comparison  
     <>   Different (**!=**)  
     >    Bigger  
     >=   Bigger or equal (**=>**)  
     <    Less  
     <=   Less or equal (**=<**)  
     OFFSET Direction or offset (**&**)  
     ( )  Brackets  

Now, some examples of valid constants are shown:

** 0**  
** -1000**  
** 2+2**  
** "Hello!"**  
** 4*(2+1)**  
 ...

---
See: Syntax - Glossary

## [1006] Declaration of global data.

**GLOBAL**  
    <declaration of datum> ;  
    ...

This section of the programs is optional. Global data, that is to say, the **data that can be used from any point of the program**, are declared in this section.

A section must obligatory start with the reserved word GLOBAL followed by a series of declarations of data finished with a symbol ; (semicolon).

In general, all those data that establish general conditions of the game related to several processes are declared as global data. An example could be the score obtained by the player, that could be stored in the **score** global variable. Thus, any process of the game could increment it, if necessary.

A declaration of global data will define a single data that can be used for all the program's processes. But, a declaration of local data will define a datum of this kind and name for each of the program's processes.

Sample program:
```div
PROGRAM my_game;
GLOBAL
    score=0;
BEGIN
    //...
END
```

---
See: Syntax - Glossary

## [1007] Declaration of local data.

**LOCAL**  
    <declaration of data> ;  
    ...

This section of the programs is optional, as local data, that is to say, the **data that all the program's processes have** are declared here, each one with its own values (as the x and y predefined local variables determine the coordinates of all the processes).

A section must obligatory start with the reserved word **LOCAL**
followed by a series of declarations of data finished with a symbol ; (semicolon).

In general, the important information of the processes, that is to say, the data to be consulted or modified from other processes, are declared as local data.

The energy remaining a process (a spacecraft, a shotgun, the character, etc.) could be an example. This information could be stored in the **energy** local variable, so any process can access or modify the energy of the rest (for instance, on colliding with them, energy could be subtracted).

Sample program:
```div
PROGRAM my_game;
LOCAL
    energy=0;
BEGIN
    //...
END
```

If a datum declared as local is to be used only inside one process, then the former can be defined as a private data (inside the section PRIVATE of that process).

---
See: Syntax - Glossary

## [1008] Declaration of private data.

**PRIVATE**  
    <declaration of data> ;  
    ...

These sections of the programs are optional. Private data, that is to say, **data that are going to be used exclusively inside a process**, can be declared in this section.

This section is defined just before the BEGIN of the process that is going to use these data and must start with the reserved word PRIVATE
followed by a series of declarations of data finished with a symbol ; (semicolon).

The main program is also considered as a process. Its declaration of private data can go just before its BEGIN.

In general, all the data that are going to contain information necessary only for a process, as well as those that can not be accessed from any other process, are declared as private data.

Those variables that are going to be used as counters in a loop, variables to contain angles or secondary identifying codes, etc. are normally defined as private data.

Sample program:
```div
PROGRAM my_game;
PRIVATE
    n;
BEGIN
    FROM n=0 TO 9;
        //...
    END
    //...
END

PROCESS my_process()
PRIVATE
    id2;
    angle2;
BEGIN
    id2=get_id(TYPE my_process);
    IF (id2<>0)
        angle2=id2.angle;
        //...
    END
    //...
END
```

If you need to consult or modify a datum declared as private from another process (datum.identifier), then that data will have to be declared local (inside the program's section LOCAL). Thus, all the processes will have the data and every process can access its value or the value that this data has in another process.

---
See: Syntax - Glossary

## [1009] Declaration of a datum.

In a declaration of a datum, three different kinds of objects can be shown:

  <Declaration  of a variable>  
  <Declaration of a table>  
  <Declaration of a structure>  

In general, a variable will store a simple numeric value. A table will store a
list of numeric values. And a structure will store a list of records of several fields (such as a list of index cards with varied information).

All the data will be declared with a name which, from that moment, will become the means to access or modify the information contained in those data.

Each data will belong to a specific area, depending on the fact that its declaration has been made inside the GLOBAL, LOCAL or PRIVATE.. sections.

  <Declaration of global data>  
  <Declaration of local data>  
  <Declaration of private data>  

It is possible to access all the global data from any point of the program. Local data belong to all the processes (every process has its own value in them). Finally, private data belong to a single specific process.

---
See: Syntax

## [1010] Declaration of a variable.

<name>

(or, if the aim is to initialize)

<name> = <constant>

To declare a variable inside a GLOBAL, LOCAL
or PRIVATE section, suffice will be to indicate its name inside that section. In this case, the variable will be initialized at 0 (zero).

To initialize the variable at other values, the symbol = (assignment) will be put after the name of the variable. The constant value at which the variable is intended to be initialized will be put after this symbol.

A variable is a cell (or position) of the computer's memory to which we refer by its name and that can contain whole numeric values within the range (min_int ... max_int).

---
See: Syntax - Glossary

## [1011] Declaration of a table.

<name> [ <constant> ]

(or, if the aim is to initialize the table)

<name> [ <constant> ] = <list of constants>

(or, if it is initialized without defining its length)

<name> [ ] = <list of constants>

To declare a table inside a GLOBAL, LOCAL
or PRIVATE section, suffice will be to indicate its name followed by the length of the table in square brackets (symbols [ ]). In that case, all the positions of the table will be initialized at 0 (zero).

The table's length is expressed as the maximum value of its index. That is to say, all the tables range from the position 0 to the position indicated in the square brackets in their declaration. For instance, a table declared as **my_table[9]**, will be a table of length **10** (of 10 positions, from my_table[0] to my_table[9]).

If the aim is to initialize the different positions of the table, it is necessary to put the symbol = (assignment) after the previous declaration and, after this symbol, a list of constants.

If the table is initialized with a list, then it is not necessary to indicate
the table's length in square brackets, as the compiler will create a table
with as many positions as the number of values included in the list.

A table is a series of cells (or positions) of the computer's memory that is called by its name, appearing after it, in square brackets, the number of cell inside the table intended to be accessed.

Every table's cell is a variable that can contain whole numeric values within the range (min_int ... max_int).

For instance, if we declare a table as the following one:

    **my_table[]=33, -1, 6, -3, 99;**

We will be declaring a table whose name is **my_table** and that has
**5** cells (or positions), from cell no. 0 to cell no. 4. In the previous declaration, cell 0 (**my_table[0]**) is initialized with the value **33**, cell 1 (**my_table[1]**) with the value** -1**, etc.

The language allows us to access cell 0 simply with the name of the table (**my_table**), as if it was a variable, omitting the zero in square brackets that should appear after. That is to say, for the compiler, **my_table[0]** will be the same as **my_table** (the first cell of the table).

---
See: Syntax - Glossary

## [1012] Declaration of a structure.

**STRUCT** <name> [ <constant> ]  
    <declaration of data> ;  
    ...  
END

(or, if you initialize the structure)

**STRUCT** <name> [ <constant> ]  
    <declaration of data> ;  
    ...  
END = <list of constants>

To declare a structure inside a GLOBAL, LOCAL or PRIVATE section, it is necessary to put the reserved word **STRUCT** preceding its name. After it, the number of records of the structure must be indicated, in square brackets (symbols [ ]).

After this head defining the name of the structure and the number of records, all the data that belong to the structure and that will comprise its fields, will be declared. Finally, the reserved word END must appear to finish the declaration.

The records' number of the structure is expressed as the maximum records' number of the structure. That is to say, all the structures have from record 0 to the record indicated in the square brackets. For instance, a structure declared as **STRUCT my_structure[9]**, will be a structure of **10** records (from the record my_structure[0] to my_structure[9]).

A structure is like an index card file (records), each of them with different written information (fields). For instance, a structure in which we could include the initial and final positions of a series of processes of a game could be as follows (an index card file with 10 cards, each of them indicating the (x, y) initial
and the (x, y) final of a process):

**STRUCT movement_enemies[9]**  
    **x_initial;**  
    **y_initial;**  
    **x_final;**  
    **y_final;**  
**END**

This structure, that would be accessed with the name **movement_enemies**, has ten records and four fields in each record (two coordinates that determine the initial position of the process [x_initial ,y_final], and two that determine the final position [x_final, y_final]).
**Movement_enemy[0].x_final** would be used to access the **x** final of the first enemy.

The language allows us to access the record 0 of the structure simply with the name of the structure (**movement_enemies.x_final**), omitting the zero in square brackets that should come later. That is to say, for the compiler
**movement_enemies[0].x_final** will be the same as **movement_enemies.x_final**.

Each field of the structure may be a variable, a table
or another complete structure, with its different records and fields.

If the aim is to initialize the structure (establishing the initial values of its fields in the different records), the symbol = (assignment) must be put after the reserved word END followed by a list of constants. If the structure is not initialized in this way, all the fields will be put at 0 by default.

Keep in mind that , in order to initialize a structure, the first values will be the values of the fields of the first record, the following ones those of the second record, and so on. 

For instance, if the following declaration is made:

STRUCT a[2]  
    b;  
    c[1];  
END = 1, 2, 3, 4, 5, 6, 7, 8, 9;

First, it must be taken into account that the structure **a** has 3 records
(from a[0] to a[2]) and that there are three fields (b, c[0] y c[1]) in each record. Then, the previous declaration will initialize the structure in the following way:

a[0].b=1;  
a[0].c[0]=2;  
a[0].c[1]=3;  
a[1].b=4;  
a[1].c[0]=5;  
...

---
See: Syntax - Glossary

## [1013] Definition of a list of constants.

A constant is a constant value or numeric expression (see <definition of constant>).

The lists of constants are basically a series of constants separated by commas (,) and they are used to initialize the values of tables or structures.

An example of a list of constants is shown below:

1, 2, 3, 4, 5;

But, besides this basic definition, the use of the operator DUP is allowed to repeat a series of constants a specific number of times. For instance, the following list:

0, 100 DUP (1, 2, 3), 0;

It is a list of 302 constants (0, 1, 2, 3, 1, 2, 3, ..., 1, 2, 3, 0). That is to say, that
the operator DUP (duplication) allows us to repeat the sequence appearing after it in brackets, the indicated number of times.

It is possible to nest operations DUP. For instance, the following list:

2 **DUP** (88, 3 DUP (0, 1), 99);

would be equivalent to:

88, 0, 1, 0, 1, 0, 1, 99, 88, 0, 1, 0, 1, 0, 1, 99;

Moreover, the omission of the operator DUP, that is to say, that
**2 DUP (0, 1)** is equivalent to **2(0, 1)**, is allowed.

The operator DUP is specially useful to initialize structures. If, for instance, the aim is to initialize the following 100 record structure:

**STRUCT a[99]**  
    **b;**  
    **c[9];**  
    **d[9];**  
**END**

With the fields **b** initialized at **0**, the fields **c[9]** at **1** and the fields
**d[9]** at **2**, the following list of initialization would be used:

100 DUP (0, 10 DUP(1), 10 DUP(2));

---
See: Syntax

## [1014] Declaration of libraries.

**IMPORT** **<name of archive>**

The creation of libraries of functions for the language is a **very advanced** issue,
only for programmers with broad experience in the **C** language and/or **Assembler**.

The libraries must be distributed with two archives: the first one, with extension **DLL**, containing the own library and, the second one, with the same name but with extension **TXT**, that must be a text archive ascii (MSDOS), explaining the purpose and working of the library. All the provided functions, the installation process and the use of the library must be explained in the second archive.

The libraries must be imported from the language, by inputting the reserved word **IMPORT** (after the declaration of local and global data) followed by the path of the archive **DLL**. If the archive with extension **DLL** has been copied in the directory of **DIV Games Studio**, then it is not necessary to specify the library's path.

Sample program:
```div
PROGRAM my_game;
IMPORT "c:\tmp\3dtrans.dll";
BEGIN
    //...
END
```

From the moment when the libraries of functions can freely be developed, **the correct working of DIV Games Studio is not guaranteed if external libraries DLL are used**. The incorrect working of the **programs' debugger** can be usual when a DLL which modifies vital parts of the library of functions or of the processes' manager of DIV Games Studio is stored in a game

---
See: Syntax

## [1015] Main code.

BEGIN  
    <statement> **;**  
    ...  
END

The main code of a program starts with the reserved word BEGIN. After it, any number of statements may appear. The main code finishes with the reserved word END.

This code controls the main process of the program, which initializes the program, controls the loops of the menu and game, and finishes the program.

Sample program:
```div
PROGRAM my_game;

GLOBAL
    option;             // Option chosen in the menu.

BEGIN                   // Beginning of the main code.

    set_mode(m640x480); // Beginning.
    set_fps(24, 4);
    // ...              // Loads files, sounds, etc.

    REPEAT              // Beginning main loop.

        option=0;       // Control loop of the options menu.
        //...           // Begins the options menu.
        REPEAT
            // ...
            IF (key(_enter)) option=1; END  // Playing is chosen.
            IF (key(_esc)) option=2; END    // Finishing is chosen.
            FRAME;
        UNTIL (option>0);

        IF (option==1)  // If the playing option has been chosen.

            // Starts regions, scroll, etc.
            // Creates the game processes.
            // Loop of game's control, waiting for its end.

        END

    UNTIL (opcion==2);  // End of the main loop.

    let_me_alone();     // Finishes all the processes.

END                     // End of the main code.

// ...                  // Declaration of the program's processes.
```

The end of the main code's execution does not imply the end of the program's execution, as it will continue if there are alive processes. To force the end of the program when the code finishes, it is possible to use, for instance, the let_me_alone() function just before the END that marks the main code's end, to eliminate the rest of processes that may remain alive.

The execution of the program can also be finished at any of its points with the exit() function, which will automatically eliminate all the processes.

---
See: Syntax

## [1016] Declaration of processes.

**PROCESS** <name> **(** <parameters> **)**  
<Declaration of private data>  
BEGIN  
    <statement> **;**  
    ...  
END

A process must start with the reserved word **PROCESS** followed by its name and its call parameters in brackets. The parameters are a list of data in which the process is going to receive different values. The brackets are obligatory even if the process has no parameters.

After this head, a PRIVATE section, declaring data to be used by the process exclusively, may be put optionally.

And finally, the process code, that is a sequence of statements between the reserved words BEGIN and END, will be specified.

A process normally corresponds with a kind of object of the
game, such as a spacecraft, an explosion, a shot, etc. Inside the process' code, a loop (in which all the necessary values to display this object, such as graphic, coordinates, etc., will be established) is normally implemented. Then, with the FRAME statement, the order to display the object with the established attributes is given.

Sample program:
```div
PROGRAM my_game;
PRIVATE
    id2;
BEGIN
    id2=my_process(160, 100)
    // ...
END

PROCESS my_process(x, y)
PRIVATE
    n;
BEGIN
    graph=1;
    FROM n=0 to 99;
        x=x+2;
        y=y+1;
        FRAME;
    END
END
```

As it can be noticed in this example, when a process is called, it returns its identifying code (that, in the example, is stored in the PRIVATE variable of the main program **id2**). If the aim is to implement a process in the style of the functions of other languages that returns a numeric result, then it is necessary to use the RETURN(value**)** statement, not using the FRAME statement inside the process, as this statement returns to the father process (caller), returning the process' identifying code as return value.

---
See: Syntax

## [1017] List of statements.

A statement is an order to be executed by the computer in a program. The possible types of statements are the following ones:

Assignment statements  
    =  

Control statements  
    IF  
    SWITCH  

Loop statements  
    LOOP  
    FROM  
    REPEAT  
    WHILE  
    FOR  

Break statements  
    BREAK  
    CONTINUE  
    RETURN  

Special statements  
    FRAME  
    CLONE  
    DEBUG  

Call statements  
    Call to a function  
    Call to a process  

The statements always appear as a group of statements, from none (which makes no sense) to as many as necessary.

All the statements will sequentially be executed (the first one,
the second one, the third one ...), with the exception of the statements that can control the flow of the program (control, loop and break statements).

---
See: Syntax - Glossary - Index

## [1018] Parameters of a process.

The parameters of a process are basically a list of data in which the process will receive different information every time it is called or used from another process.

The processes can receive parameters in the following types of data:

- A predefined local datum (such as x, size, flags, ...).

- A local datum defined inside the LOCAL section.

- A global datum defined inside the GLOBAL section.

- A process' private datum declared inside the PRIVATE section of the process itself.

- A private datum **not declared** inside the PRIVATE section.

In all these cases, it is understood that a datum may be referred to a variable,
to a specific position of a table or to an element inside a structure.

As an example of the different types of parameters, a program with a process that receives five parameters different from the types respectively indicated in the previous list, is now shown.

Sample program:
```div
PROGRAM my_game;
GLOBAL
    score=0;
LOCAL
    energy=0;
BEGIN
    my_process(1, 2, 3, 4, 5);
    // ...
END

PROCESS my_process(x, energy, score, n, m)
PRIVATE
    n;
BEGIN
    // ...
END
```

The process **my_process** receives five parameters in five variables:
predefined local, local, global, private declared and private not
declared variables.

Receiving a parameter (such as the GLOBAL **score** variable) in a global data is equivalent to make the assignment (**score=3;**) and then,
call the process.

---
See: Syntax

## [1019] Assignment statement.

The assignment statements are used to calculate expressions and
**to assign them** to a datum.

<Reference to a datum> = <expression> ;

The data in which the result of the expression is going to be stored must be indicated, followed by the symbol = (symbol of the **assignment**), as well as the numeric or logical expression to evaluate when the statement is executed. After this statement, the symbol ;(semicolon) must always be put.

In an assignment statement it is only allowed to assign values to objects
such as any kind of variables, to a position of a table,
or to an element of a structure.

It is not possible to assign a value to a constant, to a function
or to a process or, in general, to any numeric or logical expression.

Now, a program with several assignments is shown.

Sample program:
```div
PROGRAM my_game;
BEGIN
    x=x+1;
    angle=(angle*3)/2-pi/2;
    size=(x+y)/2;
    z=abs(x-y)*3-pow(x, 2);
    // ...
END
```

This is the basic form of the assignments, even if there are other symbols of assignment that, instead of assigning a new value to the referred datum, modify its value. These are the symbols of **operative assignments**:

 += Adds to the datum the result of the expression  
        **x=2; x+=2;** -> (x==4)

 -= Subtracts from the datum the result of the expression  
        **x=4; x-=2;** -> (x==2)

 *= Multiplies the datum by the result of the expression  
        **x=2; x*=3;** -> (x==6)

 /= Divides the datum by the result of the expression  
        **x=8; x/=2;** -> (x==4)

 %= Puts in the datum the remainder of dividing it by the result of the
expression  
        **x=3; x%=2;** -> (x==1)

 &= Performs an AND (binary and/or logical) between the datum and the result of the expression, assigning it as a new datum's value  
        **x=5; x&=6;** -> (x==4)

 |= Performs an OR (binary and/or logical) between the datum and the result of the expression, assigning it as a new datum's value  
        **x=5; x|=6;** -> (x==7)

 ^= Performs an exclusive OR (XOR binary and/or logical) between the data and the result of the expression, assigning it as a new datum's value  
        **x=5; x^=3;** -> (x==3)

 >>= Rotates the datum to the right as many times as indicated by the result of the expression (each rotation to the right is equivalent to dividing the datum by 2)  
        **x=8; x>>=2;** -> (x==2)

 <<= Rotates the datum to the left as many times as indicated by the result of the expression (each rotation to the left is equivalent to multiplying the datum by 2)  
        **x=2; x<<=2;** -> (x==8)

Within the category of assignment statements, the **increments** and **decrements** of a datum are also allowed. For instance, if we wanted to add 1
to the local variable **x** we could do it either with the **x=x+1;** or
**x+=1;** statements, or with the operator of increment: **x++;** o** ++x;**.

That is to say, increments ( ++ ) or decrements ( -- ) of a datum are accepted as assignment statements.

---
See: Syntax

## [1020] IF statements

**IF** ( <condition> )  
    <statement> ;  
    ...  
END

(or)

**IF** ( <condition> )  
    <statement> ;  
    ...  
ELSE  
    <statement> ;  
    ...  
END

The **IF** statement is used to run a block of statements optionally, when a condition is complied. In the second aforementioned variant,
another block of statements will also be executed (inside the
ELSE section) when the condition is **not** complied.

A program with several **IF** statements is now shown.

Sample program:
```div
PROGRAM my_game;
BEGIN

    IF (key(_esc))
        exit("Good by!", 0);
    END

    IF (x>100 AND x<220)
        y=y+4;
    ELSE
        y=y-8;
    END

    IF (size>0)
        size=size-1;
    END

    IF (timer[5]>1000)
        z=1;
    ELSE
        z=-1;
    END

    // ...
END
```

It is possible to nest **IF** statements with no limits. That is to say, more **IF** statements can be put inside the part that is running when the condition is complied (**IF part**) or inside the one that is executed when the condition is not
complied (part ELSE).

---
See: Syntax

## [1021] SWITCH statement

**SWITCH** ( <expression> )  
    CASE **<range of values>** :  
        <statement> ;  
        ...  
    END  
    ...  
    DEFAULT :  
        <statement> ;  
        ...  
    END  
END

A **SWITCH** statement is made up with a series of CASE sections and, optionally, of a DEFAULT section.

When a **SWITCH** statement is executed, the expression is first evaluated and then, if the result is within the range of values included in the first **CASE** section, its statements will be executed and the statement will finish. If the result of the expression is not in the first CASE, it will be looked for in the second, third, etc. CASE. Finally, if there is a DEFAULT section and the result of the expression has not coincided with any of the CASE sections, then the statements of the DEFAULT section will be executed.

Sample program:
```div
PROGRAM my_game;
BEGIN
    SWITCH (x)
        CASE 1:
            x=-1;
        END
        CASE 2:
            x=-2;
        END
        CASE 3:
            x=-3;
        END
        CASE 99:
            x=-99;
        END
        DEFAULT:
            x=0;
        END
    END
END
```

The **SWITCH** statement of this program will change the sign of the **x** variable if it is equal to **1**, **2**, **3** or **99**. Otherwise, the statement will put the variable at **0**.

**Range of values of a case section**

---

A value, a range of values (minimum .. maximum), or a list of values and/or ranges separated by commas (,) may be specified in a case section. For instance, the previous statement could have been expressed as follows:

  **SWITCH (x)**  
      **CASE 1..3, 99:**  
          **x=-x;**  
      **END**  
      **DEFAULT:**  
          **x=0;**  
      **END**  
  **END**  

Once one of the CASE sections of a **SWITCH** statement has been executed **no more sections will be executed**, even if they also specify the
result of the expression, for instance, in the following statement:

  **SWITCH (2+2)**  
      **CASE 3..5:**  
          **x=x+1;**  
      **END**  
      **CASE 2, 4, 6:**  
          **y=y-1;**  
      **END**  
  **END**

The **x=x+1;** section will be executed and then, the statement will finish and the **y=y-1;** section won't be executed as, even if the result of the evaluated expression (**4**) is included in it, it is also included in the previous section,
(as 4 is within the range 3..5).

It is not necessary to arrange the CASE sections according to their values (smaller to larger, or larger to smaller), but it is indispensable that the DEFAULT section (if it exits) is the last section. There can only be one DEFAULT section.

It is possible to nest **SWITCH** statements with no limits. That is to say, new **SWITCH** statements (and any other kind of statement) can be put inside a CASE section.

---
See: Syntax

## [1022] WHILE statement

**WHILE** ( <condition> )  
    <statement> ;  
    ...  
END  

The **WHILE** statement implements a **loop**. That is to say, it is capable of **repeating a group of statements a specific number of times**.

In order to implement this loop, the condition that has to be complied for the group of statements to be executed must be specified in brackets, after the reserved word **WHILE**. All the statements that necessarily have to be repeated will be put after the specification of this condition. Finally, the end of the loop will be marked with the reserved word END (It doesn't matter whether
more words END appear inside the loop when they belong to internal statements of that loop).

When a **WHILE** statement is executed, the specified verification will be carried out. If the result is true, the internal statements will be executed. Otherwise, the program will continue from the END, that marks the end of the **WHILE**.

If the internal statements have been executed (what is called to make a loop's **iteration**), the condition will be verified again. If it is true, another **iteration** will be made (the internal statements will be executed again). This process will be repeated until it is verified that the condition of the **WHILE** is false.

If the condition turns to be false directly while a **WHILE** statement is executed, then the internal statements will never be executed.

Sample program:
```div
PROGRAM my_game;
BEGIN
    x=0;
    WHILE (x<320)
        x=x+10;
        FRAME;
    END
END
```

In this example, the **x** local variable ( x coordinate of the process) will be put at 
zero and then, providing that x is less than 320, 10 will be added to **x** and a FRAME will be performed.

A BREAK statement inside a **WHILE** loop will immediately finish it, continuing the program from the following statement to that loop.

A CONTINUE statement inside a **WHILE** loop will force the program to
verify the initial condition immediately and, if it is true, to execute again the internal statements from the beginning (after the **WHILE**).
If the condition turns to be false, the CONTINUE statement will finish the loop.

The internal statements of a **WHILE** loop can be as many as desired, and of any kind, obviously including new **WHILE** loops.

---
See: Syntax

## [1023] REPEAT statement

**REPEAT**  
    <statement> ;  
    ...  
UNTIL ( <condition> )

The **REPEAT** (REPEAT ... UNTIL( ... )) statement implements a **loop**. That is to say, it is capable of **repeating a group of statements a specific number of times**.

In order to implement this loop, it is necessary to start with the reserved word **REPEAT**, followed by the statements that you want to repeat once or more times, and the end of the statement will be determined by putting the reserved word UNTIL, followed by the condition that has to be complied for **the statement to finish**.

When a **REPEAT** statement is executed, the internal statements (those placed between the **REPEAT** and the UNTIL) will be executed first and then, the condition specified in the UNTIL will be verified. If it is still false, the internal statements will be executed again. The process will be repeated until the condition of the UNTIL turns to be true, continuing then the execution of the program after this statement.

Every time that the internal statements are executed, a loop's **iteration** has been made. The **REPEAT** ... UNTIL (the **<condition>** is complied) statement will always execute the internal statements at least once, so it always verifies the condition after the execution.

Sample program:
```div
PROGRAM my_game;
BEGIN
    x=0;
    REPEAT
        x=x+10;
        FRAME;
    UNTIL (x>320)
END
```

In this example, the **x** local variable (x coordinate of the process) will be put at 
zero and then, 10 will be added to **x** and a FRAME will be performed **until** **x** becomes a number bigger than 320.

A BREAK statement inside a **REPEAT** loop will immediately finish it, continuing the program from the following statement to that loop.

A CONTINUE statement inside a **REPEAT** loop will force the program to immediately make the verification of the UNTIL and, if it is true, it will execute again the internal statements from the beginning (after the reserved word **REPEAT**). If the condition turns to be true, the CONTINUE statement will finish the loop.

The internal statements of a **REPEAT ** loop can be as many as desired, and of any kind, obviously including new **REPEAT** loops.

---
See: Syntax

## [1024] LOOP statement

**LOOP**  
    <statement> ;  
    ...  
END

The **LOOP** statement implements an **infinite loop**. That is to say, it **indefinitely repeats a group of statements**.

In order to implement this loop, it is necessary to start with the reserved word **LOOP**, followed by the statements intended to be repeated continuously, putting the reserved word END at the end.

When a **LOOP** ... END statement is found in a program, all the internal statements of that loop will repeatedly be executed from this position.

In order to finish a **LOOP** loop, it is possible to use the BREAK statement which, on being executed inside a loop of this kind, will force the program to continue from the END.

Every time that the internal statements are executed, a loop's **iteration** has been made. The CONTINUE statement inside a loop will finish the current **iteration** and will start the following one (the program will go on running after the reserved word **LOOP**.

Sample program:
```div
PROGRAM my_game;
BEGIN
    x=0;
    LOOP
        IF (key(_esc))
            BREAK;
        END
        x=x+1;
        FRAME;
    END
END
```

In this example, the **x** local variable (x coordinate of the process) will be put at 
zero and then, 1 will be added to **x** and a FRAME will continuously be done. If the escape key (**ESC**) is pressed, then the BREAK statement will be executed, finishing the **LOOP** loop.

The internal statements of a **LOOP** loop can be as many as desired, and of any kind, obviously including new **LOOP** loops.

---
See: Syntax

## [1025] FOR statement

**FOR** (<initialization>; <condition>; <increment>)  
    <statement> ;  
    ...  
END

The **FOR** statement (replica of the C language) implements a **loop**. That is to say, it is capable of **repeating a group of statements a specific number of times**.

In order to implement this loop, three different parts must be specify in brackets, separated by symbols ; (semicolon) after the reserved word **FOR**. These three parts, that are optional (they can be omitted), are the following ones:

- **Initialization**. An assignment statement is normally codified in this part. This kind of statement establishes the initial value of the variable that is going to be used as a counter of the loop's **iterations** (each execution of the inner group of statements is called a loop's **iteration**).  The assignment statement **x=0**, that would put the **x** variable at zero at the beginning of the loop (value
for the first iteration), is an example.

- Condition. A condition is specified in this part. Just before each iteration, this condition will be checked and, if it is true, the group of statements will be executed. If the condition is false, the **FOR** loop will finish, continuing the program after the END of the **FOR** loop.
An example of condition can be **x<10**, that would allow the inner group of statements to be executed only when the **x** variable is a number
less than **10**.

- **Increment**. The increment of the variable used as a counter for each iteration of the loop is indicated in the third part. It is normally expressed with an assignment statement. For instance, the **x=x+1** statement would add **1** to the **x** variable after each iteration of the loop.

The group of inner statements of the loop that are going to sequentially be repeated while the condition of continuance (second part) is complied, must appear after the definition of the **FOR** loop with its three parts. After this group of statements, the reserved word END will determine the end of the **FOR** loop.

When a **FOR** statement appears in a program, the part of the initialization will be executed first, checking the condition. If it is true, the inner group of statements first and, the part of the increment then, will be executed, being the condition checked again, etc. If, before any iteration, the condition turns to be false, the **FOR** statement will immediately finish.

A program with a **FOR** loop containing the three parts mentioned in the previous sections is now shown.

Sample program:
```div
PROGRAM my_game;
BEGIN
    FOR ( x=0 ; x<10 ; x=x+1 )
        // The internal statements would be put here.
    END
END
```

This loop would first run with the **x** variable equal to **0**, the second one equal to **1**, ..., and the last variable equal to **9**. The part of the increment would be executed after this iteration, becoming **x** equal to **10**. Then, on
checking the condition of continuance in the loop (**x** is less than **10**), if it is false, the loop would finish.

As it has been mentioned, the three parts in the definition of the loop are optional. If the three were omitted:

  **FOR ( ; ; )**  
      // ...  
  **END**

Then, this loop would be equivalent to a LOOP ... END loop.

Moreover, several parts of initialization, condition or increment can be put in a **FOR** loop, separated by commas (,). At first, all the initializations will be executed. Then, all the conditions of continuance will be checked (if any of them turns to be false, the loop will finish). The inner statements and, after every iteration, all the increments, will finally be checked.

Sample program:
```div
PROGRAM my_game;
BEGIN
    FOR ( x=0, y=1000 ; x<y ; x=x+2, y=y+1 )
        // The internal statements would be put here.
    END
END
```

A BREAK statement inside a **FOR** loop will immediately finish it, continuing the program from the following statement of this loop.

A CONTINUE statement inside a **FOR** loop will force to execute the part of the increment directly and then, to verify the condition of continuance. If it is true, then the inner statements will be executed again from the beginning. If the condition turns to be false, then the CONTINUE statement will finish the **FOR** loop.

A **FOR** loop is practically equivalent to a WHILE loop, implemented
in the following way:

Sample program:
```div
PROGRAM my_game;
BEGIN
    x=0;
    WHILE (x<10)
        // The internal statements would be put here.
        x=x+1;
    END
END
```

With the only exception that a CONTINUE statement, inside this WHILE loop, would not execute the part of the increment, while it would do so inside a **FOR** loop.

If, after the execution of the initialization, the condition turns to be false directly inside a **FOR** loop, no inner statements will ever be executed.

The internal statements of a **FOR** loop can be as many as desired, and of any kind, obviously including new **FOR ** loops.

---
See: Syntax

## [1026] BREAK statement

A **BREAK** statement inside a loop will immediately finish it, continuing the program from the following statement to that loop.
This statement can only be put inside the following loops:

  LOOP ... END  
  FROM .. TO .. STEP .. ... END  
  REPEAT ... UNTIL ( .. )  
  WHILE ( .. ) ... END  
  FOR ( .. **#1068;** .. ; .. ) ... END  

A **BREAK** sentence will make the program continue its execution after the END or the UNTIL of the loop closer to the statement.

If there are several nested loops (one inside another one), the **BREAK** statement will only exit the inner loop.

Sample program:
```div
PROGRAM my_game;
BEGIN
    LOOP
        REPEAT
            IF (key(_esc)) BREAK; END
            //...
        UNTIL (x==0);
        //...
    END
END
```

In this example, the **BREAK** statement will exit the REPEAT ... **UNTIL** (when the **ESC** key is pressed), but not the LOOP ... END.

**Important**

---

The **BREAK** statement is not valid to finish IF,
SWITCH (or the CASE sections of this statement), or
CLONE statements.

**BREAK** can only finish the statements that implement a loop.

---
See: Syntax

## [1027] CONTINUE statement

A **CONTINUE** statement inside a loop will force the program to
finish its current iteration and start the following iteration.

We call **iteration** to each execution of the set of statements internal to a loop (the statements between a LOOP and its END, for instance).

This statement can only be put inside one of the following loops:

LOOP ... END  
A CONTINUE inside this loop will jump to the LOOP.

FROM .. TO .. STEP .. ... END  
A CONTINUE inside this loop will perform the increment (STEP) and, if the value indicated in the TO has not been passed, the program will continue at the beginning of the loop.

REPEAT ... UNTIL ( .. )  
A CONTINUE inside this loop will jump to the UNTIL.

WHILE ( .. ) ... END  
A CONTINUE inside this loop will jump to the WHILE.

FOR ( .. ; .. ; .. ) ... END  
A CONTINUE inside this loop will perform the increment
and the comparison. If the latter is true, the program will continue at the beginning of the loop. But if it is false, the program will continue after the END of the FOR.

If there are several nested loops (one inside another), the **CONTINUE** statement will take effect only in the inner loop.

Sample program:
```div
PROGRAM my_game;
BEGIN
    FOR (x=0, y=0;x<10;x++)
        IF (x<5) CONTINUE; END
        y++;
    END
END
```

In this example, after the whole loop has been executed, **x** will be equal to **10** and **y** will be equal to **5** as, providing that **x** is less than 5, the **CONTINUE** statement prevents the **y++;** statement from being executed.

**Important**

---

The **CONTINUE** statement is not valid inside IF,
SWITCH (or the CASE sections of this statement), or
CLONE statements (as these statements do not implement loops and, therefore, they do not make iterations).

---
See: Syntax

## [1028] RETURN statement

The **RETURN** statement immediately finishes the current process, as if the END of its BEGIN was reached.

When this statement is included in the main code, it will finish the current process. But if there are alive processes, they will go on running. For instance, the exit() function can be used to finish a program and all its processes.

A **RETURN** inside a process will finish it, killing this process.

Sample program:
```div
PROGRAM my_game;
BEGIN
    LOOP
        IF (key(_esc))
            RETURN;
        END
        FRAME;
    END
END
```

In this example, the **RETURN** statement will be executed by pressing the escape key (**ESC**), finishing the program.

**Use of RETURN to return a value**

---

It is possible to design processes with a performance similar to the functions
of other programming languages, that {receive a series of parameters and
return a value}. For instance, a process receiving two numeric values and returning the biggest one.

For that, this statement must be used with the following syntax:

**RETURN(**<expression>**)**

It is also important not to use the FRAME statement inside the process,
as this statement will immediately return to the calling process. When the compiler finds the FRAME statement inside a PROCESS, it directly classes it as a process, ruling out its hypothetical use as a function.

The example proposed before is shown now: an implementation of the
mathematical function **max** that returns the greater of its two parameters.

Sample program:
```div
PROGRAM my_game;
BEGIN
    x=max(2, 3)+max(5, 4);
END
PROCESS max(a, b)
BEGIN
    IF (a>b)
        RETURN(a);
    ELSE
        RETURN(b);
    END
END
```

After the execution of this program, the **x** variable of the main process will be equal to **8** (3+5).

**Important**

---

By default, if the **RETURN** statement is used without the expression
in brackets or the FRAME statement is used in a process, its return value will be its identifying code of the process}.

---
See: Syntax

## [1029] FRAME statement

The **FRAME** statement is an essential part of the language. A program's working is below described in general terms:

- The main program starts its execution. This process may create more processes (objects of the game) at any point. All the processes may finish at any moment, and they may create or eliminate other processes.

- The games will always be displayed frame by frame. In each frame, the system will execute all the processes existing at that moment, one by one, until each one executes the **FRAME** statement, which will indicate that it is ready for the next display (frame).

In the preparation of each frame, all the processes will be executed in the established priority order (the priority local variable of the processes determines this order).

Therefore, this statement is similar to an order for the processes to be displayed.

If a process starts its execution and it neither finishes nor executes this statement, then the program will become blocked, as there is a process that is never ready for the next display. Therefore, the system won't be capable of showing the following frame.

Sample program:
```div
PROGRAM my_game;
BEGIN
    my_process();
    my_process();
    LOOP
        IF (key(_esc))
            my_second_process();
        END
        FRAME;
    END
END
PROCESS my_process()
BEGIN
    LOOP
        FRAME;
    END
END
PROCESS my_second_process()
BEGIN
    LOOP
    END
END
```

In this program, the main process (a **my_game** type process) creates other two
processes (**my_process** type). From that moment, the three processes
will continuously be executed, each one to their **FRAME** statement. But if the escape key (**ESC**) is pressed, then the main process will create a new process (**my_second_process** type) that will remain in a LOOP loop indefinitely, without executing any **FRAME**. Consequently, the program will be interrupted (the system will report such a situation after few seconds; see max_process_time).

Basically, all the processes that correspond with objects of a game
construct a loop inside which, every frame establishes all its display values (x, y, graph, size, angle, ...), executing then the **FRAME** statement.

**Synchronization of processes**

---

It is possible to use this statement with the following syntax:

**FRAME(**<percentage>**)**

By putting in brackets a whole percentage, from 0 to 100 or bigger, after the reserved word **FRAME**.

This figure will indicate the percentage of the following frame, completed by the  process. That is to say, the absence of this percentage is equivalent to putting **FRAME(100)** (100% of the work previous to the following display has been completed by the process).

For instance, if a process executes the **FRAME(25)** statement in a loop, it will need to execute it **4 times** before it is ready for the next display (as 4*25% is the 100%).

On the other hand, if a process executes the **FRAME(400)** statement inside its loop, after its first execution, it will have completed 400% the display. Therefore,even after the display, a completed 300% of display will still be missing. For that, in the preparation of the following **3** frames the system won't execute this process, as it is ready for the display. Then, this process would be executed just once every 4 frames (unlike the example of the previous paragraph, in which it was executed 4 times every game's frame).

The processes won't reach the next display unless they give **100%, at least**. For instance, if a process always executes **FRAME(80)** statements, it will execute them twice before the first display, so it will have completed 160% (2*80%) the display. Therefore, it will have precompleted 60% (160%-100%) for the next display. For that reason, in the second display it will only require a **FRAME(80)** statement to be displayed, as this 80%, plus the remaining 60% of the first display, will be equal to a 140% completed. Therefore, it will immediately be displayed ,and a 40% will be even left to prepare the next frame.

---

A **FRAME(0)** statement completing a 0% of the next display only makes sense in the two following cases:

- It can be a way to force the system to execute in this point the rest of the processes having the same priority as the current one and, after them, the system will execute the latter again.

- It can also be a way to initialize functions such as get_id() or
collision(), as they return some specific values for every frame. If the aim is to obtain values again, it is possible to execute a **FRAME(0)** statement that will be interpreted as a new frame by these functions.

---
See: Syntax

## [1030] CLONE statement

**CLONE**  
    <statement> ;  
    ...  
END

This statement creates a new process identical to the current one, with the exception that the statement between the reserved words **CLONE** and END will only be executed in the new process, but not in the current one.

For instance, if any process of the program, with specific coordinates (x, y) and with a specific graphic (graph), executes the following statement:

  **CLONE**  
      x=x+100;  
  END

A new process will be created, identical to the former, with the same graphic and the same values in all its variables, with the exception of the x coordinate that, in the new process, will be placed **100** pixels farther to the right.

This statement is used to create replicas of a process, dividing it into two processes (almost) similar.

Sample program:
```div
PROGRAM my_game;
BEGIN
    // ...
    x=0;
    y=0;
    CLONE
        x=x+10;
    END
    CLONE
        y=y+10;
    END
    // ...
END
```

In this example, the **2** **CLONE** statements will create **3** copies of the main process (and not 2, as it could have been expected).

On executing the first **CLONE** statement, a new process will be created. Thus, there will be **2** processes: one in (x=0, y=0) and the other in (x=10, y=0). These two processes will execute the second **CLONE** statement. The first one (the original one) will create a new process in (x=0, y=10), and the second one will create the new process in (x=10, y=10).

To create only **2** copies of the original process, the program could have been constructed, for instance, in the following way:

Sample program:
```div
PROGRAM my_game;
BEGIN
    // ...
    x=0;
    y=0;
    CLONE
        x=x+10;
        CLONE
            y=y+10;
        END
    END
    // ...
END
```

The original process (x=0, y=0) will create one in (x=10, y=0) and the latter will create another one in (x=10, y=10). Therefore, only two copies of the original will be created.

Much care must be taken when it comes to using the **CLONE** statement sequentially or inside a **loop**, as it is necessary to take into account that the first '**clones**' may also create new '**clones**'.

This statement can be used without putting statements between the words **CLONE** and END. But, intending to have two identical processes with the same coordinates, the same graphic and executing the same code, seems to make little sense, at least at first.

---
See: Syntax

## [1031] DEBUG statement

The **DEBUG** statement will call the interactive debugger when it is executed.

It is normally used to debug programs, that is to say, to find possible
errors of the programs. On some occasions, it is normally put in the following points.

- Where you want to verify that a part of the program has done what was expected. After the execution of that part, **DEBUG** will call the debugger, from which it is possible to check all the active processes and the value of all their variables.

- When you are not very sure whether something can happen in a program, you can put this statement in that point to report you whether what we are expecting actually happens.

This statement is only used temporarily, until the error that is looked for is found. From that moment, the statement won't be necessary. Thus, it can be removed from the program since it has no additional effect.

Sample program:
```div
PROGRAM my_game;
BEGIN
    // ...
    IF (x<0)
        DEBUG;
    END
    // ...
END
```

In this example, it is verified that, in a specific point of the program, the **x** coordinate of the process is not a negative number (less than zero). If this happens, the debugger will be called to find out why it has happened.

When this statement is executed, a dialog box appears, offering us the following options:

- To disable the **DEBUG** statement, preventing it from being activated in this execution of the program.

- To stop the program and enter the debugger, to be able to examine all the processes and their variables.

- Or to finish the execution of the program immediately, returning to its edition in the windows' graphic environment.

Moreover, if the escape key **ESC** is pressed in that box, the **DEBUG** statement will simply be ignored, and the program will continue to be executed as usual.

---

When a program is executed from the windows' graphic environment, the debugger can be called at any moment by pressing the **F12** key.

On invoking the debugger in this way, the program will always be interrupted just before starting the processing of a new frame. All the processes to be executed will appear before the next display.

---
See: Syntax

## [1032] List of functions of the language.

  Functions of processes' interaction  
    collision()  
    get_angle()  
    get_dist()  
    get_distx()  
    get_disty()  
    get_id()  
    let_me_alone()  
    signal()  

  Mathematical functions  
    abs()  
    advance()  
    fget_angle()  
    fget_dist()  
    near_angle()  
    pow()  
    rand()  
    rand_seed()  
    sqrt()  

  Graphic functions  
    clear_screen()  
    get_pixel()  
    map_block_copy()  
    map_get_pixel()  
    map_put()  
    map_put_pixel()  
    map_xput()  
    put()  
    put_pixel()  
    put_screen()  
    xput()  

  Music and sound functions  
    change_sound()  
    is_playing_cd()  
    load_pcm()  
    play_cd()  
    set_volume()  
    sound()  
    stop_cd()  
    stop_sound()  
    reset_sound()  
    unload_pcm()  

  Input functions  
    get_joy_button()  
    get_joy_position()  
    key()  

  Functions to use the palette  
    convert_palette()  
    fade()  
    fade_off()  
    fade_on()  
    load_pal()  
    roll_palette()  

  Functions for scroll and mode-7  
    move_scroll()  
    refresh_scroll()  
    start_mode7()  
    start_scroll()  
    stop_mode7()  
    stop_scroll()  

  Functions to display texts  
    delete_text()  
    load_fnt()  
    move_text()  
    write()  
    unload_fnt()  
    write_int()  

  Functions for animations  
    end_fli()  
    frame_fli()  
    reset_fli()  
    start_fli()  

  Functions of screen regions  
    define_region()  
    out_region()  

  Functions of information about graphics  
    get_point()  
    get_real_point()  
    graphic_info()  

  Functions of initialization  
    set_fps()  
    set_mode()  
    load_fpg()  
    load_map()  
    unload_fpg()  
    unload_map()  

  Functions of data saving  
    load()  
    save()  

  Function of the system  
    exit()  
    system()  

---

**Note:** To obtain help about a specific function directly, place the edit cursor on the name of the function (in the programs editor) and press **F1**.

---
See: Syntax

## [1033] Call to a process

<process_name>**(**<list of parameters>**)**

To call a process, put the name of the process, followed by a list including as many expressions separated by commas (,), as parameters of the process, in brackets (()). The brackets are obligatory, even if the process has no call parameters.

A call to a process will always return a value that depends on which one of the following actions is performed first by the called process.

- If the FRAME statement is executed, then the process will return its identifying code.

- If the process executes the RETURN(<expression>) statement, then the former will return the result of this expression.

- If the process finishes, either because the END of its BEGIN is reached or because a RETURN statement is executed with no expression, the process will return the identifying code that had. But, as the process has finished (killed), it is necessary to take into account that this identifying code can now be used by any other process created from now on.

The return value can be ignored, assigned to a variable or used inside an expression.

Sample program:
```div
PROGRAM my_game;
PRIVATE
  id2;
BEGIN
    my_process(0, 0);
    id2=my_process(320, 200);
    // ...
END
PROCESS my_process(x, y)
BEGIN
    LOOP
        FRAME;
    END
END
```

In this example, the main process **my_game** makes two calls to the process **my_process**, which receives two parameters in its **x** and **y** local variables.

As the process executes the FRAME statement, it will return its identifying code.

It can be noticed how the value returned in the first call to the process
is ignored (it is not used at all), and how, in the second call, the identifying code of **my_process(320, 200)** is assigned to the private variable of the main process **id2**.

When a call to a process is made, the execution of the current process is momentarily stopped, and the code of the called process is executed, until it is returned through one of the three mentioned cases (until it finishes or executes a FRAME or RETURN statement).

If the process has finished with a FRAME statement, it will be displayed in the following frame according to the values established in its local variables (x, y, graph, ...) and, in the preparation of the following frame, this process will go on running from the FRAME statement.

---
See: Syntax - Parameters of a process

## [1034] Reference to a datum

A reference to a datum is any expression making reference to a cell or a position of the computer's memory. It is normally understood as one of the following aspects:

- If the datum is a variable, in order to refer to the datum in this way, we must simply specify its name.

Example of a reference to a variable: **x**

- If the datum is a table, reference to it is normally made with its name followed by an expression in square brackets ([ ]).That expression will determine the position of the table intended to be accessed.
If the index in square brackets is omitted, the first position of the table (position 0) will be accessed.

Example of a reference to a table: **timer[0]**

- If the datum is a structure, reference to it will be made with its name followed by an expression in square brackets ([ ]) that will determine the number of records that will be accessed. After it, the symbol . (period) will be put, preceding the specific name of the structure's field that is going to be accessed. If the record number in square brackets is omitted, the first record of the structure (number 0) will be accessed. 

Example of a reference to a structure: **scroll[0].z**

These three cases deal with accessing data of the process itself or global data. To access an alien datum (a local datum of another process), it will be preceded by the identifying code of the alien process and the symbol . (period), operator of access to local data and structures).

Example of a reference to an alien local variable: **father.x**

---
See: Syntax

## [1035] Definition of an expression

An expression is basically a mathematical formula involving one or more **operands** (**x**, **2**, **id**, ...) through different **operators** (*****, **AND**, **>>**, ...); some examples of expressions would be:
**2**, **2+3** or **(x*4)/-3**.

Only integers within the range (min_int ... max_int) can be used as values. The result of the expression will always be truncated within this range.

These expressions will be evaluated when the statement containing them inside the program is executed.

The **operands** that can be used in an expression are the following ones:

    - Constants.  
    - **Numeric values**.  
    - **Literals** (texts in inverted commas).  
    - Variables, tables or structures of any kind.  
    - Any kind of function or process.  
    - Identifying code of the process.  
    - Type of process (type <name>).  

The **operators** that can be used in an expression are the following ones (the synonymous of the operator, if they exist, are shown in brackets):

     +    Addition  
     -    Subtraction (or sign negation)  
     *    Multiplication  
     /    Division  
     MOD  Module (%)  
     <<   Rotation to the right  
     >>   Rotation to the left  
     NOT  Binary and logical negation (!)  
     AND  Binary and logical AND(&, &&)  
     OR   Binary and logical OR(|, ||)  
     XOR  Exclusive OR (^, ^^)  
     ==   Comparison  
     <>   Different (!=)  
     >    Bigger  
     >=   Bigger or equal (=>)  
     <    Less  
     <=   Less or equal (=<)  
     OFFSET Direction or offset (&)  
     ++   Operator of increment  
     --   Operator of decrement  
     POINTER Addressing operator (*, ^, [ ])  
     ( )  Brackets  

Click on "Evaluation of an expression" to see the order in which the calculations are made inside an expression and when the brackets must be used.

Some examples of valid expressions are now shown:

**    -33**  
**    44-2*22**  
**    id**  
**    x+1**  
**    (angle*3)/2-pi/2**  
**    (x+y)/2**  
**    abs(x-y)*3-pow(x, 2)**  
    ...

---
See: Syntax - Evaluation of an expression

## [1036] Evaluation of an expression

It is important to know the way in which the expressions are evaluated in order to know where it is necessary to put brackets indicating the way in which the expression is intended to be evaluated.

In the language, an expression can contain operators of different levels of priority.

In the evaluation of an expression, the operators of **priority 1** (if they exist), will always be processed first, and then, those of **priority 2**, **priority 3** and so on.

Priority 1  
     ( )  Brackets, beginning and end of a subexpression  

Priority 2  
     .    Period, access' operator to local data and structures  

Priority 3  
     NOT  Binary and logical negation (#1045,**!**)  
     OFFSET Offset (#1050,**&**)  
     POINTER Addressing operator (*, ^, [ ])  
    ** -**  Sign negation  
     ++   Operator of increment  
     --   Operator of decrement  

Priority 4  
     *    Multiplication  
     /    Division  
     MOD  Module (%)  

Priority 5  
     +    Addition  
     -    Subtraction  

Priority 6  
     <<   Rotation to the right  
     >>   Rotation to the left  

Priority 7  
     AND  Binary and logical AND (&, &&)  
     OR   Binary and logical OR (|, ||)  
     XOR  Exclusive OR (^, ^^)  

Priority 8  
     ==   Comparison  
     <>   Different (!=  
     >    Bigger  
     >=   Bigger or equal (=>  
     <    Less  
     <=   Less or equal (=<  

Priority 9  
     =    Assignment  
     +=   Addition-assignment  
     -=   Subtraction-assignment  
     *=   Multiplication-assignment  
     /=   Division-assignment  
     %=   Module-assignment  
     &=   AND-assignment  
     |=   OR-assignment  
     ^=   XOR-assignment  
     >>=  Rotation to the right-assignment  
     <<=  Rotation to the left-assignment  

The operators of **priority 3** are known as **unary** operators. They do not link two operands (unlike the **binary** operators such as, for instance, a multiplication), but they just affect the value of an operator. Inside the **unary** operators, those closest to the operand will be executed first. For instance, in the expression:

  **NOT -x**

The operand **x** has two **unary** operators, the negation of sign** -** and
the logical and/or binary NOT. Among them, the negation of sign will be executed first, as it is closer to the operand.

From **priority 4**, all the operators are **binary** and they will be executed according to their level of priority. Therefore, when in an expression there is more than one operator of the same level (for instance, a multiplication and a division, both of priority 4), they will be processed from left to right. That is to say, in the following expression:

  **8/2*2**

The division will be executed first and then, the multiplication (it is the natural way to evaluate the expressions mathematically).

The only exception are the operators of **priority 9** (**assignment** operators),
that will be evaluated from right to left (instead of from left to right). That is to say, in the expression:

  **x=y=0**

**y=0** will be processed first (**y** will be put at **0**) and then, **x=y** (**x** will also be put at **0**, as **y** will now be equal to **0**).

As it can be noticed, the assignments work like an operator
After the assignment, they return the value they have assigned as a result of the operation.

---
See: Syntax - Definition of an expression

## [1037] Definition of a condition

The conditions are expressions normally similar to the following ones:

  **x<320**  
  **size==100 AND graph>10**  
  **y==0 OR (x>=100 AND x<=200)**  
  ...

In general, any expression is valid as a condition. In the language, all the **ODD** expressions are interpreted as **true** and all the **EVEN** expressions are interpreted as **false**.

Sample program:
```div
PROGRAM my_game;
BEGIN
    IF (20*2+1)
        x=x+1;
    END
END
```

In this example, the **x=x+1;** statement will always be executed, as the expression **20*2+1** is equal to **41**, an **odd** number.

All the available operators are valid inside a condition. It is even possible to perform assignments inside a condition (the assignments are operations that return the assigned value as a result).

All the identifying codes of processes are **odd** numbers. That is to say, all of them are **true**. Therefore, it is possible to implement conditions
as the following one (supposing that **id2** has been declared as a variable,
and that **shot** is a type of process of the program).

  **WHILE (id2=get_id(type shot))**  
      **id2.size=id2.size-1;**  
  **END**

In the **id2=get_id(type shot)** condition, the result of the **get_id** function is being assigned to the **id2** variable. If that function has returned an identifying code, it will be an **odd** number and the condition will be evaluated as **true** (if **get_id()** does not find (more) identifiers of "**shot** type" processes, then it will return **0** (an **even** number), and the condition will be interpreted as **false**, finishing the WHILE statement.

The previous statements would decrement the size variable of all the **shot** type processes existing in the program.

---
See: Syntax - Definition of an expression

## [1038] Ways to obtain the identifying code of a process.

All the processes have their own identifying code in ID
(reserved word in the language that is equivalent to the identifying code of the process).

When a process is created (is called), it returns its own identifying code as return value, unless it has finished with a RETURN(<expression>). That is to say, a process will always return its identifying code when it finishes (when its END is reached), when itexecutes the FRAME or the RETURN statements without expression in brackets.

In the following example, a process (**my_process** type) is created from the main program, and its identifier is stored in the **id2** variable.

Sample program:
```div
PROGRAM my_game;
PRIVATE id2;
BEGIN
    id2=my_process();
    // ...
END
PROCESS my_process()
BEGIN
    // ...
END
```

All the processes have the following local variables predefined with identifiers of other processes:

father - father, identifier of the process that created it (the one that made the call).

son - son, identifier of the last process created by it (last called process).

bigbro - Elder brother, identifier of the last process created by the father before creating it.

smallbro - Younger brother, identifier of the following process created by the father after having created it.

These variables can be equal to **0** if they have not been defined (for instance,
son will be equal to **0** until a process is not created or if this process has disappeared).

The processes' identifying codes allow us to access their local variables (<identifier>.<variable>) and, as father, son, etc. are also local variables, it is possible to make combinations such as **son.bigbro** to access the identifier of the penultimate process created (as son is the last one; therefore, its elder brother will be the penultimate one).

Besides creation or direct relationship, there are other ways to obtain identifying codes of processes, as indicated below:

- The get_id() function to obtain the identifiers of the processes of a specific type (spacecraft, shot, etc.) existing at a specific moment in the game.

- The collision() function to obtain the identifiers of the
processes with which it is colliding.

When a specific process needs to access from many others, as it is an important process such as, for instance, the protagonist spacecraft of a game,
then it can be more useful to assign its identifier to a GLOBAL variable of the program (that can be accessed by any process at any point). Thus, any process will be able to interact with it, as it will have its identifier.

Sample program:
```div
PROGRAM my_game;
GLOBAL
  id_spacecraft;
BEGIN
    id_spacecraft=spacecraft();
    // ...
END
PROCESS spacecraft()
BEGIN
    // ...
END
PROCESS enemy()
BEGIN
    // ...
    id_spacecraft.z=0;
    // ...
END
```

In this example, at a specific point the **enemy** type processes access the **z** variable of the **spacecraft** created by the main program, using for that purpose its identifier, that is included in the **id_spacecraft** global variable.

---
See: Identifying codes of processes.

## [1039] Identifying codes of processes.

A process is an object independent of the program, that executes its own code and that can have its own coordinates, graphics, etc. Processes of a program can be, for instance, a shot, spacecraft or enemy.

When something similar to what is below is input inside a program:

**PROCESS shot(**...**);**  
BEGIN  
   ** // **statements** ...**  
END

The statements that are going to execute the "**shot** type" processes (that is to say, the code ruling their performance), are specified.

As it can be noticed, more than one **shot** type process may exist in a program. Then, how can they be distinguished? Simply by their identifying code.

Every time that a new process is created in a game, an identifying code is assigned to this process. This code is going to be the exclusive reference of the process until it disappears.

Two different processes will never have the same identifying code at the same time. However, the code that belonged to a process that has already disappeared can be assigned to a new process (something similar to what happens in relation to an i.d.).

The identifying codes are always whole, positive, odd numbers, like 471, 1937 or 10823.

All the processes have their own identifying code in ID, that is something similar to a process' local variable local, with the proviso that it can not be modified.

Moreover, the processes have the identifying code of the process that created them (that called them) in father. They have the identifying code of the last process they created (the last one they called) in son. And so on.
(see Hierarchies of processes).

**What are the identifying codes for?**

---

Normally, all the processes need the identifying code of the other processes in order to interact with them (to see where they are, to modify them, ...).

For instance, it is not possible to subtract energy from the "**enemy** type" process, as many or none of this type of processes may exist. It is necessary to have the specific identifying code of the **enemy** process from which you want to subtract energy.

A process accesses all its own variables simply by their names, such as x, size or graph. Thus, if the identifier of a process is known (in son, father or any variable defined by the user, such as **id2**), then it is possible to access the variables of that process, like (**son.x**, **father.size** or **id2.graph**). That is to say, the syntax to access local variables of another process is as follows:

  <identifying_code> . <name_variable>

These variables can normally be used to consult them modify them.

**It is not at all possible to access PRIVATE variables of another process at any rate**. In order to access a private variable of another process, it is necessary to change its declaration to the LOCAL section to transform it into a local variable. Then, any process will be able to access that variable just having the identifying code of the process, as all the processes will have that variable.

The identifiers have more utilities other than the access to alien local variables,
such as the signal() function, that can send specific signals to a process if its identifying code is known (for instance, to eliminate the process).

There are also other functions, such as collision(), used to detect collisions with other processes. When this function detects a collision, it returns the identifying code of the process with which it is colliding. Once this code is known, it is possible to access the variables of the process and send them signals.

The get_id() function operates in a similar way to collision(),
obtaining the identifying code of a process. But in this case, no collision with it is necessary.

---
See: Ways to obtain the identifying code of a process.

## [1040] States of a process.

Processes are the different elements of a program (objects of the game). They may experience different states on creating, destroying or receiving
specific signals with the signal() function.

**alive or awake.** process

A process is alive when it is running (when it is interpreting the statements
located between its BEGIN and its END).

**dead.** process

A process is dead when it finishes (either because its END is reached in  the execution, a RETURN is executed or because it receives a signal s_kill or s_kill_tree).

**asleep.** process

A process may receive the signal s_sleep (or s_sleep_tree), then becoming asleep. In this state, this process will appear to be dead. But it is not as, at any moment, it may receive a signal s_wakeup and return to the alive or awake states. It is also possible to kill an asleep process.

**frozen.** process

The signal s_freeze (or s_freeze_tree) freezes a process. In the frozen state, the process, that is still visible, remain blocked. It may be detected by the rest of the processes (for instance, as for collisions), but it is not executed (it stops interpreting its code statements). It will remain in this state until it receives another signal that changes its state or that kills it.

A frozen process may be controlled (moved) by another process,
directly manipulating its variables.

---

When a signal is sent to a process, aiming at changing its state, this signal will have no effect before its following display (FRAME) is reached if the process is running. If the process is not running, then the signal will have an immediate effect.

No signal must be sent to nonexistent processes (to an identifying code that does not correspond with any process).

This signal will be ignored when the aim is to put a process in the state in which it is already.

---
See: Hierarchy of processes.

## [1041] Hierarchies of processes.

A process is an independent object of the program, that executes its own code and that may have its own coordinates, graphics, etc. For instance, a shot, spacecraft or enemy can be processes of a program.

When a program starts to run there is only one process: the initial process, which starts the execution of the main code's statements. But, from this moment, this process can create new processes that, at the same time can create other processes, destroy them, etc.

In order to clarify the events appearing through a program, we use a simile, treating the processes as if they were alive beings that are born and killed (when they are created or destroyed). For that reason, the following terms are established:

**Father**, name given to the process that has created another one (mother would have been a more appropriate name).

**Son**, process created by another one.

**Brothers**, processes created by the same father.

**Orphan**, process whose father has died (as it has been either eliminated or finished).

This vocabulary may be spread as far as your imagination desires **grandfathers**, **grandsons**, **uncles**, etc.

All the processes have direct access to the identifying codes of the processes with which they have direct relationship (see: **#1038,Ways to obtain the identifying code of a process**.

Occasionally, reference is made to actions performed by  "**the system**". This process, called **div_main**, controls the rest. Therefore, it is in charge of creating the initial process at the beginning of the execution, of setting the speed execution, the debugger, etc. All the processes that are orphaned become sons of this process.

The **div_main identifier** can be obtained with get_id(0). It can be used to send a tree signal to all the processes, but this process won't be displayed on screen , even if its x, y, graph, etc. variables are defined.

---
See: States of a process 

## [1042] Types of processes.

The blocks of the programs starting with the reserved word PROCESS
determine the performance of a specific process type. Then, when the program is executed,  any number of processes of this type will be able to exist at a specific moment. Each of these processes will have a different identifying code, but all of them are of the same type.

Sample program:
```div
PROGRAM my_game;
BEGIN
    // ...
END
PROCESS spacecraft()
BEGIN
    // ...
END
PROCESS enemy()
BEGIN
    // ...
END
PROCESS shot()
BEGIN
    // ...
END
```

In this example, four types of processes are defined: **my_game** (the type of the program's initial process), **spacecraft**, **enemy** and **shot**.

The number of processes of each of these types existing in the game depends on the number of calls made to these processes.

All the processes of **spacecraft** type will always execute the statements defined in the **PROCESS spacecraft()** of the program.

**A "process type" is a numeric code referred to the name of the PROCESS that determines how the** process **works** **during the game. This numeric code can be obtained with: TYPE <name_of_the_process>.**

**TYPE** is an operator defined in the language that, applied to a process name,
returns this numeric code.

For instance, **TYPE spacecraft** will be equivalent to a specific numeric constant and **TYPE enemy** will be equivalent to another one.

All the processes have a local variable containing this numeric code, which is: **reserved.process_type**.

**Why is the process type for?**

---

The process type is used for several things, as it is mentioned below:

- For the get_id() function that receives a process type (for instance, **get_id(TYPE enemy)**) as a parameter and returns the identifying codes of the processes of this type existing in the game at that moment.

- For the collision() function is similar to the previous one, with the proviso that it returns the identifying codes of the processes with which it is colliding (that is to say, the graphics of both processes are partially superposed).

- For the signal() function, that may send a signal to all the existing processes of a specific type.

- Or to verify, from a process' identifying code, what kind of process it is (type spacecraft, type shot, etc.).

---

The operator TYPE can only be used preceding a process name of the program or the word **mouse**, to detect collisions with the mouse pointer (with **collision(TYPE mouse)**).

---
See: Identifying codes of processes.

## [1043] FROM statement

**FROM** <variable>=<constant> TO <constant>;  
    <statement> ;  
    ...  
END

(or)

**FROM** <variable>=<constant> TO <constant> STEP <constant>;  
    <statement> ;  
    ...  
END

The **FROM** statement implements a **loop**. That is to say, it is capable of **repeating a group of statements a specific number of times**.

A GLOBAL, LOCAL or PRIVATE variable of the process itself that can be used as a loop counter is needed to implement this loop.

The reserved word **FROM** must be put before the statements that will comprise the inner group of statements. This word will be followed by the **name of the counter variable**, the symbol of assignment (=), the **initial value** of the variable, the reserved word TO and, finally, the **final value** of the variable.
The symbol ; (semicolon) must be put after this declaration of the loop **FROM**.

The inner group of statements that is intended to be repeated a specific number of times is put after this head defining the conditions of the loop. Finally, the reserved word END will be put.

The name of **iteration** of the loop is referred to the number of times that the inner set of statements is executed.

The first iteration will be performed with the **initial value**
in the variable used as a counter. After this iteration, **1 will be added**
to this variable (if the initial value **is less** that the final value). Otherwise **1 will be subtracted** from it. After having updated the value of the variable, it is necessary to pass to the following iteration, provided that the value of this variable has not reached (or exceeded) the **final value** of the loop.

The reserved word STEP can be put as second meaning of the **FROM** statement, after the initial and final values of the statement. This word must be followed by a **constant value** indicating the increment of the counter variable after every iteration of the loop, instead of **1** or** -1**, which are the increments
that will be performed by default if the STEP declaration is omitted.

The following example shows a program with two loops **FROM**: one without 
STEP declaration (with increment or decrement by default) and the other with it.

Sample program:
```div
PROGRAM my_game;
BEGIN
    FROM x=9 TO 0;
        // Inner statements ...
    END
    FROM x=0 TO 9 STEP 2;
        // Inner statements ...
    END
END
```

The first loop will be executed **10** times with the **x** variable . Its value will range between **9** and **0** in the different iterations. By default, 1 will be subtracted from the variable each time, as the initial value (9) is bigger than the final value (0).

In the second loop, constant **2** is indicated as the increment of the variable. Thus, the loop will be executed **5** times with the **x** variable, whose values will be **0**, **2**, **4**, **6** and **8**, respectively, in the consecutive iterations.
As it can be noticed, no iteration will be performed with **x** being equivalent to **9**, even if it is the loop's **final value**.

By default, if **2** had not been specified as STEP of the loop,
**1** would have been added to the **x** variable after each iteration.

A loop **FROM** can always be performed with the FOR statement,
as it is now shown (with two loops equivalent to those of the previous example).

Sample program:
```div
PROGRAM my_game;
BEGIN
    FOR ( x=9 ; x>=0 ; x=x-1 )
        // Inner statements ...
    END
    FOR ( x=0 ; x<=9 ; x=x+2 )
        // Inner statements ...
    END
END
```

The **initial** and **final** values of a loop **FROM** must be different.

If the initial value **is less** than the final value, it is not possible to specify a negative value in the STEP declaration.

If the initial value **is bigger** than the final value, it is not possible to specify a positive value in the STEP declaration.

A BREAK statement inside a loop **FROM** will immediately finish it, continuing the program from the following statement to this loop (after the END).

A CONTINUE statement inside a **FROM** loop will force the program to increment the variable used as a counter immediately and then, if the final value has not been exceeded, to start the following iteration.

The statements inner to a loop **FROM** may be as many as desired, of any kind, obviously including new loops **FROM**.

---
See: Syntax

## [1044] Use of angles in the language.

In the language, all the angles are specified in degree thousandths.
For instance:

  **0** is **0 degrees** (to the right)  
  **90000** are **90 degrees** (up)  
 ** -45000** are** -45 degrees** (down right diagonal)  

If **360 degrees** (360000) are added to or subtracted from any angle, an equivalent angle is obtained. For instance, the angles -90000 and
270000 are equivalent (the angles of **-90 degrees** and **270 degrees**
go both downwards)

The constant PI predefined as **180000**, **3.1415 radians** or, what is the same, **180 degrees**, can be used as reference. For instance, **PI/2** will be equal to 90 degrees (90000).

Some of the functions dealing with angles are mentioned below:

  get_angle()  
  get_distx()  
  get_disty()  
  fget_angle()  
  near_angle()  
  advance()  

All the processes have a predefined local variable called **angle**
which, by default, will be equal to **0**. If its value is modified, the display's angle of the graphic of the process will be changed (the graphic will rotate in the indicated degrees, from the original graphic).

---
See: Syntax

## [1045] NOT  !

Unary operator of logical and binary **negation** used in expressions and
conditions.

The reserved word **NOT** and the symbol **!** are synonymous.

**NOT logical:** If the operand is **true**, on applying this operator to it, a **false** expression will be obtained, and vice versa.

  TRUE  ->  FALSE  
  FALSE   ->  TRUE  

**NOT binary:** Changes all the bits of the operand. That is to say, it passes 0 to 1 and 1 to 0.

---

**Note:** This operator indistinctly works as logical and binary as, in the language, the **true** logical expressions are interpreted as those that have their last bit at 1 (bit 0, weight 1) or, in other words, the odd numbers (1, -1, 3, -3, ...). And the **false** logical expressions are interpreted as those having their last bit at 0 (that is to say, the even numbers: 0, 2, -2, 4, -4, ...).

On changing the **NOT** operator, all the bits also change the last one, transforming then the even numbers into odd numbers (false expressions into
true ones) and the odd numbers into even numbers (true expressions into false ones).

---
See: Syntax - Expression - Condition

## [1046] <>  !=

Logical operator [**different from**] used in conditions. The symbols
**<>** and **!=** are synonymous.

It must be used between two numeric expressions, and it returns a logical result:

**False** - If both expressions have the same result (if these two expressions are equivalent), as they ARE NOT different.

**True** - If the expressions have different results, as they ARE different.

**Examples:**

  **2+2 <> 4** will return **false**.
  **0 <> -1**  will return **true**.

---
See: Syntax - Condition

## [1047] "  '

Symbols delimiting literals.

Literals are the **texts in inverted commas**. Literals may start and finish with the character [**'**] or even with the character [**"**] (but they have to start and finish with the same character). There are two ways to include the character [**"**] in a literal, supposing that the aim is to define a literal containing the text: a"B"c

 - Duplicating the character: "a""B""c"

 - Defining it with the simple inverted comma: 'a"B"c'

It happens the same regarding the character [**'**], that can be included in a literal if it is duplicated, or if the literal is delimited with the character [**"**].

All the literals must be closed in the same line as they started. It is not possible to define literals occupying more than one line.

---
See: Syntax

## [1048] MOD  %

Arithmetic operator of **module** or **remainder of a whole division**. The reserved word **MOD** and the symbol** %** are synonymous.

This operator is used in the arithmetic expressions between two
operands, to obtain the module of the first one divided by the second one.

For instance, **7 MOD 3** will return 1, as the whole division of 7
by 3 give us 2 as quotient and **1** as **remainder**.

That is to say, **n MOD m** will always return a number within the range (0..m-1).

To understand easily how to obtain the remainder of an operation
**n MOD m**, the following steps may be followed:

**Step 1** - If **n** is less than **m**, then the result of the operation **MOD** is **n**.

**Step 2** - (When **n** is bigger than or equal to **m**), subtract **m** from **n** and go to **step 1**.

---

**Use:** On some occasions, this operator is used in the programs requiring that a counter variable always changes between **0** and **other number**. For instance, if the aim is that the **x** variable indefinitely varies between 0 and 319 (x=0, x=1, x=2, ..., x=319, x=0, x=1, ...), then there would be the following option:

  **x=0;**  
  **LOOP**  
  **    x=x+1;**  
  **    IF (x==320) x=0;**  
  **    // ...**  
  **END**  

But many programs replace these statements by the following ones:

  **x=0;**  
  **LOOP**  
  **    x=(x+1) MOD 320;**  
  **    // ...**  
  **END**  

that fulfil the same function, as the operator **MOD** will truncate the expression when it is bigger than or equal to 320 at a lesser value.

---

The **quotient** of a whole division is obtained through the operator /
(division).

---
See: Syntax - Expression

## [1049] %=

Operative assignment. Operation of **module** or **remainder of a** whole **division**.

The assignment statements are used to calculate expressions and
**to assign them** to a datum.

<reference to a datum> **=** <expression> **;**

If the symbol **%=** is used instead of **=** to perform the assignment,
the following **module** or **remainder of the division** will be assign to the datum:

  [**previous_value_of_the_datum**] / [**result_of_the_expression**]

Example: **x=3; x%=2;** -> (x=1)

---

**Note:** This symbol is a simple abbreviation derived from the **C language**. Anyhow, a **n %= m;** type statement will be equivalent to this other **n = n MOD m;** statement.

See the operator MOD for further information about the **module**.

---
See: Syntax - Assignment

## [1050] &

Bifunctional symbol, that has two different uses depending on whether it is used as an unary or binary operator.

An **UNARY** operator appears inside an expression, simply preceding an operand (as if it was its sign). In this case, the operator** &** will be a synonymous of OFFSET.

**Example: &x** is equivalent to **OFFSET x**

A **BINARY** operator appears inside an expression, concatenating
two operands (showing an operation between both). In this case, the
operator** &** will be a synonymous of AND.

**Example: x&2** is equivalent to **x AND 2**

---
See: Syntax - OFFSET - AND

## [1051] AND  &&

Binary operator of the **logical product** used in expressions and conditions.

The reserved word **AND** and the symbol** &&** are synonymous.

**AND logical:** The conditions to the right and left of the operator are first evaluated and, if both are **true**, this operator will return **true**. Otherwise, the operator will always return **false**.

  FALSE  AND FALSE  = FALSE  
  FALSE AND TRUE = FALSE  
  TRUE AND FALSE  = FALSE  
  TRUE AND TRUE = TRUE  

They are used to verify that more than one condition is obligatory complied; for instance:

  **(x>0 AND x<100)**

To verify that the variable is bigger than 0 **AND** less than 100.

**AND binary:** Evaluates the bits of the results of the expressions appearing before and after the operator, giving as a result a value  that will have at one only the bits that both expressions had at one.

  0 AND 0 = 0  
  0 AND 1 = 0  
  1 AND 0 = 0  
  1 AND 1 = 1  

This rule will be applied to all the bits of the operands (in the language, they are 32 bit integers).

---

**Note:** This operator indistinctly works as logical and binary as, in the language, the **true** logical expressions are interpreted as those that have their last bit at 1 (bit 0, weight 1) or, in other words, the odd numbers (1, -1, 3, -3, ...). And the **false** logical expressions are interpreted as those having their last bit at 0 (that is to say, the even numbers: 0, 2, -2, 4, -4, ...).

The operator **AND** will only leave the last bit at 1 (it will only return **true**
as a result} when both operands have this bit at 1 (when both are **true** expressions).

---

**Note:** The symbol** &** can also be used as another synonymous of **AND** and  ** &&**.

---
See: Syntax - Expression - Condition

## [1052] &=

Operative assignment. Binary operation of **logical product** (**AND**).

The assignment statements are used to calculate expressions and **assign them** to a datum.

<reference to a datum> **=** <expression> **;**

If the symbol **&=** is used instead of **=** to perform the assignment,
the following **logical product** will be assigned to the datum:

  [**previous_value_of_the_datum**] AND [**result_of_the_expression**]

Example: **x=5; x&=6;** -> (x=4)

---

**Note:** This symbol is a simple abbreviation derived from the **C language**. Anyhow, the **n &= m;** type statement will be equivalent to this other **n = n AND m;** statement.

See the operator AND for further information about the **logical product**.

---
See: Syntax - Assignment

## [1053] (  )

The symbols **(** and **)**, called brackets, must always appear in pairs and in this same order.

They are used to delimit some calculations, parameters or conditions
of the programs, marking their beginning with the symbol **(** and
the end with the symbol **)**.

---

Inside an expression, they indicate that the calculation within them must be done before the calculation out of them.

For instance, the expression **2*3+2** will be evaluated as **8**, as the multiplication (2 by 3 equals 6) will be done first and then, the addition (6 plus 2 equals 8).

Using brackets, it is possible to force to do the addition at first,
expressing the calculation as **2*(3+2)**, that will be evaluated as **10**, as now the addition (3 plus 2 equals 5) will be done first and then, the multiplication (2 by 5 equals 10).

---

The brackets are also use to delimit the call parameters of the processes or the functions and inside the syntax of different statements of the language.

---
See: Syntax - Expression

## [1054] *

Arithmetic operator of whole **multiplication**. This operator is used in the arithmetic expressions between two operands, to obtain the result of their multiplication.

For instance, **2 * 8** will return **16**, **99 * 0** will return **0**, **2 * -1**
will return** -2**, etc.

All the variables are 32 bit **integers** with sign in the language.
Therefore, only integers within the range (min_int ... max_int)} can be used. Then, when the result of the **multiplication** must exceed that range, **incorrect results will be shown**. In this case, the system won't report any error. Hence, much care must be taken.

---

This symbol is bifunctional; that is to say, it has two different uses depending on whether it is used as an unary or binary operator.

A **UNARY** operator appears inside an expression, simply preceding an operand (as if it was its sign). In this case, the operator ***** will be a synonymous of POINTER.

**Example: &x** is equivalent to **POINTER x**

A **BINARY** operator appears inside an expression, concatenating
two operands (showing an operation between both). In this case, the
operator ***** will be the arithmetic operator of **multiplication** previously explained.

---
See: Syntax - Expression - POINTER

## [1055] *=

Operative assignment. Arithmetic operation of **multiplication**.

The assignment statements are used to calculate expressions and
**to assign them** to a datum.

<reference to a datum> **=** <expression> **;**

If the symbol ***=** is used instead of **=** to perform the assignment,
then the following **multiplication** will be assigned to the datum:

 [**previous_value_of_the_datum**] * [**result_of_the_expression**]

Example: **x=2; x*=3;** -> (x=6)

---

**Note:** This symbol is a simple abbreviation derived from the **C language**. Anyhow, a **n *= m;** type statement will be equivalent to this other **n = n * m;** statement.

See the operator * for further information about the **multiplication**.

---
See: Syntax - Assignment

## [1056] +

Arithmetic operator of **addition**. This operator is used in the arithmetic expressions between two operands, to obtain their addition.

For instance **2 + 6** will return 8, the result of 2 plus 6.

All the variables are 32 bit **integers** with sign in the language.
Therefore, only integers within the range (min_int ... max_int)} can be used. Then, when the result of the **addition** must exceed that range, **incorrect results will be shown**. In this case, the system won't report any error. Hence, much care must be taken.

---
See: Syntax - Expression

## [1057] ++

Operator of increment. This operator, derived from the C language, allows us to increment the value of a datum (to add 1 to it) without requiring an
assignment statement for that purpose.

The datum can be a variable, a **position of a table**, or a **field of a structure**.

This operator can be included in an expression with two forms:
**pre-increment** and **post-increment**.

**Operator of pre-increment.**

When the symbol ** ++** is put just before a datum, 1 will be added to it **before the execution of the statement**. As examples, see the following statements:

** ++x;** - statement that will add 1 to the **x** variable.

** z=++x+y;** - statement that will add 1 to the **x** variable and then, it will assign
the addition between **x** (already incremented) and **y** to the **z** variable.

**Operator of post-increment.**

When the symbol** ++** is put just after a datum, 1 will be added to it **after the execution of the statement**. As examples, see the following statements:

** x++;** - statement that will add 1 to the **x** variable.

** z=x+y++;** - statement that will assign the addition between **x** and **y** to the **z** variable, incrementing then the **y** variable.

---

**Summary:**

Generally, a** ++datum;** or **datum++;** type statement is always equivalent
to the following statement: **datum=datum+1;** (or **datum+=1;**).

The difference between the **pre-increment** and the **post-increment** is that in the first case, the value of the datum already incremented is taken to evaluate the rest of the expression, while in the second case, the expression is evaluated with the value that the datum had before being incremented.

---
See: Syntax - Expression - Decrement(--)

## [1058] +=

Operative assignment. Arithmetic operation of **addition**.

The assignment statements are used to calculate expressions and **assign them** to a datum.

<reference to a datum> **=** <expression> **;**

If the symbol **+=** is used instead of **=** to perform the assignment,
the result of the following **addition** will be assigned to the datum:

  [**previous_value_of_the_datum**] + [**result_of_the_expression**]

Example: **x=2; x+=2;** -> (x=4)

---

**Note:** This symbol is a simple abbreviation derived from the **C language**. Anyhow, the **n += m;** type statement will be equivalent to this other **n = n + m;** statement.

See the operator + for further information about the **addition**.

---
See: Syntax - Assignment

## [1059] ,

The symbol of the comma ( **,** ) is used inside the programming language,
in different points of a program, **to separate** two consecutive elements of a list.

It is used, for instance, in the following points:

- In the lists of constants to separate their different numeric values.

- In the definition of the parameters of a process to separate
the names of the different parameters.

- In the call to a function and in the call to a process to also separate different expressions that will be assigned to the parameters of the function or process.

- In the FOR statement to separate different initializations,
conditions or increments.

- In the SWITCH statement to define the different values
accepted in a block **CASE ... END**.

---

The symbol of the comma can also be used to separate several
declarations of data, instead of finishing each of them with a symbol **semicolon** (;).

---
See: Syntax

## [1060] -

Arithmetic operator of **subtraction**. This operator is used in the arithmetic expressions between two operands, to obtain the result of this subtraction.

For instance, **2 - 6** will return -4, the result of subtracting 6 from 2.

All the variables are 32 bit **integers** with sign in the language.
Therefore, only integers within the range (min_int ... max_int)} can be used. Then, when the result of the **subtraction** must exceed that range, **incorrect results will be shown**. In this case, the system won't report any error. Hence, much care must be taken.

---

This symbol is bifunctional. That is to say, it has two different uses depending on whether it is used as an unary or binary operator.

A **UNARY** operator appears inside an expression, simply preceding an operand (as if it was its sign). In this case, the operator ** -** will be the **minus sign**.

**Example: -7** the negative integer **minus seven**.

A **BINARY** operator appears inside an expression, concatenating
two operands (showing an operation between both). In this case, the
operator** -** will be the arithmetic operator of **subtraction** previously explained.

---
See: Syntax - Expression

## [1061] --

Operator of decrement. This operator, derived from the C language, allows us to decrement the value of a datum (to subtract 1 from it) without requiring an
assignment statement for that purpose.

The datum can be a variable, a **position of a table**, or a **field of a structure**.

This operator can be included in an expression with two forms:
**pre-decrement** and **post-decrement**.

**Operator of pre-decrement.**

When the symbol** --** is put just before a datum, 1 will be subtracted from it **before the execution of the statement**. As examples, see the following statements:

** --x;** - statement that will subtract 1 from the **x** variable.

** z=--x+y;** - statement that will subtract 1 from the **x** variable and then, it will assign the addition between **x** (already decremented) and **y** to the **z** variable.

**Operator of post-decrement.**

When the symbol** --** is put just after a datum, 1 will be subtracted from it **after the execution of the statement**. As examples, see the following statements:

** x--;** - statement that will subtract 1 from the **x** variable.

** z=x+y--;** - statement that will assign the addition between **x** and **y** to the **z** variable, decrementing then the **y** variable.

---

**Summary:**

Generally, a** --datum;** or **datum--;** type statement is always equivalent
to the following statement: **datum=datum-1;** (or **datum-=1;**).

The difference between the **pre-decrement** and the **post-decrement** is that, in the first case, the value of the datum already decremented is taken to evaluate the rest of the expression, while in the second case, the expression is evaluated with the value that the datum had before being decremented.

---
See: Syntax - Expression - Increment(++)

## [1062] -=

Operative assignment. Arithmetic operation of **subtraction**.

The assignment statements are used to calculate expressions and **assign them** to a datum.

<reference to a datum> **=** <expression> **;**

If the symbol **-=** is used instead of **=** to perform the assignment,
the result of the following **subtraction** will be assigned to the datum:

  [**previous_value_of_the_datum**] + [**result_of_the_expression**]

Example: **x=4; x-=2;** -> (x=2)

---

**Note:** This symbol is a simple abbreviation derived from the **C language**. Anyhow, the **n -= m;** type statement will be equivalent to this other **n = n - m;** statement.

See the operator - for further information about the **subtraction**.

---
See: Syntax - Assignment

## [1063] .  ->

Operator of access to structures or to alien local data. The symbols** .** and** ->**
are synonymous. Therefore, they can indistinctly be used.

---

**Access to structures.**

To access a field of a structure, this operator must be used in the following way:

<name of the structure>**[**<no. record>**]**** . **<name of the field>

(or, using the other symbol)

<name of the structure>**[**<no. record>**]**** -> **<name of the field>

**Examples:**  
  **scroll[0].camera**  
  **m7[1]->z**  

**Note:** Keep in mind that the record number in square brackets can be omitted when record number 0 is accessed. For instance, **scroll[0].camera** will always be equivalent to **scroll.camera**.

---

**Access to alien local data (belonging to another process).**

To access a LOCAL datum of a process from another one, the identifying code of the process whose datum is going to be read or modified must be known. Then, it will be possible to access it in the following way:

<identifying code>** . **<local datum name>

(or using the other symbol)

<identifying code>** -> **<local datum name>

**Examples:**  
   **father.x**  
   **son->graph**  

---
See: Declaration of a structure - Identifying codes - Syntax

## [1064] ..

**Range of values of a section CASE**

---

The symbol** ..** (double period) is used to define a range of values. That is to say, to express the numbers ranging between two values (inclusive).

This symbol is **only used in the** SWITCH **statements**, inside the **sections CASE**, to specify a range of values.

It doesn't matter to express a range either as **minimum..maximum** or as **maximum..minimum**.

For instance, the range defined as** -2 .. 1** would be made up of the numbers** -2**,** -1**, **0** y **1**.

---
See: Syntax - SWITCH statement

## [1065] /

Arithmetic operator of whole **division**. This operator is used in the arithmetic expressions between two operands, to obtain the quotient
of the first one divided by the second one.

For instance **7 / 3** will return 2 as, on doing the whole division of 7
by 3, the quotient will equal **2** (and the remainder will be 1).

That is to say, **n / m** will always return the result of the division of **n** by **m**, but with no decimals (as all the variables are 32 bit **integers** with sign in the language).

---

The **remainder** of a whole division is obtained through the operator MOD (module).

---
See: Syntax - Expression

## [1066] /=

Operative assignment. Operation of **whole division**.

The assignment statements are used to calculate expressions and **assign them** to a datum.

<reference to a datum> **=** <expression> **;**

If the symbol **/=** is used instead of **=** to perform the assignment,
the **whole result** (quotient) of the following **division** will be assigned to the datum:

  [**previous_value_of_the_datum**] / [**result_of_the_expression**]

Example: **x=8; x/=2;** -> (x=4)

---

**Note:** This symbol is a simple abbreviation derived from the **C language**. Anyhow, the **n/-= m;** type statement will be equivalent to this other **n = n / m;** statement.

See the operator / for further information about the **whole division**.

## [1067] :

The symbol **:** (colon) is used to finish a CASE or DEFAULT declaration of a SWITCH statement.

Actually, the symbols **:** (colon) and **;** (semicolon) are synonymous
in this language. That is to say, they can be used indistinctly.

However, similarly to what happens in other programming languages,
the symbol **semicolon** is normally used to finish statements and the symbol **colon** is normally used inside the syntax of the SWITCH statement.

---
See: Syntax - CASE -  DEFAULT - SWITCH statement

## [1068] ;

The symbol **;** (semicolon) is used in many points of a program to indicate always that a statement or any kind of declaration finishes. This is called **finishing** symbol, whose only purpose is to indicate the end of something.

In the language, the following points of the program must be indicated with semicolon:

- The end of the PROGRAM declaration.

- The end of a declaration of a datum.

- The end of an IMPORT declaration.

- The end of the following statements:  
    Assignments or increments of data.  
    Calls to processes.  
    Calls to functions.  
    FRAME, RETURN, DEBUG, BREAK and CONTINUE.

- The end of the beginning of a loop FROM.

- And separating the different parts of a FOR statement.

The compiler will indicate the lacking of the symbol **;** in any of these points.

It is also possible to put this symbol in other specific points of the programs, such as after any other kind of statement, even if it will be optional in this case and, therefore, the compiler won't report its lacking.

---

Actually, the symbols **;** (semicolon) and **:** (colon) are synonymous
in this language. That is to say, they can be used indistinctly.

However, similarly to what happens in other programming languages,
the symbol **semicolon** is normally used to finish statements and the symbol **colon** is normally used inside the syntax of the SWITCH statement.

---
See: Syntax

## [1069] <

Logical operator [**less than**] used in conditions. It must be used between two numeric expressions, and it returns a logical result:

**False** - If the first expression ISN'T less than the second one.

**True** - If the first expression IS less than the second one.

**Examples:**

  **2+2 < 4** will return **false**.
  **1 < 2**   will return **true**.

---
See: Syntax - Condition

## [1070] <<

Binary operator of **rotation to the left**. This operator is used in the arithmetic expressions, between two operands, to obtain the result
of rotating the first operand to the left as many times as indicated by the second. For instance, the following rotation:

  **n** << **m**

Will return **n** rotated to the left **m** times. Every rotation to the left is equivalent to multiplying the number by 2. That is to say, rotating to the left once, is equivalent to multiplying by 2; rotating to the left twice is equivalent to multiplying by 4; 3 times is equivalent to multiplying by 8, and so on.

Or, what is the same, (the POW function**(2, m)** returns **2** raised to **m**):

  **n** * POW(2, **m**)

For instance, **2<<3** will return 16, **4<<1** will return 8, **100<<0** will return 100, etc.

All the variables are 32 bit **integers** with sign in the language.
Therefore, only integers within the range (min_int ... max_int)} can be used. Then, when the result of the **rotation** must exceed that range, **incorrect results will be shown**. In this case, the system won't report any error. Hence, much care must be taken.

---

The operator of rotation to the right (the contrary operation) is the
symbol >>.

---
See: Syntax - Expression

## [1071] <<=

Operative assignment. Binary operation of **rotation to the left**.

The assignment statements are used to calculate expressions and **assign them** to a datum.

<reference to a datum> **=** <expression> **;**

If the symbol **<<=** is used instead of **=** to perform the assignment,
the result of the following rotation will be assigned to the datum:

  [**previous_value_of_the_datum**] << [**result_of_the_expression**]

Or, what is the same, (the POW function**(2, n)** returns **2** raised to **n**):
 
  [**previous_value_of_the_datum**] * POW(2, [**result_of_the_expression**]

That is to say, if the result of the expression is:

  0 -> the datum will maintain its value.  
  1 -> the datum will be multiplied by 2.  
  2 -> the datum will be multiplied by 4.  
  3 -> the datum will be multiplied by 8.  
  ...

Example: **x=2; x<<=2;** -> (x=8)

---

**Note:** This symbol is a simple abbreviation derived from the **C language**. Anyhow, the **n <<= m;** type statement will be equivalent to this other **n = n << m;** statement.

See the operator << for further information about the **rotation to the left**.

---
See: Syntax - Assignment

## [1072] <=  =<

Logical operator [**less than or equal to**] used in conditions. The symbols **<=** and **=<** are synonymous.

It must be used between two numeric expressions, and it returns a logical result:

**False** - If the first expression ISN'T less than or equal to the second one.

**True** - If the first expression IS less than or equal to the second one.

**Examples:**

  **2+2 <= 3** will return **false**.
  **2+2 <= 4** will return **true**.

---
See: Syntax - Condition

## [1073] =

The symbol **=** (symbol of **assignment**) is used in the language inside the data declarations to initialize them, that is to say, to define their initial value. In the assignment statements, this symbol is used to separate the reference to the datum from the assigned expression.

Inside an expression, this operator can be used as a conventional binary arithmetic operator, which is placed between two operands, returning
the second operand's value as a result (besides assigning this result to the datum defined as first operand).

This operator represents an **imperative order** according to which, on executing the statement that contained it, the first operand (before the symbol) will take the value of the second operand (or expression after the symbol).

On evaluating an expression, the assignment operands are always those of **less priority** (the last ones that are interpreted in the expression),
being possible to use brackets to force a bigger priority. If, in an expression (or statement) several assignment operands have been used,
they will be evaluated (executed) from right to left.

For instance, in the statement:

  **x=y=x+y;**

The addition (**x+y**) will first be done. Then, the result will be assigned as the new value of the **y** variable (**y=x+y**) and, finally, this same value will be assigned to the **x** variable (**x=y**).

---

**Important:**

This symbol can not be used to carry out comparisons (which are carried out with the symbol ==), for instance, in the following statement:

  **IF (x=2) ... END**

The **x** variable won't be compared with value **2**, but value **2** will be assigned to the **x** variable and then, as the result of this operation (assignment) is **2**, an even number, the condition will be interpreted as **false** (the odd expressions are interpreted as true, and the even expressions are interpreted as false). Therefore, the statements internal to the **IF** statement won't be ever executed.

At the same time, the symbol == can not be used to perform assignments, as it is the logical operator of comparison.

---
See: Syntax - Data declarations - Assignment statements

## [1074] ==

Logical operator [**equal to**] used in conditions. It must be used between two numeric expressions and it returns a logical result:

**False** - If the expressions give different results, as they AREN'T equal
(or equivalent).

**True** - If both expressions give the same result (if they are equivalent expressions), as they ARE equal.

**Examples:**

  **0 == -1**  will return **false**.
  **2+2 == 4** will return **true**.

---

**Note:** The symbol = can not be used to compare two expressions
or numeric values, as it is the assignment symbol.

---
See: Syntax - Condition

## [1075] >=  =>

Logical operator [**bigger than or equal to**] used in conditions. The symbols **>=** and **=>** are synonymous.

It must be used between two numeric expressions, and it returns a logical result:

**False** - If the first expression ISN'T bigger than or equal to the second one.

**True** - If the first expression IS bigger than or equal to the second one.

**Examples:**

  **2+2 >= 3** will return **false**.
  **2+2 >= 4** will return **true**.

---
See: Syntax - Condition

## [1076] >

Logical operator [**bigger than**] used in conditions. It must be used between two numeric expressions, and it returns a logical result:

**False** - If the first expression ISN'T bigger than the second one.

**True** - If the first expression IS bigger than the second one.

**Examples:**

  **2+2 > 3** will return **false**.
  **2 > 1** will return **true**.

---
See: Syntax - Condition

## [1077] >>

Binary operator of **rotation to the right**. This operator is used in the arithmetic expressions, between two operands, to obtain the result
of rotating the first operand to the right as many times as indicated by the second one. For instance, the following rotation:

  **n** >> **m**

Will return **n** rotated to the right **m** times. Every rotation to the right is equivalent to dividing the number by 2. That is to say, rotating to the right once, is equivalent to dividing by 2; rotating to the right twice is equivalent to dividing by 4; 3 times is equivalent to dividing by 8, and so on.

Keep in mind that all the numbers used in this language are **integers**  (with no decimals). Therefore, an **integer** will always be returned as a result of the division (for instance, 7 divided by 2 will return 3).

Or, what is the same, (the POW function**(2, m)** returns **2** raised to **m**):

  **n** / POW(2, **m**)

For instance, **16>>3** will return 2, **2>>1** will return 1, **100>>0** will return 100, etc.

---

The operator of rotation to the left (the contrary operation) is the
symbol <<.

---
See: Syntax - Expression

## [1078] >>=

Operative assignment. Binary operation of **rotation to the right**.

The assignment statements are used to calculate expressions and **assign them** to a datum.

<reference to a datum> **=** <expression> **;**

If the symbol **>>=** is used instead of **=** to perform the assignment,
the result of the following rotation will be assigned to the datum:

  [**previous_value_of_the_datum**] >> [**result_of_the_expression**]

Or, what is the same, (the POW function**(2, n)** returns **2** raised to **n**):
 
  [**previous_value_of_the_datum**] / POW(2, [**result_of_the_expression**]

That is to say, if the result of the expression is:

  0 -> the datum will maintain its value.  
  1 -> the datum will be divided by 2.  
  2 -> the datum will be divided by 4.  
  3 -> the datum will be divided by 8.  
  ...

Example: **x=8; x>>=2;** -> (x=2)

The result of a rotation to the right will always be an integer,
with no decimals or, what is the same, the quotient of the previous whole division.

Example: **x=9; x>>=2;** -> (x=2)

---

**Note:** This symbol is a simple abbreviation derived from the **C language**. Anyhow, the **n >>= m;** type statement will be equivalent to this other **n = n >> m;** statement.

See the operator >> for further information about the **rotation to the right**.

---
See: Syntax - Assignment

## [1079] POINTER  [  ]

Addressing operator. This operator requires a slightly advanced level in programming techniques. The use of pointers is a characteristic of other languages that, even if it may be very useful, is not indispensable to make programs, no matter how difficult they are.

The reserved word **POINTER** is used to make reference to a specific position of the computer's memory.

**Practical case.**

---

For instance, having a variable named **my_variable** with value **3**, which will be stored in an offset of the memory (all the variables have an offset), the operator OFFSET is used to obtain this offset.

Supposing that there is another variable named **offset_of_my_variable** used
to store the offset of the previous variable, which would be done with the following statement:

  **offset_of_my_variable = OFFSET my_variable;**

This offset will be an integer, for instance **12345**. In order to obtain or modify the value of the variable (**3**), having only the offset (position) of the variable (and not its name) in the memory, the operator **POINTER** must be used. The statement to obtain the value of the variable from its offset would be as follows:

  **my_variable = POINTER offset_of_my_variable;**

A series of expressions and their numeric equivalents are now shown in order to clarify the concepts of **name of the variable**, **offset of the variable** and **value of the variable**.

  **my_variable** = **3**  
  **OFFSET my_variable** = **12345**  
  **offset_of_my_variable** = **12345**  
  **POINTER offset_of_my_variable** = **3**  

The offset of a variable may vary as a program is expanded (by adding new data and statements to it).

In short, {the operator POINTER accesses the value that is in the
position of the computer's memory indicated after it}. That is to say:

  **POINTER 12345** = **3**  

It means that value **3** is in the offset **12345** of the computer's memory, as it is in this offset where the value of the **my_variable** variable is **stored**, and it is its value.

---

The symbol * and the symbol ^ may be used as **synonymous** of the reserved word **POINTER** (in the previous example ***12345** = **3** or **^12345** = **3**).

---

The square brackets (symbols **[ ]**) work in a similar way to the operator
**POINTER**, with the proviso that they access the datum whose offset is indicated in them (in the previous example **[12345]** = **3**).

The square brackets are also used to specify the index in the tables and structures.

---
See: Syntax - OFFSET

## [1080] ^

This symbol is bifunctional; that is to say, it has two different uses, depending on whether it is used as an unary or binary operator.

A **UNARY** operator appears inside an expression, simply preceding an operand (as if it was its sign). In this case, the operator** ^** will be a synonymous of POINTER.

**Example: ^x** is equivalent to a **POINTER x**

A **BINARY** operator appears inside an expression, concatenating
two operands (showing an operation between both). In this case, the
operator** ^** will be a synonymous of XOR.

**Example: x^2** is equivalent to **x XOR 2**

---
See: Syntax - POINTER - XOR

## [1081] ^=

Operative assignment. Logical and binary operation of **exclusive OR** (**XOR**).

The assignment statements are used to calculate expressions and **assign them** to a datum.

<reference to a datum> **=** <expression> **;**

If the symbol** ^=** is used instead of **=** to perform the assignment,
the following **exclusive OR** will be assigned to the datum:

  [**previous_value_of_the_datum**] XOR [**result_of_the_expression**]

Example: **x=5; x^=3;** -> (x=3)

---

**Note:** This symbol is a simple abbreviation derived from the **C language**. Anyhow, the **n ^= m;** type statement will be equivalent to this other **n = n XOR m;** statement.

See the operator XOR for further information about the **exclusive OR**.

---
See: Syntax - Assignment

## [1082] XOR  ^^

Logical and binary operator of **exclusive OR** used in expressions and conditions.

The reserved word **XOR** and the symbol** ^^** are synonymous.

**XOR logical:** The conditions on the right and left of the operator are first evaluated and, if (only one) is **true**, this operator will return **true**. Otherwise, the operator will always return **false**.

 FALSE  XOR FALSE  = FALSE  
 FALSE XOR TRUE = TRUE  
 TRUE XOR FALSE  = TRUE  
 TRUE XOR TRUE = FALSE  

It is used to verify that one (and only one) of the two specified conditions is complied; for instance:

  **(y>0 XOR x>0)**

To verify either that the first variable is bigger than 0, or (exclusive"or") that the second variable (but not the first one) is bigger than 0.

**XOR binary:** Evaluates the bits of the results of the expressions appearing before and after the operator, giving as a result a value of 1
only for those bits that had at 1 one (and only one) of the expressions.

  0 XOR 0 = 0  
  0 XOR 1 = 1  
  1 XOR 0 = 1  
  1 XOR 1 = 0  

This rule will be applied to all the bits of the operands (in the language, they are integers of 32 bits).

---

**Note:** This operator indistinctly works as logical and binary as, in the language, the **true** logical expressions are interpreted as those that have their last bit at 1 (bit 0, weight 1) or, in other words, the odd numbers (1, -1, 3, -3, ...). And the **false** logical expressions are interpreted as those having their last bit at 0 (that is to say, the even numbers: 0, 2, -2, 4, -4, ...).

The operator **XOR** will only leave the last bit at 1 (it will only return **true**
as a result} when one (and only one) of both operands have this bit at 1 (when only one of the two expressions is **true**).

---

**Note:** The symbol** ^** can also be used as another synonymous of **XOR **  and** ^^**.

---
See: Syntax - Expression - Condition - OR

## [1083] OR  ||  |

Binary operator of **logical addition** used in expressions and conditions.

The reserved word **OR** and the symbols** ||** and** |**are synonymous.

**OR logical:** The conditions to the right and left of the operator are first evaluated and if, at least, one of them is **true**, this operator will return **true**. Otherwise, the operator will always return **false** (when both conditions are **false**).

 FALSE  OR FALSE  = FALSE  
 FALSE OR TRUE = TRUE  
 TRUE OR FALSE  = TRUE  
 TRUE OR TRUE = TRUE  

It is used to verify that one of the specified conditions is complied; for instance:

  **(x>0 OR y>0)**

To verify that, at least, one of both variables is bigger than 0. That is to say, it is verified that the first **OR** the second conditions are complied.

**OR binary:** Evaluates the bits of the results of the expressions appearing before and after the operator, giving as a result a value that will have at 1 the bits that any of the expressions would have at 1.

  0 OR 0 = 0  
  0 OR 1 = 1  
  1 OR 0 = 1  
  1 OR 1 = 1  

This rule will be applied to all the bits of the operands (in the language, they are 32 bit integers).

---

**Note:** This operator indistinctly works as logical and binary as, in the language, the **true** logical expressions are interpreted as those that have their last bit at 1 (bit 0, weight 1) or, in other words, the odd numbers (1, -1, 3, -3, ...). And the **false** logical expressions are interpreted as those having their last bit at 0 (that is to say, the even numbers: 0, 2, -2, 4, -4, ...).

The operator **OR** will leave the last bit at 1 (it will return **true**
as a result) when one of any of the operands have this bit at 1 (when, at least, one of the two expressions is **true**).

---
See: Syntax - Expression - Condition - XOR

## [1084] |=

Operative assignment. Binary operation of **logical addition** (**OR**).

The assignment statements are used to calculate expressions and **assign them** to a datum.

<reference to a datum> **=** <expression> **;**

If the symbol** |=** is used instead of **=** to perform the assignment,
the following **logical addition** will be assigned to the datum:

  [**previous_value_of_the_datum**] OR [**result_of_the_expression**]

Example: **x=5; x|=6;** -> (x=7)

---

**Note:** This symbol is a simple abbreviation derived from the **C language**. Anyhow, the **n  |= m;** type statement will be equivalent to this other **n = n OR m;** statement.

See the operator OR for further information about the **logical addition**.

---

**Note:** don't confuse this symbol with that of [**different from**] expressed as !=, that is used to compare whether two expressions have different results.

---
See: Syntax - Assignment

## [1085] OFFSET

The reserved word **OFFSET** allows us to obtain the offset of a
datum inside the computer's memory.

All the data of a program correspond with any specific position of the memory in which its value is stored. The operator **OFFSET** allows us to obtain this position as a numeric value.

This operator is mainly used in the parameters of any of the language's functions. Thus, these functions are able to modify these parameters.

If you have a variable (called, for instance, **my_variable**) with value **321** and this variable is passed, as a parameter, to a parameter function, the number 321 is being passed to the function. Then, the function won't be able to modify the variable, as it knows its value but not **where the variable is** (because many
**321** values may exist in the whole computer's memory, and it won't know which of them is the variable).

If **OFFSET my_variable** is passed to this function as a parameter, it is receiving information about the place in which the variable value is stored. Then, the function will be able to access this value in order to consult it or modified it.

For further information about this operator, it is possible to access the
operator POINTER that does the operation opposite to that of the operator **OFFSET** (that is to say, it obtains the value stored in a specific position of the memory).

---

The symbol & can be used as **synonymous** of the reserved word **OFFSET**.

---
See: Syntax - POINTER

## [1086] BEGIN

This reserved word shows the beginning of the program or process.

That is to say, the word **BEGIN** is used to separate the area of data declaration of the main program or of a process, from the area of statements.

The **BEGIN** declaration is obligatory in the main program and in all the processes.

When a program or process are executed, they will always start with the statement coming after **BEGIN**.

The **BEGIN** statement **does nothing**. It is only used as a delimiting element inside the structure of the programs.

---

Every **BEGIN** is directly linked to an END  that will mark the end of the area of statements of the program or process.

---
See: Syntax - Main Code - Declaration of processes

## [1087] CASE

This reserved word is a part of the SWITCH statement. It is used as the beginning of the different sections of statements that can or can not be executed, depending of the result of the evaluated expression.

Every **CASE** must have a word END indicating the end of the section.

The SWITCH statement evaluates an expression, and the word **CASE** means "**in case that the result of the expression is ..., then the following statements must be executed ...**".

---
See: Syntax - SWITCH statement

## [1088] DEFAULT

This reserved word is a part of the SWITCH statement, that is used to begin a section of statements that must be executed when the result of the evaluated expression is not contemplated in any of the sections CASE of the statement.

Every **DEFAULT** must have a word END indicating the end of the section.

The SWITCH statement evaluates an expression. Every section
CASE of the statement will contemplate one of several results in which that section must be executed. Finally, a section **DEFAULT** appears to express "**in case that the result of the expression is none of the previous ones, then the following statements must be executed ...**".

---
See: Syntax - SWITCH statement

## [1089] DUP

This word is used to define lists of constants (numeric values),
by repeating a simple pattern. It is used to initialize the initial values of tables and structures.

Its syntax is as follows:

<number of times> **DUP (**<sequence to repeat>**)**

It is equivalent to put the <sequence to repeat> the indicated <number of times>.

For instance, the sequence **1, 2, 3, 1, 2, 3, 1, 2, 3** would be equivalent to the sequence **3 DUP (1, 2, 3)**.

---
See: Syntax - Definition  of a list of constants

## [1090] ELSE

This word is a part of the IF statement, and is used to specify where the block of statements that must be executed starts when the condition specified in the IF is not complied.

The format of the IF statement is the following one:

**IF (<**condition**>)**  
    // Code to execute when the condition is complied  
**ELSE**  
    // Code to execute when the condition  **isn't** complied  
**END**  

The meaning of **ELSE** is "**otherwise ...**".

---

The section **ELSE** is optional. The IF statement can be formulated in the following way:

**IF (<**condition**>)**  
    // Code to execute when the condition is complied  
**END**  

When no statement is required to be executed **in the opposite case**.

---
See: Syntax - IF statement

## [1091] END

This reserved word marks the end of one of the following statements:

  BEGIN  
  IF  
  WHILE  
  SWITCH  
  CASE  
  DEFAULT  
  FOR  
  FROM  
  LOOP  
  CLONE  

That is to say, the function of the word **END** is **to delimit where a statement finishes**.

Keep in mind that the statements may be nested (that is to say, they may be included one inside another). Therefore, if a program is not well structured (tabulating the code), it can be difficult to find out to which statement each **END** corresponds.

For instance, in the following code it is possible to see clearly to which statement each **END** belongs.

**BEGIN**  
    **IF (x>0)**  
        **x=x-1;**  
    **END**  
**END**  

But this same code could have been expressed as follows:

**BEGIN**  
    **IF (x>0)**  
    **x=x-1;**  
**END**  
    **END**  

being much more complicated the reading of the program, even if for the compiler of the language **both code blocks are exactly the same** (the compiler will continue to interpret that the first **END** is that of the **IF** statement and the second one that of the **BEGIN** statement, even if they are incorrectly tabulated).

---
See: Syntax

## [1092] ID

The reserved word **ID** is used to obtain the identifying code of a process while executing.

An identifying code is a numeric value that **identifies** each of the active processes at any moment (each of the game's objects).

That is to say, **ID** is like a numeric constant, with the only difference that its value will be different for each consulted process.

It is not possible to change the value of **ID**, as it is a simple object of
reading.

Normally, a process accesses this value when it intends to report
other processes on its identifying code.

---
See: Syntax - Identifying codes

## [1093] SETUP_PROGRAM

This reserved word is used to designate a special kind of programs, related to the **sound hardware setup**.

The special characteristic of these programs is that they start with the reserved word **SETUP_PROGRAM** instead of PROGRAM.

This topic is very advanced, for expert users.

A program of this type can be observed in the **SETUP** directory of DIV Games Studio. These programs, once they have been compiled, will automatically be included in the installations of the rest of the programs, when the box "**Include sound setup**" is activated during the installation process.

**Note:** In the installations, the last setup program compiled in DIV Games Studio will always be included.

---

However, keep in mind that it is not indispensable to create sound setup programs, as the games created with DIV Games
Studio will automatically detect whether the computer in which they are executed is provided with a sound card compatible with **Sound Blaster**
or **Gravis Ultrasound**, providing that it is correctly configured.

---

This kind of programs normally modify the setup global structure, that controls the parameters of the sound system.

---
See: Syntax - Setup structure

## [1094] SIZEOF()

**SIZEOF(**<name of the datum>**)**

**Returns:**

The numbers of elements contained in the datum.

**Description:**

The reserved word **SIZEOF** is used to calculate the number of elements that a  table or a structure have.

This reserved word **is used as if it was a function** of the language,
indicating in brackets, the name of the datum and returning the number of elements (positions) of the latter.

It can be used to obtain the number of elements of a variable but, in this case, **SIZEOF** will always return **1** as the number of elements (as a variable is a single element).

Sample program:
```div
PROGRAM example_sizeof;

PRIVATE
    table1[]=0, 1, 2, 3;
    table2[]=4, 5, 6, 7, 8;
    variable=9;

BEGIN
    // ...

    save("help.dat", OFFSET table1, SIZEOF(table1)+SIZEOF(table2)+SIZEOF(variable));

    // ...
END
```

In this example, **SIZEOF** is used to obtain the number of elements
of the following three data:

**table1** of **4** elements.  
**table2** of **5** elements.  
**variable** (**1** element).  

In this case, it is used to save in the **help.dat** archive the contents of these three data with the save() function that requires the number of elements intended to be stored in the archive, as a third parameter.

In this case, **10** elements will be stored in the **help.dat** archive, numbers from **0** to **9**, according to the initialization of the data in the example.

The save() statement of the previous example could have also been expressed without using **SIZEOF**, in the following way:

  **save("help.dat", OFFSET table1, 10);**

There is only one difference: if, in the program of the example, some elements were added to any of the two tables, it would be not necessary to modify the call to the save() function, as **SIZEOF** will always return the current size of the tables.

---
See: Syntax - Declaration of a table - Declaration of a structure

## [1095] STEP

The reserved word **STEP** is a part of the FROM statement and it is used to indicate the increment (step) that has to be made in every loop iteration.

The FROM statement implements a loop, that is to say, a group of statements that are going to be repeated a specific number of times. For that, it uses a variable as a counter of the number of repetitions.

Both the initial and final values of the variable are defined. The loop will be repeated until the variable reaches the final value, starting from the initial value.

By default, the variable will pass through all the whole numeric values ranging between the initial and final values. But it is possible to indicate a **STEP** declaration to establish a different variable increment.

For instance, if a loop in which the **x** variable is going to have the values ranged from **1** to **10** is defined, this loop will be executed a total of **10** times. But if **STEP** is established as **2**, then the loop will only be executed **5** times, in which the **x** variable will take the **1**, **3**, **5**, **7** and **9** values, as it has been established that the variable must be incremented **2** by **2**. This loop would be implemented in the following way:

**FROM x=1 TO 10 STEP 2**  
  // Statements that are going to be repeated five times  
**END**  

If the **STEP** declaration is omitted from the FROM statement, then the increment will always be 1 by 1, adding 1 to the variable after every loop
iteration (or subtracting 1, in case that the final value is less than the initial value).

**Note:** Only whole increments can be established.

---
See: Syntax - FROM statement

## [1096] TO

The reserved word **TO** is a part of the FROM statement and it is used to separate the constants that indicate the initial and final values that the variable used as a loop counter must take.

The FROM statement implements a loop, that is to say, a set of statements that are going to be repeated a specific number of times. For that, it uses a variable as a counter of the number of repetitions.

Both the initial and final values of the variable are defined. The loop will be repeated until the variable reaches the final value, starting from the initial value.

**Example:**

  **FROM x=1 TO 10**  
    // Statements that will be repeated 10 times  
  **END**  

By default, the variable will take all the whole numeric values ranging between the initial and final values. But it is possible to indicate a STEP declaration to establish a different increment of the variable.

---
See: Syntax - FROM statement - STEP

## [1097] UNTIL

The reserved word **UNTIL** is a part of the REPEAT statement,
whose syntax is, broadly speaking, the following one:

REPEAT  
    <statement>;  
    ...  
**UNTIL (<**condition>}**)**

The REPEAT statement implements a loop, that is to say, it is capable of repeating a set of statements a specific number of times.

The end of the statement is determined by putting the reserved word **UNTIL**
followed by the condition that must be complied so that the **statement finishes**.

---
See: Syntax - REPEAT statement

## [1100] GLOBAL STRUCT mouse

**STRUCT mouse;**  
    **x, y;**                // Coordinates  
    **graph;**               // Graphic code  
    **file;**                // File code  
    **z;**                   // Depth plane  
    **angle;**               // angle  
    **size;**                // Size (%)  
    **flags;**               // Mirrors indicator  
    **region;**              // Clipping region  
    **left, middle, right;** // State of buttons  
**END**  

This global structure is used to control the mouse. It contains a series of fields related to the programming of this driver, such as the screen position, the pointer graphic, the state of the buttons, etc.

In order to access these fields, the name of the field must be preceded by the word **mouse**  and by the symbol . (period). For instance, in order to
access the field **x** (horizontal coordinate of the mouse pointer), it is necessary to use **mouse.x**.

---

**x**, **y** - Horizontal and vertical coordinates of the mouse. It will be necessary to read only these two fields (**mouse.x** and **mouse.y**) to know the position of the mouse cursor on screen.

To **locate the mouse at other coordinates** (to force its position),
suffice will be to assign the new coordinates to these two fields.

---

**graph** - **Graphic code** assigned as a mouse pointer. By default **the mouse won't be visible**. To make it visible, it is necessary to create the graphic that is going to be used as a pointer in the **graphic editor**, to load it in the program (with the load_fpg() or load_map() functions, depending on whether this graphic has been stored in a **file FPG** or in an **archive MAP**) and finally, to assign its **graphic code** to this variable (**mouse.graph**). Then, the mouse pointer will be seen on screen.

The center of the graphic will appear at the **mouse.x**, **mouse.y** coordinates, unless its control point number **0** has been defined in the **graphic editor**. If this point (usually called **hot spot**) is defined, then it will appear at the coordinates indicated in the fields **mouse.x** and **mouse.y**.

For instance, if an arrow is created to depict the mouse pointer (as it happens dealing with the mouse pointer of DIV Games Studio), the hot spot (control point number **0**) will be defined in the upper left corner of the graphic, as it is the **active point** inside the graphic. Then, when the mouse was located
at the (0, 0) coordinates, for instance, the "**tip of this arrow**" would precisely be located at those coordinates

---

**file** - **File code** containing the graphic. The **file code** containing the graphic of the mouse pointer is defined in this field.
**It is not necessary** to indicate a value here if the graphic was loaded from an
**archive MAP**, or if it is stored in the first **archive FPG** loaded in the program. Otherwise, **mouse.file** will have to be assigned the **file code** that returned the load_fpg() function on loading the file that contains the graphic of the mouse pointer.

---

**z** - Priority of the graphic display. Indicates the depth plane in which the graphic of the mouse pointer must be displayed. **By default** this field will be equal to** -512**, which implies that **the pointer will be seen above the rest of graphics and texts**. The bigger this field is, the deeper the mouse pointer will be located.

If the aim was to make a graphic of a process appear above the mouse pointer,  suffice would be to assign an integer lesser than** -512** 
(for instance,** -600**) to the local z variable of that process.

---

**angle** - angle with which the graphic of the mouse pointer will be seen.
The value of **mouse.angle** by default is **0**, which implies that this graphic won't be seen rotated, unless a new angle is assigned to this field.

Keep in mind that the angles must be specified in degree thousandths. For instance, the **mouse.angle=90000;** statement will make the pointer appear rotated **90 degrees** (see the use of angles in the language).

---

**size** - Size of the graphic in percentage. By default, this field will be equal to **100** (the graphic will be seen 100%). Then, it is not necessary to indicate another value here, unless the aim is to scale the graphic (to display it expanded or reduced).

If, for instance, the aim was to double the original size of the graphic (being displayed at 200%), the **mouse.size=200;** statement should be used.

---

**flags** - In this field, different values will be indicated when the aim is to
mirror the graphic of the mouse (that is to say, horizontally or vertically inverted), or to display it as a (semi) transparent graphic. The possible values that can be assigned to the **mouse.flags** are the following ones:

 **0**-Normal graphic (value by default).  
 **1**-Horizontal mirror.  
 **2**-Vertical mirror.  
 **3**-Horizontal and vertical mirror (180°).  
 **4**-Transparent graphic.  
 **5**-Transparent and horizontal mirror.  
 **6**-Transparent and vertical mirror.  
 **7**-Transparent, horizontal and vertical mirror.  

---

**region** - Graphic's clipping region. A value must be assigned to this field **just when the aim is to make the mouse pointer visible only inside a region** (a rectangular zone of the screen). In order to achieve it, it is necessary first to
define this region with the define_region() function and then, to assign the number of the region that has been defined to this field (**mouse.region**).

By default, this value will be equal to **0**, that is a number of region referred to the entire screen. Therefore, the graphic will be seen on the whole screen.

---

**left**, **middle** and **right** - These three fields store logical values (**0** or **1**) depending on whether the mouse buttons are pressed or not (they correspond with the left, central and right mouse buttons). Normally, only two buttons of the mouse (**left** and **right**) are activated, being ignored the state of the central button. This depends on the mouse **driver** installed in the computer.

For instance, to perform an action in a program **when the mouse left button is pressed** (**mouse.left**), it is necessary to include the following statement in the code:

  **IF (mouse.left)**  
    // Action to perform (statements)  
  **END**  

---
See: Global data

## [1101] GLOBAL STRUCT scroll

**STRUCT scroll[9];**  
    **x0, y0;**    // Foreground's coordinates  
    **x1, y1;**    // Background's coordinates  
    **z;**         // Depth plane  
    **camera;**    // Identifying code of the camera  
    **ratio;**     // Relative speed of the background  
    **speed;**     // Maximum speed of the foreground  
    **region1;**   // First screen region  
    **region2;**   // Second screen region  
**END**  

This **10** record structure contains certain fields related to changeable parameters of the **scroll windows**. These ten records have the same field names, but each of them modifies the parameters of a different scroll window
(as up to 10 windows of this type can be activated).

A **scroll window** could be defined as a screen region that only shows a part of a graphic bigger than that window (this graphic is normally the **décor** or **background** of the game). The **scroll** is the movement of that window through the graphic in any direction, being displayed the entire graphic little by little, section by section.

For a record (from **0** to **9**) of the **scroll structure** to make sense,
that **scroll window** (from **0** to **9**) must first be activated with the
start_scroll function (for further information about the scroll windows, see this function}.

It is understood that the fields of this structure are complementary to those of the call parameters of this last function.

---

**How to use the scroll structure:**

To access these fields, the field name must be preceded by the word **scroll**, the record's number in square brackets and the symbol . (period).

For instance, if two scroll windows, number 0 and number 1, are initialized, it could be possible to access the **camera** field of both windows as
**scroll[0].camera** and **scroll[1].camera**, respectively. Moreover, when the scroll window number 0 is accessed, it is possible to omit the window's number in square brackets. That is to say, the **scroll.camera** and the **scroll[0].camera** variables are, to all intents and purposes, the same for the language.

---

**A detailed description of every field is now shown.**

**x0, y0** - Coordinates of the scroll's foreground, when the scroll **ISN'T** automatic (the **camera** field has not been defined), **These are the fields that will have to be modified in order to move the scroll window's foreground**.

These two fields store the horizontal and vertical coordinates of the upper left corner of the scroll window (the point of the foreground's graphic that will be seen in the window's upper left corner).

When the **camera** field of this structure has been defined, the movement of the scroll window will be automatic; thus, they are read-only fields. In order to check where the scroll is at every moment (see the move_scroll() function).

---

**x1, y1** - Background's coordinates, when a graphic for the background has been defined. When the scroll **ISN'T** automatic (the **camera** field has not been defined), **these are the fields to modify in order to move the background of the scroll window**.

When the **camera** field of this structure has been defined, the movement of the
scroll window will be automatic; thus, they will be read-only fields, and the definition of the background's movement speed will depend on the **ratio** field of the same structure.

---

**z** - Scroll display priority, to indicate the depth plane in which this window must be painted, with respect to the rest of processes. By default, this variable will equal **512**, which implies that, as the processes have their local z variable at **0** by default, the scroll window will be painted in a greater (deeper) depth plane, being the graphics of the processes displayed above the window. In order to vary this situation, it is possible to modify either the **z** window's variable (for instance, putting it at** -1**) or the **z** processes' variable (for instance, putting it at **600**).

---

**camera** - It is not necessary to initialize this field, as it will be initialized when the aim is that the scroll is **automatic**, that is to say, that the system deals with it to always follow a process (a game's graphic). For that, it is necessary to put
the process' identifying code in this field. Thus, the shift of the scroll window will pass to be controlled automatically by the system, always trying to center the graphic of this process in the window. This process must have the ctype local variable with the value c_scroll.

By default, this field will equal **0**, which implies that the scroll won't follow any process, unless the identifying code of a process is assigned to **camera**. When it is done, this process will be known as the scroll's **camera process**.

**Note:** A series of fields are now shown **only for automatic scroll windows**. It means that for those fields to make sense (and, therefore, effect), the **camera** field of this structure has to be defined previously with the identifying code of the process that is going to be centered in the scroll. These values will affect the way in which the process called **scroll camera** is going to be followed.

---

**ratio** - **Automatic scroll windows**. When two scroll planes have been defined in the call to the start_scroll() function, in this field it is possible to define the **movement speed of the background** with respect to that of the foreground. By default, this value will equal **200**, which implies that the background will move half the speed of the foreground; if it is defined as **400**, it will move at the fourth part (four times slower), **100** at the same speed, **50** at double speed of the foreground, etc.

---

**speed** - **Automatic scroll windows**. Maximum speed of the scroll foreground, which will equal **0** by default. It means that no speed limit is imposed. If a limit is imposed, specifying the maximum number of points that the foreground can be shifted for every game's frame, the **camera process** will be uncentered in the scroll window when it is moved at a higher speed.

---

**region1** - **Automatic scroll windows**. Scroll lock region, whose value by default equals** -1**, which means that there is no lock region.
If this field is defined with a number of region (a rectangular zone of the screen previously defined with the define_region() function), then the system won't scroll as long as the **camera process** remained inside it.

---

**region2** - **Automatic scroll windows**. External region of the scroll. By default, its value is equal to** -1**, which means that there is no external region.
If this field is defined with a region's number and a **maximum speed** has been defined in the **speed** field, then the system will ignore that speed limit when the **camera** process is going to exceed from this region (it is done in order to continue to see the process (for its graphic to be visible always within the scroll window).

**Note:** If the two regions (**region1** and **region2**) are defined, region 1 is normally lesser than region 2 (the first one is contained in the second one). It will imply that:

- The background won't shift (the scroll won't be performed) while the camera process' graphic is inside region 1.

- If a maximum **speed** has been defined, then a scroll will be performed
to try to restore the graphic of the camera process to region 1, but without exceeding the imposed speed limit.

- If the graphic of the camera process tried to exceed from region 2, the imposed speed limit would be ignored in order not to allow it.

---
See: Global data - start_scroll() - stop_scroll()

## [1102] GLOBAL STRUCT m7

**STRUCT m7[9];**  
    **camera;**   // Identifying code of the camera  
    **height;**   // Height of the camera  
    **distance;** // Distance of the camera  
    **horizon;**  // Height of the horizon  
    **focus;**    // Focus  
    **z;**        // Depth plane  
    **color;**    // Color of the exterior  
**END**  

This **10** record structure contains certain fields dealing with changeable parameters of the **mode 7 window**. The ten records have the same fields names, but each of them modifies the parameters of a different mode 7 window (as up to 10 windows of this type may be activated).

A **mode 7 window** could be defined as a screen region that shows a graphic plane three-dimensionally folded (for instance, like a sheet of paper with a picture horizontally positioned, displayed on screen with a virtual bottom (or top).

For a record (numbered from **0** to **9**) of the **m7 structure** to make sense,
that **mode 7 window** (from **0** to **9**) must first be activated with the start_mode7() function (see this function for further information about the mode 7 windows}.

It is understood that the fields of this structure are complementary to the call parameters of this function. In order to observe a practical example
of a mode 7, it is possible to access the help about the start_mode7() function.

---

**How to use the m7 structure:**

To access these fields, the field name must be preceded by the word **m7**, the number of record in square brackets and the symbol . (period).

For instance, if two mode-7 windows, number 0 and number 1, were initialized the **camera** variable of both windows could be accessed as **m7[0].camera** and **m7[1].camera**, respectively. When the mode-7 window number 0 is accessed, it is also possible to omit the number of windows in square brackets. That is to say, the **m7.camera** variable and the **m7[0].camera** variable are, to all ends, the same for the language.

---

**A detailed description of each field is now shown.**

**camera** - Identifying code of the process followed by the camera. To move the camera that controls the mode-7 view, only a mode-7 process must be created, a process having its local variable ctype **=** c_m7, and its identifying code must be put in the **camera** variable of this structure. After so, only the x, y and angle local variables of this process must be modified  and, for instance, the advance() function must be used to move forward the camera.

For the mode 7 window to be activated, it is **indispensable** to initialize the **camera** field. Without this field, the window can not determine from where the folded plane must be **seen**.

---

**height** - Height of the camera. This variable of the structure manages the distance to which the camera is placed from the bottom. By default, its value equals **32**. Any positive number will make the camera be placed upper as the number is greater. If a negative number (less than zero) is put in the **height** field of this structure, then the camera will be placed below the folded plane, showing a "**top**" instead of a "**bottom**".

Two mode-7 must be created within the same region: one as top and the other as bottom (one with positive **height** and the other with negative height). In
this case, it is important to establish the **z** variable of the m7 structure of both, to thus determine the depth plane in which each one must be painted.

---

**distance** - Distance from the camera to the followed process. The perspective of the camera will always be positioned slightly behind the process whose identifier has been put in the **camera** field of the structure. This is done for the graphic of the process used as a camera to be seen, just in case this process has defined it (in its graph or xgraph local variable).

By default, the camera will be positioned at **64** points behind the process. "Behind" means a point placed at the indicated distance from the graphic
in the angle opposite to that one to which the process is orientated. For instance, if the process is facing right, 64 points to its left.

---

**horizon** - Horizon's height. This is the same value as that indicated as last parameter of the **start_mode7()** function. Its initial value will equal to the one indicated in the call to this function. The utility of this variable is to make the horizon go up or down in every frame of the game, depending on the needs of the latter.

On changing the **horizon's height**, the "**facing up**" and "**facing down**" effects will be obtained in the **mode 7 window**.

---

**focus** - Focus for the camera. This variable controls the perspective of the camera. By default, its value equals 256, but any value ranging from **0** and **512** may be put, obtaining different distortion effects of the three-dimensional plane.

That is to say, this field controls the angle got by the camera focus. The greater this value is, the closer all the objects (processes) placed in the folded plane will be seen.

---

**z** - Mode-7 display priority. To indicate the depth plane in which this window must be painted, with respect to the rest of processes. By default, this variable will equal **256**, which means that, as the processes have their local z variable at **0** by default, the mode-7 window will be painted in a greater (deeper) depth plane, being the graphics of the processes painted above the window. This situation may change by modifying the **z** variable of the window (for instance, putting it at** -1**) or the **z** variable of the processes (for instance, putting it at **257**).

---

**color** - Color for the mode-7 exterior. When, in the call to the **start_mode7()**
function, any **external graphic** is not specified (the fourth call parameter is put at **0**), this variable will control the color in which it is aim to paint the exterior. In other words, the color that the screen must be painted in beyond the graphic that is being folded (beyond its limits).

By default, this field is initialized at **0**, which is normally the black color
in the color palette, Therefore, if this field is not assigned another value (and an external graphic is not defined) the screen will be seen in black beyond the foreground.

---
See: Global data - start_mode7() - stop_mode7()

## [1103] GLOBAL STRUCT joy

**STRUCT joy;**  
    **left;**    // Left control  
    **right;**   // Right control  
    **up;**      // Up control  
    **down;**    // Down control  
    **button1;** // First button  
    **button2;** // Second button  
    **button3;** // Third button  
    **button4;** // Fourth button  
**END**  

This global structure is used to control the **joystick**. It contains a series of logical fields related to the programming of this device: the state of the buttons (whether they are pressed or not) and the state of the main four control directions.

To access these fields, the name of the field must be preceded by the word **joy** and the symbol . (period). For instance, to access the **left** field (which indicates whether the left control is pressed), it is necessary to use **joy.left**.

---

**left** - This field will be at **1** when the **joystick** is orientated to the **left**, and at **0** in the opposite case.

**right**  - This field will be at **1** when the **joystick** is orientated to the **right**, and at **0** in the opposite case.

**up**  - This field will be at **1** when the **joystick** is orientated **up**, and at **0** in the opposite case.

**down**  - This field will be at **1** when the **joystick** is orientated **down**, and at **0** in the opposite case.

For instance, to perform an action in a program **when the joystick is moved to the right** (**joy.right**), a statement like the following one must be included in the code:

  **IF (joy.right)**  
    // Action to perform (statements)  
  **END**  

For diagonal positions, the two fields comprising this diagonal must be verified. For instance, to perform an action when the **joystick** is in the upper right diagonal, the following statement will be used:

  **IF (joy.up AND joy.right)**  
    // Action to perform (statements)  
  **END**  

---

**button1**, **button2**, **button3** and **button4** - These fields indicate the state
of up to four joystick's buttons, being at **1** when the respective button is pressed, and at **0**, when it is not.

Some joysticks only have 2 buttons. In this case, they will be buttons number 0 and 1. In computers with two connected joysticks, the second joystick
will have the buttons number 2 and 3.

---

**Note:** When an analogical reading of the **joystick** is required (to know the exact coordinates at which the joystick is located), it will be necessary to use the get_joy_position() function. Obviously, this function will only be useful in an analogical **joystick**, and it won't work in the digital ones.

---
See: Global data - get_joy_position() - get_joy_button()

## [1104] GLOBAL STRUCT setup

**STRUCT setup;**  
    **card;**     // Type of card  
    **port;**     // Access port  
    **irq;**      // Interruption request  
    **dma;**      // Direct memory access channel  
    **dma2;**     // 16 bit channel of access  
    **master;**   // Master (general) volume  
    **sound_fx;** // Effects volume  
    **cd_audio;** // CD audio volume  
**END**  

This is a very advanced data structure, which is not at all necessary to create a game, no matter how difficult it is, as DIV Games Studio's process manager will normally take charge of the sound hardware automatically.

All the fields referred to the sound hardware are automatically updated by the program if you have a sound card, provided that the **BLASTER** or **GRAVIS** environment variable is properly initialized.

This one record structure contains a series of fields divided into two
groups: the first one, to activate new parameters of the sound hardware installed in the computer, and the second one to adjust the different volume controls managed by the sound system's **mixer**.

---

**Important:**

The reset_sound() function must be called to activate the new parameters of the sound hardware inserted in this structure (in the **card**, **port**, **irq**, **dma** and **dma2** fields).

The set_volume() function must be called to activate the new volume levels inserted in the structure (in the **master**, **sound_fx** and **cd_audio** fields). 

This structure is normally used inside the sound system setup programs (see setup_program).

**Note:** To access these fields, the field name must be preceded by the word **setup** and by the symbol . (period). For instance, **setup.master** must be used to access the **master** field (which indicates the mixer's general volume level).

---

A more detailed description of every field of this structure is now shown.

**card** - Indicates the type of sound card installed in the computer.
The program accepts cards of the **Sound Blaster** (tm) and **Gravis Ultra Sound** (tm) families, as well as all those **100%** compatible with them.

The values that this field can take are the following ones, depending on the sound card type:

    Without card or sound    = **0**  
    Sound Blaster 1.5        = **1**  
    Sound Blaster 2.0        = **2**  
    Sound Blaster Pro        = **3**  
    Sound Blaster 16         = **4**  
    Sound Blaster AWE        = **5**  
    Gravis Ultra Sound       = **6**  
    Gravis Ultra Sound MAX   = **7**  

---

**port** - Indicates the computer's communications port in which
the data of the sound card must be written and read.

The values that this field can take are the following ones, depending on the port assigned to the sound hardware:

    0x210 = **0**  
    0x220 = **1**  
    0x230 = **2**  
    0x240 = **3**  
    0x250 = **4**  
    0x260 = **5**  

---

**irq** - This field indicates the number of IRQ (Interrupt request) assigned to the active sound card.

The values that this field can take are the following ones, depending on the IRQ used by the card:

    IRQ 2   = **0**  
    IRQ 3   = **1**  
    IRQ 5   = **2**  
    IRQ 7   = **3**  
    IRQ 10  = **4**  
    IRQ 11  = **5**  
    IRQ 12  = **6**  
    IRQ 13  = **7**  
    IRQ 14  = **8**  
    IRQ 15  = **9**  

---

**dma** - The direct memory access (DMA) channel's number used by the sound card must be indicated in this field.

This field can take values from 0 to 10, directly depending on the channel's number.

---

**dma2** - Some sound cards have a second direct memory access channel
faster than the previous one, of 16 bits, commonly named HDMA, DMA2 or DMA16.

Like in the previous field of this structure, this second channel can take values from 0 to 10 depending on the 16 bit channel's number used by the card.

---

**master** - This field contains the output general or master volume of the card. A number ranging from 0 (minimum volume) and 15 (maximum volume) must be here indicated. By default, the value equals **15**, the maximum volume.

Turning the master volume down will affect the sound effects' volume as well as the CD audio music reproduction's volume.

---

**sound_fx** - This field controls the volume to which the sound effects executed with the sound() functions are reproduced.

This volume is independent from that used with the sound functions. The former is general for all the sound effects. On the contrary, the latter (volume indicated in the functions) is specific for every sound.

The values of this field also range from 0 (minimum volume) and 15 (maximum volume). By default, the value will be equal to the maximum volume.

---

**cd_audio** - This field controls the volume of the music that will be reproduced from the audio tracks of a CD ROM or Compact Disc.

Similar to the two previous fields, the values of this field can also rage from 0 (minimum volume) and 15 (maximum volume). By default, the value will be equal to the maximum volume.

---
See: Global data - reset_sound() - set_volume()

## [1105] GLOBAL timer[]

**timer[9];** // Counters of time

---
.

This is a 10 position global table, from **timer[0]** to **timer[9]**,
and each of these 10 positions is a counter of **second hundredth** that is automatically incremented.

At the beginning of the program, these 10 counters will be put at  zero. They are use to time within a program. For that purpose, they can be put at zero at any time.

There are 10 counters so that the user can dedicate each of them to perform a different action inside the game, no matter which ones of the 10 counters are used. Normally, if the program only needs one counter (most of the times), that numbered **0** (**timer[0]**) is used, as the language allows us to omit the zero in square brackets in this case. That is to say, if only one counter is needed, it is possible to use **timer** simply.

For instance, to implement a process that 5 seconds after the beginning of its execution (if it had been called) performed a specific action, it would be constructed in a way similar to the following one (by using, for instance,
the counter timer[9]):

 **PROCESS process_example();**  
 **BEGIN**  
     **timer[9]=0;**  
     // ...  
     **LOOP**  
         **IF (timer[9]>=500)**  
             // Action to perform ...  
         **END**  
         // ...  
         **FRAME;**  
     **END**  
 **END**  

---

**Note 1:** As timing is performed in second hundredths, these counters can be incremented in **1** hundredth, **2**, **3**, **4**, etc. in every frame of the game That is to say, in an example like the previous one, the user can not wait for **timer[9]** to equal **500** exactly, as a frame could indicate **497** hundredths passed (since it was put at zero with **timer[9]=0;**) and the following frame **502** hundredths, without having passed through value **500**.

---

**Note 2:** It is also important to underline that much care must be taken to prevent several processes of the program from using the same counter for different purposes.

If, for instance, a **process_example()** (like the previous one) was created, in every frame of the game these processes would never manage to execute the action of the five seconds, as each of them would put the counter **timer[9]** at **0** at the beginning of their execution, thus invalidating the timing of the previous processes.

Keeping in mind that the counter timer[9] is GLOBAL, that is to say, it is the same for all the game's processes, if a process puts it at **0**, it will be put at **0** for the rest of the processes.

---

**Note 3:** Finally, much care must be taken regarding the conditions similar to those of the previous example (**IF (timer[9]>=500) ... **), as these conditions
won't only be activated **once every 5 seconds**, but they will be activated
**always after the first 5 seconds**.

To understand the problem better, a process performing one action, **only once**, five seconds after the beginning of its execution, is now shown.

 **PROCESS process_example();**  

 **PRIVATE**  
     **action_performed=FALSE;**  

 **BEGIN**  
     **timer[9]=0;**  
     // ...  
     **LOOP**  
         **IF (timer[9]>=500) AND NOT action_performed)**  
             // Action to perform ...  
             **action_performed=TRUE;**  
         **END**  
         // ...  
         **FRAME;**  
     **END**  
 **END**  

A private variable called **action_performed** which, at first, will be **false** is used. To perform an action now, it will be necessary that more than five 
seconds have passed and that **the action has not been performed yet**.
Therefore, after its performance the **action_performed** variable will become **true**.

For the previous example to execute the action **every five seconds**
(indefinitely), suffice will be to put the statement **timer[9]=0;** again after the
**action to perform**, not being necessary, in this case, the **action_performed** private variable, as other **5** seconds would be necessary for **timer[9]** to be again bigger than or equal to **500**.

---
See: Global data

## [1106] GLOBAL text_z

**text_z=-256;** // Texts' depth planes

---
.

The depth plane in which the texts must appear on screen is indicated in this global variable. That is to say, it indicates what must appear above the texts and what below them.

The depth planes can be any integer within the range (min_int ... max_int) and, the greater the number is, the deeper the text or graphic will be placed.

By default, the processes' graphics have their local z variable at **0** , the texts **text_z** at** -256** and the mouse pointer has mouse.z at** -512** by default.

That means that, by default, if these values are not modified,
the texts will appear above the processes' graphics and the mouse pointer above the texts.

If, for instance, the aim was that the texts appeared above the mouse pointer (opposite to which has been established by default), two things could have been done:

**a)** To place the pointer's plane lower than the texts' plane (a
greater number), such as, for instance: **mouse.z=-200;** (as** -200** is a number
bigger than** -256**).

**b)** To place the texts' plane upper that the pointer's plane such as,
for instance, **text_z=-600;** as** -600** is a number lesser than** -512** and,
thus, a less depth plane (less deep).

---

**Note 1:** The **text_z** variable is GLOBAL for all the texts. That is to say, it is not possible to define texts in different depth planes.

**Note 2:** The texts can only be displayed with the write()
(alphanumeric texts) function or with the write_int() (variables' numeric values) function.

---
See: Global data - write() - write_int()

## [1107] GLOBAL fading

**fading=FALSE;** // Indicator of screen fading

---
.

This global variable indicates if a screen fading (a gradual change of the game's palette colors) is being performed at a specific moment. Its value will be:

false (0) - If a fading is **not** being performed.

true (1) - If a fading is being performed.

The purpose of this variable is to be able to determine the end of a screen fading started with the fade() or fade_on() functions.

On using these functions, a fading of the palette's colors will start, gradually coming closer to the definitive colors in the next frames of the game. That is to say, in every FRAME statement a part of the fading will be performed.

When a fading is started, the **fading** variable will automatically become equal to **true** (1) and when it is finished, it will recover its original value, **false** (0).

---

**Note 1:** Generally, this variable is used to control the fade() function,
and verify whether the fading has already been executed (performed). For instance, to stop the program's execution until the fading is finished, which can be done with a statement as follows (just after the call to the fade() function):

  **WHILE (fading)**  
      **FRAME;**  
  **END**  

Literally this statement defines: "**while the fading continues to be performed, a new frame must be displayed**".

**Note 2:** All the programs perform a fading (fade_on()) at
the beginning of their execution (automatically). Therefore, this variable will be put at **true (1)** at the beginning of all the programs until this initial fading doesn't finish (while the screen "**fading on**" is being performed).

---
See: Global data - fade() - fade_on()

## [1108] GLOBAL shift_status

**shift_status=0;** // State of the special keys

---
.

The state of different special keys, such as [**ALT**], [**CONTROL**], etc. is indicated in this predefined global variable.

Each of these keys have the following code assigned:

Right SHIFT key        = **1**  
Left SHIFT key         = **2**  
CONTROL keys           = **4**  
ALT and/or ALT GR keys = **8**  
SCROLL LOCK key        = **16**  
NUM LOCK key           = **32**  
CAPS LOCK key          = **64**  
INSERT key             = **128**  

The **shift_status** variable will contain the **addition of all the codes of the pressed or activated keys**.

For instance, if the [**ALT**] key was pressed ant the [**CAPS LOCK**] was activated, the **shift_status** variable's value would equal **72** (8+64).

In order to verify whether a key like [**ALT**] is pressed, it is not possible to check that **shift_status** is equal to **8**, as it would imply that [**ALT**] is
the **only** pressed or activated special key.

A correct verification would be carried out as follows:

  **IF (shift_status AND 8 == 8)**  
      // The [ALT] key is pressed ...  
  **END**  

---

**Note:** The key() function is normally used to verify whether a key is pressed. But it is not possible to determine with this same function whether keys such as **CAPS LOCK** are activated, but only if they are pressed or not.

There are two variables containing the code of the last pressed key;
scan_code (**scan** code of the last pressed key) and ascii
(**ascii** code of the last pressed key).

---
See: Global data - key() - ascii - scan_code

## [1109] GLOBAL ascii

**ascii=0;** // ASCII code of the last pressed key

---
.

This global variable always indicates the ASCII code of the **last pressed key** in the last game's frame.

The **ascii** variable will be at **0** if no key has been pressed in the previous frame of the game.

The ASCII codes are a list of characters (letters, numbers and symbols)
numbered from **0** to **255** that have been standardized. The codes less than 32 are called control characters; from 32 to 127 appears the international set of characters; and from number 128, appears the expanded set of characters (according to the PC standard). The international and expanded ASCII characters are shown below.

**Summary of the standard PC ASCII codes.**

---
033 21** !**│097 61** a**│161 A1** í**│225 E1** ß**  
034 22** "**│098 62** b**│162 A2** ó**│226 E2** Γ**  
035 23** #**│099 63** c**│163 A3** ú**│227 E3** π**  
036 24** $**│100 64** d**│164 A4** ñ**│228 E4** Σ**  
037 25** %**│101 65** e**│165 A5** Ñ**│229 E5** σ**  
038 26** &**│102 66** f**│166 A6** ª**│230 E6** µ**  
039 27** '**│103 67** g**│167 A7** º**│231 E7** τ**  
040 28** (**│104 68** h**│168 A8** ¿**│232 E8** Φ**  
041 29** )**│105 69** i**│169 A9** ⌐**│233 E9** Θ**  
042 2A** ***│106 6A** j**│170 AA** ¬**│234 EA** Ω**  
043 2B** +**│107 6B** k**│171 AB** ½**│235 EB** δ**  
044 2C** ,**│108 6C** l**│172 AC** ¼**│236 EC** ∞**  
045 2D** -**│109 6D** m**│173 AD** ¡**│237 ED** φ**  
046 2E** .**│110 6E** n**│174 AE** «**│238 EE** ε**  
047 2F** /**│111 6F** o**│175 AF** »**│239 EF** ∩**  
048 30** 0**│112 70** p**│176 B0** ░**│240 F0** ≡**  
049 31** 1**│113 71** q**│177 B1** ▒**│241 F1** ±**  
050 32** 2**│114 72** r**│178 B2** ▓**│242 F2** ≥**  
051 33** 3**│115 73** s**│179 B3** │**│243 F3** ≤**  
052 34** 4**│116 74** t**│180 B4** ┤**│244 F4** ⌠**  
053 35** 5**│117 75** u**│181 B5** ╡**│245 F5** ⌡**  
054 36** 6**│118 76** v**│182 B6** ╢**│246 F6** ÷**  
055 37** 7**│119 77** w**│183 B7** ╖**│247 F7** ≈**  
056 38** 8**│120 78** x**│184 B8** ╕**│248 F8** °**  
057 39** 9**│121 79** y**│185 B9** ╣**│249 F9** ∙**  
058 3A** :**│122 7A** z**│186 BA** ║**│250 FA** ∙**  
059 3B** ;**│123 7B** {**│187 BB** ╗**│251 FB** √**  
060 3C** <**│124 7C** |**│188 BC** ╝**│252 FC** ⁿ**  
061 3D** =**│125 7D** }**│189 BD** ╜**│253 FD** ²**  
062 3E** >**│126 7E** ~**│190 BE** ╛**│254 FE** ■**  
063 3F** ?**│127 7F** **│191 BF** ┐**│255 FF**  **  
064 40** @**│128 80** Ç**│192 C0** └**  
065 41** A**│129 81** ü**│193 C1** ┴**  
066 42** B**│130 82** é**│194 C2** ┬**  
067 43** C**│131 83** â**│195 C3** ├**  
068 44** D**│132 84** ä**│196 C4** ─**  
069 45** E**│133 85** à**│197 C5** ┼**  
070 46** F**│134 86** å**│198 C6** ╞**  
071 47** G**│135 87** ç**│199 C7** ╟**  
072 48** H**│136 88** ê**│200 C8** ╚**  
073 49** I**│137 89** ë**│201 C9** ╔**  
074 4A** J**│138 8A** è**│202 CA** ╩**  
075 4B** K**│139 8B** ï**│203 CB** ╦**  
076 4C** L**│140 8C** î**│204 CC** ╠**  
077 4D** M**│141 8D** ì**│205 CD** ═**  
078 4E** N**│142 8E** Ä**│206 CE** ╬**  
079 4F** O**│143 8F** Å**│207 CF** ╧**  
080 50** P**│144 90** É**│208 D0** ╨**  
081 51** Q**│145 91** æ**│209 D1** ╤**  
082 52** R**│146 92** Æ**│210 D2** ╥**  
083 53** S**│147 93** ô**│211 D3** ╙**  
084 54** T**│148 94** ö**│212 D4** ╘**  
085 55** U**│149 95** ò**│213 D5** ╒**  
086 56** V**│150 96** û**│214 D6** ╓**  
087 57** W**│151 97** ù**│215 D7** ╫**  
088 58** X**│152 98** ÿ**│216 D8** ╪**  
089 59** Y**│153 99** Ö**│217 D9** ┘**  
090 5A** Z**│154 9A** Ü**│218 DA** ┌**  
091 5B** [**│155 9B** ¢**│219 DB** █**  
092 5C** \**│156 9C** £**│220 DC** ▄**  
093 5D** ]**│157 9D** ¥**│221 DD** ▌**  
094 5E** ^**│158 9E** ₧**│222 DE** ▐**  
095 5F** _**│159 9F** ƒ**│223 DF** ▀**  
096 60** `**│160 A0** á**│224 E0** α**

---

Therefore, an ASCII code is referred to the **character that has been created with the last keystroke** (or keystroke combinations, in those cases such as letters bearing a stress mark).

---

**Important:** There is another predefined global variable, called scan_code, which also contains the code of the last pressed key. But, unlike **ascii**, this new variable stores the **scan code** of the key. That is to say, it indicates **which key has been pressed** and not **which character has been generated** by it (like **ascii**).

There is a series of constants designating these keys codes (keyboard scan codes). Access the help about these keys codes
to observe, moreover, a **sample program** with the **ascii** and **scan_code** variables.

The key() function of the language is normally used in order to verify whether a key is being pressed or not. This function receives one of these keys codes as a parameter, and returns **0** if the key is not pressed or **1** if it is pressed.

---
See: Global data - scan_code - key()

## [1110] GLOBAL scan_code

**scan_code=0;** // Scan code of the last pressed key

---
.

This global variable always indicates the scan code of the **last pressed key** in the last frame of the game.

The **scan_code** variable will be at **0** if no key has been pressed in the previous frame of the game.

This variable is often used to wait in a program for the user to press any key with a statement similar to the following one:

  **WHILE (scan_code == 0)**  
      **FRAME;**  
  **END**  

This statement indicates that, while no key has been pressed in the previous frame (while **scan_code** equals **0**), the frames of the game must continue to be displayed.

The **scan codes** are simply a numeric list of the PC's keys. These codes can slightly vary (in any key) regarding different keyboards, as there are keyboards of different languages, with a varied number of keys, etc.

However, almost all the codes of the main keys remain constant. There is a predefined list of constants (synonymous for these codes)
in the language that can be seen by accessing the help about keys codes (or keyboard scan codes). These numeric values will precisely be assigned to the **scan_code** variable when the respective keys are pressed in the program.

---

**Important:** There is another predefined global variable, called ascii, which also contains the code of the last pressed key. But, unlike **scan_code**, this new variable stores the **ASCII code** (character) generated by the key. That is to say, it indicates **which character has been generated by the last pressed key** and not **which key has been pressed** (like **scan_code**).

Access the help about the keys codes to observe a **sample program** with the **ascii** and **scan_code** variables.

The key() function of the language is normally used in order to verify whether a key is being pressed or not. This function receives one of these keys codes as a parameter, and returns **0** if the key is not pressed or **1** if it is pressed.

---
See: Global data - ascii - key()

## [1111] GLOBAL joy_filter

**joy_filter=10;** // Filter applied to the joystick

---
.

This global variable is used to define the filter applied to the read
joystick's coordinates.

It is defined as a percentage from **0 %** to **99 %**. By default, **joy_filter**
will equal **10** (a 10% filter will be applied).

The purpose of applying this filter to the joystick's coordinates is to make its movements gentler and to avoid possible "**irregularities**" in the coordinates' reading. Those joystick's coordinates must be obtained with the get_joy_position() function. The **joy_filter** variable will only be useful when the latter function is being used.

The bigger the filter applied to the joystick is, the gentler the movements of the latter will be. But, at the same time, its answer will take longer.

As the task performed by this "**filter**" is somewhat difficult to understand,
an example is now shown.

Sample program:
```div
PROGRAM example_joy_filter;
BEGIN
    write(0, 0, 0, 0, "joy_filter=");
    write_int(0, 70, 0, 0, offset joy_filter);
    write(0, 160, 180, 1, "The graphic is shown in the joystick's coordinates");
    write(0, 160, 190, 1, "Use the up/down keys to vary the filter");
    load_fpg("help.fpg");
    put_screen(0, 1);
    graph=100;
    LOOP
        IF (scan_code==_up AND joy_filter<99)
            joy_filter++;
        END
        IF (scan_code==_down AND joy_filter>0)
            joy_filter--;
        END
        x=get_joy_position(0);
        y=get_joy_position(1);
        FRAME;
    END
END
```

This program displays the graphic of a ball at the coordinates returned by the main joystick with the get_joy_position() function.

It can be notice how, for small values of **joy_filter**, many "**irregularities**" appear in the reading, and for very big values (like 95%) the coordinates' read is much gentler and regular, but slightly slower.

**Note:** It is indispensable to have a joystick (or gamepad) connected to the computer for this variable to be useful. If the joystick is connected during the program's execution, the system won't detect it (it must be connected from the beginning). See the joy_status global variable.

---
See: Global data - get_joy_position() - joy_status

## [1112] GLOBAL joy_status

**joy_status=0;** // State of the joystick

---

The state of the joystick (or gamepad) connected to the computer is indicated in this global variable. These are the values that this variable takes by default:

**0** - If the joystick reading system is disabled. This value means that a joystick connected to the computer either has not been found at the beginning of the program's execution, or has been disconnected.

**1** - If the joystick reading system is active. This is the initial value by default, but if the joystick is disconnected (or there is no joystick connected), the reading system will be disabled (indicating **0** in the joy_status variable).

If the system is disabled, it can be reactivated by simply assigning **1** to **joy_status** (with the **joy_status=1;** statement). But if, after a limited time, no joystick is detected, the system will be disabled again.

---

There is a **special mode** in which the joystick reading system **won't be ever disabled**. This mode is simply defined by {assigning 2 to
joy_status}.

  **joy_status=2;** // Activates special mode  

Nevertheless, much care must be taken as, if the joystick reading system is activated in this way, and there is no joystick connected to the computer, **the game's execution may be slowed down**.

---

**Note:** To read the joystick in the programs, the global joy structure is normally accessed. This structure always indicates its offset and the state of its
buttons (whether they are pressed or not).

---
See: Global data - Joy structure - joy_filter

## [1113] GLOBAL restore_type

**restore_type=complete_restore;** // Restoring type

---
.

This global variable indicates the restoring type that must be performed after each frame on screen.

The term **background restoring** means to recover the screen zones in which graphics have been painted or texts have been written in the previous frame. That is to say, "**unpaint**" the graphics and "**unwrite**" the texts (delete them).

There are three applicable restoring types which directly correspond to three constants that can be assigned to the **restore_type** variable.

no_restore       - The fastest one, the background is not restored (-1)  
partial_restore  - Average, partial restoring (0)  
complete_restore - The slowest one, complete restoring (1)  

By default, the value of **restore_type** equals **complete_restore**. That is to say,
if a different value is not indicated in this variable, a complete screen restoring will take place after each frame of the game.

This restoring mode (complete) is the slowest one out of these three modes. Thus, it will surely be possible to gain speed in the game's execution (for it to be faster in slow computers), if a different value is assigned to this variable.
For instance, the following statement must be used to indicate a partial restoring:

  **restore_type=partial_restore;**

This statements orders the process' manager of DIV Games
Studio to partially restore the screen background (only those screen zones where graphics or texts have been put) after the following frames of the game.

The **no_restore** type (not restoring the screen background) is the fastest mode. However, it is only applicable when the game develops inside a scroll or mode 7 window occupying the entire screen. Otherwise, the graphics will leave signs (of the previous frames) on moving through the screen.

The restoring mode can be changed under a program's execution as often as necessary, according to the requirements of the stages (or sections) under execution at each moment.

---

**Note:** There is another global variable also related to DIV
Games Studio's management on screen. This is called dump_type and it defines the type of frames **dump** that must be performed (what information
must be sent to the monitor after every frame of the game).

---
See: Global data - dump_type

## [1114] GLOBAL dump_type

**dump_type=complete_dump;** // Type of dump

---

This global variable indicates the frame dump on screen types that must be performed in every frame of the game.

The term **dump** means that the game's frames are sent to the monitor (to the video memory of the graphic card).

---

There are two applicable types of dump which directly correspond with two constants that can be assigned to the **dump_type** variable.

partial_dump - When indicated with the following statement, **partial dumps** will be performed:

  **dump_type=partial_dump;**

Only the graphics that are updated, that have changed with respect to the previous frame, will be dumped on screen in this mode. It is advisable to activate this dump **in order to gain speed** when a game (or one section of it) is programmed without a scroll or mode 7 window occupying the entire screen. That is to say, either when the game shows graphics' movements against a fixed background or when the active scroll or mode 7 windows are smaller than the screen.

complete_dump - When indicated with the following statement, **complete dumps** will be performed:

  **dump_type=complete_dump;**

In this mode, the entire screen will be dumped no matter whether the graphics have changed or not. This mode is slower than the **partial dump**. Nevertheless, it must be used when the game has a scroll or mode 7 window occupying all the screen.

---

By default, the value of **dump_type** is **complete_dump**. That is to say,
if no other value is indicated in this variable, **complete dumps** on the screen will be performed after each game's frame (which is normally **slower** than performing partial dump).

The dump type can be changed during a program's execution as often as necessary, according to the requirements of the stages (or sections) under execution at each moment.

---

**Note:** There is another global variable also related to DIV
Games Studio's management on screen. This is called restore_type  and it defines the type of **restoring** that must be performed on screen after every game's frame (which graphics or texts must be deleted).

---
See: Global data - restore_type

## [1115] GLOBAL max_process_time

**max_process_time=500;** // Maximum execution time

---
.

Programs are provided with an **anti-blocking** system that will make the manager of processes of DIV Games Studio interrupts its execution when a process exceeds the **maximum execution time** in a game's frame.

This maximum time is indicated in the **max_process_time** global variable in **hundredths of second**. By default, its value is **500 hundredths** (**5 seconds**).

That is to say, when a process takes longer than the indicated time in
executing a FRAME statement (which indicates that the process
is ready for the following frame of the game), an execution error will arise.

**Note:** The utility of the possibility of changing this variable, assigning a new value to it, is to avoid this error in the programs in which there is a process that must be doing calculations for a long time.

The following statement must be used to order the process' manager, for instance, not to interrupt a process, unless its execution in a frame is longer that 30 seconds:

  **max_process_time=3000;**

As 30 seconds are 3000 second hundredths.

---

**Important:** Keep in mind that the time used by every computer to do the program's calculations is different. Therefore, this value must be defined with a certain margin, in order to avoid to exceed  the **maximum execution time**
when the game is executed in slower computers.

---
See: Global data - FRAME statement

## [1116] LOCAL STRUCT reserved

**STRUCT reserved;**  
    **process_id;**    // Identifier of the process  
    **id_scan;**       // Index of processes  
    **process_type;**  // Type of process  
    **type_scan;**     // Index of types  
    **status;**        // State of the process  
    **param_offset;**  // Offset of the parameters  
    **program_index;** // Program counter  
    **is_executed;**   // executed process  
    **is_painted;**    // painted process  
    **distance_1;**    // Mode 7 reserved  
    **distance_2;**    // Mode 7 reserved  
    **frame_percent;** // Percentage of frame  
    **box_x0, box_y0;** // Beginning of the process' graphic  
    **box_x1, box_y1;** // End of the process' graphic  
**END**  

In this structure, different **variables of internal use** (used by the **manager of processes of DIV Games Studio**) are stored.

They are local variables reserved for the system. It is not necessary to know these variables, as most of them are not useful to create programs.

**Important:** The modification of the values of these variables will probably provoke the **blocking** of the computer, an incorrect working of the **manager of processes** or problems on using many of the internal functions. Therefore, no responsibility is assumed for the hypothetical problems derived from an incorrect use of the **reserved** structure.

---

A **brief description** of each of these fields is now shown, just for information.

**process_id** - Identifying code of the process. This value is normally obtained with the reserved word ID and the value of this field must not be modified.

**id_scan** - It is internally used on detecting collisions in order to save the identifying code of the last process that has collided with the current process.

**process_type** - Type of the current process, normally obtained with the operator TYPE, later indicating  the process name (see Types of processes).

**type_scan** - It is internally used to detect collisions or obtain identifying codes of processes of a specific type.

**status** - Present state of the process. The values that this field can adopt are the following ones:

  **0** - non-existent process.  
  **1** - process that has received a signal **s_kill**.  
  **2** - alive or awake process (s_wakeup).  
  **3** - asleep process (s_sleep).  
  **4** - frozen process (s_freeze).  

**param_offset** - Offset of the computer's memory in which the parameters received by the process are located.

**program_index** - Program's counter. Offset of the computer's memory in which the first statement that must execute the process in the next frame is located.

**is_executed** - It indicates whether this process has already been executed in the current frame.

**is_painted** - It indicates whether the graphic of the process has already been painted in the current frame of the game.

**distance_1** - Vertical distance of the process (reserved for processes
displayed in a mode 7 window).

**distance_2** - Horizontal distance of the process (reserved for processes
displayed in a mode 7 window).

**frame_percent** - Percentage of the following frame completed by the process. This value will be useful when the FRAME statement is used indicating a percentage. Otherwise, it will simply be equal to 0 (0%) when the process has not been executed and 100 (100%) when it has already been executed.

**box_x0, box_y0** - Upper left coordinate of the graphic in the previous frame of the game (where the graphic was placed at screen coordinates).

**box_x1, box_y1** - Lower right coordinate of the graphic in the previous frame of the game.

---
See: Local data - Syntax

## [1117] LOCAL father

**father;** // Identifying code of the father

---
 process.

This is a predefined LOCAL variable, which means that each process will have its own value in its **father** variable.

This variable always contains the identifying code of the process that created (called) the current process (the one that has this variable). That is to say, it indicates which process called it.

Inside the language, father process is the name given to the process that calls another one. The process that has been called receives the name of son process. For further information, see the hierarchies of processes in the language.

The DIV's **manager of processes** is the process named **div_main**. Its function is to create the main process of the program (**PROGRAM**) at the beginning of the game's execution. Therefore, it will be the father of the main program, as well as the father of all the processes that become orphan (processes whose father has been killed or finished before them, see states of a process).

---

**Note:** The identifying code of the son process is indicated in the
predefined son local variable.

---
See: Local data - Identifying code - Hierarchies of processes

## [1118] LOCAL son

**son=0;** // Identifying code of the son

---
 process.

This is a predefined LOCAL variable, which means that each process will have its own value in its **son** variable.

This variable always contains the identifying code of the **last** process  created (called) by the current process. That is to say, it indicates which is the last process called.

Inside the language, father process is the name given to the process that calls another one. On the other hand, son process is the name given to the process that has been called. For further information, see the hierarchies of processes in the language.

By default, this variable will be equal to **0** until the process makes a call to another process. At this moment, the new process will be created
indicating its identifying code in **son**.

---

**Note:** The identifying code of the father process is indicated in the predefined father local variable.

---
See: Local data - Identifying code - Hierarchies of processes

## [1119] LOCAL smallbro

**smallbro=0;** // Identifying code of the younger brother

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its **smallbro** variable.

This variable always contains the identifying code of the **following** process  created by the father of the current process after it. That is to say, when the process that called the current one calls later another one, this variable will indicate which one is called now.

Inside the language, **younger brother** is the name given to this process. For further information, see the hierarchies of processes in the language.

By default, this variable will be equal to **0** until the father process makes a call to another process. At this moment, the new process (the younger brother of this one) will be created, indicating its identifying code in **smallbro**.

---

**Note:** The identifying code of the **elder brother** is indicated
in the predefined bigbro local variable.

---
See: Local data - Identifying code - Hierarchies of processes

## [1120] LOCAL bigbro

**bigbro=0;** // Identifying code of the elder brother

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its **bigbro** variable.

This variable always contains the identifying code of the process  created by the father just before creating the current process after it. That is to say, when the process that called the current one had created another one before, this variable will indicate which one is it.

Inside the language, **elder brother** is the name given to this process. For further information, see the hierarchies of processes in the language.

By default, this variable will be equal to **0** if the father process (the one that called the current one) has not created any other process before. If it has created one, or more than one, **bigbro** will indicate the identifying code of the last one.

---

**Note:** The identifying code of the **younger brother** is indicated
in the predefined smallbro local variable.

---
See: Local data - Identifying code - Hierarchies of processes

## [1121] LOCAL priority

**priority=0;** // Level of priority of the process

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its **priority** variable.

In the preparation of each frame, all the processes will be executed in
the priority order established by the **priority** local variable.

The higher the value of **priority** in a process is, the sooner it will be processed in each frame. The priority value may be established as any integer within the (min_int ... max_int) range. For instance, to establish the priority level of a process at **10**, the following statement must be used:

  **priority=10;**

All the processes active in the program having **the same level of priority** will be executed in a **undetermined order** that, moreover, may vary from some executions of the game to others.

By default, the **priority** local variable will be initialized at **0**
in all the processes created in the program. Thus, it will be possible to execute them in any order, if the value of this variable is not defined.

If the **priority** of a single process is fixed at a positive number, such as 1, it will be executed before the rest of the of the processes. On the other hand, if it is fixed at a negative number, such as -1, then it will be executed after the rest (supposing that the **priority** variable of the rest has not been modified, so its value is still equal to **0**).

**When the processes priority must be established?**

---

When a process needs to use data of another process for its calculations, it is normally advisable to execute it after the latter, defining its lowest priority for the data of the second process to be updated when they are read.

For instance, if process **B** must place its graphic 8 pixels lower than the graphic of process **A**, the priority of **A** must be greater than that of **B**, for the latter to be executed first.

Thus, when process **B** obtains its **y** coordinate by adding 8 to the one of process **A**, this calculation is done with the **y** coordinate of process **A**
already updated for the following frame (to ensure that in each frame, the **y** coordinate of process **A** first, and then that of process **B** will be established).

For that purpose, suffice would be to define either the priority of **A** as **1** or the priority of **B** as** -1**, since by default both priorities are at **0**.

---

**Note:** The priority level of the process has nothing to do with the depth plane in which its graphic appears on screen, as this plane is indicated in the local z variable. That is to say, the fact that a process is processed before does not mean that the graphic is painted before.

---
See: Local data

## [1122] LOCAL ctype

**ctype=c_screen;** // System of coordinates

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its  **ctype** variable.

The **system of coordinates** used by the process is indicated in this variable. That is to say, it shows how the process' coordinates (contained in the x and y local variables) must be interpreted.

It is possible to use three different systems of coordinates, directly corresponding with three constants that can be assigned to the **ctype** variable.

  c_screen - Screen coordinates  
  c_scroll - Scroll coordinates  
  c_m7     - Mode 7 coordinates  

**By default, the ctype value is** c_screen, used for the process' graphic coordinates to be interpreted as referred to the screen, where the upper left corner is (0, 0).

With the following statement, c_scroll will be assigned to **ctype**:

 **ctype=c_scroll;**

For the process' graphic coordinates to be interpreted as referred to a scroll window, with coordinates located above the foreground's graphic.

With the following statement, c_m7 will be assigned to **ctype**:

 **ctype=c_m7;**

For the process graphic coordinates to be interpreted as referred to a mode 7 window, with coordinates located above the main graphic, three-dimensionally folded in that window.

---

**Note:** There is another local variable that also affects the way in which the process coordinates must be interpreted, This variable is resolution, which establishes the resolution (scale) in which the coordinates are defined.

---
See: Local data - c_screen - c_scroll - c_m7

## [1123] LOCAL x

**x=0;** // Horizontal coordinate of the graphic

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its **x** variable.

The **x** and y local variables of the processes define where their graphic (defined in the graph local variable) must be placed.

The **x** local variable defines the process' **horizontal coordinate**,
which may be defined as an integer within the range (min_int ...
max_int), putting the positive coordinates to the right and the negative ones, to the left.

By default, these coordinates will be specified in **pixels**,
referred to screen coordinates, where the upper left corner is the point placed at (**0**, **0**).

**Type of coordinates.**

---

There are several systems of coordinates that may be used by the processes and that are defined with the ctype local variable. The coordinates related to the screen are the system by default.

**Resolution of the coordinates.**

---

The resolution local variable indicates the precision of the process coordinates. By default, this variable will be equal to **0** and the (**x**, y) coordinates will be specified in pixels.

The higher the value of resolution is, the smaller (and more precise) the unit in which the coordinates are interpreted will be. Some examples are now shown:

**resolution=1;** - The coordinates are specified in pixels.

**resolution=10;** - They are specified in tens of pixels.

**resolution=100;** - They are specified in hundreds of pixels.

**resolution=2;** - They are specified in half pixel.

...

---

**Note:** A different type and resolution of coordinates may be either defined for each process or changed while executing if necessary.

---

**Important:** When a graphic is placed at some specific coordinates, it is the graphic **center** that will normally be placed at these coordinates.

This can be changed by defining in the **graphic editor** the control point number **0** of the graphic of the process (whose **graphic code** is indicated in the graph variable).

If the control point has been defined, it will be placed at the specified coordinates.

For instance, if control point number **0** is placed in the upper left corner of the graphic, and then, the graphic is put at the (100, 100) coordinates, the upper left corner of the graphic will be placed at these coordinates.

---
See: Local data - ctype - resolution

## [1124] LOCAL y

**y=0;** // Vertical coordinate of the graphic

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its **y** variable.

The x and **y** local variables of the processes define where their graphic (defined in the graph local variable) must be placed.

The **y** local variable defines the process' **vertical coordinate**,
which may be defined as an integer within the range (min_int ...
max_int), placing the positive coordinates downwards and the negative ones, upwards.

By default, these coordinates will be specified in **pixels**,
referred to screen coordinates, where the upper left corner is the point placed at (**0**, **0**).

**Type of coordinates.**

---

There are several systems of coordinates that may be used by the processes and that are defined with the ctype local variable. The system by default defines the coordinates related to the screen.

**Resolution of the coordinates.**

---

The resolution local variable indicates the precision of the process coordinates. By default, this variable will be equal to **0** and the (x,**y**) coordinates will be specified in pixels.

The higher the value of resolution is, the smaller (and more precise) the unit in which the coordinates are interpreted will be. Some examples are now shown:

**resolution=1;** - The coordinates are specified in pixels.

**resolution=10;** - They are specified in tens of pixels.

**resolution=100;** - They are specified in hundreds of pixels.

**resolution=2;** - They are specified in half pixel.

...

---

**Note:** A different type and resolution of coordinates may be either defined for each process or changed while executing if necessary.

---

**Important:** When a graphic is placed at some specific coordinates, it is the graphic **center** that will normally be placed at these coordinates.

This can be changed by defining in the **graphic editor** the control point number **0** of the graphic of the process (whose **graphic code** is indicated in the graph variable).

If the control point has been defined, it will be placed at the specified coordinates.

For instance, if control point number **0** is placed in the upper left corner of the graphic, and then, the graphic is put at the (100, 100) coordinates, the upper left corner of the graphic will be placed at these coordinates.

---
See: Local data - ctype - resolution

## [1125] LOCAL z

**z=0;** // Depth plane of the process graphic

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its **z** variable.

The **z** local variable defines the depth plane in which the process graphic must be placed on screen (the graphic is defined in the graph local variable). That is to say, it defines what must appear above the process' graphic and what under it.

Any integer within the range (min_int ... max_int) may be used as a depth plane. The greater the number is, the deeper the graphic will be placed.

---

By default, the depth planes are arranged in the following way:

** (+) Greater depth**

** +512** - Scroll windows (see scroll[].z)  
** +256** - Mode 7 windows (see m7[].z)  
**  0**   - Graphics of the processes (local **z**)  
** -256** - Texts (see text_z)  
** -512** - Mouse pointer (see mouse.z)  

** (-) Less depth**

That is to say, the **z** local variable that defines the depth plane of the processes' graphics will be initialized at **0**. The processes' graphics will be placed below the mouse pointer and texts, and above the scroll and mode 7 windows (if the values are not modified by default).

---

All the objects (texts, graphics, windows, ...) placed in the same depth plane will appear on screen (on being superposed) in an **undetermined order**, that may vary from some program's executions to some others.

If the aim was, for instance, that the graphic of a process appeared above all the objects of the program, a depth plane could be fixed for it above the rest (as -1000}, with the following statement:

  **z=-1000;**

At the beginning, all the processes have their **z** variable at **0**,
then the graphic of the processes will appear in any order if the plane in which each of them must be placed is not defined.

The depth plane of a process may be modified (by assigning a new value to its **z** variable) as often as necessary inside a program.

The depth planes of the rest of objects (windows, texts
and mouse pointer) may also be modified at any stage of the program.

---

**Note 1:** The processes that belong to a **scroll window** (having its variable ctype**=**c_scroll) will be painted in the **depth plane of the scroll window**. Nevertheless, inside that window, all the graphics of the processes will appear **in order, according to their depth plane**.

That is to say, the process' depth plane (indicated as usual in the **z** variable) will be **referred to the scroll window**
in which the process appears (see start_scroll()).

---

**Note 2:** The processes that belong to a **mode 7 window** (having its variable ctype**=**c_m7) will appear in that window **in order, according to the depth order in the three-dimensional plane** ignoring the value of their **z** local variable.

The only sense of the **z** local variable in **mode 7** processes is to define the order in which the processes **exactly** placed at the same coordinates of the folded plane must be superposed. That is to say, if two processes are placed in the three-dimensional plane at the same coordinates, then it will be possible to define, through the **z** variable, which one must appear above the other (see start_mode7()).

---
See: Local data - mouse.z - scroll[].z - m7[].z - text_z

## [1126] LOCAL graph

**graph=0;** // Code of the process graphic

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its **graph** variable.

Normally, most of the processes correspond with a graphic object
displayed on screen that will be placed at the indicated coordinates
in the x and y local variables. It is necessary to define which graphic corresponds with this process by assigning a **graphic code** to the **graph** local variable.

By default, this variable will be equal to **0**, which implies that no graphic will be displayed for this process.

The graphics must first be created in the **graphic editor** of DIV
Games Studio (with the option "**New...**" of the maps menu) and then, they can be saved in an **archive MAP** (containing this graphic),
or in a **file FPG** together with other graphics (it is possible to create a new file with the option "**New...**" of the files menu).

That is to say, the graphics used in a program may come from an **archive MAP** (that contain just one graphic) or from a **file FPG**
(that may contain many graphics).

**Note:** The same graphic may be used in a program by many processes at the same time.

**Archives MAP**

---

In order to use a graphic from an **archive MAP** in the program, it must be loaded by calling the load_map() function, which will return the **graphic code** that must be assigned to the **graph** variable.

A GLOBAL variable is normally used to save this **graphic code** and then, it is assigned to the **graph** variable.

Sample program:
```div
PROGRAM example_graph;

GLOBAL
    graphic1;

BEGIN
    graphic1=load_map("help.map");

    graph=graphic1; // The graphic of the process is defined.

    LOOP
        x=mouse.x;
        y=mouse.y;
        FRAME;
    END
END
```

Even if in the previous example, the **graphic1** global variable could have been omitted, having directly assigned the code returned by the load_map() function to the **graph** variable with the following statement:

  **graph=load_map("help.map");**

the **graphic code** returned by this function are simply integers from **1000**.

**Files FPG**

---

In order to include a graphic that has been done in the **graphic editor**
in a **file FPG**, it is necessary to **drag the graphic window to the file window** (click on the graphic, move to the file and release). Then, the program will ask for the **graphic code**, so an integer ranging from **1** and **999** must be included here.

Thus, to use the graphic in a program, the **file FPG** that contains it must first be loaded with the load_fpg() function, assigning then the **graphic code** to the **graph** variable.

An example is now shown. Before, it is necessary to know that a **brown ball** graphic was stored in the **file HELP.FPG**
indicating the **graphic 100 code**.

Sample program:
```div
PROGRAM example_graph;
BEGIN
    load_fpg("help.fpg");

    graph=100; // The graphic of the process is defined.

    LOOP
        x=mouse.x;
        y=mouse.y;
        FRAME;
    END
END
```

**Several files FPG** can be loaded in a program. In this case, it will be necessary to indicate, besides the **graphic code** in the **graph** local variable, the **file code** returned by the load_fpg() function in the file local variable.

It won't be necessary if only one file is loaded, as the file variable equals **0** by default in all the processes and **0** will always be the **first file's code** loaded in the program.

---

There are more local variables related to the graphic of a process. The most important ones are mentioned below:

  **graph**  - Graphic code  
  file   - File code  
  x, y   - Graphic coordinates  
  z      - Depth plane  
  angle  - graphic angle  
  size   - graphic size  
  flags  - Mirrors and transparencies  
  region - Display window  

---
See: Local data

## [1127] LOCAL flags

**flags=0;** // Indicator of mirrors and transparency

---
.

This is a predefined LOCAL variable, which means that every process will have its own value in its **flags** variable.

The **flags** local variable indicates the mirrors and transparencies of the displayed graphic in the processes. The possible values are the following ones:

 **0**-Normal graphic.  
 **1**-Horizontal mirror.  
 **2**-Vertical mirror.  
 **3**-Horizontal and vertical mirror (180°).  
 **4**-Transparent graphic.  
 **5**-Transparent and horizontal mirror.  
 **6**-Transparent and vertical mirror.  
 **7**-Transparent, horizontal and vertical mirror.  

By default, the value of the **flags** variable is **0**. That is to say, if it is not modified, the graphic will be displayed opaque (not transparent or mirror).

The terms **mirror** and **transparency** are now defined:

- **Horizontal mirror**, the graphic will be horizontally flipped. That is to say, if it was facing left, it will face now right and vice versa.

- **Vertical mirror**, the graphic will be vertically flipped. That is to say, if it was facing up, it will face now down and vice versa.

- **Transparency** (or **ghost-layering**), the graphic will be displayed semitransparent. That is to say, it will be possible to see what is placed behind the graphic, as if it was a coloured window, unlike the opaque graphics normally displayed.

For instance, the following statement must be used to display a transparent graphic of a process:

  **flags=4;**

---

**Note:** The graphic of a process must be indicated assigning a **graphic code** to the graph local variable.

---
See: Local data

## [1128] LOCAL size

**size=100;** // Size (percentage) of the graphic

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its **size** variable.

The **size** local variable defines the size in which the graphic of the process must be seen. This size is a percentage related to its original size.

By default, the value of this variable will be equal to **100** (100%) for all the processes, and when the graphic is modified, it will **scale**
(reducing or expanding its size) to adjust to the new size.

That is to say, to **double** the size of the graphic displayed, it will be necessary to specify **200%**. The following statement will be used for this purpose:

  **size=200;**

Therefore, if this value is lesser than **100**, the graphic will be seen smaller; otherwise, it will be seen bigger.

At first, there is no limit for the graphic size, but if the **size** local variable is put at **0** (0%), then the graphic of the process won't be seen.

---

**Note:** The graphic of a process must be indicated assigning **a graphic code** to the graph local variable.

---
See: Local data

## [1129] LOCAL angle

**angle=0;** // angle of the process' graphic

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its **angle** variable.

The **angle** local variable defines the angle in which the graphic of the process must be seen, indicating an angle with regard to the original graphic in **degree thousandths** (see Use of angles in the language).

By default, the value of this variable will be equal to **0** (0 degrees) for all the processes, but when the graphic is modified, it will **rotate** to adjust to the new angle.

The angle may be defined as any integer within the range (min_int ... max_int).

Some examples of the angles that define certain values in the **angle** local variable are now shown (keep in mind that the angles are expressed in degree **thousandths**):

      ...  
 ** -180000** - Angle to the left  
 **  -90000** - Angle downwards  
 **  -45000** - Angle of the diagonal down/right  
 **       0** - Angle to the right  
 **  +45000** - Angle of the diagonal right/up  
 **  +90000** - Angle upwards  
 ** +180000** - Angle to the left  
 ** +270000** - Angle downwards  
      ...  

**Important:** When the aim is to rotate the graphic of a process,
**it is advisable to paint it orientated to the right**, as it will be displayed like this by default (with the **angle** local variable equal to **0**).

Thus, when another angle is specified, the graphic will appear exactly orientated towards it.

For instance, a graphic that has been drawn to the right can be seen orientated upwards (to the angle of 90 degrees) by indicating the following statement:

  **angle=90000;** // 90 degree thousandths (90 degrees).

That is to say, if a graphic was painted orientated towards another angle,
(for instance, downwards), it would become orientated downwards by default,
**in the angle 0**, which can provoke confusions when it comes to orientating the graphic towards another angle.

---

To make the graphic of a process advance its coordinates (x, y) towards its angle (the one specified **angle** in the local variable of the process) a specific distance, the advance() function can be used.

---

**Note:** The graphic of a process must be indicated assigning a **graphic code** to the graph local variable.

---
See: Local data - Use of angles in the language

## [1130] LOCAL region

**region=0;** // Screen region assigned to the process

---
.

This is a predefined LOCAL variable, which means that each process will have it own value in its **region** variable.

The **region** local variable defines the zone of the screen in which the graphic of the process must be visible, indicating the **number of region**.

A region is a rectangular zone of the screen, such as a window,
associated to a number.

By default, this variable will be equal to **0** in all the processes, making reference to **region number 0** that is the **entire screen**.

That is to say, by default the graphics of the process will be visible
in the whole screen (at any point of the screen in which they are placed).

At the beginning, only **region number 0** is defined.
To define new screen regions, it is necessary to use the define_region() function.

---

For instance, for the graphic of a process  to be visible only inside a 100 by 100 pixel box placed in the upper left corner of the screen (at the coordinates 0, 0), first the new region should be defined in the following way, supposing that region number **1** is defined:

  **define_region(1, 0, 0, 100, 100);**

and then, the number of region (**1**) should be assigned to the **region** local variable of the process with the following statement:

  **region=1;**

The regions may be redefined at any moment inside a program. That is to say, they can change their position or size if necessary.

---

**Note:** The graphic of a process must be indicated assigning a **graphic code** to the graph local variable.

---
See: Local data - define_region()

## [1131] LOCAL file

**file=0;** // File code of the process' graphic

---
.

This is a predefined LOCAL variable, which means that every process will have its own value in its **file** variable.

In the case that several graphics files **files FPG** have been loaded in a program, the **file** local variable indicates which file contains the graphic that the process is using.

The graphic of a process must be indicated by assigning a **graphic's code** to the graph local variable.

If just one file has been loaded in the program, it won't be necessary
to assign any value to **file**, as the **code of the first loaded file**
will equal **0** and this is the value of the variable by default.

If the graphic has been loaded with the load_map() function, it won't be necessary to assign any value to **file** either, as the graphics loaded with this function are used as if they belonged to file number **0**
(to the first one that is loaded in the program).

When more than a file is loaded, it is necessary to indicate in each process
in which one its graphic is stored. It is done by assigning
the **file code** returned by the load_fpg() function
(on loading this **file FPG**) to the **file** local variable.

**Note:** Normally, if several files are sequentially loaded in a program,
the first one will have the code **0**, the second, the code **1**, the third, the code **2** and so on.

---

In general, if several files are used, it is a good practice to have the same number of global variables (named, for instance, **file1**, **file2**, ...) containing the code of each of the files, to use them in the processes when it comes to defining
its **file** variable (the **file FPG** that must be used).

The variables would be defined inside the section GLOBAL in the following way:

  **GLOBAL**  
      **file1;** // First file's code  
      **file2;** // Second file's code  
      ...

Next, these variables would be assigned the **file codes**
on loading them with the load_fpg() function in the following way (supposing that the names of the files is **name1.fpg**,
**name2.fpg**, etc.):

  **file1=load_fpg("name1.fpg");** // Files loading  
  **file2=load_fpg("name2.fpg");**  
  ...

These files are generally loaded at the beginning of the program. Later, the used file would only have to be defined inside each process with the following statement (supposing that the process uses graphics stored in the file **name1.fpg**):

  **file=file1;** // The first file is used  

---

**Note:** Keep in mind that defining the **file** local variable is futile,
unless a **graphic's code** is assigned to the graph local variable.

---
See: Local data

## [1132] LOCAL xgraph

**xgraph=0;** // OFFSET of the process' graphic table

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its **xgraph** variable.

This is an advanced level variable. Thus, its use requires certain experience.

The **xgraph** local variable (**extended graphic**) allows us to use **multiple graphics**. This variable is used to define the graphic of a process as a **graphics set** among which it is necessary to see **the most appropriate with the process' angle** (specified in the angle local variable).

That is to say, if the **xgraph** variable is defined, the graph local variable which normally defines the graphic of the process **will be ignored** and one graphic or another will be used depending on the angle variable.

Therefore, on changing the process' angle **the graphic of the process won't appear rotated**, but it will use this angle to select the process' graphic (inside the defined set).

By default the **xgraph** variable will equal **0** in all the processes,
which indicates that they are not going to use **multiple graphics**.

---

The utility of the multiple graphics lies on the possibility of creating games in **perspective**, where the change of an angle in the process doesn't implied
a rotation of its graphic, but the replacement of the graphic by another one painted in a different **perspective** (painted with another angle inside that perspective).

**How to use the multiple graphics.**

---

1 - First, the different pictures that are going to represent the process' graphic have to be painted with different angles in perspective. The latter will be a finite number of graphic's views, such as **4**, **8**, **12**, etc., (or any other integer bigger than **1**).

Take into account that if 4 views are defined, a different view will be defined every 90 degrees, if 8 views are defined, every 45 degrees, etc.

2 - It is necessary to put these graphics in order according to their angles. First, the graphic corresponding with angle 0 (towards the right) and then, the rest in a clockwise direction.

3 - A table, generally GLOBAL, must be created and initialized with the following values:

  **Number of graphic's views**,  
  **Graphic's code for **angle **0 (first view)**,  
  **Code of the following angle (second view)**,  
  ...

The name given to this table makes no difference. For instance,
if a multiple graphic is defined with 4 views, which must be the graphics with the codes 10, 11, 12, and 13, the definition of the table could be as follows:

  **GLOBAL**  
      **table_graphic1[]=4, 10, 11, 12, 13;**  
      ....

4 - Finally, the offset of this table must be assigned inside the computer's memory to the **xgraph** local variable of the process, which is done with the following statement (inside the process in question):

  **xgraph=OFFSET table_graphic1;**

The OFFSET operator is used to obtain the offset of a program's datum in the memory.

---

Once the **multiple graphic** has been defined, in each frame of the game the system will use the graphic corresponding with the angle **closest to the process' angle** (the one indicated in its angle variable).

The **xgraph** variable must be put at **0** again in order to disable the **multiple graphic** system in a process,

**Important:** If any graphic's code is put with a **negative sign** inside the table that defines the set of graphics, then this graphic will appear **horizontally flipped**. That is to say, if the graphic was facing right, it will appear facing left, and vice versa.

---

**Note:** The multiple graphic system is normally used in **mode 7 windows**, as in the folded three-dimensional plane the graphics must be seen in a different way, according to the angle from which they are observed.

For further information about this technique, see the start_mode7() function used to activate a **mode 7 window** in the program.

---
See: Local data

## [1133] LOCAL height

**height=0;** // Graphic's height (in mode 7)

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its **height** variable.

The local **height** variable is **exclusively** used in the processes that belong to
**mode 7 windows**. That is to say, processes that have their coordinates' system inside a three-dimensional window (its local variable ctype=c_m7).

It is used to define the height at which the graphics of the processes must be placed above the three-dimensional plane. The local z variable is not used for this purpose, as it is used to define the depth plane of the graphics (even if it is now useful only for processes placed at the same coordinates).

The height of the process can be defined as any integer within the (min_int ... max_int) range, even if positive numbers are normally used, as the **height** of the bottom is **0** and processes are placed above it.

By default, the value of the **height** variable is **0** for all the processes, which means that if another value is not specified, the graphics of the processes will appear just above the bottom of the **mode 7** (above the plane three-dimensionally folded).

The **graphic's base** will first be placed in the indicated **height** of the process, unless control point number **0** is defined. In this case, this point will be placed in that height.

**Note:** For further information about the **mode 7 windows** and how to place graphics inside these windows, see the help about the start_mode7() function, which is used to activate them in the program.

---

This variable can be used for any other purpose in the non **mode 7** processes, as the system will completely ignore it.

---
See: Local data - start_mode7()

## [1134] LOCAL cnumber

**cnumber=0;** // Number of scroll or mode 7 windows

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its **cnumber** variable.

The local **cnumber** variable is **exclusively** used when, in a game, several **scroll windows** or several **mode 7 windows** simultaneously appear on screen.

- For further information about the **scroll windows**, see the help about the start_scroll() function, which is used to activate them in the program.

- For further information about the **mode 7 windows**, see the help about the start_mode7() function, which is used to activate them in the program.

---

The **cnumber** utility lies on indicating **in which of these windows the graphic of the process must be seen**. Obviously, this variable must be defined only in processes visible inside the **scroll windows** or the **mode 7 windows**. This variable is useless for the rest of the processes (screen processes or processes with no graphics).

**If the process must be seen in all the windows**, then it won't be necessary to modify this variable, as the value of **cnumber** (**0**) by default precisely indicates so.

Up to **10** windows of both types may be activated, numbered from **0** to **9**. There are ten predefined constants used to define the value of **cnumber**. These are c_0, c_1, c_2, ..., c_9 and directly correspond with the **10** possible windows of these types.

**cnumber** must be assigned **the addition of the constants** corresponding with the **windows in which the process must be visible**.

For instance, if there are **4 scroll windows** numbered **0**, **1**, **2** and **3** in a program, and the aim is to define that a specific process must be only visible in windows **0** and **2**, the following statement must be used:

  **cnumber=c_0+c_2;**

The value of **cnumber** can be changed during the process execution if necessary.

---

**Note:** Keep in mind that for the graphic of the process to be seen in all the windows, it is not necessary to do anything, as it is the option by default.

---
See: Local data - c_0...c_9

## [1135] LOCAL resolution

**resolution=0;** // Resolution of the process coordinates

---
.

This is a predefined LOCAL variable, which means that each process will have its own value in its **resolution** variable.

Normally, the coordinates of a process (indicated in the x and y local variables) are defined in screen pixels.

The **resolution** local variable must be used when the aim is to define the coordinates in **units smaller** than the pixel.

That is to say, this variable indicates the precision of the process' coordinates.

By default, the variable will equal **0** and the coordinates will be specified in pixels.

The greater the value of resolution is, the smaller (and more accurate)
the unit in which the coordinates are interpreted will be. Some examples are show below:

**resolution=1;** - The coordinates are specified in pixels (similar to **resolution=0**, which is the value by default).

**resolution=10;** - They are specified in tenths of pixel.

**resolution=100;** - They are specified in hundredths of pixels.

**resolution=2;** - They are specified in half pixel.

...

For instance, a process located at **160**, **100** with **resolution** equal to
**0** (or **1**), will be in the same position as a process located at
**1600**, **1000** and with **resolution** equal to **10**.

The value of **resolution** is normally defined as a **positive integer multiple of 10** (10, 100, 1000, ...).

---

In short, when the value of **resolution** is defined, the processes' manager of DIV Games Studio **will divide** the coordinates of the processes
between **resolution** when it comes to painting their graphics on screen.

---

**Important:** Much care must be taken when, in a program,
there are several processes with different resolutions of coordinates,
as some functions, such as get_dist() (used to obtain the distance between two processes), will return **incorrect results**
when two processes using different resolution of coordinates are accessed.

It is normally advisable that all the processes active in the game,
at least all that interact (that are detected, modified or that can be collide) use the same resolution.

---
See: Local data

## [1136] Control points.

[image]The **control points** are defined inside the **graphic editor**
with the bar of control points, indicated with this icon.[image]

---

In order to access the **graphic editor**, suffice will be to "**double-click**" with the left mouse button on a graphic inside the environment (on a map window).

The **control points** are simply points that can be placed inside a graphic for different purposes.

The **bar of control points** allows us to position up to **1000** different points inside a graphic. Each of them will be identified by its number (from **0** to **999**).

In order to position one of these points, suffice will be to select the {number of
point} with the **left arrow** and **right arrow** icons and then, to click on the graphic.

In order to **delete** (unselect) a control point, it is necessary to click on the same  graphic a second time.

---

The only **control point** used by the system is control point number **0** (the first one). This point defines which is the **virtual center of the graphic** and has many applications inside the language.

When **control point number 0** is not defined, the system
will work as if the graphic's virtual center was its **real center** (a point located at half the width and height of the graphic).

---

**Note:** Once the control points have been defined, for them to have effect in a
program, it is necessary to save the **archive MAP** or include the graphic again in the **file FPG** by dragging the former to the latter (depending on which one of both is loaded in the program).

## [1150] Videomodes

Constants: **m320x200** ... **m1024x768**

---

These constants are used to indicate the videomode in the set_mode() function. The whole list of constants is the following one:

    m320x200  
    m320x240  
    m320x400  
    m360x240  
    m360x360  
    m376x282  
    m640x400  
    m640x480  
    m800x600  
    m1024x768  

Each constant indicates the videomode in the following way: first,
the letter **m** and then, the horizontal and vertical resolution of the mode, separated by an **x**.

The values defined for these constants are the following ones.

    m320x200  = 320200  
    m320x240  = 320240  
    m320x400  = 320400  
    m360x240  = 360240  
    m360x360  = 360360  
    m376x282  = 376282  
    m640x400  = 640400  
    m640x480  = 640480  
    m800x600  = 800600  
    m1024x768 = 1024768  

---
See: Constants - set_mode()

## [1151] true

Constant: **true**

---

This constant is used to indicate **true** values, to initialize logical variables or
to define logical parameters. That is to say, it must be evaluated as a condition.

Its value is **1** and, as in the language all the **odd** numbers are interpreted as **true**, this constant will be evaluated as a condition that is always complied (**true**).

---

The false constant is opposite to this one, and it is used to indicate logical **false** values.

---
See: Constants - false

## [1152] false

Constant: **false**

---

This constant is used to indicate **false** values, to initialize logical variables or
to define logical parameters. That is to say, it must be evaluated as a condition.

Its value is **0** and, as in the language all the **even** numbers are interpreted as **false**, this constant will be evaluated as a condition that is never complied (**false**).

---

The true constant is opposite to this one, and it is used to indicate logical **true** values.

---
See: Constants - true

## [1153] s_kill

Constant: **s_kill**

---

This constant is used as a parameter of the signal() function (to send signals to the processes).
Its value is **0**.

This signal transmits the imperative order **kill**
to the processes. It is used to eliminate processes in the program
(to make certain objects of the game disappear).

That is to say, on sending a signal **s_kill** to a process, the latter will be eliminated and will not appear any longer in the following frames of the game.

The constant s_kill_tree is directly linked to this constant, with the proviso that, on sending this signal, the former will eliminate the indicated process and its **sons**, which are the processes created by it.

The whole list of the constants used as signals that can be sent to the different processes of a program is the following one:

    **s_kill**  
    s_wakeup  
    s_sleep  
    s_freeze  
    s_kill_tree  
    s_wakeup_tree  
    s_sleep_tree  
    s_freeze_tree  

---
See: Constants - signal() - s_kill_tree

## [1154] s_wakeup

Constant: **s_wakeup**

---

This constant is used as a parameter of the signal() function (to send signals to the processes).
Its value is **1**.

This signal transmits the imperative order **wakeup**
to the processes. It is used to restore the processes that have been made dormant (with the signal s_sleep), or frozen (with the signal s_freeze) to their normal state.

That is to say, on sending a signal **s_wakeup** to a process, the latter will be reactivated in the following frames of the game (it will be seen and processed again).

The constant s_wakeup_tree is directly linked to this constant, with the proviso that, on sending this signal, the former will wake up the indicated process and its **sons**, which are the processes created by it.

The whole list of the constants used as signals that can be sent to the different processes of a program is the following one:

s_kill  
    **s_wakeup**  
    s_sleep  
    s_freeze  
    s_kill_tree  
    s_wakeup_tree  
    s_sleep_tree  
    s_freeze_tree  

---
See: Constants - signal() - s_wakeup_tree

## [1155] s_sleep

Constant: **s_sleep**

---

This constant is used as a parameter of the signal() function (to send signals to the processes).
Its value is **2**.

This signal transmits the imperative order **sleep** to the processes. It is used to make a process dormant. An asleep process will not appear in the following frames of the game, but it won't be eliminated, as it happens with the signal s_kill. Indeed, this kind of process may **wake up** at any moment with a signal s_wakeup.

That is to say, on sending a signal **s_sleep ** to a process, the latter will not appear in the following frames of the game (until it is awaken or eliminated).

The constant s_sleep_tree is directly linked to this constant, with the proviso that, on sending this signal, the former will make dormant the indicated process and its **sons**, which are the processes created by it.

The whole list of the constants used as signals that can be sent to the different processes of a program is the following one:

    s_kill  
    s_wakeup  
    **s_sleep**  
    s_freeze  
    s_kill_tree  
    s_wakeup_tree  
    s_sleep_tree  
    s_freeze_tree  

---
See: Constants - signal() - s_sleep_tree

## [1156] s_freeze

Constant: **s_freeze**

---

This constant is used as a parameter of the signal() function (to send signals to the processes).
Its value is **3**.

This signal transmits the imperative order **freeze**
to the processes. It is used to freeze (immobilize) a process. A frozen process will continue to appear in the following frames of the game, but it won't be processed, so it will remain immobile. This process can be **reactivated** at any moment if a signal s_wakeup is sent to it.

That is to say, on sending a signal **s_freeze** to a process, the latter will stop processing (stop interpreting its statements) in the following frames of the game (until it is activated or eliminated with s_kill).

The constant s_freeze_tree is directly linked to this constant, with the proviso that, on sending this signal, the indicated process as well as its **sons** (which are the processes created by it) will be frozen.

The whole list of the constants used as signals that can be sent to the different processes of a program is the following one:

    s_kill  
    s_wakeup  
    s_sleep  
    **s_freeze**  
    s_kill_tree  
    s_wakeup_tree  
    s_sleep_tree  
    s_freeze_tree  

---
See: Constants - signal() - s_freeze_tree

## [1157] s_kill_tree

Constant: **s_kill_tree**

---

This constant is used as a parameter of the signal() function (to send signals to the processes).
Its value is **100**.

This signal is used to eliminate a process and all the process created by it, by sending the imperative order **kill** to them. This is a version of the signal s_kill, which eliminates a process, but not the processes that it had created.

That is to say, the signal **s_kill_tree** will eliminate the process and all its descendants. Thus, none of them will appear any longer in the following frames of the game.

The whole list of the constants used as signals that can be sent to the different processes of a program is the following one:

    s_kill  
    s_wakeup  
    s_sleep  
    s_freeze  
    **s_kill_tree**  
    s_wakeup_tree  
    s_sleep_tree  
    s_freeze_tree  

---
See: Constants - signal() - s_kill

## [1158] s_wakeup_tree

Constant: **s_wakeup_tree**

---

This constant is used as a parameter of the signal() function (to send signals to the processes).
Its value is **101**.

This signal is used to **wake up** a process and all the processes created by it, by sending the imperative order **wakeup** to them. This is a version of the signal s_wakeup, which wakes a process up, but not the processes that it had created.

That is to say, the signal **s_wakeup_tree** will **wake up** the process and all its descendants. Thus, all these processes will return to their normal state in the following frames of the game.

Processes that have been **made dormant** with the signal s_sleep_tree or **frozen** with the signal s_freeze_tree can be woken up (reactivated).

The whole list of the constants used as signals that can be sent to the different processes of a program is the following one:

    s_kill  
    s_wakeup  
    s_sleep  
    s_freeze  
    s_kill_tree  
    **s_wakeup_tree**  
    s_sleep_tree  
    s_freeze_tree  

---
See: Constants - signal() - s_wakeup

## [1159] s_sleep_tree

Constant: **s_sleep_tree**

---

This constant is used as a parameter of the signal() function (to send signals to the processes).
Its value is **102**.

This signal is used to **make** a process and all the processes created by it **dormant**, by sending the imperative order **sleep** to them. This is a version of the signal s_sleep, which makes a process dormant, but not the processes that it had created.

That is to say, the signal **s_sleep_tree** will make the process and all its descendants dormant. Thus, all these processes will disappear in the following frames of the game (but they won't be eliminated).

These **asleep** processes can be woken up (reactivated) with the signal s_wakeup_tree.

The whole list of the constants used as signals that can be sent to the different processes of a program is the following one:

    s_kill  
    s_wakeup  
    s_sleep  
    s_freeze  
    s_kill_tree  
    s_wakeup_tree  
    **s_sleep_tree**  
    s_freeze_tree  

---
See: Constants - signal() - s_sleep

## [1160] s_freeze_tree

Constant: **s_freeze_tree**

---

This constant is used as a parameter of the signal() function (to send signals to the processes).
Its value is **103**.

This signal is used to freeze (immobilize) a process and all the processes created by it, by sending the imperative order **freeze** to them. This is a version of the signal s_freeze, which freezes a process, but not the processes that it had created.

That is to say, the signal **s_freeze_tree** will **freeze** the process and all its descendants. Thus, all these processes will stop processing in the following frames of the game (they will remain immobile, as they won't execute their statements).

These **frozen** processes can be unfrozen (reactivated) with the signal s_wakeup_tree.
.
The whole list of the constants used as signals that can be sent to the different processes of a program is the following one:

    s_kill  
    s_wakeup  
    s_sleep  
    s_freeze  
    s_kill_tree  
    s_wakeup_tree  
    s_sleep_tree  
    **s_freeze_tree**  

---
See: Constants - signal() - s_freeze

## [1161] all_text

Constant: **all_text**

---

This constant is used as a parameter of the delete_text() function,
to delete **all** the texts displayed in the program with the write() and write_int() functions.

That is to say, the following statement must be executed in order to make disappear all the texts displayed on screen:

  **delete_text(all_text);**

The value assigned to this constant is **0**.

---
See: Constants - delete_text()

## [1162] all_sound

Constant: **all_sound**

---

This constant is used as a parameter of the stop_sound() function,
to stop **all** the sound effects previously activated with the sound() function.

That is to say, the following statement must be executed in order to stop all the sound channels, active at a specific moment:

  **stop_sound(all_sound);**

The value assigned to this constant is** -1**.

---
See: Constants - stop_sound() - sound()

## [1163] g_wide

Constant: **g_wide**

---

This constant is used as a parameter of the graphic_info() function,
to ask for information about the **width** (in pixels) of a specific graphic.
Its value is **0**.

The constants that can be used as parameter of this function are the following ones:

    **g_wide**  
    g_height  
    g_x_center  
    g_y_center  

---
See: Constants - graphic_info()

## [1164] g_height

Constant: **g_height**

---

This constant is used as a parameter of the graphic_info() function,
to ask for information about the **height ** (in pixels) of a specific graphic.
Its value is **1**.

The constants that can be used as parameter of this function are the following ones:

    g_wide  
    **g_height**  
    g_x_center  
    g_y_center  

---
See: Constants - graphic_info()

## [1165] g_x_center

Constant: **g_x_center**

---

This constant is used as a parameter of the graphic_info() function,
to ask for information about the **horizontal center** of a specific graphic.
Its value is **2**.

The **horizontal center** of a graphic will be half the width (in pixels),
if  control point number **0** (graphic center) has not been defined in the painting tool.

The constants that can be used as parameter of this function are the following ones:

    g_wide  
    g_height  
    **g_x_center**  
    g_y_center  

---
See: Constants - graphic_info()

## [1166] g_y_center

Constant: **g_y_center**

---

This constant is used as a parameter of the graphic_info() function,
to ask for information about the **vertical center** of a specific graphic.
Its value is **3**.

The **vertical center** of a graphic will be half the height (in pixels),
if the control point number **0** (graphic center) has not been defined in the painting tool.

The constants that can be used as parameter of this function are the following ones:

    g_wide  
    g_height  
    g_x_center  
    **g_y_center**  

---
See: Constants - graphic_info()

## [1167] c_screen

Constant: **c_screen**

---

This constant is used to be assigned to the predefined ctype local variable used to define the type of coordinates that a process will have. Its value is **0**.

**This is the value by default of** ctype, used for the coordinates of the graphic of the process to be interpreted as if they were referred to the screen. The (0,0) coordinate is the upper left corner.

There are other constants used for other systems of coordinates.
The whole list is the following one:

    **c_screen** - Screen coordinates  
    c_scroll - Scroll coordinates  
    c_m7     - Mode 7 coordinates  

---
See: Constants - ctype

## [1168] c_scroll

Constant: **c_scroll**

---

This constant is used to be assigned to the predefined ctype local variable used to define the type of coordinates that a process will have. Its value is **1**.

This is the value assigned to ctype, used for the coordinates of the graphic of the process to be interpreted as if they were referred to a scroll window, to coordinates with respect to the foreground's graphic.

For further information about the **scroll windows**, it is possible to access the start_scroll() function used to activate them.

There are other constants used for other systems of coordinates.
The whole list is the following one:

    c_screen - Screen coordinates  
    **c_scroll** - Scroll coordinates  
    c_m7     - Mode 7 coordinates  

---
See: Constants - ctype - start_scroll()

## [1169] c_m7

Constant: **c_m7**

---

This constant is used to be assigned to the predefined ctype local variable used to define the type of coordinates that a process will have. Its value is **2**.

This is the value assigned to ctype, used for the coordinates of the graphic of the process to be interpreted as if they were referred to a mode 7 window, three-dimensionally folded in that window.

For further information about the **mode 7 windows**, it is possible to access the start_mode7() function used to activate them.

There are other constants used for other systems of coordinates.
The whole list is the following one:

    c_screen - Screen coordinates  
    c_scroll - Scroll coordinates  
    **c_m7**     - Mode 7 coordinates  

---
See: Constants - ctype - start_mode7()

## [1170] partial_dump

Constant: **partial_dump**

---

This  constant is used to be assigned to the predefined
dump_type global variable used to define the type of dump that will be performed on screen. Its value is **0**.

The following statement is used:

  **dump_type=partial_dump;**

This statement indicates to the manager of processes of DIV Games that the following dumps must be **partial**.

**Dump** is the name given to the system of sending the game frames to the monitor (to the video memory of the graphics card).

There are two types of dumps:

**Partial**: Only the graphics that are updated and that have varied with regard to the previous frame will be dumped on screen. It is advisable to activate this dump in order **to gain speed** when programming a game (or a section of it) without a scroll or mode 7 window occupying the whole screen. That is to say, either when the game shows graphics movements against a fixed  background or when the active scroll or mode 7 windows are smaller that the screen.

**Complete**: All the screen will be dumped, irrespective of whether the graphics have changed or not. This is the dump by default and it is **slower that the partial dump**. However, the complete dump must be used when the game has a scroll or mode 7 window occupying the whole screen.

---

The other constant used to designate the type of dump is complete_dump which, unlike this one, defines a **complete** dump.

---
See: Constants - dump_type - complete_dump

## [1171] complete_dump

Constant: **complete_dump**

---

This  constant is used to be assigned to the predefined
dump_type global variable used to define the type of dump that will be performed on screen. Its value is **1**.

This is the **value by default** of the dump_type variable.
To establish this value, it is necessary to use the following statement:

  **dump_type=complete_dump;**

This statement indicates that the following dumps must be **complete** to the manager of processes of DIV Games.

**Dump** is the name given to the system of sending the game frames to the monitor (to the video memory of the graphics card).

There are two types of dumps:

**Partial**: Only the graphics that are updated and that have varied with regard to the previous frame will be dumped on screen. It is advisable to activate this dump in order **to gain speed** when programming a game (or a section of it) without a scroll or mode 7 window occupying the whole screen. That is to say, either when the game shows graphics movements on a fixed  background or when the active scroll or mode 7 windows are smaller that the screen.

**Complete**: All the screen will be dumped, irrespective of whether the graphics have changed or not. This is the dump by default and it is **slower that the partial dump**. However, the complete dump must be used when the game has a scroll or mode 7 window occupying the whole screen.

---

The other constant used to designate the type of dump is partial_dump which, unlike this one, defines a **partial** dump.

---
See: Constants - dump_type - partial_dump

## [1172] no_restore

Constant: **no_restore**

---

This constant is used to be assigned to the predefined restore_type global variable used to define the type of restoration that must be applied to the screen background after each game frame.
Its value is** -1**.

The name **background restoration** deals with the operation of restoring the screen areas in which graphics have been painted or texts have been written in the previous frame. That is to say, to delete both the painted graphics and the written texts.

The following statement must be used to establish this value:

  **restore_type=no_restore;**

This statement indicates to the manager of processes of DIV Games
Studio that, after the following game frames {it is not necessary
to restore the screen background}.

If the background is not restored,**speed will be gained** in the execution of the game (that will go faster in slow computers). But this mode of restoration (**no_restore**) can only be applied in games or in their sections in which **there is a scroll or mode 7 window occupying the whole screen**.

The three types of restoration that can be applied correspond with the following three constants:

**no_restore**       - The fastest; it doesn't restore the background  
partial_restore  - Average, partial restorations  
complete_restore - The slowest one, complete restoration  

---
See: Constants - restore_type

## [1173] partial_restore

Constant: **partial_restore**

---

This constant is used to be assigned to the predefined restore_type global variable used to define the type of restoration that must be applied to the screen background after each game frame.
Its value is** 0**.

The name **background restoration** deals with the operation of restoring the screen areas in which graphics have been painted or texts have been written in the previous frame. That is to say, to delete both the painted graphics and the written texts. 

The following statement must be used to establish this value:

  **restore_type=partial_restore;**

This statement indicates to the manager of processes of DIV Games
Studio that, after the following game frames **only the screen areas in which graphics have been painted or texts have been written must be restored**.

This mode of restoration (**partial_restore**) is faster than a complete restoration (option by default), but it must only be applied in games, or in their sections, in which **there ISN'T a scroll or mode 7 window occupying the whole screen**.

The three types of restoration that can be applied correspond with the following three constants:

no_restore       - The fastest; it doesn't restore the background  
**partial_restore**  - Average, partial restorations  
complete_restore - The slowest one, complete restoration  

---
See: Constants - restore_type

## [1174] complete_restore

Constant: **complete_restore**

---

This constant is used to be assigned to the predefined restore_type global variable used to define the type of restoration that must be applied to the screen background after each game frame.
Its value is** 1**.

The name **background restoration** deals with the operation of restoring the screen areas in which graphics have been painted or texts have been written in the previous frame. That is to say, to delete both the painted graphics and the written texts. 

**This is the value by default of the** restore_type **variable** and,
it is the **slowest** mode of the three available restoration modes.
The following statement must be used to establish this value:

  **restore_type=complete_restore;**

This statement indicates to the manager of processes of DIV Games
Studio that, after the following game's frames **the screen background must completely be restored**.

This mode of restoration (**complete_restore**) is the slowest one (and it is the option by default). Therefore, it can be changed by another one in order **to gain speed** in the execution of the game (so it will go faster in slow computers). 

As a matter of fact, this mode of restoration is only interesting for games (or for their sections) that **DON'T have** a scroll or mode 7 window occupying the whole screen, but that have a great number of graphics moving through the screen.

The three types of restoration that can be applied correspond with the following three constants:

no_restore       - The fastest; it doesn't restore the background  
partial_restore  - Average, partial restorations  
**complete_restore** - The slowest one, complete restoration  

---
See: Constants - restore_type

## [1175] Numbers of window

Constants: **c_0** ... **c_9**

---

These constants are used to be assigned to the predefined cnumber local variable that is used to define the scroll or mode 7 windows in which the graphic of a process must appear.

**This will only be necessary when several scroll or mode 7 windows have been activated, and it ISN'T aimed to display the graphic of the process in all of them.**

Up to 10 windows of these types may be defined, numbered from **0** to **9**, and that directly correspond with the constants
**c_0**, **c_1**, **c_2** ... **c_9**.

For the graphic of a process to appear in one of these windows only, the corresponding constant must be assigned to its cnumber local variable. For instance, if the aim was for the graphic of a process to appear only in (scroll or mode 7) window number 3, the following statement would be included in its code:

  **cnumber=c_3;**

If the aim for the graphic of a process is to appear in several of these windows, then the constants must be added.
For instance, for a process to appear in the windows 0, 4, and 5, the following assignment will be performed:

  **cnumber=c_0+c_4+c_5;**

For the graphic to appear in all the windows, suffice will be to assign **0** to the cnumber variable. It won't be necessary if this variable has not been modified, as it is its value by default.

The values equivalent to these constants correspond with the following powers of 2:

    **c_0** = 1   scroll / mode-7 number 0  
    **c_1** = 2   scroll / mode-7 number 1  
    **c_2** = 4   scroll / mode-7 number 2  
    **c_3** = 8   scroll / mode-7 number 3  
    **c_4** = 16  scroll / mode-7 number 4  
    **c_5** = 32  scroll / mode-7 number 5  
    **c_6** = 64  scroll / mode-7 number 6  
    **c_7** = 128 scroll / mode-7 number 7  
    **c_8** = 256 scroll / mode-7 number 8  
    **c_9** = 512 scroll / mode-7 number 9  

---
See: Constants - cnumber.

## [1176] Key codes

Constants: **Key codes**

---

These constants are normally used as a parameter of the key() function, to indicate which key is the one that the user wishes to know whether it is pressed.

It can also be used to compare the scan_code global variable, that contains the code of the last key that has been pressed, with these values.

The character **_** (underlining) followed by the name of the key, is normally used to designate each constant. For instance, for the [**A**] key, the constant referred to its code will be **_a**.

The whole list of these constants, with their respective values,
is as follows (according to the standard arrangement of the keyboard):

**_esc**         = 1   [ESC] or escape  
**_f1**          = 59  [F1] or function 1  
**_f2**          = 60  [F2] or function 2  
**_f3**          = 61  [F3] or function 3  
**_f4**          = 62  [F4] or function 4  
**_f5**          = 63  [F5] or function 5  
**_f6**          = 64  [F6] or function 6  
**_f7**          = 65  [F7] or function 7  
**_f8**          = 66  [F8] or function 8  
**_f9**          = 67  [F9] or function 9  
**_f10**         = 68  [F10] or function 10  
**_f11**         = 87  [F11] or function 11  
**_f12**         = 88  [F12] or function 12 (DEBUGGER)  
**_prn_scr**     = 55  [PRINT SCREEN]  
**_scroll_lock** = 70  [SCROLL LOCK]  

**_wave**        = 41  [º] or [ª] key  
**_1**           = 2   Number "1" key  
**_2**           = 3   Number "2" key  
**_3**           = 4   Number "3" key  
**_4**           = 5   Number "4" key  
**_5**           = 6   Number "5" key  
**_6**           = 7   Number "6" key  
**_7**           = 8   Number "7" key  
**_8**           = 9   Number "8" key  
**_9**           = 10  Number "9" key  
**_0**           = 11  Number "0" key  
**_minus**       = 12  Symbol "?" key  
**_plus**        = 13  Symbol "¿" key  

**_backspace**   = 14  Delete ( <- ) key  
**_tab**         = 15  Tabulator [TAB] key  
**_q**           = 16  Letter "Q" key  
**_w**           = 17  Letter "W" key  
**_e**           = 18  Letter "E" key  
**_r**           = 19  Letter "R" key  
**_t**           = 20  Letter "T" key  
**_y**           = 21  Letter "Y" key  
**_u**           = 22  Letter "U" key  
**_i**           = 23  Letter "I" key  
**_o**           = 24  Letter "O" key  
**_p**           = 25  Letter "P" key  
**_l_brachet**   = 26  Key [^] or [`]  
**_r_brachet**   = 27  Key [*] or [+]  
**_enter**       = 28  [ENTER] (Enter or Return)  

**_caps_lock**   = 58  [CAPS LOCK] or capitals lock  
**_a**           = 30  Letter "A" key  
**_s**           = 31  Letter "S" key  
**_d**           = 32  Letter "D" key  
**_f**           = 33  Letter "F" key  
**_g**           = 34  Letter "G" key  
**_h**           = 35  Letter "H" key  
**_j**           = 36  Letter "J" key  
**_k**           = 37  Letter "K" key  
**_l**           = 38  Letter "L" key  
**_semicolon**   = 39  Letter "Ñ" key  
**_apostrophe**  = 40  [{] key  
**_backslash**   = 43  [}] key  

**_l_shift**     = 42  [SHIFT] or left capitals  
**_z**           = 44   Letter "Z" key  
**_x**           = 45  Letter "X" key  
**_c**           = 46  Letter "C" key  
**_v**           = 47  Letter "V" key  
**_b**           = 48  Letter "B" key  
**_n**           = 49  Letter "N" key  
**_m**           = 50  Letter "M" key  
**_comma**       = 51  Key [;] or [,] key  
**_point**       = 51  [:] or [.] key  
**_slash**       = 51  [_] or [-] key  
**_r_shift**     = 54  [SHIFT] or right capitals  

**_control**     = 29  [CONTROL] keys  
**_alt**         = 56  [ALT] or [ALT GR] keys  
**_space**       = 57  [SPACE] or spacebar  

**_ins**         = 82  [INSERT]  
**_home**        = 71  [HOME]  
**_pgup**        = 73  [PGUP] or page up  
**_del**         = 83  [DEL] or delete  
**_end**         = 79  [END]  
**_pgdn**        = 81  [PGDN] or page down  

**_up**          = 72  Up cursor  
**_down**        = 80  Down cursor  
**_left**        = 75  Left cursor  
**_right**       = 77  Right cursor  

**_num_lock**    = 69  [NUM LOCK] or numeric lock  
**_c_backslash** = 53  Symbol [/] of the numeric keyboard  
**_c_asterisk**  = 55  Symbol [*] of the numeric keyboard  
**_c_minus**     = 74  Symbol [-] of the numeric keyboard  
**_c_home**      = 71  [HOME] of the numeric keyboard  
**_c_up**        = 72  Up cursor of the numeric keyboard  
**_c_pgup**      = 73  [PGUP] of the numeric keyboard  
**_c_left**      = 75  Left cursor of the numeric keyboard  
**_c_center**    = 76  [5] key of the numeric keyboard  
**_c_right**     = 77  Right cursor of the numeric keyboard  
**_c_end**       = 79  [END] of the numeric keyboard  
**_c_down**      = 80  Down cursor of the numeric keyboard  
**_c_pgdn**      = 81  [PG DN] of the numeric keyboard  
**_c_ins**       = 82  [INS] of the numeric keyboard  
**_c_del**       = 83  [DEL] of the numeric keyboard  
**_c_plus**      = 78  Symbol [+] of the numeric keyboard  
**_c_enter**     = 28  [ENTER] of the numeric keyboard  

It is indifferent to use these constants or the numeric values that they represent. That is to say, it is possible to call the key() function, to verify whether the [**A**] key is pressed, such as **key(_a)** or **key(30)** (in the previous list, it is possible to verify that **30** is the numeric value of the constant **_a**).

---

**Important:** Some of these codes can vary in certain keyboards. In case of doubt it is possible to execute the following sample program, that shows a table on screen, corresponding to the key() function (indicating the **codes of the keys that are pressed** at any moment), besides the values of the scan_code, ascii and shift_status variables (also related to the reading of the keyboard).

Sample program:
```div
PROGRAM example_codes_of_the_keyboard;

GLOBAL
    keys[128];

BEGIN
    write(0, 0, 0, 0, "Codes of the pressed keys, according to key()");
    FROM x=0 TO 127;
        write_int(0, (x%16)*20, (x/16)*10+20, 0, OFFSET keys[x]);
    END
    write(0, 0, 160, 0, "Code of the last key pressed (scan_code):");
    write_int(0, 320, 160, 2, OFFSET scan_code);
    write(0, 0, 180, 0, "Code ASCII of the last key (ascii):");
    write_int(0, 320, 180, 2, OFFSET ascii);
    write(0, 0, 190, 0, "State of the special keys (shift_status):");
    write_int(0, 320, 190, 2, OFFSET shift_status);
    LOOP
        FROM x=1 TO 127;
            IF (key(x))
                keys[x]=x;
            ELSE
                keys[x]=0;
            END
        END
        FRAME;
    END
END
```

This program may be used (by clicking on the text "**Sample program:**" with the mouse and then, by pressing the [**F10**] key) to find out the code that any specific key has.

This numeric code can later be used as a parameter of the key() function, to verify in the game whether this key is pressed at a specific moment.

---
See: Constants - key() - scan_code - ascii - shift_status

## [1177] min_int

Constant: **min_int**

---

This constant defines the minimum value that any datum can store in this language. This value is** -2147483648**.

All the data are 32 bit **integers** with sign in this language.
For that reason, only integers within the range
(** -2147483648** ...** +2147483647** ) may be used.

When the result of an arithmetic operation exceeds that range,
the system won't report any error. In order to avoid this situation, much care must be taken.

---
See: Constants - max_int

## [1178] max_int

Constant: **max_int**

---

This constant defines the maximum value that any datum can store in this language. This value is** 2147483647**.

All the data are 32 bit **integers** with sign in this language.
For that reason, only integers within the range
(** -2147483648** ...** +2147483647** ) may be used.

When the result of an arithmetic operation exceeds that range,
the system won't report any error. In order to avoid this situation, much care must be taken.

---
See: Constants - min_int

## [1179] pi

Constant: **pi**

---

This constant defines the equivalence in **degree thousandths** of the mathematical constant **pi** (approximately **3.14159265** radians).

Its value is **180000** degree thousandths (180 degrees), equivalent to
**pi radians**.

It is normally used to define angles. For instance, **180 degrees** could be defined as **pi**,** -90 degrees** as** -pi/2**,
**45 degrees** as **pi/4**, etc.

---
See: Constants - Use of angles in the language

## [1200] Predefined global data

Each of the predefined global data are now described.

STRUCT mouse     - Parameters of the mouse  
STRUCT scroll[9] - Control of the scroll windows  
STRUCT m7[9]     - Control of the mode 7 windows  
STRUCT joy       - Parameters of the joystick  
STRUCT setup     - Control of the sound card  
timer[9]         - Counters of time  
text_z           - Depth plane of the texts  
fading           - Indicator of screen fading  
shift_status     - State of the special keys  
ascii            - Reading of ASCII codes of the keyboard  
scan_code        - Reading of keyboard codes  
joy_filter       - Filter applied to the joystick  
joy_status       - State of the joystick  
restore_type     - Type of screen restoration  
dump_type        - Type of screen dump  
max_process_time - Maximum time of a process' execution  

---
See: Constants - Local data - Syntax

## [1201] Predefined local data

Each of the predefined local data are now described.

STRUCT reserved - Internal parameters of the processes  
father          - Identifier of the process' father  
son             - Identifier of the process' son  
smallbro        - Identifier of the process' younger brother  
bigbro          - Identifier of the process' elder brother  
priority        - Priority of the process' execution  
ctype           - Type of coordinates used by the process  
x               - Horizontal coordinate of the process  
y               - Vertical coordinate of the process  
z               - Depth plane of the process' graphic  
graph           - Code of the graphic assigned to the process  
flags           - Indicators of mirror and transparency  
size            - Size of the process' graphic  
angle           - angle of the process' graphic  
region          - Screen region assigned to the process  
file            - File code of the process' graphic  
xgraph          - OFFSET of the graphic table of the process  
height          - Height of the process in mode 7 windows  
cnumber         - Numbers of scroll or mode 7 windows  
resolution      - Resolution of the process' coordinates  

---
See: Constants - Global data - Syntax

## [1202] Constants predefined

Each of the predefined constants are now described.

m320x200 .. m1024x768 - Videomodes  
true                  - True value  
false                 - False values  
s_kill                - Signal to kill processes   
s_wakeup              - Signal to wake processes up  
s_sleep               - Signal to make processes dormant  
s_freeze              - Signal to freeze processes  
s_kill_tree           - Signal to kill processes and sons  
s_wakeup_tree         - Signal to wake processes and sons up  
s_sleep_tree          - Signal to make processes and sons dormant  
s_freeze_tree         - Signal to freeze processes and sons  
all_text              - Indicator of all the texts  
all_sound             - Indicator of all the sounds  
g_wide                - Indicator of width  
g_height              - Indicator of height  
g_x_center            - Indicator of horizontal center  
g_y_center            - Indicator of vertical center  
c_screen              - Screen coordinates  
c_scroll              - Scroll window coordinates  
c_m7                  - Mode7 window coordinates  
partial_dump          - Partial background dump  
complete_dump         - Complete background dump  
no_restore            - Diasbled screen restoration  
partial_restore       - Partial screen restoration  
complete_restore      - Complete screen restoration  
c_0 .. c_9            - Indicators of windows  
min_int               - Minimum value of data  
max_int               - Maximum values of data  
pi                    - Mathematical value of pi  

Key codes     - Keyboard codes  

---
See: Global data - Local data - Syntax

## [1249] Help about the programming language.

  Glossary of terms.  
  Syntax of a program.  
  Relation of statements.  
  List of functions.  

  Predefined constants.  
  Predefined global data.  
  Predefined local data.  

  Arithmetic expressions.  
  Logical conditions.  

  Keyboard codes.  


//HEAVILY modified from simple metronome example on ChucK programs site, original by Jascha Narveson (2007)

//Copyright (C) 2014 Matthew G. Harvell

//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files 
//(the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Impulse pulse => BiQuad filt => dac;
330 => filt.pfreq;
0.99 => filt.prad;

float bpm;
float lowBpm;
float highBpm;
float newBpm;
int tempLow;
int tempHigh;

1::second => dur beat;

MAUI_View view;
view.size(400,400); 

MAUI_Slider lowTempo;
lowTempo.range(30, 180);
lowTempo.size(400,60);
lowTempo.position(0,0);
lowTempo.displayFormat(lowTempo.integerFormat);
lowTempo.name("Low Tempo");
60 => lowTempo.value;
view.addElement(lowTempo);

MAUI_Slider highTempo;
highTempo.range(30, 180);
highTempo.size(400,60);
highTempo.position(0,70);
highTempo.displayFormat(highTempo.integerFormat);
highTempo.name("High Tempo");
60 => highTempo.value;
view.addElement(highTempo);


MAUI_LED redlight;
redlight.size(30,30);
redlight.position(170, 50);
redlight.color(redlight.red);
view.addElement(redlight); 

MAUI_LED greenlight;
greenlight.size(30,30);
greenlight.position(200, 50);
greenlight.color(greenlight.green);
view.addElement(greenlight); 

MAUI_Button eighths;
eighths.toggleType();
eighths.size(110,70);
eighths.position(145, 100);
eighths.name("eighths");
view.addElement(eighths);

MAUI_Button triplets;
triplets.toggleType();
triplets.size(110,70);
triplets.position(145, 150);
triplets.name("triplets");
view.addElement(triplets);

MAUI_Button sixteenths;
sixteenths.toggleType();
sixteenths.size(110,70);
sixteenths.position(145, 200);
sixteenths.name("sixteenths");
view.addElement(sixteenths);

MAUI_Button Next;
Next.pushType();
Next.size(110,70);
Next.position(145, 250);
Next.name("Next Tempo");
view.addElement(Next);

MAUI_Slider indicTempo;
indicTempo.range(30, 180);
indicTempo.size(400,60);
indicTempo.position(0,300);
indicTempo.displayFormat(indicTempo.integerFormat);
indicTempo.name("Current Tempo");
60 => indicTempo.value;
view.addElement(indicTempo);

view.display(); 


fun void controlNext() 
{
    while(true) {
        Next => now;
        lowTempo.value() => lowBpm;
        highTempo.value() => highBpm;
        lowBpm $ int => tempLow;
        highBpm $ int => tempHigh;
        <<< tempLow >>>;
        <<< tempHigh >>>;
        Math.random2(tempLow,tempHigh) => newBpm;
        <<< newBpm >>>;
        float fnewBpm;
        60.0/newBpm => fnewBpm;
        fnewBpm::second => beat;
        indicTempo.value(newBpm);
        50::ms => now;
    }
}

fun void flashRed()
{
    redlight.light();
    0.125::beat => now;
    redlight.unlight();
}

fun void flashGreen()
{
    greenlight.light();
    0.125::beat => now;
    greenlight.unlight();
}

fun void controlEighths()
{
    while (true)
    {
        eighths => now;
        if (eighths.state() != 0) 
        {triplets.state(0); sixteenths.state(0);}
    }
}

fun void controlTriplets()
{
    while (true)
    {
        triplets => now;
        if (triplets.state() != 0) 
        {eighths.state(0); sixteenths.state(0);}
    }
}

fun void controlSixteenths()
{
    while (true)
    {
        sixteenths => now;
        if (sixteenths.state() != 0) 
        {eighths.state(0); triplets.state(0);}
    }
} 

fun void pulsing()
{
    while (true)
    {
        if (sixteenths.state() != 0)
        {
            660 => filt.pfreq;
            1 => pulse.next;
            spork ~ flashRed();
            0.25::beat => now;
            0 => int i;
            do{
                330 => filt.pfreq;
                1 => pulse.next;
                spork ~ flashGreen();
                0.25::beat => now;
                i++;
            } until (i > 2);
        }  
        
        if (triplets.state() != 0)
        {
            660 => filt.pfreq;
            1 => pulse.next;
            spork ~ flashRed();
            0.334::beat => now;
            0 => int i;
            do{
                330 => filt.pfreq;
                1 => pulse.next;
                spork ~ flashGreen();
                0.333::beat => now;
                i++;
            } until (i > 1);
        }
        
        if (eighths.state() != 0)
        {
            660 => filt.pfreq;
            1 => pulse.next;
            spork ~ flashRed();
            0.5::beat => now;
            330 => filt.pfreq;
            1 => pulse.next;
            spork ~ flashGreen();
            0.5::beat => now;
        }
        
        if (eighths.state() == 0 && triplets.state() == 0 && sixteenths.state() == 0)
        {
            660 => filt.pfreq;
            1 => pulse.next;
            spork ~ flashRed();
            1::beat => now;
        }
    }
}


spork ~ controlNext();
spork ~ pulsing();
spork ~ controlEighths();
spork ~ controlTriplets();
spork ~ controlSixteenths(); 

while (true)
{
    1::second => now;
}
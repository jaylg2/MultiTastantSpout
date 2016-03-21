 
// Arduino Script for MultiTastant Spout
// -----------
// When combined with the Multi Tastant Spout Arduino shield, spout interface board, and spout
// assembly, and an analog input signal to cue trial type, this script can run a repeated trial
// combined approach/avoidance learning task designed for rodents. Designed for Arduino Uno. 
// ----------
// See construction and experimental information at http://github/nathanvc/MultiTastantSpout
// Nathan V-C
// 7/2014-7/2015, 11/2015, 3/2016
// -----------

//----------------
// trial types indicated with analog input on trial_type_pin, 
// ---------------
// Active trials: 
// ---------------
// 2-3.5 seconds of water + light cue, followed by 400-1000ms tone, followed by 1.5-3 s tastant delivery,
// lick must be detected within 1000ms for full trial, otherwise light turns off and enters new timeout period
// Light remains on for full trial. 
// Water only "easy" keeps light on 3.9-7.5 seconds and delivers water, but does not require lick within 1000ms 
// Not all analog values are in an intuitive order, for historical task design reasons
//----------------
// Trial Type               Voltage in  Arduino units   Range of units read
//-----------               ----------  -------------   -------------------
// water easy & no tone,    0.25v       51.1.3          25-75
// water & no tone,         0.5v        102.3           76-153
// tone A & tast 1          1v          204.6           154-234
// Tone C & tast 1          1.25v       255.75          235-276
// tone B & tast 2          1.5v        306.9           277-358 
// tone B & tast 1          2v          409.2           359-439
// Tone C & tast 2          2.25v       460.35          440-480
// tone A & tast 2          2.5v        511.5           481-562
// tone A & water           3v          613.8           563-644
// Tone C & water           3.25v       664.95          645-685
// Tone B & water           3.5v        716.1           686-756
// --------
// Passive trials
// --------
// Tone presented and tastant delivered, without light cue or requirement to lick quickly
// Catch trials are no tone and no tastant, but occur with same time features as usual tone trials 
// used to detect false positive rate
//--------
// Trial Type                       Voltage in  Arduino units   Range of units read
//-----------                       ----------  -------------   -------------------
// Tone C, no light, tast 1,        3.8v        777.48          757-797
// Tone A only, no light, tast 1,   4 v         818.4           798-838
// Tone B only, no light, tast 2,   4.2v        859.32          839-879
// Tone B only, no light, tast 1,   4.4v        900.24          880-920
// Tone A only, no light, tast 2,   4.6v        941.16          921-961
// Tone C, no light, tast 2,        4.8v        982.08          962-1002
//----------------
// Costa Trial
// ---------------
// An alternate task on the same set up. 
// Long single trial, modeled after Costa et al., 2006 task, where tastant is delivered for a long (45 min) block
// Here altered with a light cue as opposed to a shutter, and fluid delivered every 10 licks,
// In contrast to delivery at a standard sipper tube, flued runs through a fourth mixed "vac" valve to avoic
// contamination of pure tastant lines
// ----------------
// Trial Type               Voltage in  Arduino units   Range of units read
//-----------               ----------  -------------   -------------------
// Costa trial              4.95V       1013            1003+
//-----------
//***********
// NOTE: that there are alternate "PORT" commands to write directly to the pins that can replace "digitalwrite", here they are commented out. 
// This option can speed things up faster than using digitalwrite but not on a time scale that mattered for this prep, 
// and you have to make sure you get your pin mappings correct if you use these (these map to the pins set in the header). 
// but if you use the PORT commands, you need to change in each command directly
//-----------

// INITIALIZE PINS
// ---------------
// electrical lick sensor pin
int elick_pin=A5;

// pin to sense battery power
int batt_check_pin=A1;

// analog signal that indicats which trial type to run when a mouse initiates a trial
int trial_type_pin=A0;    

// unused pin for reading to reduce digital noise on last read pin
int dummy_pin = A4;       

// pins to trigger opening valves for tastants
int water_out = 6; 
int tast_out_a = 5; // default is sugar
int tast_out_b = 4; // default is quinine
int vac_out = 3;  // this is an optional vac line, or a line for delivering tastants for the costa task
int light_out = 11;  // pin for cue light, needs to be the same as led_c_pin
int del_lick_pin = 13;  // indicates licks where fluid was delivered (for data acquisition)

// indicator LEDs
int led_a_pin = 9;  // indicates tastant a (sugar) is available
int led_b_pin = 10; // indicates tastant b (quinine) is available
int led_c_pin = 11; // needs to be same as light_out, indicates fluid available (and also high when light in cage is on)
int led_d_pin = 12; // indicates detected licks

// button pin input, used for loading and calibrating lines
// button is only detected when there is no active run
int button_pin=17;  //This is A3 -- Analog pin being used as digital input, 
                    //Digital analog can be a problem near analog in, but button should never be active when running a session

// pin to report difficulty (licks skipped before next tastant delivery)
// this pin also conveys specific timing information per trial (trial start, and length of learning period on active trials)
int countlick_pin = 8;
int speak_pin = 2; // tone A pin, tone plays if pin is high
int speak_pin_2 = 7; // tone B pin, tone plays if pin is high
                     // Tone C is both tones simultaneously


// --------
// INITIALIZE VARIABLES, THRESHOLDS AND COUNTERS
// --------
// threshold of voltage change to detect a lick, 
// if your rig is noisy, may need to change to be higher, or use pure threshold not difference threshold
int elick_diff_thresh = 40; 
float rewardsize = 25; // time valve open for each reward in ms, on my rig this give about a 1 microliter delivery

// vaccuum and rinse control timing, not currently used, but there are functions here that can be used to rinse if you need it
int vacdelay = 300;   //
int vacduration = 200; //in ms
int rinsedelay = 450;
int rinseduration= 50;

int interval = 50; // interval for the pulses that indicate skiplick number (so skiplick is rounding to multiple of 50ms)
int pulseState = LOW; // variable that will be used to set the skiplick pin

// initialize variables for light cue and tastants
boolean light_arm = 0;
boolean lastlight_arm = 0;
boolean water_arm = 0;
boolean tast_a_arm = 0;
boolean lasttast_a_arm = 0; 
boolean tast_b_arm = 0;
boolean lasttast_b_arm = 0; 
boolean tast_c_arm = 0;
boolean lasttast_c_arm=0;
boolean deliver = 0;
boolean lasttone_b_arm = 0; 
boolean lasttone_a_arm = 0; 

// timing and button initialization
unsigned long currentms=0;
unsigned long lastms=0;
unsigned long last_off=0;
unsigned long last_lick=0;
unsigned long ButtonTime=0;
unsigned long lastButtonTime=0;
unsigned long lastlastButtonTime=0;
unsigned long tone_cue_time=0;
unsigned long checktm=0;
unsigned long last_reward_ind=0;

// more initialization...
int buttonState = 0;         // current state of the button
int lastButtonState = 0;     // previous state of the button
int buttonPushCounter = 0;   // count of button presses
int button_off = 0;          // time button turned off
int lick_break_time = 50;    // forced break between reward delivery, caps lick detection at 20Hz, which is double speed mice actually lick
long last_elick = -1;        // time of last lick
long last_rwd_time = 0;      // time of last delivered lick
int skiplicks = random(10,31);  // initialize skiplicks between 10 & 30 licks
int lickcounter = skiplicks-1;  // counter for how many licks since prior, setting as skiplicks-1 assures delivery on first lick
int count_pulse = 0;        // indicator for turning on/off difficulty signal (for data collection of skiplick variable for that trial)
int lickcount_trial = 0;    // counts licks during a trial
long timeout_retrig = 0;    // variable for time that a timeout restarts (i.e. tracks licks during timeouts)
int tone_ind = 0;           // indicator for type of tone to play on trial (1, 2, 3)
int tast_ind = 0;           // indicator for tastant to deliver on a trial (1 = sugar, 2= quinine)
int light_ind = 0;          // indicator for whether light turns on in a trial

// initialization for trial arming and calibration button
int trial_type=0;
boolean calibrate=0;
boolean button_valve=0;
boolean tone_a_arm=0;
boolean tone_b_arm=0;
boolean water_ind=0;
boolean easy_ind=0;  // determines if turn on the rapid shutoff for water only trials -- only used for shaping
boolean openvalves=0;
boolean closevalves=0;
boolean tonecal=0;
boolean trial_arm=0;
boolean info_arm=0;
boolean lasttrial_arm=0;
unsigned long lastrep=0;

// Variables for trial and timeout lengths in ms
boolean timeout=1; // start in a timeout
boolean lastto=1; // timeout on last loop through
int timeout_length=random(3000,6001);  // length of initial timeout, 3-6s
long start_tone_ms=0;
long switch_ms=0;
long end_trial_ms=0;
long trial_start_ms=0;

// SETUP
void setup() {                

  // initialize the digital pins as inputs and outputs as needed
  pinMode(water_out, OUTPUT);
  pinMode(tast_out_a, OUTPUT);
  pinMode(tast_out_b, OUTPUT);
  pinMode(light_out, OUTPUT);
  pinMode(vac_out, OUTPUT);
  pinMode(led_a_pin, OUTPUT);
  pinMode(led_b_pin, OUTPUT);
  pinMode(led_c_pin, OUTPUT);
  pinMode(led_d_pin, OUTPUT);
  pinMode(countlick_pin, OUTPUT);
  pinMode(del_lick_pin, OUTPUT);
  pinMode(speak_pin, OUTPUT);
  pinMode(speak_pin_2, OUTPUT);
  pinMode(button_pin, INPUT);
  
  analogReference(DEFAULT);

  // read in a new random seed
  randomSeed(10000*analogRead(A4));

  Serial.begin(9600); 
  digitalWrite(countlick_pin, LOW); 

  // during setup, check if the battery that drives the tones has low volgage (if it does, frequency changes)
  // read the voltage coming out of the voltage regulator that drives tones
  long battval = analogRead(batt_check_pin);
  
 //if not very close to 5V, then blink all lights. 
 // If all lights blink when turning on rig, turn off, change battery, and restart 
  if (battval < 1000) {
      for (int i=0; i <= 30; i++){
      all_light_on();
      delay(800);
      all_light_off();
      delay(200);
      }
    }
  }

//-----------
// START LOOP
//-----------  
void loop() {  
  lastms=currentms;
  lastto=timeout;
  currentms = millis();
  
  
  // read electrical lick signal
  long elick = analogRead(elick_pin);  
  // take a reading of the trial type indicator pin
  long reward_ind = analogRead(trial_type_pin);
  // you get weird noise, might need this to avoid noise in whatever was last pin read
  // long dummy_val = analogRead(dummy_pin);

  // check button if not actively running task, as soon as task stops, reset button counters and button arming
  // calibration for valves and tones only allowed when task not running
  if (reward_ind<20){
    if (last_reward_ind>20 && reward_ind < 20) {
          button_off=0;
          lastButtonState=LOW;
          buttonPushCounter=0;      
          button_valve=0;
          openvalves=0; 
          closevalves=0;
          calibrate=0;
          tonecal=0;   
    }
    check_button();
  }

  // RUN COSTA TASK IF ANALOG SIGNAL INDICATES
  //----------------- 
  // set up trial for costa type task (free fluid delivery every 10 licks for as long as signal indicates), no lick timeout
  // set this only when last reward ind was less than this value (almost certainly near zero) 
  if (reward_ind>1002 && last_reward_ind < 1002)  {
      timeout=0; // no timeout for costa task
      trial_type=19;  
      water_ind=0;
      tone_ind=0;
      tast_ind=3; //  3 is vac line (for costa task)
      easy_ind=1; // don't turn off ligh
      light_ind=1;
      if (lastto==1) {
          trial_start_ms=currentms;
          //end_trial_ms=start_tone_ms+30*60*1000; // 30 minute trial, make sure nidaq set to acquire for long enough
          switch_ms=trial_start_ms;
          start_tone_ms=trial_start_ms; //but no tone really plays
          skiplicks=10; // fxed reward delvery, not random  
      } 
      end_trial_ms=trial_start_ms+500; // set end trial 500ms in the future at each step that reward_ind is at right level
   }    
    
   // turn off the costa type task when trial indicator drops back to zero by setting end time t     
   if (reward_ind<1002 && last_reward_ind>1002) {
      trial_type=0;
      water_ind=0;
      tone_ind=0;
      tast_ind=0;
      easy_ind=0;
      light_ind=0;
      end_trial_ms=currentms;
   }

  // ------------
  // START DETECTION FOR REPEATED TRIAL STRUCTURE
  // ------------
  // If there is no lick & we are currently in timeout & there have been no licks during the timeout for longer than the current timeout length 
  // then we switch out of timeout and start a trial
      
  if (last_elick-elick<=elick_diff_thresh && timeout && currentms-timeout_retrig>timeout_length) {
    // turn off timeout indicator 
    timeout=0;
    
    // choose time lengths for the trial
    trial_start_ms=currentms;
    start_tone_ms=currentms+random(2000,3500);
    switch_ms=start_tone_ms+random(400,1000);
    end_trial_ms=switch_ms+random(1500,3000);

    // initialize lick count
    lickcount_trial=0;

    // water easy trial (doesn't require lick within one second)
    if (reward_ind>25 && reward_ind <=75) { 
      trial_type=8;
      water_ind=1;
      tone_ind=0;
      tast_ind=0;
      easy_ind=1;
      light_ind=1;
    }
    // water only trial
    else if (reward_ind>76 && reward_ind <=133) {
      trial_type=1;
      water_ind=1;
      tone_ind=0;
      tast_ind=0;
      easy_ind=0;
      light_ind=1;
    }
    // Active, Tone A, taste 1
    else if (reward_ind>173 && reward_ind <=235)  {
      trial_type=2;
      water_ind=1;
      tone_ind=1;
      tast_ind=1;
      easy_ind=0;
      light_ind=1;
    }
    // Active, Tone C, taste 1
    else if (reward_ind>235 && reward_ind <=276)  {
      trial_type=13;
      water_ind=1;
      tone_ind=3;
      tast_ind=1;
      easy_ind=0;
      light_ind=1;
    }
    // Active, Tone B, taste 2
    else if (reward_ind>276 && reward_ind <=358)  {
      trial_type=3;
      water_ind=1;
      tone_ind=2;
      tast_ind=2;
      easy_ind=0;
      light_ind=1;
    }
    // Active, Tone B, taste 1
    else if (reward_ind>358 && reward_ind <=440)  {
      trial_type=4;
      water_ind=1;
      tone_ind=2;
      tast_ind=1;
      easy_ind=0;
      light_ind=1;
    }
    // Active, Tone C, taste 2
    else if (reward_ind>440 && reward_ind <=480)  {
      trial_type=14;
      water_ind=1;
      tone_ind=3;
      tast_ind=2;
      easy_ind=0;
      light_ind=1;
    }
    // Active, Tone A, taste 2
    else if (reward_ind>480 && reward_ind <=562)  {
      trial_type=5;
      water_ind=1;
      tone_ind=1;
      tast_ind=2;
      easy_ind=0;
      light_ind=1;
    }
    // Active, Tone A, Water
    else if (reward_ind>562 && reward_ind <=645)  {
      trial_type=6;
      water_ind=1;
      tone_ind=1;
      tast_ind=0;
      easy_ind=0;
      light_ind=1;
    }
    // Active, Tone C, Water
    else if (reward_ind>645 && reward_ind <=685)  {
      trial_type=15;
      water_ind=1;
      tone_ind=3;
      tast_ind=0;
      easy_ind=0;
      light_ind=1;
    }
    // Active, Tone 2, Water
    else if (reward_ind>685 && reward_ind <=757)  {
      trial_type=7;  
      water_ind=1;
      tone_ind=2;
      tast_ind=0;
      easy_ind=0;
    }
    // Passive, tone C, taste 1
    else if (reward_ind>757 && reward_ind <=797)  {
      trial_type=16;  
      water_ind=0;
      tone_ind=3;
      tast_ind=1;
      easy_ind=1;
      light_ind=0;
    }
    // Passive, tone A, taste 1
    else if (reward_ind>797 && reward_ind <=838)  {
      trial_type=9;  
      water_ind=0;
      tone_ind=1;
      tast_ind=1;
      easy_ind=1;
      light_ind=0;
    }
    // Passive, tone B, taste 2
    else if (reward_ind>838 && reward_ind <=879)  {
      trial_type=10;  
      water_ind=0;
      tone_ind=2;
      tast_ind=2;
      easy_ind=1;
      light_ind=0;
    }
    // Passive, tone B, taste 1
    else if (reward_ind>879 && reward_ind <=920)  {
      trial_type=11;  
      water_ind=0;
      tone_ind=2;
      tast_ind=1;
      easy_ind=1;
      light_ind=0;
    }
    // Passive, tone A, taste 2
    else if (reward_ind>920 && reward_ind <=961)  {
      trial_type=12;  
      water_ind=0;
      tone_ind=1;
      tast_ind=2;
      easy_ind=1;
      light_ind=0;
    }
    // Passive, tone C, taste 2
    else if (reward_ind>961 && reward_ind <=1002)  {
      trial_type=17;  
      water_ind=0;
      tone_ind=3;
      tast_ind=2;
      easy_ind=1;
      light_ind=0;
    }
    // Passive, Blank trial
    else if (reward_ind>133 && reward_ind <=173)  {
      trial_type=18;  
      water_ind=0;
      tone_ind=0;
      tast_ind=0;
      easy_ind=1;
      light_ind=0;
    }     
    else {
      trial_type=0;
      water_ind=0;
      tone_ind=0;
      tast_ind=0;
      easy_ind=0;
      light_ind=0;
    }
    
    // reset time windows for passive trials (2-3.5 secs of tone + tastant)
    // if a tone only trial (easy & no water), make trial end after initial 2-3.5 seconds by redefining end time
    // set tone to start at beginning
    if (!water_ind && easy_ind){
      end_trial_ms=start_tone_ms;
      start_tone_ms=trial_start_ms;
      switch_ms=start_tone_ms;
    }
  }

  //---------------
  // If not in a timeout, need start trial and set what is and isn't armed
  //---------------
  
  if (!timeout) {

    // at start (when lastto=1) all arming values are false
    // if JUST left a timeout then trial_arm turns on
    if (lastto && trial_type>0) {
      trial_arm=true;
    }

    // If light for trial is indicated, then light is on, if not, light stays set to false
    if (light_ind && lastto) {
       light_arm=true;
    }
    // if active trial with water start, turn on water
    if (water_ind && lastto) {
       water_arm=true;
    }
    
    // if animal has not licked within the first 1000 ms then go back to timeout and turn off all arming values 
    // (but don't do this if in the easy water trial or a passive trial)
    if (currentms>trial_start_ms+1000 && lickcount_trial==0 && !easy_ind) {
      timeout=1;
      timeout_retrig=currentms;
      trial_arm=false;
      //info_arm=false;
      light_arm=false;
      water_arm=false;
      tone_a_arm=false;
      tone_b_arm=false;
      tast_a_arm=false; 
      tast_b_arm=false;
      tast_c_arm=false;
      // choose time for length of the next timeout
      timeout_length=random(3000,6001);
    }

    // once time moves past start_tone_ms turn on the appropriate tone arming 
    // (the other tone will remain at false, and neither is set if tone_ind==0)
    // for passive trials this starts right at beginning
    if (currentms>=start_tone_ms && lastms<start_tone_ms && currentms<end_trial_ms) {
      if (tone_ind==1) {
        tone_a_arm=true;
      }
      else if (tone_ind==2) {
        tone_b_arm=true;
      }
      else if (tone_ind==3) {
        tone_a_arm=true;
        tone_b_arm=true;
      }
    }

    // once time moves past switch ms, turn on appropriate fluid 
    // (if switching from water, also need to turn on water, if just keeping water, don't need to switch anything)
    // for passive trials this is right at beginning, turn off water arming after you switch
    if (currentms>=switch_ms && lastms<switch_ms && currentms<end_trial_ms) {  
      if (tast_ind==1) {
        tast_a_arm=true;
        water_arm=false;
      }
      else if (tast_ind==2) {
        tast_b_arm=true;
        water_arm=false;
      }
     else if (tast_ind==3) {
        tast_c_arm=true;
        water_arm=false;
      }
    }

    // after end of trial reset all amring to false, turn timeout back on, and choose new timeout length
    if (currentms>=end_trial_ms && lastms<end_trial_ms){
      timeout=1;
      timeout_retrig=currentms;
      trial_arm=false;
      light_arm=false;
      water_arm=false;
      tone_a_arm=false;
      tone_b_arm=false;
      tast_a_arm=false;
      tast_b_arm=false;
      tast_c_arm=false;
      // choose time for length of the next timeout
      timeout_length=random(3000,6001);
    }
  }

  //------------------
  // Now set lights and other things based on what is armed
  //------------------

  // turn on the indicator light for mouse (indicating tastant available)  
  // turn on indicator light on box that fluid is available (this replaces water-indicator light in prior version to save a pin)
  if (light_arm && !lastlight_arm) {
    digitalWrite(light_out,HIGH);
    //PORTB |= _BV(PORTB3);  //PB3=pin 11 
  }
  else if (!light_arm && lastlight_arm) {
    digitalWrite(light_out,LOW);
    //PORTB &= ~_BV(PORTB3);  //PB3=pin 11 
  }

  // turn on the indicator light for tastant a available -- only turn on after the actual switch -- will be after tone turns on
  if (tast_a_arm && !lasttast_a_arm) {
    digitalWrite(led_a_pin,HIGH); 
    //PORTB |= _BV(PORTB1);  //PB1=pin 9 
  }
  else if (!tast_a_arm && lasttast_a_arm) {
    digitalWrite(led_a_pin,LOW);
    //PORTB &= ~_BV(PORTB1);  //PB1=pin 9 
  }

  // turn on the indicator light for tastant b available -- only turn on after the actual switch -- will be after the tone turns on
  if (tast_b_arm && !lasttast_b_arm) { 
    digitalWrite(led_b_pin,HIGH); 
    //PORTB |= _BV(PORTB2);  //PB2 = pin 10 
  }
  else if (!tast_b_arm && lasttast_b_arm){
    digitalWrite(led_b_pin,LOW);
    //PORTB &= ~_BV(PORTB2);  //PB2 = pin 10 
  }
  
  // turn on/off tone a  
  if (tone_a_arm && !lasttone_a_arm) { 
    digitalWrite(speak_pin, HIGH);
    //PORTD |= _BV(PORTD2);  //PD2 = pin 2  
  }
  else if (!tone_a_arm && lasttone_a_arm) {
    digitalWrite(speak_pin, LOW);
    //PORTD &= ~_BV(PORTD2);  //PD2 = pin 2 
  }

  // turn on/off tone b 
  if (tone_b_arm && !lasttone_b_arm) { 
    digitalWrite(speak_pin_2, HIGH);
    //PORTD |= _BV(PORTD7);  //PD7 = pin 7  
  }
  else if (!tone_b_arm && lasttone_b_arm) {
    digitalWrite(speak_pin_2, LOW);
    //PORTD &= ~_BV(PORTD7);  //PD7 = pin 7 
  }

  // set difficulty indicator and info pin -- turns on after trial for 50ms * skiplick, turns on for 200 ms at trial start
  // turns on between tone and tastant during active task
  //-----------------
  // at trial start, turn on info pin
  if (trial_arm && !lasttrial_arm) {  
    digitalWrite(countlick_pin, HIGH);
    //PORTB |= _BV(PORTB0);  //PB0 = pin 8  
  }
  // set info pin low 200 ms after trial start
  else if (currentms-trial_start_ms>=200 && lastms-trial_start_ms<200 && trial_arm) {
    digitalWrite(countlick_pin, LOW); 
    //PORTB &= ~_BV(PORTB0);  //PB0 = pin 8 
  }
  // at tone start, turn on info pin high active trials
  //if (((tone_a_arm && !lasttone_a_arm) || (tone_b_arm && !lasttone_b_arm)) && !easy_ind) {
  else if (currentms>=start_tone_ms && lastms<start_tone_ms && !easy_ind && trial_arm) {  
    digitalWrite(countlick_pin, LOW); 
    //PORTB |= _BV(PORTB0);  //PB0 = pin 8  
  }
  // at valve swtich turn info pin low active trials anly
  //if (((tast_a_arm && !lasttast_a_arm) || (tast_b_arm && !lasttast_b_arm)) && !easy_ind)  {
  else if (currentms>=switch_ms && lastms<switch_ms && !easy_ind && trial_arm) {   
    digitalWrite(countlick_pin, LOW); 
    //PORTB &= ~_BV(PORTB0);  //PB0 = pin 8 
  }
  // when trial end re-choose lick difficulty & set trial type back to no trial, set indicator for difficulty
  else if (!trial_arm && lasttrial_arm) {  
    digitalWrite(countlick_pin, HIGH);
    //PORTB |= _BV(PORTB0);  //PB0 = pin 8  
    last_off=currentms;
    trial_type=0;
    count_pulse=1;
  }
  // turn off difficulty indicator after 50*skiplicks, and pick difficulty for next trial
  else if (currentms-last_off>50*skiplicks && count_pulse==1) {
    digitalWrite(countlick_pin, LOW); 
    //PORTB &= ~_BV(PORTB0);  //PB0 = pin 8 
    count_pulse=0;
    skiplicks=random(10,31);
  }
  
  // Set indicator to run the pulse to indicate skiplicks, initiate first pulse that indicates skiplick
  // when light turns on start running the indication of skiplick difficulty  
  if (light_arm && !lastlight_arm ) { 
    // set to deliver immediately on first lick at start 
    lickcounter=skiplicks-1; 
  }

  if (tast_a_arm && !lasttast_a_arm ) { 
    // set to deliver immediately on first lick when tastant switches
    lickcounter=skiplicks-1; 
  }

  if (tast_b_arm && !lasttast_b_arm ) { 
    // set to deliver immediately on first lick when tastant switches
    lickcounter=skiplicks-1; 
  }

  // set information on last trial
  lasttrial_arm=trial_arm;
  lastlight_arm=light_arm; 
  lasttast_a_arm=tast_a_arm;
  lasttast_b_arm=tast_b_arm;
  lasttast_c_arm=tast_c_arm;
  lasttone_a_arm=tone_a_arm;
  lasttone_b_arm=tone_b_arm;
 

  //------
  // If a lick is detected and we are in a timeout, then reset the counter for the timeout 
  //------

  if (last_elick-elick>elick_diff_thresh && currentms-last_lick>lick_break_time && timeout && !button_valve) { 
    timeout_retrig=currentms;
    last_lick=currentms;
    digitalWrite(led_d_pin,HIGH);
    //PORTB |= _BV(PORTB4);  //PD4 = pin 12  
    noreward();
    digitalWrite(led_d_pin,LOW);
    //PORTB &= ~_BV(PORTB4);  //PB4 = pin 12 
  }

  if (last_elick-elick>elick_diff_thresh && !timeout) {
    // only deliver if less than lick_break_time ms from last reward delivery (so as not to retrigger on same lick)
    // also require lick counter to equal skiplicks -- skips skiplicks number of licks between deliveries
    if (currentms-last_lick>lick_break_time & !button_valve){
      deliver = 1;
      lickcounter=lickcounter+1;
      lickcount_trial=lickcount_trial+1;
      digitalWrite(led_d_pin,HIGH);
      //PORTB |= _BV(PORTB4);  //PD4 = pin 12  
      last_lick=currentms;
    }
    else {
      deliver=0;
    }

    // set deliver back to zero if we haven't already skipped the necessary licks before next delivery
    // if equal to skiplicks, keep deliver at 1 but set lickcounter back to zero and start over 
    if (lickcounter==skiplicks){
      lickcounter=0;
    }
    else {
      deliver=0;
    }

    // Deliver the correct fluid
    if (deliver && water_arm){  
      reward_water();
    } 

    else if (deliver && tast_a_arm){  
      reward_tast_a();
    } 

    else if (deliver && tast_b_arm){  
      reward_tast_b();
    } 
    
    // runs fluid through vaccuum line
    else if (deliver && tast_c_arm){  
      reward_tast_c();
    } 

    else {
      noreward();
    }

    // turn off lick light  
    digitalWrite(led_d_pin,LOW);   
    //PORTB &= ~_BV(PORTB4);  //PB4 = pin 12 
    
    last_rwd_time=currentms;
  } 
  
  last_elick=elick;
  last_reward_ind=reward_ind;
}

//----------------
// Button control to open & close all valves 
// (one push to open, one push to close) and to do calibration openings (3 rapid pushes) 
// and play test tones (press and hold)
//----------------

void check_button() {
  // read the pushbutton input pin:
  buttonState = digitalRead(button_pin);
  
  // compare the buttonState to its previous state
  if (buttonState != lastButtonState) {
    
    // if the state has changed HIGH TO LOW, increment the counter
    if (buttonState == LOW) {
      button_off=1;
    }
    
    // if the state has changed LOW TO HIGH, increment the counter
    if (buttonState == HIGH) {

      buttonPushCounter++;
      ButtonTime=currentms;
      button_valve=1;
      button_off=0;
      
      // if first in series after a prior action, set time after which to take action 
      // (500ms -- so valve will open/close with single button press with a 500ms delay, to allow time for setting a calibration)
      if (buttonPushCounter==1) {
        checktm=currentms+500;
      }    
      

      // if odd button press set to open 
       if (buttonPushCounter % 2 == 1) {
          openvalves=1;
          closevalves=0;
          calibrate=0;
          tonecal=0;
        }
      
      // if even button press set to close
       else if (buttonPushCounter % 2 == 0) {  
          openvalves=0;
          closevalves=1;
          calibrate=0;
          tonecal=0;
        }

      // if three button presses really fast, then calibrate (overwrites a prior open/close)
      //if (ButtonTime-lastButtonTime<300 && buttonPushCounter == 2) {
      if (ButtonTime-lastlastButtonTime<400 && buttonPushCounter > 2) {  
          openvalves=0;
          closevalves=0;
          calibrate=1;
          tonecal=0;
      }
      
    }
    lastButtonState=buttonState;  
    lastButtonTime=ButtonTime;
    lastlastButtonTime=lastButtonTime;
  }
  
  if (buttonState == HIGH && button_off == 0 && currentms-ButtonTime>450) {
    openvalves=0;
    closevalves=0;
    calibrate=0;
    tonecal=1;
  }
    
  if (button_valve && currentms>checktm) {    

      // if pushcounter is odd, open all valves and turn on lick light
      if (openvalves) {
        open_all();
        openvalves=0;
      }
      
      if (closevalves) {
        close_all();
        button_valve=0;
        // reset count after button close  
        buttonPushCounter=0;
        closevalves=0;
      }

      //If two button presses really fast, then calibrate (1000 25 ms openings on all fluid valves) 
      if (calibrate) {
        for (int i=0; i <= 1000; i++){
          open_all();
          delay(25);
          close_all();
          delay(100);
        } 
        digitalWrite(led_d_pin,LOW);
        calibrate=0;
        button_valve=0;
        buttonPushCounter=0;
      }
      
      if (tonecal) {
        for (int i=0; i<=1; i++){
          digitalWrite(led_a_pin,HIGH);
          digitalWrite(speak_pin, HIGH);
          delay(3000);
          digitalWrite(led_a_pin,LOW);
          digitalWrite(speak_pin, LOW);    
          delay(500);
          digitalWrite(led_b_pin,HIGH);
          digitalWrite(speak_pin_2, HIGH);
          delay(3000);
          digitalWrite(led_b_pin,LOW);
          digitalWrite(speak_pin_2, LOW);
          delay(500);
        }
        tonecal=0;
        button_valve=0;
        buttonPushCounter=0;
      }
  }
}

//----------------
// LOWER LEVEL OPEN/CLOSING COMMANDS
//----------------

void reward_water() {
  digitalWrite(water_out,HIGH);
  //PORTD |= _BV(PORTD6);  //PD6 = pin 6  
  digitalWrite(del_lick_pin,HIGH);
  //PORTB |= _BV(PORTB5);  //PB5 = pin 13  
  delay(rewardsize); 
  digitalWrite(water_out,LOW);
  //PORTD &= ~_BV(PORTD6);  //PD6 = pin 6 
  digitalWrite(del_lick_pin,LOW);
  //PORTB &= ~_BV(PORTB5);  //PB5 = pin 13 
}

void reward_tast_a() {
  digitalWrite(tast_out_a,HIGH);
  //PORTD |= _BV(PORTD5);  //PD5 = pin 5  
  digitalWrite(del_lick_pin,HIGH);
  //PORTB |= _BV(PORTB5);  //PB5 = pin 13  
  delay(rewardsize);
  digitalWrite(tast_out_a,LOW);
  //PORTD &= ~_BV(PORTD5);  //PD5 = pin 5 
  digitalWrite(del_lick_pin,LOW);
  //PORTB &= ~_BV(PORTB5);  //PB5 = pin 13 
}

void reward_tast_b() {
  digitalWrite(tast_out_b,HIGH);
  //PORTD |= _BV(PORTD4);  //PD4 = pin 4  
  digitalWrite(del_lick_pin,HIGH);
  //PORTB |= _BV(PORTB5);  //PB5 = pin 13  
  delay(rewardsize);
  digitalWrite(tast_out_b,LOW);
  //PORTD &= ~_BV(PORTD4);  //PD4 = pin 4 
  digitalWrite(del_lick_pin,LOW);
  //PORTB &= ~_BV(PORTB5);  //PB5 = pin 13 
}

// Run fluid for tastant through the vac line (for costa task)
void reward_tast_c() {
  digitalWrite(vac_out,HIGH);
  //PORTD |= _BV(PORTD3);  //PD3 = pin 3
  digitalWrite(del_lick_pin,HIGH);
  //PORTB |= _BV(PORTB5);  //PB5 = pin 13  
  delay(rewardsize);
  digitalWrite(vac_out,LOW);
  //PORTD &= ~_BV(PORTD3);  //PD3 = pin 3 
  digitalWrite(del_lick_pin,LOW);
  //PORTB &= ~_BV(PORTB5);  //PB5 = pin 13 
}

void run_vac(){
  digitalWrite(vac_out,HIGH);
  //PORTD |= _BV(PORTD3);  //PD3 = pin 3
  delay(vacduration);
  digitalWrite(vac_out,LOW);
  //PORTD &= ~_BV(PORTD3);  //PD3 = pin 3
}

void noreward() {
  delay(rewardsize); 
}

void open_all() {
  digitalWrite(led_d_pin,HIGH);
  //PORTB |= _BV(PORTB4);  //PB4 = pin 12  
  digitalWrite(tast_out_a,HIGH);
  //PORTD |= _BV(PORTD5);  //PD5 = pin 5
  digitalWrite(tast_out_b,HIGH);
  //PORTD |= _BV(PORTD4);  //PD4 = pin 4
  digitalWrite(water_out,HIGH);
  //PORTD |= _BV(PORTD6);  //PD6 = pin 6
  digitalWrite(vac_out,HIGH);
  //PORTD |= _BV(PORTD3);  //PD3 = pin 3
}

void close_all() {
  digitalWrite(led_d_pin,LOW);
  //PORTB &= ~_BV(PORTB4);  //PB4 = pin 12 
  digitalWrite(tast_out_a,LOW);
  //PORTD &= ~_BV(PORTD5);  //PD5 = pin 5
  digitalWrite(tast_out_b,LOW);
  //PORTD &= ~_BV(PORTD4);  //PD4 = pin 4 
  digitalWrite(water_out,LOW);
  //PORTD &= ~_BV(PORTD6);  //PD6 = pin 6
  digitalWrite(vac_out,LOW);
  //PORTD &= ~_BV(PORTD3);  //PD3 = pin 3
}  

void run_rinse(){
  digitalWrite(vac_out,HIGH);
  digitalWrite(water_out,HIGH);
  delay(rinseduration);
  digitalWrite(water_out,LOW);
  delay(rinsedelay);
  digitalWrite(vac_out,LOW);
}

void all_light_on() {
  digitalWrite(led_a_pin,HIGH);
  digitalWrite(led_b_pin,HIGH);
  digitalWrite(led_c_pin,HIGH);
  digitalWrite(led_d_pin,HIGH);
}

void all_light_off() {
  digitalWrite(led_a_pin,LOW);
  digitalWrite(led_b_pin,LOW);
  digitalWrite(led_c_pin,LOW);
  digitalWrite(led_d_pin,LOW);
}

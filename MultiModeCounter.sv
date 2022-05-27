module MultiModeCounter(ctr_if.dut abc);
  
  // ----------------------- PARAMETERS --------------------------------
  parameter COUNTER_SIZE = 4;  
  parameter GAME_SIZE = 4;  
  
  // ------------------------  VARIABLE DECLARATIONS -------------------
  bit [COUNTER_SIZE-1 :0] counter;          			// original counter
  bit [GAME_SIZE-1 :0] countWinners;				 	// counts number of winners (1's)
  bit [GAME_SIZE-1 :0] countLosers; 				 	// counts number of losers (0's)
  bit WINNER;											// raised when counter = all 1's
  bit LOSER;											// raised when counter = all 0's
  
  // ------------------------  RESET FUNCTION------ --------------------
  function void Reset();
    counter = 0;
    countWinners = 0;
    countLosers = 0;
    WINNER = 0;
    LOSER = 0;
    abc.GAMEOVER <= 0;
    abc.WHO <= 2'b00;
    endfunction
  
   // INITIAL RESET
    initial Reset();
    
  // ------------------------- START OF CLOCK CYCLE ----------------------
  always@(posedge abc.clk)
    begin
      

      // ------------- SYNCHRONOUS RESET (active low)  ----------------------
      // ------------- RESET SYNCHRONOUSLY EVERY GAMEOVER  ------------------
      if ( (abc.resetLow == 1'b0) || (abc.GAMEOVER == 1'b1) )
        begin
          Reset();
        end 

      //------ @ INIT HIGH parallely load the initialValue in the counter ----
      else if (abc.INIT == 1'b1)
        begin
          counter = abc.initialValue;
        end
            
      // ------------------------  MAIN BODY  ------------------------------
      else
        begin  

          // --------- RESET EACH TIME A WIN/LOSE CONDITION OCCURS  --------------
          if (WINNER || LOSER)
            begin
              WINNER = 0;	// CAN BE HIGH FOR ONE CYCLE ONLY
              LOSER = 0;	// CAN BE HIGH FOR ONE CYCLE ONLY
          end          
          
          // controlValue determines counter mode
          case(abc.controlValue)
            2'b00: counter = counter + 1;
            2'b01: counter = counter + 2;
            2'b10: counter = counter - 1;
            2'b11: counter = counter - 2;
          endcase

      // ------------------------ WINNER OR LOSER?  -------------------------

          // check for winners ( all 1's set)
          if (counter == '1)
            begin
              // set winner signal 
              countWinners = countWinners +1;
              WINNER = 1;
            end

          // check for losers ( all 1's set)
          else if (counter == 0)
            begin
              // set loser signal
              countLosers = countLosers +1;
              LOSER = 1;
            end
      // ------------------------ GAMEOVER  ---------------------------

          // GAMEOVER DUE TO WINNERS
          if (countWinners == '1)
            begin
              abc.GAMEOVER <= 1;
              //Game is over because WINNER got to 15 first
              abc.WHO <= 2'b10;
            end 

           // GAMEOVER DUE TO LOSERS
           else if (countLosers == '1)
            begin
              abc.GAMEOVER <= 1;
              //Game is over because LOSER got to 15 first
              abc.WHO <= 2'b01; 
            end         
        end // end of "else"    
      
    end // end of "always"
    
endmodule 


  // --------------------------------------------------------------------
  // ------------------------- TOP	-------------------------------------
  // --------------------------------------------------------------------
    
module top(output logic clk);
  
  // --------------------------- CLOCK ------------------------------
  initial clk = 0;
  initial forever #5 clk=~clk;
  
  // --------------------------- CONNECTION -------------------------
  ctr_if i1(clk);
  MultiModeCounter c1(i1.dut);
  TestBench test(i1.tb);
  
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars;
  end
endmodule


  // --------------------------------------------------------------------
  // ------------------------- INTERFACE---------------------------------
  // --------------------------------------------------------------------

interface ctr_if(input logic clk);
  // ----------------------- PARAMETERS ------------------------------
  parameter COUNTER_SIZE = 4;  
  parameter GAME_SIZE = 4;   
  
  // ------------------------- INPUTS IN DESIGN -------------------------
  logic [1:0] controlValue = 0;
  logic [COUNTER_SIZE-1 :0] initialValue = 0; // initialValue is loaded into the counter 
  logic INIT= 0, resetLow = 0;
  
  // -------------------------- OUTPUTS IN DESIGN -----------------------
  logic GAMEOVER = 0;
  logic [1:0] WHO = 2'b00;   
   
  // -------------------------- CLOCKING SYNCH --------------------------
  clocking cb @(posedge clk);
    //default input #1ns;// output #1ns;
    output resetLow, controlValue, initialValue, INIT;
    input  GAMEOVER, WHO;
  endclocking
    
  // ----------------------------- PORTING ------------------------------

  modport dut(input clk, resetLow, controlValue, initialValue, INIT
             ,output  GAMEOVER, WHO);

  // -------------------------- SYNCHRONOUS TB PORTING ------------------
  modport tb(clocking cb);
  
endinterface 
   
    
    
program TestBench(ctr_if.tb xyz);    
  // -------------------------- CONCURRENT ASSERTIONS ------------------
  
    // WHO SHOULD NEVER BE 2'b11
  	property WHO_PROP;
      @(xyz.cb)
       xyz.cb.WHO !== 2'b11;
    endproperty  
  
    // GAMEOVER RAISED IMPLIES THAT SOMEONE WON THE GAME (WHO IS RAISED)
    // WHO & GAMEOVER RAISED IN THE SAME CYCLE (1 CYCLE ONLY)
    property GAMEOVER_PROP;
      @(xyz.cb)
      xyz.cb.GAMEOVER |-> xyz.cb.WHO;
    endproperty
  
    // AS LONG AS WHO IS 0 THEN GAME CANT BE OVER
    property NOT_GAMEOVER_PROP;
        @(xyz.cb)
        !xyz.cb.WHO |-> !xyz.cb.GAMEOVER;
      endproperty

    A1: assert property (WHO_PROP)
      else $error("WHO ASSERTION ERROR");
  
    A2: assert property (GAMEOVER_PROP)
      else $error("GAMEOVER ASSERTION ERROR");
      
    A3: assert property (NOT_GAMEOVER_PROP)
      else $error("NOT GAMEOVER ASSERTION ERROR");
  // -------------------------- TESTING ------------------
    
  initial begin    
    xyz.cb.INIT<= 0;
    xyz.cb.resetLow<= 0;
    xyz.cb.controlValue <= 0; 

    // ------------------ First test case scenario counter up by 1 ----------------
    
    @ xyz.cb  
    xyz.cb.resetLow<= 1;
    
    // ------------------ Second test case scenario counter up by 2 ----------------
    #2600			
    xyz.cb.controlValue<= 1; //@955  
    xyz.cb.INIT<= 1;
    xyz.cb.initialValue<= 10;
    
    // CLEAR ON NEXT EDGE
    @ xyz.cb  
	xyz.cb.INIT<= 0;
    xyz.cb.initialValue<= 0;

    
    // ------------------ Third test case scenario counter down by 1 ----------------
    #1200
     xyz.cb.controlValue<= 2;

    #100
    // RESET IN THE MIDDLE AND INIT
    xyz.cb.resetLow<= 0;
    xyz.cb.INIT<= 1;
    xyz.cb.initialValue<= 2;

    @ xyz.cb  
    xyz.cb.resetLow<= 1;
    xyz.cb.INIT<=0;    
    xyz.cb.initialValue<= 0;
    
    // ------------------ Forth test case scenario counter down by 2 ----------------
    #3000
    xyz.cb.controlValue<= 3; 
    
	#1500
    xyz.cb.controlValue<= 0;

  end
    
endprogram

    
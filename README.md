# MultiMode-Counter

## Contents

1. Project Brief
2. Code Explanation
4. Design Choice
5. Test Bench Scenarios


## 1. Project Brief:

### Multi-mode counter that can count up, down, by ones and by twos. There is a two-bit control

### bus input indicating which one of the four modes are active.

### There’s an Initial value input and a control signal called INIT. When INIT is logic 1, the initial

### value will be parallelly loaded into the multi-mode counter.

### Whenever the count is equal to all zeros, a signal called LOSER is high.

### When the count is all ones, a signal called WINNER is high.

### In either case, the signal will remain high for only one cycle.

### When the number of times WINNER and LOSER goes high 15 times an output called GAMEOVER

### will be set high.

### If the game is over because WINNER got to 15 first, WHO is set to 2’b10, and if LOSER got to 15

### first then WHO is set to 2’b01. WHO starts at 2’b00 and returns to it after each game over.

### All the counters are synchronously cleared and then the game starts over.

### Using the following:

### 1. An interface with the appropriate set of modports, and clocking blocks.

### 2. A testbench (implemented as a program not a module).

### 3. A top module.

### 4. Assertions to ensure that some illegal scenarios can’t be generated.

## 2. Code Explanation:


## 2.1 Design

First, we begin with defining the parameters then by declaring all the variables that will be used inside
the module, and a function for Reset, (Interface is used for input and output signals)
![image](https://user-images.githubusercontent.com/68311964/170764553-e934d7f4-8d26-451f-ae2f-c24d862755d5.png)

2 - Inside the always block which is triggered by positive edge of the clock performs the following actions:
![image](https://user-images.githubusercontent.com/68311964/170764577-3dfd5e31-38f8-459a-859c-4047f628d391.png)

1. Check reset (active low), if triggered reset all flags and counters. (Synchronous Reset)
2. Check the INIT control signal, if high load the initial value in the multi-mode counter.
3. Check if GAMEOVER is high, if high then reset the game.

3 - Else it performs the main body of the operations

1. If WINNER or LOSER signals are high, reset both signals.


2. Check control value to specify which mode to use to perform the count operation.
3. If the counter is equal to all 1’s, then increment the “winnerCounter” and raise the WINNER flag.
    - If the counter is equal to all 0’s, then increment the “loserCounter” and raise the LOSER
       flag.
    - If “winnerCounter” or “loserCounter” reaches 15, then raise the “GAMEOVER” signal
       and specify which counter using the “WHO” signal.
![image](https://user-images.githubusercontent.com/68311964/170764620-be2d5a02-1d2c-46c3-878d-63a5b45b5b60.png)

## 2.2 TOP Module
![image](https://user-images.githubusercontent.com/68311964/170764645-c55341fe-031f-425b-9203-e5797a669991.png)


## 2.3 Interface Module
![image](https://user-images.githubusercontent.com/68311964/170764700-22b47879-ec24-4b52-a9ca-9c73c50476b9.png)

## 2.4 Testbench Program
![image](https://user-images.githubusercontent.com/68311964/170764754-48538dc0-9cd3-40e3-8144-4fc61ed602e3.png)



## 3. Design Choice:

The clock is used in the design to trigger the always block which contains the main body of the code
including the count operation.
Counter counts based on a positive edge of an input signal which is the “clk” signal (clock).
“resetLow” is an input signal which is used to reset the game at any time, so the user can reset the game
at any time. The reset being synchronous or asynchronous won’t matter much in this design, here it is
synchronous.

## 4. Test Bench Scenarios

- Counter Up by 1 (NO INIT)
- Counter Up by 2 (INIT)
- Counter down by 1 (Reset in the middle & INIT signal raised high)
- Counter down by 2 (Reset in the middle & NO INIT)

**4.1. Counter Up by 1 (INIT)**

Counter starts counting from 0 by 1
![image](https://user-images.githubusercontent.com/68311964/170764818-a5780c36-6c7d-4cab-a214-04a7be6885ac.png)

GAMEOVER since the “counterWinners” reached 15 (0xF), so the WINNER, GAMEOVER, WHO signals are
raised for one cycle, WHO is set to 0b10 (0x02) since “counterWinners” reached 15 first.

GAMEOVER (reset all the counters and signals).
![image](https://user-images.githubusercontent.com/68311964/170764830-d2dd410c-8dd9-4398-b265-d96eb9cfdf13.png)


**4. 2. Counter Up by 2 (INIT)**

“controlValue” is set to 1 which indicates the second mode (Counter Up By 2) so at the next positive
edge of the clock cycle the counter starts incrementing by 2 and initial value is loaded since INIT is
logically high.
![image](https://user-images.githubusercontent.com/68311964/170764865-303437ee-148d-4ec4-91b9-8649a9afdd4f.png)

GAMEOVER since the “counterLosers” reached 15 (0xF), so the WINNER, GAMEOVER, WHO signals are
raised for one cycle, WHO is set to 0b0 1 (0x0 1 ) since “counterLosers” reached 15 first.

GAMEOVER (reset all the counters and signals).
![image](https://user-images.githubusercontent.com/68311964/170764887-6dece6fe-0382-41e8-8b6d-3cd3564c2897.png)


**4.3. Counter Down by 1 (Reset in the middle & INIT)**

“controlValue” is set to 2 which indicates the third mode (counter down by 1) so at the next positive
edge of the clock cycle the counter starts decrementing by 1.
![image](https://user-images.githubusercontent.com/68311964/170764934-d1ff2f76-b642-49a9-9c27-de325be62f92.png)

@3925 ns “resetLow” is set to low (active low reset) so the game is reset and starts on the 3rd mode
since “controlValue” is set to 2 and initial value is loaded since INIT is logically high.
![image](https://user-images.githubusercontent.com/68311964/170764954-3fd6aec9-5bbc-4d32-bfc9-eaf055a0f929.png)

GAMEOVER since the “counterWinners” reached 15 (0xF), so the WINNER, GAMEOVER, WHO signals are
raised for one cycle, WHO is set to 0b10 (0x02) since “counterWinners” reached 15 first.

GAMEOVER (reset all the counters and signals).
![image](https://user-images.githubusercontent.com/68311964/170764980-e18230b0-c090-4af9-80b7-3a0b745ab7dd.png)


**4. 4. Counter Down by 2**

@ 2450 ns “controlValue” is set to 3 which indicates the fourth mode (counter down by 2 ) so at the next
positive edge of the clock cycle the counter starts decrementing by 2.
![image](https://user-images.githubusercontent.com/68311964/170765009-fac02e10-bd21-414a-a042-bb9f345d9b27.png)

GAMEOVER since the “counterLosers” reached 15 (0xF), so the LOSER, GAMEOVER, WHO signals are
raised for one cycle, WHO is set to 0b 01 (0x0 1 ) since “counterLosers” reached 15 first.

GAMEOVER (reset all the counters and signals).
![image](https://user-images.githubusercontent.com/68311964/170765031-746404f4-4468-45a1-8fe8-c9f9bf5a0508.png)



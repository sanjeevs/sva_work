# sva_work
Playing around with system verilog assertions.

Interesting examples of System Verilog assertion. Writing SVA for either simulation or formal verification is an art. So
decided to collect some examples of it.

## count_in_sva
A request comes in with a count 'n'. The DUT responds with 'n' wide pulse of grant. I could not figure out how to count in sva? Tried local variables, generate but nothing really worked.
![Example Waveform](https://github.com/sanjeevs/sva_work/blob/master/count_in_sva/wavedrom.png)

## deadlock
Detect deadlock in state machine by writing a negative assertion. If the error condition happens then the implication fires and it fails. However the problem is that fv tool will create a coverage on the antecedent. This will
never fire which might be a problem for fv reporting.

## non_consec_match
Check the [=m:n] and [->m:n] operator with different behavior of the qualifying expression.

## boolean 
Check the and/or sequence operator. Does *and* sequence need to start at the same time? This means that start checking
together and finish at the longest sequence match. For or finish at the shortest match.

The more useful is the intersec that allows us to define a window in which to check for a sequence. like `true[*1:4] means a window upto 4 clocks.

## bus_stable
This is cannonical example of $past used to verify that the bus is stable. It also saves us from $fell.  Also use throught to check the time window that the grant must be asserted in.
Another classic is that request must be asserted till grant is asserted.

## intersect
Errata in Ashok Mehta book on page 136.

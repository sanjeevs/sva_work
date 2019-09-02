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

# sva_work
Playing around with system verilog assertions.

Interesting examples of System Verilog assertion. Writing SVA for either simulation or formal verification is an art. So
decided to collect some examples of it.

## count_in_sva
A request comes in with a count 'n'. The DUT responds with 'n' wide pulse of grant. I could not figure out how to count in sva? Tried local variables, generate but nothing really worked.
![Example Waveform](file://count_in_sva/wavedrom.png)

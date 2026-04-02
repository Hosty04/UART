UART - Pouze vybrane casti





\# =================================================

\# Nexys A7-50T - General Constraints File

\# Based on https://github.com/Digilent/digilent-xdc

\# =================================================



\# -----------------------------------------------

\# Clock

\# -----------------------------------------------

**set\_property -dict { PACKAGE\_PIN E3 IOSTANDARD LVCMOS33 } \[get\_ports {clk}];**

**create\_clock -add -name sys\_clk\_pin -period 10.00 -waveform {0 5} \[get\_ports {clk}];**



\# -----------------------------------------------

\# Switches

\# -----------------------------------------------

**set\_property -dict { PACKAGE\_PIN J15 IOSTANDARD LVCMOS33 } \[get\_ports {sw\[0]}];**

**set\_property -dict { PACKAGE\_PIN L16 IOSTANDARD LVCMOS33 } \[get\_ports {sw\[1]}];**

**set\_property -dict { PACKAGE\_PIN M13 IOSTANDARD LVCMOS33 } \[get\_ports {sw\[2]}];**

**set\_property -dict { PACKAGE\_PIN R15 IOSTANDARD LVCMOS33 } \[get\_ports {sw\[3]}];**

**set\_property -dict { PACKAGE\_PIN R17 IOSTANDARD LVCMOS33 } \[get\_ports {sw\[4]}];**

**set\_property -dict { PACKAGE\_PIN T18 IOSTANDARD LVCMOS33 } \[get\_ports {sw\[5]}];**

**set\_property -dict { PACKAGE\_PIN U18 IOSTANDARD LVCMOS33 } \[get\_ports {sw\[6]}];**



\# -----------------------------------------------

\# Seven-segment cathodes CA..CG + DP (active-low)

\# seg\[6]=A ... seg\[0]=G

\# -----------------------------------------------


**set\_property PACKAGE\_PIN L18 \[get\_ports {seg\[0]}]; # CG**

**set\_property PACKAGE\_PIN H15 \[get\_ports {dp}];**

**set\_property IOSTANDARD LVCMOS33 \[get\_ports {seg\[\*] dp}]**



\# -----------------------------------------------

\# Seven-segment anodes AN7..AN0 (active-low)

\# -----------------------------------------------

**set\_property PACKAGE\_PIN J17 \[get\_ports {an\[0]}];**

**set\_property PACKAGE\_PIN J18 \[get\_ports {an\[1]}];**

**set\_property IOSTANDARD LVCMOS33 \[get\_ports {an\[\*]}]**




\# -----------------------------------------------

\# USB-RS232 Interface

\# -----------------------------------------------

**set\_property -dict { PACKAGE\_PIN C4 IOSTANDARD LVCMOS33 } \[get\_ports {uart\_txd\_in}];**

**set\_property -dict { PACKAGE\_PIN D4 IOSTANDARD LVCMOS33 } \[get\_ports {uart\_rxd\_out}];**

**set\_property -dict { PACKAGE\_PIN D3 IOSTANDARD LVCMOS33 } \[get\_ports {uart\_cts}];**

**set\_property -dict { PACKAGE\_PIN E5 IOSTANDARD LVCMOS33 } \[get\_ports {uart\_rts}];**



\# -----------------------------------------------

\# (Remaining peripherals preserved but omitted here for brevity)

\# JB, JC, JD, XADC, VGA, SD, Ethernet, Audio, etc.

\# Same conversion style applies:

\#

\# # set\_property PACKAGE\_PIN <PIN> \[get\_ports {<signal>}]

\# # set\_property IOSTANDARD LVCMOS33 \[get\_ports {...}]

\#

\# -----------------------------------------------


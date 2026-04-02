# =================================================

# Nexys A7-50T - General Constraints File

# Based on https://github.com/Digilent/digilent-xdc

# =================================================

# -----------------------------------------------

# Clock

# -----------------------------------------------

set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports {clk}];

create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

# -----------------------------------------------

# Switches

# -----------------------------------------------

set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports {sw[0]}];

set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports {sw[1]}];

set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports {sw[2]}];

set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports {sw[3]}];

set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports {sw[4]}];

set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports {sw[5]}];

set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports {sw[6]}];

# -----------------------------------------------

# Seven-segment cathodes CA..CG + DP (active-low)

# seg[6]=A ... seg[0]=G

# -----------------------------------------------

set_property PACKAGE_PIN L18 [get_ports {seg[0]}]; # CG

set_property PACKAGE_PIN H15 [get_ports {dp}];

set_property IOSTANDARD LVCMOS33 [get_ports {seg[*] dp}]

# -----------------------------------------------

# Seven-segment anodes AN7..AN0 (active-low)

# -----------------------------------------------

set_property PACKAGE_PIN J17 [get_ports {an[0]}];

set_property PACKAGE_PIN J18 [get_ports {an[1]}];

set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]

# -----------------------------------------------

# USB-RS232 Interface

# -----------------------------------------------

set_property -dict { PACKAGE_PIN C4 IOSTANDARD LVCMOS33 } [get_ports {uart_txd_in}];

set_property -dict { PACKAGE_PIN D4 IOSTANDARD LVCMOS33 } [get_ports {uart_rxd_out}];

set_property -dict { PACKAGE_PIN D3 IOSTANDARD LVCMOS33 } [get_ports {uart_cts}];

set_property -dict { PACKAGE_PIN E5 IOSTANDARD LVCMOS33 } [get_ports {uart_rts}];

# -----------------------------------------------

# (Remaining peripherals preserved but omitted here for brevity)

# JB, JC, JD, XADC, VGA, SD, Ethernet, Audio, etc.

# Same conversion style applies:

#

# # set_property PACKAGE_PIN [get_ports {}]

# # set_property IOSTANDARD LVCMOS33 [get_ports {...}]

#

# -----------------------------------------------
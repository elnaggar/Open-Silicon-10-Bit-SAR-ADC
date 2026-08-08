# Timing constraints for sar_logic_diff -- Chipathon 2026 (gf180mcu, hardened macro)
# Clock period: 40 ns (25 MHz) -- set via CLOCK_PERIOD in config.yaml.
# Used for both PnR (PNR_SDC_FILE) and signoff STA (SIGNOFF_SDC_FILE).
# NOTE: OpenSTA has no 'remove_from_collection'; use lsearch/lreplace instead.

set clk_name   clk
set clk_port   [get_ports clk]
set clk_period $::env(CLOCK_PERIOD)

# Primary clock
create_clock -name $clk_name -period $clk_period $clk_port

# All inputs except the clock (OpenSTA-compatible: no remove_from_collection)
set clk_indx [lsearch [all_inputs] [get_port $clk_name]]
set in_ports [lreplace [all_inputs] $clk_indx $clk_indx]

# External I/O timing budget = 20% of the clock period (macro-level assumption).
# Scales automatically with CLOCK_PERIOD.
set io_delay [expr {$clk_period * 0.20}]
set_input_delay  $io_delay -clock $clk_name $in_ports
set_output_delay $io_delay -clock $clk_name [all_outputs]

# Clock non-idealities.
# Uncertainty is a FIXED value, not a % of period: real clock jitter/skew does
# not scale with the period, so a percentage overstates it at slow clocks.
# 0.5 ns is a reasonable margin at this node; raise if the top-level clock
# distribution is known to be noisier.
set_clock_uncertainty 0.5  [get_clocks $clk_name]
set_clock_transition  0.15 [get_clocks $clk_name]

# Realistic drive on inputs / load on outputs so the resizer sizes buffers
# sensibly. buf_4 (not the minimum buf_1) reflects that real upstream logic
# will drive these ports -- assuming buf_1 inflates input-net transitions and
# makes the resizer's job harder at the input boundary.
set_driving_cell -lib_cell gf180mcu_fd_sc_mcu7t5v0__buf_4 -pin Z $in_ports
set_load 0.05 [all_outputs]

# Design rule limits -> force buffering of high-fanout nets.
# max_fanout matches MAX_FANOUT_CONSTRAINT in config.yaml (keep both at 6 so
# synthesis, PnR, and signoff enforce the SAME limit).
set_max_fanout     6  [current_design]
set_max_transition 3.0 [current_design]

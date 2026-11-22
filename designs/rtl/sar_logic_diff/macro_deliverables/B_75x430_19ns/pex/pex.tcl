gds read /foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff/macro_deliverables/B_75x430_19ns/gds/sar_logic_diff.gds
load sar_logic_diff
select top cell
extract do local
extract do coupling
extract all
ext2spice lvs
ext2spice cthresh 0
ext2spice format ngspice
ext2spice -o sar_logic_diff.pex.spice
quit -noprompt

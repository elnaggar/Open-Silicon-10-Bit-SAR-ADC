v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -250 10 -250 60 {lab=clk}
N -250 120 -250 160 {lab=0}
N -450 30 -450 70 {lab=0}
N -450 -30 -390 -30 {lab=vinp}
N -360 -10 -360 80 {lab=vinn}
N -360 140 -360 160 {lab=0}
N -390 -30 -150 -30 {lab=vinp}
N -360 -10 -150 -10 {lab=vinn}
N -250 10 -150 10 {lab=clk}
N 310 10 310 60 {lab=comp_decision}
N 310 120 310 140 {lab=0}
N 210 30 210 60 {lab=comp_decision_b}
N 210 120 210 140 {lab=0}
N 150 30 210 30 {lab=comp_decision_b}
N 150 10 310 10 {lab=comp_decision}
N 480 90 480 150 {lab=0}
N 480 -30 480 30 {lab=#net1}
N 150 -30 480 -30 {lab=#net1}
N 150 -10 430 -10 {lab=0}
N 430 -10 430 0 {lab=0}
C {vsource.sym} -250 90 0 0 {name=VCLK value="PULSE(0 3.3 20n 100p 100p 50n 100n)" savecurrent=false}
C {gnd.sym} -250 160 0 0 {name=l3 lab=0}
C {vsource.sym} -450 0 0 0 {name=VINP value=1.4992676 savecurrent=false}
C {gnd.sym} -450 70 0 0 {name=l4 lab=0}
C {vsource.sym} -360 110 0 0 {name=VINN value=1.5007324 savecurrent=false}
C {gnd.sym} -360 160 0 0 {name=l5 lab=0}
C {lab_wire.sym} -340 -30 0 0 {name=p1 sig_type=std_logic lab=vinp}
C {lab_wire.sym} -260 -10 0 0 {name=p2 sig_type=std_logic lab=vinn}
C {lab_wire.sym} -250 30 0 0 {name=p3 sig_type=std_logic lab=clk}
C {capa.sym} 310 90 0 0 {name=COUTP
m=1
value=5f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 310 140 0 0 {name=l6 lab=0}
C {capa.sym} 210 90 0 0 {name=COUTN
m=1
value=5f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 210 140 0 0 {name=l7 lab=0}
C {lab_wire.sym} 310 10 2 0 {name=p9 sig_type=std_logic lab=comp_decision}
C {lab_wire.sym} 210 30 2 0 {name=p10 sig_type=std_logic lab=comp_decision_b}
C {vsource.sym} 480 60 0 0 {name=VDD value=3.3 savecurrent=false}
C {gnd.sym} 480 150 0 0 {name=l1 lab=0}
C {gnd.sym} 430 0 0 0 {name=l2 lab=0}
C {code_shown.sym} -480 -940 0 0 {name=MODELS
only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
"}
C {code_shown.sym} -490 -740 0 0 {name=NGSPICE
only_toplevel=true
value="
.control
save all
tran 1p 200n
let input_diff = v(vinp) - v(vinn)
let latchdiff = v(comp_decision) - v(comp_decision_b)
plot v(clk) v(vinp) v(vinn)
plot v(comp_decision) v(comp_decision_b)
plot input_diff latchdiff
wrdata /foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/libs/tb_analog/tb_comp/comp_latch_test_neg.txt v(clk) v(vinp) v(vinn) input_diff v(comp_decision) v(comp_decision_b) latchdiff

.endc
"}
C {Open-Silicon-10-Bit-SAR-ADC/designs/libs/core_analog/comp_tot.sym} 0 0 0 0 {name=x1}

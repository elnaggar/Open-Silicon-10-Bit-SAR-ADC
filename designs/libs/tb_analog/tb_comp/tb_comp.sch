v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 480 -500 580 -500 {lab=vdd}
N 1920 -370 1920 -310 {lab=0}
N 480 -440 480 -360 {lab=0}
N 110 -460 110 -410 {lab=clk}
N 110 -460 180 -460 {lab=clk}
N 110 -350 110 -310 {lab=0}
N -30 -500 180 -500 {lab=vinp}
N -90 -440 -90 -400 {lab=0}
N -90 -500 -30 -500 {lab=vinp}
N 0 -480 0 -390 {lab=vinn}
N 0 -480 180 -480 {lab=vinn}
N 0 -330 0 -310 {lab=0}
N 580 -500 670 -500 {lab=vdd}
N 480 -480 610 -480 {lab=raw_voutp}
N 1860 -140 1860 -90 {lab=comp_decision}
N 1860 -30 1860 -10 {lab=0}
N 480 -460 530 -460 {lab=raw_voutn}
N 1760 -120 1760 -90 {lab=comp_decision_b}
N 1760 -30 1760 -10 {lab=0}
N 670 -500 830 -500 {lab=vdd}
N 1920 -490 1920 -430 {lab=vdd}
N 1120 -500 1410 -500 {lab=vdd}
N 1830 -360 1880 -360 {lab=buf_voutp}
N 1410 -500 1550 -500 {lab=vdd}
N 1290 -480 1550 -480 {lab=vdd}
N 480 -360 480 -240 {lab=0}
N 610 -480 640 -480 {lab=raw_voutp}
N 830 -500 1120 -500 {lab=vdd}
N 530 -460 570 -460 {lab=raw_voutn}
N 570 -460 570 -370 {lab=raw_voutn}
N 1190 -330 1250 -330 {lab=buf_voutn}
N 640 -480 960 -480 {lab=raw_voutp}
N 1020 -480 1020 -460 {lab=vdd}
N 630 -260 810 -260 {lab=0}
N 480 -260 630 -260 {lab=0}
N 1250 -330 1280 -330 {lab=buf_voutn}
N 1280 -330 1280 -270 {lab=buf_voutn}
N 1020 -480 1290 -480 {lab=vdd}
N 810 -260 870 -260 {lab=0}
N 870 -330 870 -260 {lab=0}
N 870 -460 870 -370 {lab=vdd}
N 870 -460 1020 -460 {lab=vdd}
N 870 -350 890 -350 {lab=#net1}
N 1190 -310 1190 -260 {lab=0}
N 870 -260 1190 -260 {lab=0}
N 1190 -480 1190 -350 {lab=vdd}
N 960 -480 960 -400 {lab=raw_voutp}
N 960 -400 1210 -400 {lab=raw_voutp}
N 1510 -480 1510 -400 {lab=vdd}
N 1510 -380 1530 -380 {lab=#net2}
N 1510 -360 1510 -260 {lab=0}
N 1190 -260 1510 -260 {lab=0}
N 1550 -500 1920 -500 {lab=vdd}
N 1920 -500 1920 -490 {lab=vdd}
N 1550 -480 1920 -480 {lab=vdd}
N 1830 -480 1830 -380 {lab=vdd}
N 1830 -340 1830 -260 {lab=0}
N 1510 -260 1830 -260 {lab=0}
N 1880 -360 1880 -220 {lab=buf_voutp}
N 1380 -220 1880 -220 {lab=buf_voutp}
N 1380 -220 1380 -160 {lab=buf_voutp}
N 1380 -160 1400 -160 {lab=buf_voutp}
N 1280 -140 1400 -140 {lab=buf_voutn}
N 1280 -270 1280 -140 {lab=buf_voutn}
N 1700 -160 1900 -160 {lab=vdd}
N 1900 -480 1900 -160 {lab=vdd}
N 1700 -100 1720 -100 {lab=0}
N 1720 -100 1720 -50 {lab=0}
N 1110 -50 1720 -50 {lab=0}
N 1110 -260 1110 -50 {lab=0}
N 1700 -120 1760 -120 {lab=comp_decision_b}
N 1700 -140 1860 -140 {lab=comp_decision}
C {title.sym} 100 140 0 0 {name=tb_comp author="Gulu"}
C {vsource.sym} 1920 -400 0 0 {name=VDD value=3.3 savecurrent=false}
C {gnd.sym} 1920 -310 0 0 {name=l1 lab=0}
C {gnd.sym} 480 -240 0 0 {name=l2 lab=0}
C {vsource.sym} 110 -380 0 0 {name=VCLK value="PULSE(0 3.3 20n 100p 100p 50n 100n)" savecurrent=false}
C {gnd.sym} 110 -310 0 0 {name=l3 lab=0}
C {vsource.sym} -90 -470 0 0 {name=VINP value=1.5007324 savecurrent=false}
C {gnd.sym} -90 -400 0 0 {name=l4 lab=0}
C {vsource.sym} 0 -360 0 0 {name=VINN value=1.4992676 savecurrent=false}
C {gnd.sym} 0 -310 0 0 {name=l5 lab=0}
C {capa.sym} 1860 -60 0 0 {name=COUTP
m=1
value=5f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 1860 -10 0 0 {name=l6 lab=0}
C {capa.sym} 1760 -60 0 0 {name=COUTN
m=1
value=5f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 1760 -10 0 0 {name=l7 lab=0}
C {code_shown.sym} -110 -1070 0 0 {name=MODELS
only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
"}
C {code_shown.sym} -130 -970 0 0 {name=NGSPICE
only_toplevel=true
value="

.control
save all
tran 10p 200n

let input_diff = v(vinp)-v(vinn)
let rawdiff = v(raw_voutn)-v(raw_voutp)
let bufdiff = v(buf_voutn)-v(buf_voutp)
let latchdiff = v(comp_decision)-v(comp_decision_b)

plot v(clk) v(vinp) v(vinn)
plot v(raw_voutp) v(raw_voutn)
plot v(buf_voutp) v(buf_voutn)
plot v(comp_decision) v(comp_decision_b)
plot input_diff rawdiff bufdiff latchdiff

wrdata /foss/designs/sscs-chipathon-2026/designs/libs/tb_analog/tb_comp/comp_latch_test_pos.txt v(clk) v(vinp) v(vinn) input_diff v(raw_voutp) v(raw_voutn) rawdiff v(buf_voutp) v(buf_voutn) bufdiff v(comp_decision) v(comp_decision_b) latchdiff

.endc
"}
C {lab_wire.sym} 20 -500 0 0 {name=p1 sig_type=std_logic lab=vinp}
C {lab_wire.sym} 100 -480 0 0 {name=p2 sig_type=std_logic lab=vinn}
C {lab_wire.sym} 110 -440 0 0 {name=p3 sig_type=std_logic lab=clk}
C {lab_wire.sym} 570 -500 0 0 {name=p4 sig_type=std_logic lab=vdd}
C {lab_wire.sym} 550 -480 0 0 {name=p5 sig_type=std_logic lab=raw_voutp}
C {lab_wire.sym} 500 -460 2 0 {name=p6 sig_type=std_logic lab=raw_voutn}
C {lab_wire.sym} 1280 -300 0 0 {name=p7 sig_type=std_logic lab=buf_voutn}
C {lab_wire.sym} 1880 -360 0 0 {name=p8 sig_type=std_logic lab=buf_voutp}
C {lab_wire.sym} 1860 -140 2 0 {name=p9 sig_type=std_logic lab=comp_decision}
C {lab_wire.sym} 1760 -120 2 0 {name=p10 sig_type=std_logic lab=comp_decision_b}
C {Open-Silicon-10-Bit-SAR-ADC/designs/libs/core_analog/comp/comp.sym} 330 -470 0 0 {name=x7}
C {Open-Silicon-10-Bit-SAR-ADC/designs/libs/core_analog/inv_x1/inv_x1.sym} 720 -350 0 0 {name=x2}
C {Open-Silicon-10-Bit-SAR-ADC/designs/libs/core_analog/inv_x3/inv_x3.sym} 1040 -330 0 0 {name=x1}
C {Open-Silicon-10-Bit-SAR-ADC/designs/libs/core_analog/inv_x1/inv_x1.sym} 1360 -380 0 0 {name=x3}
C {Open-Silicon-10-Bit-SAR-ADC/designs/libs/core_analog/inv_x3/inv_x3.sym} 1680 -360 0 0 {name=x4}
C {Open-Silicon-10-Bit-SAR-ADC/designs/libs/core_analog/nand_SR_latch/nand_SR_latch.sym} 1550 -130 0 0 {name=x5}

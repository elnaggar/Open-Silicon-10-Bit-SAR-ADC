v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -210 -350 -110 -350 {lab=vdd}
N -210 -290 -210 -210 {lab=vss}
N -110 -350 -20 -350 {lab=vdd}
N -210 -330 -80 -330 {lab=raw_voutp}
N -210 -310 -160 -310 {lab=raw_voutn}
N -20 -350 140 -350 {lab=vdd}
N 430 -350 720 -350 {lab=vdd}
N 1140 -210 1190 -210 {lab=buf_voutp}
N 720 -350 860 -350 {lab=vdd}
N 600 -330 860 -330 {lab=vdd}
N -80 -330 -50 -330 {lab=raw_voutp}
N 140 -350 430 -350 {lab=vdd}
N -160 -310 -120 -310 {lab=raw_voutn}
N -120 -310 -120 -220 {lab=raw_voutn}
N 500 -180 560 -180 {lab=buf_voutn}
N -50 -330 270 -330 {lab=raw_voutp}
N 330 -330 330 -310 {lab=vdd}
N -60 -110 120 -110 {lab=vss}
N -210 -110 -60 -110 {lab=vss}
N 560 -180 590 -180 {lab=buf_voutn}
N 590 -180 590 -120 {lab=buf_voutn}
N 330 -330 600 -330 {lab=vdd}
N 120 -110 180 -110 {lab=vss}
N 180 -180 180 -110 {lab=vss}
N 180 -310 180 -220 {lab=vdd}
N 180 -310 330 -310 {lab=vdd}
N 180 -200 200 -200 {lab=#net1}
N 500 -160 500 -110 {lab=vss}
N 180 -110 500 -110 {lab=vss}
N 500 -330 500 -200 {lab=vdd}
N 270 -330 270 -250 {lab=raw_voutp}
N 270 -250 520 -250 {lab=raw_voutp}
N 820 -330 820 -250 {lab=vdd}
N 820 -230 840 -230 {lab=#net2}
N 820 -210 820 -110 {lab=vss}
N 500 -110 820 -110 {lab=vss}
N 860 -350 1230 -350 {lab=vdd}
N 1230 -350 1230 -340 {lab=vdd}
N 860 -330 1230 -330 {lab=vdd}
N 1140 -330 1140 -230 {lab=vdd}
N 1140 -190 1140 -110 {lab=vss}
N 820 -110 1140 -110 {lab=vss}
N 1190 -210 1190 -70 {lab=buf_voutp}
N 690 -70 1190 -70 {lab=buf_voutp}
N 690 -70 690 -10 {lab=buf_voutp}
N 690 -10 710 -10 {lab=buf_voutp}
N 590 10 710 10 {lab=buf_voutn}
N 590 -120 590 10 {lab=buf_voutn}
N 1010 -10 1210 -10 {lab=vdd}
N 1210 -330 1210 -10 {lab=vdd}
N 1010 50 1030 50 {lab=vss}
N 1030 50 1030 100 {lab=vss}
N 420 100 1030 100 {lab=vss}
N 420 -110 420 100 {lab=vss}
N 1230 -340 1230 -330 {lab=vdd}
N -540 -350 -510 -350 {lab=vinp}
N -540 -330 -510 -330 {lab=vinn}
N -540 -310 -510 -310 {lab=clk}
N -210 -210 -210 -110 {lab=vss}
N -230 -110 -210 -110 {lab=vss}
N 1230 -350 1250 -350 {lab=vdd}
N 1010 10 1060 10 {lab=Q}
N 1010 30 1090 30 {lab=Qb}
C {lab_wire.sym} -120 -350 0 0 {name=p4 sig_type=std_logic lab=vdd}
C {lab_wire.sym} -140 -330 0 0 {name=p5 sig_type=std_logic lab=raw_voutp}
C {lab_wire.sym} -190 -310 2 0 {name=p6 sig_type=std_logic lab=raw_voutn}
C {lab_wire.sym} 590 -150 0 0 {name=p7 sig_type=std_logic lab=buf_voutn}
C {lab_wire.sym} 1190 -210 0 0 {name=p8 sig_type=std_logic lab=buf_voutp}
C {Open-Silicon-10-Bit-SAR-ADC/designs/libs/core_analog/comp/comp.sym} -360 -320 0 0 {name=x7}
C {Open-Silicon-10-Bit-SAR-ADC/designs/libs/core_analog/inv_x1/inv_x1.sym} 30 -200 0 0 {name=x2}
C {Open-Silicon-10-Bit-SAR-ADC/designs/libs/core_analog/inv_x3/inv_x3.sym} 350 -180 0 0 {name=x3}
C {Open-Silicon-10-Bit-SAR-ADC/designs/libs/core_analog/inv_x1/inv_x1.sym} 670 -230 0 0 {name=x4}
C {Open-Silicon-10-Bit-SAR-ADC/designs/libs/core_analog/inv_x3/inv_x3.sym} 990 -210 0 0 {name=x5}
C {Open-Silicon-10-Bit-SAR-ADC/designs/libs/core_analog/nand_SR_latch/nand_SR_latch.sym} 860 20 0 0 {name=x6}
C {ipin.sym} -540 -350 0 0 {name=p1 lab=vinp
}
C {ipin.sym} -540 -330 0 0 {name=p2 lab=vinn
}
C {ipin.sym} -540 -310 0 0 {name=p3 lab=clk
}
C {opin.sym} 1060 10 0 0 {name=p11 lab=Q}
C {opin.sym} 1090 30 0 0 {name=p12 lab=Qb}
C {iopin.sym} 1250 -350 0 0 {name=p9 lab=vdd
}
C {iopin.sym} -230 -110 2 0 {name=p10 lab=vss
}

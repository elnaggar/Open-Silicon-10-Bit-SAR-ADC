v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 490 -760 490 -750 {lab=VSS}
N 490 -750 530 -750 {lab=VSS}
N 490 -910 490 -900 {lab=#net1}
N 490 -910 530 -910 {lab=#net1}
N 490 -580 490 -570 {lab=VSS}
N 490 -570 530 -570 {lab=VSS}
N 490 -730 490 -720 {lab=VDD}
N 490 -730 530 -730 {lab=VDD}
N 490 -400 490 -390 {lab=VSS}
N 490 -390 530 -390 {lab=VSS}
N 490 -550 490 -540 {lab=VDD}
N 490 -550 530 -550 {lab=VDD}
N 490 -220 490 -210 {lab=VSS}
N 490 -210 530 -210 {lab=VSS}
N 490 -370 490 -360 {lab=VDD}
N 490 -370 530 -370 {lab=VDD}
N 490 -40 490 -30 {lab=VSS}
N 490 -30 530 -30 {lab=VSS}
N 490 -190 490 -180 {lab=VDD}
N 490 -190 530 -190 {lab=VDD}
N 1120 -40 1120 -30 {lab=VSS}
N 1120 -30 1160 -30 {lab=VSS}
N 1120 -190 1120 -180 {lab=VDD}
N 1120 -190 1160 -190 {lab=VDD}
N 1120 -220 1120 -210 {lab=VSS}
N 1120 -210 1160 -210 {lab=VSS}
N 1120 -370 1120 -360 {lab=VDD}
N 1120 -370 1160 -370 {lab=VDD}
N 1120 -400 1120 -390 {lab=VSS}
N 1120 -390 1160 -390 {lab=VSS}
N 1120 -550 1120 -540 {lab=VDD}
N 1120 -550 1160 -550 {lab=VDD}
N 1120 -580 1120 -570 {lab=VSS}
N 1120 -570 1160 -570 {lab=VSS}
N 1120 -730 1120 -720 {lab=VDD}
N 1120 -730 1160 -730 {lab=VDD}
N 1120 -760 1120 -750 {lab=VSS}
N 1120 -750 1160 -750 {lab=VSS}
N 1120 -910 1120 -900 {lab=VDD}
N 1120 -910 1160 -910 {lab=VDD}
N 110 -830 140 -830 {lab=IN[0]}
N 110 -650 140 -650 {lab=IN[1]}
N 110 -470 140 -470 {lab=IN[2]}
N 740 -830 770 -830 {lab=IN[5]}
N 740 -650 770 -650 {lab=IN[6]}
N 740 -470 770 -470 {lab=IN[7]}
N 740 -290 770 -290 {lab=IN[8]}
N 740 -110 770 -110 {lab=IN[9]}
N 110 -290 140 -290 {lab=IN[3]}
N 110 -110 140 -110 {lab=IN[4]}
N 580 -830 610 -830 {lab=OUT[0]}
N 580 -650 610 -650 {lab=OUT[1]}
N 580 -470 610 -470 {lab=OUT[2]}
N 580 -290 610 -290 {lab=OUT[3]}
N 580 -110 610 -110 {lab=OUT[4]}
N 1210 -830 1240 -830 {lab=OUT[5]}
N 1210 -650 1240 -650 {lab=OUT[6]}
N 1210 -470 1240 -470 {lab=OUT[7]}
N 1210 -290 1240 -290 {lab=OUT[8]}
N 1210 -110 1240 -110 {lab=OUT[9]}
C {ipin.sym} 80 -540 0 0 {name=p_in lab=IN[9:0]}
C {opin.sym} 1330 -570 0 0 {name=p_out lab=OUT[9:0]}
C {iopin.sym} 10 -740 0 0 {name=p_vdd lab=VDD}
C {iopin.sym} 10 -200 0 0 {name=p_vss lab=VSS}
C {bp_buffer_medium.sym} 60 -520 0 0 {name=x1}
C {bp_buffer_medium.sym} 60 -340 0 0 {name=x2}
C {bp_buffer_medium.sym} 60 -160 0 0 {name=x3}
C {bp_buffer_medium.sym} 60 20 0 0 {name=x4}
C {bp_buffer_medium.sym} 60 200 0 0 {name=x5}
C {bp_buffer_medium.sym} 690 -520 0 0 {name=x6}
C {bp_buffer_medium.sym} 690 -340 0 0 {name=x7}
C {bp_buffer_large.sym} 690 -160 0 0 {name=x8}
C {bp_buffer_large.sym} 690 20 0 0 {name=x9}
C {bp_buffer_large.sym} 690 200 0 0 {name=x10}
C {lab_wire.sym} 110 -830 2 1 {name=p1 sig_type=std_logic lab=IN[0]}
C {lab_wire.sym} 530 -750 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 530 -730 2 1 {name=p3 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 530 -570 0 0 {name=p4 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 530 -550 2 1 {name=p5 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 530 -390 0 0 {name=p6 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 530 -370 2 1 {name=p7 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 530 -210 0 0 {name=p8 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 530 -190 2 1 {name=p9 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 530 -30 0 0 {name=p10 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 1160 -190 2 1 {name=p11 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 1160 -30 0 0 {name=p12 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 1160 -370 2 1 {name=p13 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 1160 -210 0 0 {name=p14 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 1160 -550 2 1 {name=p15 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 1160 -390 0 0 {name=p16 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 1160 -730 2 1 {name=p17 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 1160 -570 0 0 {name=p18 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 1160 -910 2 1 {name=p19 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 1160 -750 0 0 {name=p20 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 110 -650 2 1 {name=p21 sig_type=std_logic lab=IN[1]}
C {lab_wire.sym} 110 -470 2 1 {name=p22 sig_type=std_logic lab=IN[2]}
C {lab_wire.sym} 740 -830 2 1 {name=p23 sig_type=std_logic lab=IN[5]}
C {lab_wire.sym} 740 -650 2 1 {name=p24 sig_type=std_logic lab=IN[6]}
C {lab_wire.sym} 740 -470 2 1 {name=p25 sig_type=std_logic lab=IN[7]}
C {lab_wire.sym} 740 -290 2 1 {name=p26 sig_type=std_logic lab=IN[8]}
C {lab_wire.sym} 740 -110 2 1 {name=p27 sig_type=std_logic lab=IN[9]}
C {lab_wire.sym} 110 -290 2 1 {name=p28 sig_type=std_logic lab=IN[3]}
C {lab_wire.sym} 110 -110 2 1 {name=p29 sig_type=std_logic lab=IN[4]}
C {lab_wire.sym} 610 -830 2 0 {name=p30 sig_type=std_logic lab=OUT[0]}
C {lab_wire.sym} 610 -650 2 0 {name=p31 sig_type=std_logic lab=OUT[1]}
C {lab_wire.sym} 610 -470 2 0 {name=p32 sig_type=std_logic lab=OUT[2]}
C {lab_wire.sym} 610 -290 2 0 {name=p33 sig_type=std_logic lab=OUT[3]}
C {lab_wire.sym} 610 -110 2 0 {name=p34 sig_type=std_logic lab=OUT[4]}
C {lab_wire.sym} 1240 -830 2 0 {name=p35 sig_type=std_logic lab=OUT[5]}
C {lab_wire.sym} 1240 -650 2 0 {name=p36 sig_type=std_logic lab=OUT[6]}
C {lab_wire.sym} 1240 -470 2 0 {name=p37 sig_type=std_logic lab=OUT[7]}
C {lab_wire.sym} 1240 -290 2 0 {name=p38 sig_type=std_logic lab=OUT[8]}
C {lab_wire.sym} 1240 -110 2 0 {name=p39 sig_type=std_logic lab=OUT[9]}

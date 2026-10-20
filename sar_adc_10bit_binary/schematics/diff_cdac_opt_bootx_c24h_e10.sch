v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
L 4 170 -740 170 -480 {}
L 4 40 -600 170 -600 {}
L 4 170 -740 250 -740 {}
L 4 170 -480 250 -480 {}
L 4 2660 -690 2740 -690 {}
L 4 2660 -530 2740 -530 {}
L 4 1350 -80 1350 -20 {}
L 4 30 -80 1350 -80 {}
L 4 1350 -140 1350 -80 {}
L 4 30 -140 1350 -140 {}
L 4 30 -140 30 -20 {}
L 4 30 -20 1350 -20 {}
L 4 610 -135 610 -20 {}
L 16 1970 -230 1970 -10 {}
L 16 1380 -230 2560 -230 {}
L 16 1380 -10 2560 -10 {}
L 16 2560 -230 2560 -10 {}
L 16 1380 -230 1380 -10 {}
B 7 900 -640 2400 -630 {}
B 7 900 -590 2400 -580 {}
B 12 900 -370 2400 -360 {}
B 12 900 -860 2400 -850 {}
P 4 4 170 -600 140 -620 140 -580 170 -600 {fill=1}
P 4 4 250 -740 230 -750 230 -730 250 -740 {fill=1}
P 4 4 250 -480 230 -490 230 -470 250 -480 {fill=1}
P 4 4 2740 -690 2720 -700 2720 -680 2740 -690 {fill=1}
P 4 4 2740 -530 2720 -540 2720 -520 2740 -530 {fill=1}
P 16 5 1150 -250 1340 -250 1340 -160 1150 -160 1150 -250 {}
T {MIM bottom plate 
   +ve array} 2420 -870 0 0 0.4 0.4 {layer=12}
T {MIM bottom plate 
   -ve array} 2420 -410 0 0 0.4 0.4 {layer=12}
T {MIM top plate 
   -ve array} 2420 -600 0 0 0.4 0.4 {layer=7}
T {MIM top plate 
   +ve array} 2420 -670 0 0 0.4 0.4 {layer=7}
T {Cu    : 50fF
Type: mim_2f0fF
Size : 5µ*5µ} 1160 -240 0 0 0.4 0.4 {layer=16}
T {Cu} 2360 -700 0 0 0.4 0.4 {}
T {Cu} 2200 -700 0 0 0.4 0.4 {}
T {2Cu} 2050 -700 0 0 0.4 0.4 {}
T {4Cu} 1890 -700 0 0 0.4 0.4 {}
T {8Cu} 1750 -700 0 0 0.4 0.4 {}
T {16Cu} 1580 -700 0 0 0.4 0.4 {}
T {32Cu} 1440 -700 0 0 0.4 0.4 {}
T {64Cu} 1280 -700 0 0 0.4 0.4 {}
T {128Cu} 1120 -700 0 0 0.4 0.4 {}
T {256Cu} 960 -700 0 0 0.4 0.4 {}
T {512Cu} 820 -700 0 0 0.4 0.4 {}
T {Cu} 2360 -540 0 0 0.4 0.4 {}
T {Cu} 2200 -540 0 0 0.4 0.4 {}
T {2Cu} 2050 -540 0 0 0.4 0.4 {}
T {4Cu} 1890 -540 0 0 0.4 0.4 {}
T {8Cu} 1750 -540 0 0 0.4 0.4 {}
T {16Cu} 1580 -540 0 0 0.4 0.4 {}
T {32Cu} 1440 -540 0 0 0.4 0.4 {}
T {64Cu} 1280 -540 0 0 0.4 0.4 {}
T {128Cu} 1120 -540 0 0 0.4 0.4 {}
T {256Cu} 960 -540 0 0 0.4 0.4 {}
T {512Cu} 820 -540 0 0 0.4 0.4 {}
T {LAYOUT AREA ESTIMATION: 10-BIT DIFFERENTIAL SAR ADC CDAC (Paired Common Centroid)
} 1370 -270 0 0 0.5 0.5 {layer=16}
T {1. UNIT CAPACITOR (Cu)
------------------------------------
- Value:                  50 fF
- Physical Size:       5 µm x 5 µm
- Layout Pitch:        6 µm x 6 µm (includes DRC minimum spacing rules)

2. ACTIVE CORE ARRAY (Common Centroid)
---------------------------------------------------------------
- Total Capacitors:       2,048 Cu (1024 Cu Positive + 1024 Cu Negative)
- Matrix Dimensions:   46 x 46 (yields 2,116 slots, 68 extra tied to GND)
- Core Size:                 276 µm x 276 µm} 1390 -220 0 0 0.3 0.3 {layer=16}
T {3. MATCHING & ISOLATION
----------------------------------------
- Dummy Ring:           +1 capacitor border on all sides (48 x 48 matrix)
- Size w/ Dummy Ring:  288 µm x 288 µm
- Routing/Guard Rings: +20 µm margin per side (P+ substrate / N-well)

4. FINAL ESTIMATED FOOTPRINT
----------------------------------------------
- Total Bounding Box:  328 µm x 328 µm
- Total Silicon Area:  ~ 0.108 mm²} 1980 -220 0 0 0.3 0.3 {layer=16}
T {Differential

Input Sampling} 180 -630 0 0 0.4 0.4 {layer=4}
T {To
Comparator} 2680 -640 0 0 0.4 0.4 {layer=4}
T {IEEE SSCS Chipathon 2026} 767.5 -130 0 0 0.6 0.6 {layer=9}
T {Team A-25 OpenSilicon: 10 Bits IoT SAR ADC} 627.5 -67.5 0 0 0.6 0.6 {layer=9}
T {Designer: Ahmed Elnaggar} 127.5 -67.5 0 0 0.6 0.6 {layer=9}
T {Boostrapped Switch} 175 -127.5 0 0 0.6 0.6 {layer=9}
N 2400 -560 2400 -520 {lab=VOUT_N}
N 2240 -560 2240 -520 {lab=VOUT_N}
N 2100 -560 2100 -520 {lab=VOUT_N}
N 1940 -560 1940 -520 {lab=VOUT_N}
N 1800 -560 1800 -520 {lab=VOUT_N}
N 1640 -560 1640 -520 {lab=VOUT_N}
N 1500 -570 1500 -520 {lab=VOUT_N}
N 1340 -570 1500 -570 {lab=VOUT_N}
N 1340 -570 1340 -520 {lab=VOUT_N}
N 1200 -570 1340 -570 {lab=VOUT_N}
N 1200 -570 1200 -520 {lab=VOUT_N}
N 1040 -570 1200 -570 {lab=VOUT_N}
N 1040 -570 1040 -520 {lab=VOUT_N}
N 900 -570 1040 -570 {lab=VOUT_N}
N 900 -570 900 -520 {lab=VOUT_N}
N 2400 -700 2400 -660 {lab=VOUT_P}
N 2240 -700 2240 -650 {lab=VOUT_P}
N 2100 -700 2100 -650 {lab=VOUT_P}
N 1940 -700 1940 -650 {lab=VOUT_P}
N 1800 -700 1800 -650 {lab=VOUT_P}
N 1640 -700 1640 -650 {lab=VOUT_P}
N 1500 -700 1500 -650 {lab=VOUT_P}
N 1340 -650 1500 -650 {lab=VOUT_P}
N 1340 -700 1340 -650 {lab=VOUT_P}
N 1200 -650 1340 -650 {lab=VOUT_P}
N 1200 -700 1200 -650 {lab=VOUT_P}
N 1040 -650 1200 -650 {lab=VOUT_P}
N 1040 -700 1040 -650 {lab=VOUT_P}
N 900 -650 1040 -650 {lab=VOUT_P}
N 900 -700 900 -650 {lab=VOUT_P}
N 900 -820 900 -760 {lab=SW_P[9]}
N 860 -820 900 -820 {lab=SW_P[9]}
N 1040 -820 1040 -760 {lab=SW_P[8]}
N 1000 -820 1040 -820 {lab=SW_P[8]}
N 1200 -820 1200 -760 {lab=SW_P[7]}
N 1160 -820 1200 -820 {lab=SW_P[7]}
N 1340 -820 1340 -760 {lab=SW_P[6]}
N 1300 -820 1340 -820 {lab=SW_P[6]}
N 1500 -820 1500 -760 {lab=SW_P[5]}
N 1460 -820 1500 -820 {lab=SW_P[5]}
N 1640 -820 1640 -760 {lab=SW_P[4]}
N 1600 -820 1640 -820 {lab=SW_P[4]}
N 1800 -820 1800 -760 {lab=SW_P[3]}
N 1760 -820 1800 -820 {lab=SW_P[3]}
N 1940 -820 1940 -760 {lab=SW_P[2]}
N 1900 -820 1940 -820 {lab=SW_P[2]}
N 1500 -650 2400 -650 {lab=VOUT_P}
N 2400 -660 2400 -650 {lab=VOUT_P}
N 2100 -820 2100 -760 {lab=SW_P[1]}
N 2060 -820 2100 -820 {lab=SW_P[1]}
N 2240 -820 2240 -760 {lab=SW_P[0]}
N 2200 -820 2240 -820 {lab=SW_P[0]}
N 2400 -820 2400 -760 {lab=VSS}
N 2360 -820 2400 -820 {lab=VSS}
N 900 -460 900 -400 {lab=SW_N[9]}
N 860 -400 900 -400 {lab=SW_N[9]}
N 1040 -460 1040 -400 {lab=SW_N[8]}
N 1000 -400 1040 -400 {lab=SW_N[8]}
N 1200 -460 1200 -400 {lab=SW_N[7]}
N 1160 -400 1200 -400 {lab=SW_N[7]}
N 1340 -460 1340 -400 {lab=SW_N[6]}
N 1300 -400 1340 -400 {lab=SW_N[6]}
N 1500 -460 1500 -400 {lab=SW_N[5]}
N 1460 -400 1500 -400 {lab=SW_N[5]}
N 1640 -460 1640 -400 {lab=SW_N[4]}
N 1600 -400 1640 -400 {lab=SW_N[4]}
N 1800 -460 1800 -400 {lab=SW_N[3]}
N 1760 -400 1800 -400 {lab=SW_N[3]}
N 1940 -460 1940 -400 {lab=SW_N[2]}
N 1900 -400 1940 -400 {lab=SW_N[2]}
N 2100 -460 2100 -400 {lab=SW_N[1]}
N 2060 -400 2100 -400 {lab=SW_N[1]}
N 2240 -460 2240 -400 {lab=SW_N[0]}
N 2200 -400 2240 -400 {lab=SW_N[0]}
N 2400 -460 2400 -400 {lab=VSS}
N 2360 -400 2400 -400 {lab=VSS}
N 1500 -570 1640 -570 {lab=VOUT_N}
N 1640 -570 1640 -560 {lab=VOUT_N}
N 1640 -570 1800 -570 {lab=VOUT_N}
N 1800 -570 1800 -560 {lab=VOUT_N}
N 1800 -570 1940 -570 {lab=VOUT_N}
N 1940 -570 1940 -560 {lab=VOUT_N}
N 1940 -570 2100 -570 {lab=VOUT_N}
N 2100 -570 2100 -560 {lab=VOUT_N}
N 2100 -570 2240 -570 {lab=VOUT_N}
N 2240 -570 2240 -560 {lab=VOUT_N}
N 2240 -570 2400 -570 {lab=VOUT_N}
N 2400 -570 2400 -560 {lab=VOUT_N}
N 840 -570 900 -570 {lab=VOUT_N}
N 2400 -540 2570 -540 {lab=VOUT_N}
N 2400 -680 2570 -680 {lab=VOUT_P}
N 720 -570 840 -570 {lab=VOUT_N}
N 650 -480 680 -480 {lab=VOUT_N}
N 680 -480 720 -570 {lab=VOUT_N}
N 840 -650 900 -650 {lab=VOUT_P}
N 720 -650 840 -650 {lab=VOUT_P}
N 650 -740 680 -740 {lab=VOUT_P}
N 680 -740 720 -650 {lab=VOUT_P}
N 350 -480 410 -480 {lab=VCM_N}
N 350 -740 410 -740 {lab=VCM_P}
N 530 -830 530 -800 {lab=VCM_EN}
N 530 -570 530 -540 {lab=VCM_EN}
N 530 -680 530 -650 {lab=VCM_EN_B}
N 530 -420 530 -390 {lab=VCM_EN_B}
N 480 -830 480 -800 {lab=VDD}
N 480 -680 480 -650 {lab=VSS}
N 480 -570 480 -540 {lab=VDD}
N 480 -420 480 -390 {lab=VSS}
C {symbols/cap_mim_2f0fF.sym} 2400 -490 0 0 {name=LSB_dummy_n
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=1}
C {symbols/cap_mim_2f0fF.sym} 2240 -490 0 0 {name=bo_n
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=1}
C {symbols/cap_mim_2f0fF.sym} 2100 -490 0 0 {name=b1_n
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=2}
C {symbols/cap_mim_2f0fF.sym} 1940 -490 0 0 {name=b2_n
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=4}
C {symbols/cap_mim_2f0fF.sym} 1800 -490 0 0 {name=b3_n
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=8}
C {symbols/cap_mim_2f0fF.sym} 1640 -490 0 0 {name=b4_n
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=16}
C {symbols/cap_mim_2f0fF.sym} 1500 -490 0 0 {name=b5_n
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=32}
C {symbols/cap_mim_2f0fF.sym} 1340 -490 0 0 {name=b6_n
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=64}
C {symbols/cap_mim_2f0fF.sym} 1200 -490 0 0 {name=b7_n
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=128}
C {symbols/cap_mim_2f0fF.sym} 1040 -490 0 0 {name=b8_n
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=256}
C {symbols/cap_mim_2f0fF.sym} 900 -490 0 0 {name=b9_n
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=512}
C {symbols/cap_mim_2f0fF.sym} 2400 -730 2 1 {name=LSB_dummy_p
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=1}
C {symbols/cap_mim_2f0fF.sym} 2240 -730 2 1 {name=bo_p
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=1}
C {symbols/cap_mim_2f0fF.sym} 2100 -730 2 1 {name=b1_p
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=2}
C {symbols/cap_mim_2f0fF.sym} 1940 -730 2 1 {name=b2_p
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=4}
C {symbols/cap_mim_2f0fF.sym} 1800 -730 2 1 {name=b3_p
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=8}
C {symbols/cap_mim_2f0fF.sym} 1640 -730 2 1 {name=b4_p
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=16}
C {symbols/cap_mim_2f0fF.sym} 1500 -730 2 1 {name=b5_p
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=32}
C {symbols/cap_mim_2f0fF.sym} 1340 -730 2 1 {name=b6_p
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=64}
C {symbols/cap_mim_2f0fF.sym} 1200 -730 2 1 {name=b7_p
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=128}
C {symbols/cap_mim_2f0fF.sym} 1040 -730 2 1 {name=b8_p
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=256}
C {symbols/cap_mim_2f0fF.sym} 900 -730 2 1 {name=b9_p
W=5e-6
L=5e-6
model=cap_mim_2f0fF
spiceprefix=X
m=512}
C {lab_wire.sym} 900 -820 0 0 {name=p1 sig_type=std_logic lab=SW_P[9]}
C {lab_wire.sym} 1040 -820 0 0 {name=p2 sig_type=std_logic lab=SW_P[8]}
C {lab_wire.sym} 1200 -820 0 0 {name=p3 sig_type=std_logic lab=SW_P[7]}
C {lab_wire.sym} 1340 -820 0 0 {name=p4 sig_type=std_logic lab=SW_P[6]}
C {lab_wire.sym} 1500 -820 0 0 {name=p5 sig_type=std_logic lab=SW_P[5]}
C {lab_wire.sym} 1640 -820 0 0 {name=p6 sig_type=std_logic lab=SW_P[4]}
C {lab_wire.sym} 1800 -820 0 0 {name=p7 sig_type=std_logic lab=SW_P[3]}
C {lab_wire.sym} 1940 -820 0 0 {name=p8 sig_type=std_logic lab=SW_P[2]}
C {lab_wire.sym} 2100 -820 0 0 {name=p9 sig_type=std_logic lab=SW_P[1]}
C {lab_wire.sym} 2240 -820 0 0 {name=p10 sig_type=std_logic lab=SW_P[0]}
C {lab_wire.sym} 900 -400 2 1 {name=p12 sig_type=std_logic lab=SW_N[9]}
C {lab_wire.sym} 1040 -400 2 1 {name=p13 sig_type=std_logic lab=SW_N[8]}
C {lab_wire.sym} 1200 -400 2 1 {name=p14 sig_type=std_logic lab=SW_N[7]}
C {lab_wire.sym} 1340 -400 2 1 {name=p15 sig_type=std_logic lab=SW_N[6]}
C {lab_wire.sym} 1500 -400 2 1 {name=p16 sig_type=std_logic lab=SW_N[5]}
C {lab_wire.sym} 1640 -400 2 1 {name=p17 sig_type=std_logic lab=SW_N[4]}
C {lab_wire.sym} 1800 -400 2 1 {name=p18 sig_type=std_logic lab=SW_N[3]}
C {lab_wire.sym} 1940 -400 2 1 {name=p19 sig_type=std_logic lab=SW_N[2]}
C {lab_wire.sym} 2100 -400 2 1 {name=p20 sig_type=std_logic lab=SW_N[1]}
C {lab_wire.sym} 2240 -400 2 1 {name=p21 sig_type=std_logic lab=SW_N[0]}
C {ipin.sym} 820 -820 0 0 {name=p25 lab=SW_P[9:0]}
C {ipin.sym} 820 -400 0 0 {name=p26 lab=SW_N[9:0]}
C {ipin.sym} 350 -740 0 0 {name=p27 lab=VCM_P}
C {ipin.sym} 350 -480 0 0 {name=p28 lab=VCM_N}
C {lab_wire.sym} 2570 -680 0 1 {name=p29 sig_type=std_logic lab=VOUT_P}
C {lab_wire.sym} 2570 -540 2 0 {name=p30 sig_type=std_logic lab=VOUT_N}
C {opin.sym} 2580 -650 0 0 {name=p31 lab=VOUT_P}
C {opin.sym} 2580 -570 0 0 {name=p32 lab=VOUT_N}
C {top_nmos_switch.sym} 530 -740 0 0 {name=x1}
C {top_nmos_switch.sym} 530 -480 0 0 {name=x2}
C {lab_wire.sym} 530 -830 0 1 {name=p23 sig_type=std_logic lab=VCM_EN}
C {lab_wire.sym} 530 -650 2 0 {name=p33 sig_type=std_logic lab=VCM_EN_B}
C {lab_wire.sym} 530 -570 0 1 {name=p24 sig_type=std_logic lab=VCM_EN}
C {lab_wire.sym} 530 -390 2 0 {name=p34 sig_type=std_logic lab=VCM_EN_B}
C {ipin.sym} 370 -900 0 0 {name=p35 lab=VCM_EN}
C {ipin.sym} 410 -340 0 0 {name=p36 lab=VCM_EN_B}
C {iopin.sym} 370 -820 0 1 {name=p11 lab=VDD}
C {iopin.sym} 370 -600 0 1 {name=p37 lab=VSS}
C {lab_wire.sym} 480 -830 0 0 {name=p22 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 480 -570 0 0 {name=p38 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 480 -650 2 1 {name=p39 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 480 -390 2 1 {name=p40 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 2390 -820 0 0 {name=p41 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 2390 -400 2 1 {name=p42 sig_type=std_logic lab=VSS}
C {symbols/nfet_03v3.sym} 2560 -560 0 0 {name=XMN_dum_x1
L=0.28u
W=10u
nf=4
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_03v3
spiceprefix=X
}
N 2580 -590 2640 -590 {lab=VOUT_P}
C {lab_wire.sym} 2640 -590 0 0 {name=pdum1_D sig_type=std_logic lab=VOUT_P}
N 2540 -560 2480 -560 {lab=VCM_EN_B}
C {lab_wire.sym} 2480 -560 0 0 {name=pdum1_G sig_type=std_logic lab=VCM_EN_B}
N 2580 -530 2640 -530 {lab=VOUT_P}
C {lab_wire.sym} 2640 -530 0 0 {name=pdum1_S sig_type=std_logic lab=VOUT_P}
N 2580 -560 2640 -560 {lab=VSS}
C {lab_wire.sym} 2640 -560 0 0 {name=pdum1_B sig_type=std_logic lab=VSS}
C {symbols/nfet_03v3.sym} 2560 -400 0 0 {name=XMN_dum_x2
L=0.28u
W=10u
nf=4
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_03v3
spiceprefix=X
}
N 2580 -430 2640 -430 {lab=VOUT_N}
C {lab_wire.sym} 2640 -430 0 0 {name=pdum2_D sig_type=std_logic lab=VOUT_N}
N 2540 -400 2480 -400 {lab=VCM_EN_B}
C {lab_wire.sym} 2480 -400 0 0 {name=pdum2_G sig_type=std_logic lab=VCM_EN_B}
N 2580 -370 2640 -370 {lab=VOUT_N}
C {lab_wire.sym} 2640 -370 0 0 {name=pdum2_S sig_type=std_logic lab=VOUT_N}
N 2580 -400 2640 -400 {lab=VSS}
C {lab_wire.sym} 2640 -400 0 0 {name=pdum2_B sig_type=std_logic lab=VSS}
T {F-08 dummy-compensation NFETs (XMN_dum_x1/x2), present in the
opt_bootx netlist, absent from the base diff_cdac} 2560 -900 0 0 0.3 0.3 {layer=16}

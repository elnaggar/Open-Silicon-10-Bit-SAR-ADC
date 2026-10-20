v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 120 -570 180 -570 {lab=tp}
N 80 -600 20 -600 {lab=gt}
N 120 -630 180 -630 {lab=VDD}
N 120 -600 180 -600 {lab=tp}
N 520 -570 580 -570 {lab=gt}
N 480 -600 420 -600 {lab=ngb}
N 520 -630 580 -630 {lab=tp}
N 520 -600 580 -600 {lab=tp}
N 920 -570 980 -570 {lab=ngb}
N 880 -600 820 -600 {lab=VCM_EN}
N 920 -630 980 -630 {lab=VDD}
N 920 -600 980 -600 {lab=VDD}
N 120 -330 180 -330 {lab=bt}
N 80 -300 20 -300 {lab=VCM_EN_B}
N 120 -270 180 -270 {lab=VSS}
N 120 -300 180 -300 {lab=VSS}
N 520 -330 580 -330 {lab=gt}
N 480 -300 420 -300 {lab=VDD}
N 520 -270 580 -270 {lab=nmid}
N 520 -300 580 -300 {lab=VSS}
N 920 -330 980 -330 {lab=bt}
N 880 -300 820 -300 {lab=gt}
N 920 -270 980 -270 {lab=VCM}
N 920 -300 980 -300 {lab=VSS}
N 1320 -330 1380 -330 {lab=VTOP}
N 1280 -300 1220 -300 {lab=gt}
N 1320 -270 1380 -270 {lab=VCM}
N 1320 -300 1380 -300 {lab=VSS}
N 120 -30 180 -30 {lab=nmid}
N 80 0 20 0 {lab=VCM_EN_B}
N 120 30 180 30 {lab=VSS}
N 120 0 180 0 {lab=VSS}
N 520 -30 580 -30 {lab=ngb}
N 480 0 420 0 {lab=VCM_EN}
N 520 30 580 30 {lab=bt}
N 520 0 580 0 {lab=VSS}
N 1300 -630 1300 -672 {lab=tp}
N 1300 -570 1300 -528 {lab=bt}
N 900 -30 900 -72 {lab=VCM_EN_B}
N 900 30 900 72 {lab=VSS}
C {symbols/pfet_03v3.sym} 100 -600 0 0 {name=XMP1
L=0.28u
W=4u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_03v3
spiceprefix=X
}
C {symbols/pfet_03v3.sym} 500 -600 0 0 {name=XMP2
L=0.28u
W=4u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_03v3
spiceprefix=X
}
C {symbols/pfet_03v3.sym} 900 -600 0 0 {name=XMP3
L=0.28u
W=2u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_03v3
spiceprefix=X
}
C {symbols/nfet_03v3.sym} 100 -300 0 0 {name=XMN1
L=0.28u
W=24u
nf=6
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
C {symbols/nfet_03v3.sym} 500 -300 0 0 {name=XMN2c
L=0.28u
W=24u
nf=6
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
C {symbols/nfet_03v3.sym} 900 -300 0 0 {name=XMN3
L=0.28u
W=4u
nf=1
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
C {symbols/nfet_03v3.sym} 1300 -300 0 0 {name=XMSW
L=0.28u
W=20u
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
C {symbols/nfet_03v3.sym} 100 0 0 0 {name=XMN2
L=0.28u
W=24u
nf=6
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
C {symbols/nfet_03v3.sym} 500 0 0 0 {name=XMN4
L=0.28u
W=2u
nf=1
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
C {symbols/cap_mim_2f0fF.sym} 1300 -600 0 0 {name=Xcb
W=15.7e-6
L=15.7e-6
model=cap_mim_2f0fF
spiceprefix=X
m=1}
C {symbols/cap_mim_2f0fF.sym} 900 0 0 0 {name=Xcenb
W=10.0e-6
L=10.0e-6
model=cap_mim_2f0fF
spiceprefix=X
m=1}
C {lab_wire.sym} 180 -570 0 0 {name=p1 sig_type=std_logic lab=tp}
C {lab_wire.sym} 20 -600 0 0 {name=p2 sig_type=std_logic lab=gt}
C {lab_wire.sym} 180 -630 0 0 {name=p3 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 180 -600 0 0 {name=p4 sig_type=std_logic lab=tp}
C {lab_wire.sym} 580 -570 0 0 {name=p5 sig_type=std_logic lab=gt}
C {lab_wire.sym} 420 -600 0 0 {name=p6 sig_type=std_logic lab=ngb}
C {lab_wire.sym} 580 -630 0 0 {name=p7 sig_type=std_logic lab=tp}
C {lab_wire.sym} 580 -600 0 0 {name=p8 sig_type=std_logic lab=tp}
C {lab_wire.sym} 980 -570 0 0 {name=p9 sig_type=std_logic lab=ngb}
C {lab_wire.sym} 820 -600 0 0 {name=p10 sig_type=std_logic lab=VCM_EN}
C {lab_wire.sym} 980 -630 0 0 {name=p11 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 980 -600 0 0 {name=p12 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 180 -330 0 0 {name=p13 sig_type=std_logic lab=bt}
C {lab_wire.sym} 20 -300 0 0 {name=p14 sig_type=std_logic lab=VCM_EN_B}
C {lab_wire.sym} 180 -270 0 0 {name=p15 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 180 -300 0 0 {name=p16 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 580 -330 0 0 {name=p17 sig_type=std_logic lab=gt}
C {lab_wire.sym} 420 -300 0 0 {name=p18 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 580 -270 0 0 {name=p19 sig_type=std_logic lab=nmid}
C {lab_wire.sym} 580 -300 0 0 {name=p20 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 980 -330 0 0 {name=p21 sig_type=std_logic lab=bt}
C {lab_wire.sym} 820 -300 0 0 {name=p22 sig_type=std_logic lab=gt}
C {lab_wire.sym} 980 -270 0 0 {name=p23 sig_type=std_logic lab=VCM}
C {lab_wire.sym} 980 -300 0 0 {name=p24 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 1380 -330 0 0 {name=p25 sig_type=std_logic lab=VTOP}
C {lab_wire.sym} 1220 -300 0 0 {name=p26 sig_type=std_logic lab=gt}
C {lab_wire.sym} 1380 -270 0 0 {name=p27 sig_type=std_logic lab=VCM}
C {lab_wire.sym} 1380 -300 0 0 {name=p28 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 180 -30 0 0 {name=p29 sig_type=std_logic lab=nmid}
C {lab_wire.sym} 20 0 0 0 {name=p30 sig_type=std_logic lab=VCM_EN_B}
C {lab_wire.sym} 180 30 0 0 {name=p31 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 180 0 0 0 {name=p32 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 580 -30 0 0 {name=p33 sig_type=std_logic lab=ngb}
C {lab_wire.sym} 420 0 0 0 {name=p34 sig_type=std_logic lab=VCM_EN}
C {lab_wire.sym} 580 30 0 0 {name=p35 sig_type=std_logic lab=bt}
C {lab_wire.sym} 580 0 0 0 {name=p36 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 1300 -672 0 0 {name=p37 sig_type=std_logic lab=tp}
C {lab_wire.sym} 1300 -528 0 0 {name=p38 sig_type=std_logic lab=bt}
C {lab_wire.sym} 900 -72 0 0 {name=p39 sig_type=std_logic lab=VCM_EN_B}
C {lab_wire.sym} 900 72 0 0 {name=p40 sig_type=std_logic lab=VSS}
C {iopin.sym} 1550 -300 0 0 {name=pb1 lab=VTOP}
C {ipin.sym} -150 -850 0 0 {name=pb2 lab=VCM_EN}
C {ipin.sym} -150 150 0 0 {name=pb3 lab=VCM_EN_B}
C {iopin.sym} 1550 -500 0 0 {name=pb4 lab=VCM}
C {iopin.sym} -150 -600 0 0 {name=pb5 lab=VDD}
C {iopin.sym} -150 -100 0 0 {name=pb6 lab=VSS}

v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 300 -150 300 -130 {lab=tail}
N 300 -130 550 -130 {lab=tail}
N 550 -150 550 -130 {lab=tail}
N 420 -130 420 -100 {lab=tail}
N 300 -260 300 -210 {lab=P}
N 550 -260 550 -210 {lab=Q}
N 240 -290 300 -290 {lab=vss}
N 550 -290 580 -290 {lab=vss}
N 300 -180 330 -180 {lab=vss}
N 530 -180 550 -180 {lab=vss}
N 420 -40 420 -20 {lab=vss}
N 420 -70 460 -70 {lab=vss}
N 230 -180 260 -180 {lab=vinp}
N 590 -180 620 -180 {lab=vinn}
N 350 -70 380 -70 {lab=clk}
N 300 -480 300 -320 {lab=voutp}
N 550 -480 550 -320 {lab=voutn}
N 340 -290 400 -290 {lab=voutn}
N 400 -390 400 -290 {lab=voutn}
N 400 -390 550 -390 {lab=voutn}
N 430 -290 510 -290 {lab=voutp}
N 430 -370 430 -290 {lab=voutp}
N 300 -370 430 -370 {lab=voutp}
N 270 -430 300 -430 {lab=voutp}
N 550 -430 570 -430 {lab=voutn}
N 400 -510 510 -510 {lab=voutp}
N 400 -510 400 -460 {lab=voutp}
N 300 -460 400 -460 {lab=voutp}
N 340 -510 380 -510 {lab=voutn}
N 380 -510 380 -470 {lab=voutn}
N 380 -470 550 -470 {lab=voutn}
N 90 -480 90 -470 {lab=voutp}
N 90 -470 90 -460 {lab=voutp}
N 90 -460 300 -460 {lab=voutp}
N 780 -480 780 -470 {lab=voutn}
N 550 -470 780 -470 {lab=voutn}
N -60 -590 -60 -540 {lab=vdd}
N -60 -590 950 -590 {lab=vdd}
N 950 -590 970 -590 {lab=vdd}
N 970 -590 970 -540 {lab=vdd}
N 780 -590 780 -540 {lab=vdd}
N 550 -590 550 -540 {lab=vdd}
N 300 -590 300 -540 {lab=vdd}
N 90 -590 90 -540 {lab=vdd}
N 90 -510 150 -510 {lab=vdd}
N 150 -590 150 -510 {lab=vdd}
N -60 -510 -0 -510 {lab=vdd}
N 0 -590 0 -510 {lab=vdd}
N 230 -510 300 -510 {lab=vdd}
N 230 -590 230 -510 {lab=vdd}
N 550 -510 620 -510 {lab=vdd}
N 620 -590 620 -510 {lab=vdd}
N 710 -510 780 -510 {lab=vdd}
N 710 -590 710 -510 {lab=vdd}
N 890 -510 970 -510 {lab=vdd}
N 890 -590 890 -510 {lab=vdd}
N 430 -600 430 -590 {lab=vdd}
N -120 -510 -100 -510 {lab=clk}
N 30 -510 50 -510 {lab=clk}
N 30 -510 30 -430 {lab=clk}
N -120 -510 -120 -440 {lab=clk}
N -130 -430 30 -430 {lab=clk}
N -120 -440 -120 -430 {lab=clk}
N 820 -510 850 -510 {lab=clk}
N 850 -510 850 -440 {lab=clk}
N 850 -440 1030 -440 {lab=clk}
N 1010 -510 1010 -440 {lab=clk}
N -60 -480 -60 -250 {lab=P}
N -60 -250 300 -250 {lab=P}
N 970 -480 970 -250 {lab=Q}
N 560 -250 970 -250 {lab=Q}
N 550 -250 560 -250 {lab=Q}
C {title.sym} 60 50 0 0 {name=comparator author="Gulu"}
C {symbols/nfet_03v3.sym} 280 -180 0 0 {name=M1
L=0.36u
W=2u
nf=2
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
C {symbols/nfet_03v3.sym} 570 -180 0 1 {name=M2
L=0.36u
W=2u
nf=2
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
C {symbols/nfet_03v3.sym} 400 -70 0 0 {name=M7
L=0.28u
W=4u
nf=2
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
C {symbols/nfet_03v3.sym} 320 -290 0 1 {name=M3
L=0.28u
W=1u
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
C {symbols/nfet_03v3.sym} 530 -290 0 0 {name=M4
L=0.28u
W=1u
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
C {symbols/pfet_03v3.sym} 530 -510 0 0 {name=M6
L=0.28u
W=2u
nf=2
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
C {symbols/pfet_03v3.sym} 320 -510 0 1 {name=M5
L=0.28u
W=2u
nf=2
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
C {symbols/pfet_03v3.sym} 800 -510 0 1 {name=M10
L=0.28u
W=2u
nf=2
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
C {symbols/pfet_03v3.sym} 990 -510 0 1 {name=M11
L=0.28u
W=1u
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
C {symbols/pfet_03v3.sym} 70 -510 0 0 {name=M8
L=0.28u
W=2u
nf=2
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
C {symbols/pfet_03v3.sym} -80 -510 0 0 {name=M9
L=0.28u
W=1u
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
C {iopin.sym} 420 -20 3 1 {name=p6 lab=vss}
C {iopin.sym} 430 -600 3 0 {name=p9 lab=vdd}
C {ipin.sym} 230 -180 0 0 {name=p7 lab=vinp
}
C {ipin.sym} 620 -180 0 1 {name=p8 lab=vinn
}
C {ipin.sym} 350 -70 0 0 {name=p10 lab=clk
}
C {opin.sym} 570 -430 0 0 {name=p11 lab=voutn
}
C {opin.sym} 270 -430 0 1 {name=p12 lab=voutp}
C {lab_wire.sym} 300 -250 2 0 {name=p15 sig_type=std_logic lab=P
}
C {lab_wire.sym} 550 -250 2 1 {name=p16 sig_type=std_logic lab=Q
}
C {lab_wire.sym} 420 -130 0 0 {name=p17 sig_type=std_logic lab=tail
}
C {lab_wire.sym} 330 -180 2 0 {name=p1 sig_type=std_logic lab=vss}
C {lab_wire.sym} 580 -290 2 0 {name=p2 sig_type=std_logic lab=vss}
C {lab_wire.sym} 240 -290 0 0 {name=p3 sig_type=std_logic lab=vss}
C {lab_wire.sym} 530 -180 0 0 {name=p4 sig_type=std_logic lab=vss}
C {lab_wire.sym} -130 -430 0 0 {name=p13 sig_type=std_logic lab=clk}
C {lab_wire.sym} 1030 -440 0 1 {name=p14 sig_type=std_logic lab=clk}
C {lab_wire.sym} 460 -70 2 0 {name=p5 sig_type=std_logic lab=vss}

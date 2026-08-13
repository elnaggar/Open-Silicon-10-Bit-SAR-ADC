v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -120 -240 -120 -220 {lab=VDD}
N -120 -240 90 -240 {lab=VDD}
N 90 -240 90 -220 {lab=VDD}
N -120 -160 -120 -130 {lab=Q}
N -120 -130 90 -130 {lab=Q}
N 90 -160 90 -130 {lab=Q}
N -10 -130 -10 -110 {lab=Q}
N -10 -50 -10 -0 {lab=#net1}
N -10 60 -10 90 {lab=VSS}
N -260 30 -50 30 {lab=S}
N -270 30 -260 30 {lab=S}
N -190 -190 -160 -190 {lab=S}
N -190 -190 -190 30 {lab=S}
N 30 -80 160 -80 {lab=Qb}
N 160 -190 160 -80 {lab=Qb}
N 130 -190 160 -190 {lab=Qb}
N 510 -240 510 -220 {lab=VDD}
N 300 -240 510 -240 {lab=VDD}
N 300 -240 300 -220 {lab=VDD}
N 510 -160 510 -130 {lab=Qb}
N 300 -130 510 -130 {lab=Qb}
N 300 -160 300 -130 {lab=Qb}
N 400 -130 400 -110 {lab=Qb}
N 400 -50 400 0 {lab=#net2}
N 400 60 400 90 {lab=VSS}
N 440 30 650 30 {lab=R}
N 650 30 660 30 {lab=R}
N 550 -190 580 -190 {lab=R}
N 580 -190 580 30 {lab=R}
N 230 -80 360 -80 {lab=Q}
N 230 -190 230 -80 {lab=Q}
N 230 -190 260 -190 {lab=Q}
N -10 -120 230 -120 {lab=Q}
N 260 -120 400 -120 {lab=Qb}
N 260 -120 260 -100 {lab=Qb}
N 160 -100 260 -100 {lab=Qb}
N -20 -270 -20 -240 {lab=VDD}
N 400 -260 400 -240 {lab=VDD}
N 400 -120 660 -120 {lab=Qb}
N -260 -120 -10 -120 {lab=Q}
N -120 -190 -70 -190 {lab=VDD}
N -70 -240 -70 -190 {lab=VDD}
N 40 -190 90 -190 {lab=VDD}
N 40 -240 40 -190 {lab=VDD}
N -60 -80 -10 -80 {lab=VSS}
N -60 -80 -60 80 {lab=VSS}
N -60 80 -10 80 {lab=VSS}
N -10 30 30 30 {lab=VSS}
N 30 30 30 80 {lab=VSS}
N -10 80 30 80 {lab=VSS}
N 300 -190 350 -190 {lab=VDD}
N 350 -240 350 -190 {lab=VDD}
N 470 -190 510 -190 {lab=VDD}
N 470 -240 470 -190 {lab=VDD}
N 400 -80 450 -80 {lab=VSS}
N 450 -80 450 70 {lab=VSS}
N 400 70 450 70 {lab=VSS}
N 360 30 400 30 {lab=VSS}
N 360 30 360 70 {lab=VSS}
N 360 70 400 70 {lab=VSS}
N -20 -270 400 -270 {lab=VDD}
N 400 -270 400 -260 {lab=VDD}
N 200 -300 200 -270 {lab=VDD}
N 400 90 400 120 {lab=VSS}
N -10 120 400 120 {lab=VSS}
N -10 90 -10 120 {lab=VSS}
N 200 120 200 140 {lab=VSS}
C {symbols/pfet_03v3.sym} -140 -190 0 0 {name=M1
L=0.28u
W=1.0u
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
C {symbols/pfet_03v3.sym} 110 -190 0 1 {name=M2
L=0.28u
W=1.0u
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
C {symbols/nfet_03v3.sym} 10 -80 0 1 {name=M3
L=0.28u
W=1.0u
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
C {symbols/nfet_03v3.sym} -30 30 0 0 {name=M4
L=0.28u
W=1.0u
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
C {symbols/pfet_03v3.sym} 530 -190 0 1 {name=M5
L=0.28u
W=1.0u
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
C {symbols/pfet_03v3.sym} 280 -190 0 0 {name=M6
L=0.28u
W=1.0u
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
C {symbols/nfet_03v3.sym} 380 -80 0 0 {name=M7
L=0.28u
W=1.0u
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
C {symbols/nfet_03v3.sym} 420 30 0 1 {name=M8
L=0.28u
W=1.0u
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
C {iopin.sym} 200 140 1 0 {name=p2 lab=VSS
}
C {iopin.sym} 200 -300 3 0 {name=p4 lab=VDD}
C {ipin.sym} -270 30 0 0 {name=p5 lab=S}
C {ipin.sym} 660 30 2 0 {name=p6 lab=R}
C {opin.sym} -260 -120 2 0 {name=p7 lab=Q}
C {opin.sym} 660 -120 2 1 {name=p8 lab=Qb}

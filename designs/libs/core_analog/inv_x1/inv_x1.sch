v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -90 -40 -40 -40 {lab=vin}
N -90 -40 -90 90 {lab=vin}
N -90 90 -40 90 {lab=vin}
N 0 -10 -0 60 {lab=vout}
N 0 -110 0 -70 {lab=VDD}
N -0 120 0 170 {lab=VSS}
N -0 -40 40 -40 {lab=VDD}
N 40 -80 40 -40 {lab=VDD}
N 0 -80 40 -80 {lab=VDD}
N 0 90 40 90 {lab=VSS}
N 40 90 40 140 {lab=VSS}
N 0 140 40 140 {lab=VSS}
N -130 30 -90 30 {lab=vin}
N 0 30 70 30 {lab=vout}
C {symbols/nfet_03v3.sym} -20 90 0 0 {name=M1
L=0.28u
W=0.5u
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
C {symbols/pfet_03v3.sym} -20 -40 0 0 {name=M2
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
C {iopin.sym} 0 -110 3 0 {name=p2 lab=VDD}
C {iopin.sym} 0 170 1 0 {name=p3 lab=VSS}
C {ipin.sym} -130 30 0 0 {name=p5 lab=vin}
C {opin.sym} 70 30 0 0 {name=p1 lab=vout}

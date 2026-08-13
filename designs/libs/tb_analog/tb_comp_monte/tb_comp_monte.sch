v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -2120 20 -2020 20 {lab=vdd}
N -680 150 -680 210 {lab=0}
N -2120 80 -2120 160 {lab=0}
N -2490 60 -2490 110 {lab=clk}
N -2490 60 -2420 60 {lab=clk}
N -2490 170 -2490 210 {lab=0}
N -2630 20 -2420 20 {lab=vinp}
N -2690 80 -2690 120 {lab=0}
N -2690 20 -2630 20 {lab=vinp}
N -2600 40 -2600 130 {lab=vinn}
N -2600 40 -2420 40 {lab=vinn}
N -2600 190 -2600 210 {lab=0}
N -2020 20 -1930 20 {lab=vdd}
N -2120 40 -1990 40 {lab=raw_voutp}
N -720 160 -720 210 {lab=buf_voutp}
N -720 270 -720 290 {lab=0}
N -2120 60 -2070 60 {lab=raw_voutn}
N -1320 250 -1320 280 {lab=buf_voutn}
N -1320 340 -1320 360 {lab=0}
N -1930 20 -1770 20 {lab=vdd}
N -680 30 -680 90 {lab=vdd}
N -1480 20 -1190 20 {lab=vdd}
N -770 160 -720 160 {lab=buf_voutp}
N -1190 20 -1050 20 {lab=vdd}
N -1310 40 -1050 40 {lab=vdd}
N -2120 160 -2120 280 {lab=0}
N -1990 40 -1960 40 {lab=raw_voutp}
N -1770 20 -1480 20 {lab=vdd}
N -2070 60 -2030 60 {lab=raw_voutn}
N -2030 60 -2030 150 {lab=raw_voutn}
N -1410 190 -1350 190 {lab=buf_voutn}
N -1960 40 -1640 40 {lab=raw_voutp}
N -1580 40 -1580 60 {lab=vdd}
N -1970 260 -1790 260 {lab=0}
N -2120 260 -1970 260 {lab=0}
N -1350 190 -1320 190 {lab=buf_voutn}
N -1320 190 -1320 250 {lab=buf_voutn}
N -1580 40 -1310 40 {lab=vdd}
N -1790 260 -1730 260 {lab=0}
N -1730 190 -1730 260 {lab=0}
N -1730 60 -1730 150 {lab=vdd}
N -1730 60 -1580 60 {lab=vdd}
N -1730 170 -1710 170 {lab=#net1}
N -1410 210 -1410 260 {lab=0}
N -1730 260 -1410 260 {lab=0}
N -1410 40 -1410 170 {lab=vdd}
N -1640 40 -1640 120 {lab=raw_voutp}
N -1640 120 -1390 120 {lab=raw_voutp}
N -1090 40 -1090 120 {lab=vdd}
N -1090 140 -1070 140 {lab=#net2}
N -1090 160 -1090 260 {lab=0}
N -1410 260 -1090 260 {lab=0}
N -1050 20 -680 20 {lab=vdd}
N -680 20 -680 30 {lab=vdd}
N -1050 40 -680 40 {lab=vdd}
N -770 40 -770 140 {lab=vdd}
N -770 180 -770 260 {lab=0}
N -1090 260 -770 260 {lab=0}
C {vsource.sym} -680 120 0 0 {name=VDD value=3.3 savecurrent=false}
C {gnd.sym} -680 210 0 0 {name=l1 lab=0}
C {gnd.sym} -2120 280 0 0 {name=l2 lab=0}
C {vsource.sym} -2490 140 0 0 {name=VCLK value="PULSE(0 3.3 20n 100p 100p 50n 100n)" savecurrent=false}
C {gnd.sym} -2490 210 0 0 {name=l3 lab=0}
C {vsource.sym} -2690 50 0 0 {name=VINP value=\{vcm+vid/2\} savecurrent=false}
C {gnd.sym} -2690 120 0 0 {name=l4 lab=0}
C {vsource.sym} -2600 160 0 0 {name=VINN value=\{vcm-vid/2\} savecurrent=false}
C {gnd.sym} -2600 210 0 0 {name=l5 lab=0}
C {capa.sym} -720 240 0 0 {name=COUTP
m=1
value=5f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} -720 290 0 0 {name=l6 lab=0}
C {capa.sym} -1320 310 0 0 {name=COUTN
m=1
value=5f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} -1320 360 0 0 {name=l7 lab=0}
C {code_shown.sym} -2690 -670 0 0 {name=MODELS
only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice

.param sw_stat_global=0
.param sw_stat_mismatch=1
.param mc_skew=1

.param vcm=1.5
.param vid=0

.lib $::180MCU_MODELS/sm141064.ngspice statistical
"}
C {code_shown.sym} -2710 -420 0 0 {name=NGSPICE
only_toplevel=true
value="

.control
save all

let nrun = 50
let vid_start = -30m
let vid_stop = 30m
let vid_step = 5m
let cur_vid = vid_start

shell rm -f /foss/designs/sscs-chipathon-2026/designs/libs/tb_analog/tb_comp_monte/mc_probability_wide_raw.txt

while cur_vid le vid_stop
  let run = 0
  while run lt nrun
    alterparam vid = $&cur_vid
    reset
    tran 10p 80n
    let bufdiff = v(buf_voutn)-v(buf_voutp)
    meas tran final_diff FIND bufdiff AT=25n
    echo $&cur_vid $&run $&final_diff >> /foss/designs/sscs-chipathon-2026/designs/libs/tb_analog/tb_comp_monte/mc_probability_wide_raw.txt
    let run = run + 1
  end
  let cur_vid = cur_vid + vid_step
end

.endc
"}
C {lab_wire.sym} -2580 20 0 0 {name=p1 sig_type=std_logic lab=vinp}
C {lab_wire.sym} -2500 40 0 0 {name=p2 sig_type=std_logic lab=vinn}
C {lab_wire.sym} -2490 80 0 0 {name=p3 sig_type=std_logic lab=clk}
C {lab_wire.sym} -2030 20 0 0 {name=p4 sig_type=std_logic lab=vdd}
C {lab_wire.sym} -2050 40 0 0 {name=p5 sig_type=std_logic lab=raw_voutp}
C {lab_wire.sym} -2100 60 2 0 {name=p6 sig_type=std_logic lab=raw_voutn}
C {sscs-chipathon-2026/designs/libs/core_analog/comp/comp.sym} -2270 50 0 0 {name=x2}
C {lab_wire.sym} -1320 240 0 0 {name=p7 sig_type=std_logic lab=buf_voutn}
C {lab_wire.sym} -720 160 0 0 {name=p8 sig_type=std_logic lab=buf_voutp}
C {sscs-chipathon-2026/designs/libs/core_analog/inv_x1/inv_x1.sym} -1880 170 0 0 {name=x1}
C {sscs-chipathon-2026/designs/libs/core_analog/inv_x3/inv_x3.sym} -1560 190 0 0 {name=x3}
C {sscs-chipathon-2026/designs/libs/core_analog/inv_x1/inv_x1.sym} -1240 140 0 0 {name=x4}
C {sscs-chipathon-2026/designs/libs/core_analog/inv_x3/inv_x3.sym} -920 160 0 0 {name=x5}

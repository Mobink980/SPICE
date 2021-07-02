*************CMOS Full Adder HSPICE netlist************ 
.include 'mosistsmc180.lib'
*netlist--------------------------------------- 
.param SUPPLY=1.8


*Voltage Sources 
VDD  VDD GND 'SUPPLY'

*signals for showing the correctness
*VA   A   GND  PULSE ('SUPPLY' 0 0ps 100ps 100ps 8ns 16ns)
*VB   B   GND  PULSE ('SUPPLY' 0 0ps 100ps 100ps 16ns 32ns)
*VCin Cin GND  PULSE ('SUPPLY' 0 0ps 100ps 100ps 32ns 64ns)

*signals for calculating circuit parameters for Sum
*VA   A    GND  PULSE (0 'SUPPLY' 0ps 100ps 100ps 8ns 16ns)
*VB   B    GND  0
*VCin Cin  GND  0

*signals for calculating circuit parameters for Cout
VA   A   GND PULSE (0 'SUPPLY' 2ns 100ps 100ps 8ns 16ns)
VB   B   GND PULSE (0 'SUPPLY' 2ns 100ps 100ps 8ns 16ns)
VCin Cin GND 'SUPPLY'


.option scale=90n
.GLOBAL VDD GND * same in the whole circuit

*Defining sub-circuit for CMOS inverter ((W/L)n=1, (W/L)p=2)
.subckt inverter A out N=2 P=4
MP1 VDD A out VDD PMOS W='P' L=2 AS='P*5' PS='2*P+10' AD='P*5' PD='2*P+10'
MN1 out A GND GND NMOS W='N' L=2 AS='N*5' PS='2*N+10' AD='N*5' PD='2*N+10'
.ends

*Defining sub-circuit for CMOS NAND-2 ((W/L)n=2, (W/L)p=2)
.subckt NAND_TWO A B out N=4 P=4
MP1 VDD A out   VDD PMOS W='P' L=2 AS='P*5' PS='2*P+10' AD='P*5' PD='2*P+10'
MP2 VDD B out   VDD PMOS W='P' L=2 AS='P*5' PS='2*P+10' AD='P*5' PD='2*P+10'
MN1 out A node1 GND NMOS W='N' L=2 AS='N*5' PS='2*N+10' AD='N*5' PD='2*N+10' 
MN2 node1 B GND GND NMOS W='N' L=2 AS='N*5' PS='2*N+10' AD='N*5' PD='2*N+10' 
.ends

*Defining sub-circuit for CMOS NAND-3 ((W/L)n=3, (W/L)p=2)
.subckt NAND_THREE A B C out N=6 P=4
MP1 VDD A out     VDD PMOS W='P' L=2 AS='P*5' PS='2*P+10' AD='P*5' PD='2*P+10'
MP2 VDD B out     VDD PMOS W='P' L=2 AS='P*5' PS='2*P+10' AD='P*5' PD='2*P+10'
MP3 VDD C out     VDD PMOS W='P' L=2 AS='P*5' PS='2*P+10' AD='P*5' PD='2*P+10'
MN1 out A node1   GND NMOS W='N' L=2 AS='N*5' PS='2*N+10' AD='N*5' PD='2*N+10' 
MN2 node1 B node2 GND NMOS W='N' L=2 AS='N*5' PS='2*N+10' AD='N*5' PD='2*N+10' 
MN3 node2 C GND   GND NMOS W='N' L=2 AS='N*5' PS='2*N+10' AD='N*5' PD='2*N+10'
.ends

*Defining sub-circuit for CMOS XOR compound gate ((W/L)n=2, (W/L)p=4)
.subckt COMP_XOR A B A_bar B_bar out N=4 P=8
MP1 VDD A node1      VDD PMOS W='P' L=2 AS='P*5' PS='2*P+10' AD='P*5' PD='2*P+10'
MP2 VDD B node1      VDD PMOS W='P' L=2 AS='P*5' PS='2*P+10' AD='P*5' PD='2*P+10'
MP3 node1 A_bar out  VDD PMOS W='P' L=2 AS='P*5' PS='2*P+10' AD='P*5' PD='2*P+10'
MP4 node1 B_bar out  VDD PMOS W='P' L=2 AS='P*5' PS='2*P+10' AD='P*5' PD='2*P+10'
MN1 out A node2      GND NMOS W='N' L=2 AS='N*5' PS='2*N+10' AD='N*5' PD='2*N+10' 
MN2 node2 B GND      GND NMOS W='N' L=2 AS='N*5' PS='2*N+10' AD='N*5' PD='2*N+10' 
MN3 out A_bar node3  GND NMOS W='N' L=2 AS='N*5' PS='2*N+10' AD='N*5' PD='2*N+10'
MN4 node3 B_bar GND  GND NMOS W='N' L=2 AS='N*5' PS='2*N+10' AD='N*5' PD='2*N+10'
.ends


*Instantiating the sub-circuit for sum
Xinv1  A    A_bar    inverter  N=2  P=4
Xinv2  B    B_bar    inverter  N=2  P=4
Xinv3  M    M_bar    inverter  N=2  P=4
Xinv4  Cin  Cin_bar  inverter  N=2  P=4
Xxor1  A  B    A_bar  B_bar    M    COMP_XOR  N=4  P=8 
Xxor2  M  Cin  M_bar  Cin_bar  sum  COMP_XOR  N=4  P=8 
 

*Instantiating the sub-circuit for cout
Xnand1  A  B    W  NAND_TWO  N=4  P=4
Xnand2  A  Cin  Y  NAND_TWO  N=4  P=4
Xnand3  B  Cin  Z  NAND_TWO  N=4  P=4 
Xnand4  W  Y  Z  Cout  NAND_THREE  N=6  P=4 


*Output capacitors
CLoud1 sum  GND 15fF
CLoud2 Cout GND 27fF  


*extra control information--------------------- 
.options post=2 nomod 
.op 

*analysis-------------------------------------- 
*.TRAN 10ps 64ns * transient analysis: Step end_time 
.TRAN 10ps 16ns * transient analysis: Step end_time 


* period for inputs: A = 16ns, B= 0, Cin=0 ==> period for output: LCM(16, 0, 0)=16ns
.measure charge INTEGRAL I(Vdd) FROM=0ns TO=16ns
.measure energy param='-charge * 1.8'


*Measuring the requested values for output Sum 
*.measure tpdr				* rising propagation delay(tpLH)
*+     TRIG v(A)		    VAL='SUPPLY/2' RISE=1 
*+     TARG v(sum)	  	VAL='SUPPLY/2' RISE=1
*.measure tpdf				* falling propagation delay(tpHL), input A is at node 1
*+     TRIG v(A)  	    VAL='SUPPLY/2' FALL=1
*+     TARG v(sum)  	    VAL='SUPPLY/2' FALL=1 
*.measure tpd param='(tpdr+tpdf)/2'	* average propagation delay

*.measure trise					* rise time
*+	TRIG v(sum)	VAL='0.1 * SUPPLY' RISE=1
*+	TARG v(sum)	VAL='0.9 * SUPPLY' RISE=1
*.measure tfall					* fall time
*+	TRIG v(sum)	VAL='0.9 * SUPPLY' FALL=1
*+	TARG v(sum)	VAL='0.1 * SUPPLY' FALL=1


*Measuring the requested values for output Cout 
.measure tpdr				* rising propagation delay(tpLH)
+     TRIG v(A)		    VAL='SUPPLY/2' RISE=1 
+     TARG v(Cout)	  	VAL='SUPPLY/2' RISE=1
.measure tpdf				* falling propagation delay(tpHL), input A is at node 1
+     TRIG v(A)  	    VAL='SUPPLY/2' FALL=1
+     TARG v(Cout)  	VAL='SUPPLY/2' FALL=1 
.measure tpd param='(tpdr+tpdf)/2'	* average propagation delay

.measure trise					* rise time
+	TRIG v(Cout)	VAL='0.1 * SUPPLY' RISE=1
+	TARG v(Cout)	VAL='0.9 * SUPPLY' RISE=1
.measure tfall					* fall time
+	TRIG v(Cout)	VAL='0.9 * SUPPLY' FALL=1
+	TARG v(Cout)	VAL='0.1 * SUPPLY' FALL=1


.END 
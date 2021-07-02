*************CMOS NAND GATE HSPICE netlist************ 
.include 'mosistsmc180.lib'
*netlist--------------------------------------- 
.param SUPPLY=1.8
.param WN=0.18u
.param WP=0.36u
.param LSD=0.36u


* Voltage Sources 
VDD Vdd 0 'SUPPLY'
VA 1 0 PULSE 0 'SUPPLY' 10NS 100PS 100PS 10NS 20NS 	*input line: square wave, amp. rise t, fall t, on t, period 
VB 2 0 PULSE 0 'SUPPLY' 20NS 100PS 100PS 20NS 40NS 	*input line: square wave, amp. rise t, fall t, on t, period 

*Darin Gate Source Bulk Model_Name L=length W=width AS="Area of Source" PS="Perimeter of Source" AD PD
*PULL-UP NETWORK
MP1 vdd 1 out vdd PMOS L=.18u W='WP' AS='WP*LSD' PS='2*WP+2*LSD' AD='WP*LSD' PD='2*WP+2*LSD'
MP2 vdd 2 out vdd PMOS L=.18u W='WP' AS='WP*LSD' PS='2*WP+2*LSD' AD='WP*LSD' PD='2*WP+2*LSD'
*PULL-DOWN NETWORK
MN1 out 1 3 0     NMOS L=.18u W='WN' AS='WN*LSD' PS='2*WN+2*LSD' AD='WN*LSD' PD='2*WN+2*LSD'
MN2 3   2 0 0     NMOS L=.18u W='WN' AS='WN*LSD' PS='2*WN+2*LSD' AD='WN*LSD' PD='2*WN+2*LSD'

*Output capacitor with size C=60fF
CLoud out gnd 60fF  

*extra control information--------------------- 
.options post=2 nomod 
.op 
*analysis-------------------------------------- 
.TRAN 10ps 90ns * transient analysis: Step end_time 

* period for inputs: A = 20ns, B= 40ns ==> period for output: LCM(40, 20)=40ns
.measure charge INTEGRAL I(Vdd) FROM=0ns TO=40ns
.measure energy param='-charge * 1.8'


*Measuring the requested values Wn=0.18um
.measure tpdr				* rising propagation delay(tpLH), input B is at node 2
+     TRIG v(2)		    VAL='SUPPLY/2' FALL=1 
+     TARG v(out)	  	VAL='SUPPLY/2' RISE=1
.measure tpdf				* falling propagation delay(tpHL), input A is at node 1
+     TRIG v(1)  	VAL='SUPPLY/2' RISE=2
+     TARG v(out)  	VAL='SUPPLY/2' FALL=1 
.measure tpd param='(tpdr+tpdf)/2'	* average propagation delay

.measure trise					* rise time
+	TRIG v(out)	VAL='0.2 * SUPPLY' RISE=1
+	TARG v(out)	VAL='0.8 * SUPPLY' RISE=1
.measure tfall					* fall time
+	TRIG v(out)	VAL='0.8 * SUPPLY' FALL=1
+	TARG v(out)	VAL='0.2 * SUPPLY' FALL=1

.END 
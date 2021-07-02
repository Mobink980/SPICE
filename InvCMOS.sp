
*************CMOS Inverter HSPICE netlist************ 
.include 'mosistsmc180.lib'
*netlist--------------------------------------- 
.param SUPPLY=1.8

*VDD Vdd 0 1.8 
VDD Vdd 0 'SUPPLY'
VIN A0 0 PULSE 0 'SUPPLY' 0NS 100PS 100PS 15NS 30NS 	*input line: square wave, amp. rise t, fall t, on t, period 

   *Darin Gate Source Bulk Model_Name L=length W=width AS="Area of Source" PS="Perimeter of Source" AD PD
MP1 vdd A0 Vout vdd PMOS L=.18u W=.72u AS='0.72u*0.36u' PS='2*0.72u+2*0.36u' AD='0.72u*0.36u' PD='2*0.72u+2*0.36u'
MN1 Vout A0 0 0     NMOS L=.18u W=.36u AS='0.36u*0.36u' PS='2*0.36u+2*0.36u' AD='0.36u*0.36u' PD='2*0.36u+2*0.36u'

C Vout gnd 10fF

*extra control information--------------------- 
.options post=2 nomod 
.op 
*analysis-------------------------------------- 
.TRAN 10ps 60ns * transient analysis: Step end_time 
.measure charge INTEGRAL I(Vdd) FROM=0ns TO=30ns
.measure energy param='-charge * 1.8'

.measure tpdr				* rising propagation delay
+     TRIG v(A0)		VAL='SUPPLY/2' FALL=1 
+     TARG v(Vout)	  	VAL='SUPPLY/2' RISE=1
.measure tpdf				* falling propagation delay
+     TRIG v(A0)  	VAL='SUPPLY/2' RISE=2
+     TARG v(Vout)  	VAL='SUPPLY/2' FALL=2 
.measure tpd param='(tpdr+tpdf)/2'	* average propagation delay

.measure trise					* rise time
+	TRIG v(Vout)	VAL='0.1 * SUPPLY' RISE=1
+	TARG v(Vout)	VAL='0.9 * SUPPLY' RISE=1
.measure tfall					* fall time
+	TRIG v(Vout)	VAL='0.9 * SUPPLY' FALL=2
+	TARG v(Vout)	VAL='0.1 * SUPPLY' FALL=2


.END 
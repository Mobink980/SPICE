*sin.sp sinusoidal source
.options post node
v         1     0   sin( 0 1 100meg 2n 5e7 0) 
r         1     0   1 
.tran     .05n  50n 
.end 

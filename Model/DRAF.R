##############################################
# File   : Digital Resonate-and-Fire Neuron
# Author : Trung-Khanh Le
# Email  : ltkhanh@hcmus.edu.vn
# Date   : Feb 20, 2023
# License: MIT
##############################################
# Clean all global environments
rm(list = ls())

# Function: clean R console
# Input: none
# Return: none
cls <- function() {
  cat("\014")
}

# Remove All Plots from RStudio
if (is.null(dev.list()['RStudioGD'])){
  dev.new()
} else{
  dev.off()
}
dev.new()
cls()

# Set the plotting area into a 2*2 array
#par(mfrow=c(2,2))

# Impulse function
impulse <- function(interval,dt,width) {
  pulse <- (rep(0,length(interval)))
  pos <- which((interval>=dt) & (interval<=(dt+width+0.001)))
  pulse[pos] <- 1
  return(pulse)
}
# Damped oscillation
hj <- function(j,dw) ((1/j)*sinpi(j*dw))
current <- function(wrad,dw,dE,timing,n) (
  (-dE*(n+(2/pi)*(hj(1,dw)*cospi(wrad*timing)
                  +hj(2,dw)*cospi(2*wrad*timing)
                  +hj(3,dw)*cospi(3*wrad*timing)
  )
  )
  -(2/pi)*wrad*pi*(hj(1,dw)*sinpi(wrad*timing)
                   +2*hj(2,dw)*sinpi(2*wrad*timing)
                   +3*hj(3,dw)*sinpi(3*wrad*timing)
  )
  )
)
voltage <- function(wrad,dw,timing) (
  (2/pi)*(hj(1,dw)*cospi(wrad*timing)
          +hj(2,dw)*cospi(2*wrad*timing)
          +hj(3,dw)*cospi(3*wrad*timing)
  )
)
dampedPulse <- function(frq,ampl,duty,dampEff,interval) {
  # Convert Frequency to rad/s/pi
  wr <- (360*frq)/180
  return(exp(-dampEff*interval)*ampl*(
    current(wr,duty,dampEff,interval/1000,duty)
    +1i*(duty+voltage(wr,duty,interval/1000))
  )
  )
}
logistic <- function(rate,val,th) {
  return (1/(1+exp(-rate*( val-th))))
}
# Parameters
b <- 0.02         ; d <- 0.3
f <- 20           ; ampere <- 0.2
A <- 1            ; Vn <- 0
k <- 5000         ; tn <- 0
oAct <- rep(0,1)  ; Vc <- rep(0,1)
subOsc <- rep(0,1); cell_State <- rep(0,1)
Vth <- 2*A*(d-(1/2)+(2/pi)*(hj(1,d)
                            +hj(2,d)
                            +hj(3,d)
)
)
print(sprintf("VTH = %f",Vth))
# Simluation
dt = 0.1; tspan <- seq(100,1000,by=dt)
index <- 1; tn_index <- 0;
stimuli<- ampere*(impulse(tspan,110,dt)
                  + impulse(tspan,200,dt)
                  + impulse(tspan,300,dt)
                  + impulse(tspan,350,dt)
                  + impulse(tspan,450,dt)
                  + impulse(tspan,470,dt)
                  + impulse(tspan,600,dt)
                  + impulse(tspan,605,dt)
)
for(t in tspan){
  subOsc[index]     <- dampedPulse(f,A,d,b,t-tn) - 1i*A/2
  Vc[index]         <- Vn*exp(-b*(t-tn))
  cell_State[index] <- subOsc[index] + stimuli[index] + 1i*(Vc[index])
  oAct[index]       <- logistic(k,Im(cell_State[index]),Vth)
  if(stimuli[index]!=0){
    Vn <- Im(subOsc[index]) + Vc[index] + stimuli[index]*dt*b
    tn <- t
    tn_index <- index
  }
  index <- index + 1
}
# Plot cell state
plot(cell_State,type='l',lwd=2.5,cex.lab=1.3)
# draw points
points(Re(cell_State)[1],Im(cell_State)[1],col='red',pch=21,lwd=2,cex=1.5)
points(Re(cell_State)[tn_index-1],Im(cell_State)[tn_index-1],col='red',pch=22,lwd=2,cex=2)
points(Re(cell_State)[tn_index],Im(cell_State)[tn_index],col='red',pch=24,lwd=2,cex=2)
arrows(x0=Re(cell_State)[tn_index],y0=Im(cell_State)[tn_index],
       x1=Re(cell_State)[tn_index+1],y1=Im(cell_State)[tn_index+1],
       col='red',lwd=2)
text(5,Im(cell_State)[tn_index],"tn",cex=2)
text(15,Im(cell_State)[tn_index+1],"tn + dt",cex=2)
#text(-20,Im(cell_State)[tn_index-1],"tn - dt",cex=2)
grid()
# Plot cell's membrane voltage
plot(Im(cell_State),type='l',lwd=3,lty='solid',
     cex.lab=1.3,xaxt="n",ylim=c(-1.7, 1.5),
     xlab="millisecond",ylab="amplitude")
lines((stimuli/ampere)-1.7,type='l',col='red',lwd=2)
text(x=length(tspan)-220,y=-0.2,"Im(cell_State)",cex=2)
text(x=length(tspan)-200,y=-1.5,"Impulse",cex=2)
axis(1,at=seq(1,length(tspan),by=100),
     labels=tspan[(seq(1,length(tspan),by=100))])
grid()
# Plot membrane potential's damped oscillation
plot(Im(subOsc),type='l',lwd=3,lty='dashed',
     cex.lab=1.3,xaxt="n",ylim =c(-1.7, 1.5),
     xlab="millisecond",ylab="amplitude")
# Plot integrator potential component
lines(Vc,type='l',lwd=3,col='blue')
lines((stimuli/ampere)-1.7,type='l',col='red',lwd=2)
text(x=length(tspan)-200,y=0.2,"Vc",cex=2)
text(x=length(tspan)-1000,y=-0.2,"Im(subOsc)",cex=2)
text(x=length(tspan)-500,y=-1.5,"Impulse",cex=2)
axis(1,at=seq(1,length(tspan),by=100),
     labels=tspan[(seq(1,length(tspan),by=100))])
grid()
# Plot Action potential
plot(oAct,type='l',lwd=3,lty='solid',
     cex.lab=1.3,xaxt="n",ylim=c(-1.7, 1.5),
     xlab="millisecond",ylab="amplitude")
lines((stimuli/ampere)-1.7,type='l',col='red',lwd=1)
text(x=length(tspan)-500,y=0.2,"Action",cex=2)
text(x=length(tspan)-500,y=-1.5,"Impulse",cex=2)
axis(1,at=seq(1,length(tspan),by=100),
     labels=tspan[(seq(1,length(tspan),by=100))])
grid()

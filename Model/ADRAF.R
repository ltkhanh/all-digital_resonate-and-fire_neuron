###############################################
# File   : All-Digital Resonate-and-Fire Neuron
# Author : Trung-Khanh Le
# Email  : ltkhanh@hcmus.edu.vn
# Date   : Feb 20, 2023
# License: MIT
###############################################
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
dt = 0.1; tspan <- seq(100,1100,by=dt)
index <- 1; tn_index <- 0;
stimuli<- ampere*(impulse(tspan,110,dt)
                  + impulse(tspan,310,dt)
                  + impulse(tspan,400,dt)
                  + impulse(tspan,500,dt)
                  + impulse(tspan,550,dt)
                  + impulse(tspan,650,dt)
                  + impulse(tspan,670,dt)
                  + impulse(tspan,800,dt)
                  + impulse(tspan,805,dt)
)
for(t in tspan){
  subOsc[index]     <- dampedPulse(f,A,d,b,t-tn) - 1i*A/2
  oscDigi <- logistic(k,Im(subOsc[index]),-0.25) - 0.5
  subOsc[index] <- complex(real=Re(subOsc[index]),imaginary=oscDigi)
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
# plot(Im(cell_State)-4,type='l',lwd=3,lty='solid',
#      cex.lab=1.3,xaxt="n",yaxt="n",ylim=c(-7.5, 1.5),
#      xlab="millisecond",ylab="amplitude")
# lines(rep(Vth-4,index),type='l',lty='dotdash',col='red')
# lines(Im(subOsc),type='l',lty='twodash',lwd=3)
# lines(Vc,type='l',lwd=3,col='blue')
# lines(oAct-6,type='l',lty='solid',lwd=3)
# lines((stimuli/ampere)-7.5,type='l',col='red',lwd=1)
# text(x=length(tspan)-1100,y=-3.9,"Im(cell_State)",cex=2)
# text(x=length(tspan)-500,y=-2.2,"Vth",cex=2)
# text(x=length(tspan)-500,y=0.5,"Vc",cex=2)
# text(x=length(tspan)-1000,y=-1.1,"Im(subOsc)",cex=2)
# text(x=length(tspan)-500,y=-5.5,"Action",cex=2)
# text(x=length(tspan)-500,y=-7,"Impulse",cex=2)
# axis(1,at=seq(1,length(tspan),by=100),
#      labels=tspan[(seq(1,length(tspan),by=100))])

plot(oAct,type='l',lwd=3,lty='solid',col='red',
     xaxt="n",yaxt="n",ylim=c(-3, 1),
     xlab="",ylab="")
title(xlab="millisecond",cex.lab=2,line=3)
title(ylab="amplitude",cex.lab=2,line=1)
lines(Im(subOsc)-1,type='l',lty='solid',lwd=3)
lines((stimuli/ampere)-3,type='l',col='red',lwd=1.2)
text(x=length(tspan)-1000,y=0.5,"Action\npotential",cex=1.5)
text(x=length(tspan)-1000,y=-0.9,"Membrane's\npotential\noscillation",cex=1.5)
text(x=length(tspan)-1000,y=-2.5,"Impulses",cex=2)
axis(1,at=seq(1,length(tspan),by=100),
     labels=tspan[(seq(1,length(tspan),by=100))])

grid()
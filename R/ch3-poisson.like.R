# ---------------------------------------------------------------------------- #
#                             CHAPTER 3. POISSON MLE                        ----
# ---------------------------------------------------------------------------- #

# A POISSON LIKELIHOOD AND LOG-LIKELIHOOD FUNCTION
llhfunc<-function(X,p,do.log=TRUE) {
    d <- rep(X,length(p))
    print(d)
    u.vec <- rep(p,each=length(X))
    print(u.vec)
    d.mat <- matrix(dpois(d,u.vec,log=do.log),ncol=length(p))
    print(d.mat)
    if (do.log==TRUE) apply(d.mat,2,sum)
    else apply(d.mat,2,prod)
}


y.vals<-c(1,3,1,5,2,6,8,11,0,0)

# EXAMPLE RUN FOR TWO POSSIBLE VALUES OF THETA: 4 AND 30 
llhfunc(y.vals,c(4,30))

# USE THE R CORE FUNCTION FOR OPTIMIZING,
# par=STARTING VALUES,
# control=list(fnscale=-1) INDICATES A MAXIMIZATION, 
# bfgs=QUASI-NEWTON ALGORITHM
mle <- optim(par=1,fn=llhfunc,X=y.vals,
    control=list(fnscale=-1),method="BFGS")

# GRAPH
pdf("./Images/poisson.like.pdf")
par(oma=c(6,6,2,2),mar=c(0,0,0,0),cex.lab=2,mfrow=c(2,1))
ruler <- seq(from=.01, to=20, by= .01)
poison.ll <- llhfunc(y.vals,ruler)
poison.l <- llhfunc(y.vals,ruler,do.log=FALSE)
plot(ruler,poison.l,type="l",xaxt="n",lwd=3,xlab="")
text(mean(ruler),mean(poison.l),"Poisson Likelihood Function")
plot(ruler,poison.ll,type="l",lwd=3,xlab=expression(paste("Support of ",theta)))
text(mean(ruler)+5,mean(poison.ll)/2,"Poisson Log-Likelihood Function")
mtext(side=1,line=4,cex=1.5,outer=TRUE, expression(paste("Support of ",theta)))
mtext(side=2,line=4,cex=1.5,outer=TRUE, "Function Values")
dev.off()

#system("open ./Images/poisson.like.pdf")
#system("pdf2ps ./Images/poisson.like.pdf ./Images/poisson.like.ps")

# ---------------------------------------------------------------------------- #
#                        CHAPTER 5. NORMAL-NORMAL MODEL                     ----
# ---------------------------------------------------------------------------- #

# Data is accessed at: https://www.glassdoor.com/Salaries/data-scientist-salary-SRCH_KO0,14.htm
# N = 8,880

library(MCMCpack) # FOR THE dinvgamma(x, shape, scale = 1) FUNCTION

# DATA
salary <- scan("./Data/glassdoor.dat")
salary <- salary/1000
n <- length(salary)

#summary(salary)
#var(salary)


# inverse gamma mean = b/(a-1); inverse gamma variance = b^2/((a-1)^2 * (a-2))

# HYPERPRIOR VALUES
m <- 170; a <- 2; b <- 550

# POSTERIOR PARAMETERS
post.a <- a + n/2 + 1/2
post.b <- b + 0.5*sum(salary^2) - 0.5*n*mean(salary)^2
post.mu <- (n*mean(salary) + m)/n
post.var <- post.b/(post.a - 1)

# GRAPH
pdf("./Images/glassdoor.pdf")
par(oma=c(1,1,1,1), mar=c(3,5,1,1),cex.lab=1.5, mfrow=c(2,1))
ruler <- seq(60,300,length=500)
prior.dens <- dnorm(ruler,m,sqrt(b/(a-1)))
plot(ruler,prior.dens,type="l",ylim=c(0,0.018),lwd=3,
    col="grey70", ylab=expression(paste(mu," Density")),xlab="")
post.dens <- dnorm(x=ruler,mean=post.mu,sd=sqrt(post.var))
lines(ruler,post.dens,lwd=3, col="grey30") 
text(125,0.010,"Prior",col="grey70",cex=1.10,adj=0.5)
text(250,0.0050,"Posterior",col="grey10",cex=1.10,adj=0.5)
ruler <- seq(0,2000,length=500)
prior.dens <- dinvgamma(ruler,a,b)
plot(ruler,prior.dens,type="l",ylim=c(0,0.0025),xlim=c(-200,2000),lwd=3,
    col="grey70", ylab=expression(paste(sigma^2," Density")),xlab="")
post.dens <- dinvgamma(ruler,post.a,post.b)
lines(ruler,post.dens,lwd=3,col="grey30")
text(-50,0.0020,"Prior",col="grey70",cex=1.10,adj=0.5)
text(1060,0.0010,"Posterior",col="grey10",cex=1.10,adj=0.5)
dev.off()

#system("open   ./Images/glassdoor.pdf")
#system("pdf2ps ./Images/glassdoor.pdf ./Images/glassdoor.ps")















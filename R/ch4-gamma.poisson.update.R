# ---------------------------------------------------------------------------- #
#                        CHAPTER 4. POISSON GAMMA UPDATE                    ----
# ---------------------------------------------------------------------------- #

pdf("./Images/poisson.gamma.update.pdf")
y <- c(3,10,7,12,5,11,12,14,9,19,27,13,20,18,19,19,19,31,30,30,40,61)
par(mar=c(6,6,2,2), cex.lab=1.5)
ruler <- seq(from=0,to=25,length=300)
alpha <-14; beta <- 2
plot(ruler,dgamma(ruler,alpha,beta),type="l",ylim=c(0,0.5),lwd=3,
    col="grey70", ylab="Density",xlab="Support")
lines(ruler,dgamma(ruler,alpha+sum(y),beta+length(y)),lwd=4)
text(7,0.25,"Prior",col="grey70",cex=1.5,adj=0.5)
text(18.46,0.485,"Posterior",col="grey10",cex=1.5,adj=0.5)
dev.off()

#system("open   ./Images/poisson.gamma.update.pdf")
#system("pdf2ps ./Images/poisson.gamma.update.pdf ./Images/poisson.gamma.update.ps")

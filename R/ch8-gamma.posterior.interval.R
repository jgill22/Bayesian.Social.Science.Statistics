# ---------------------------------------------------------------------------- #
#                        CHAPTER 8. GAMMA POSTERIOR INTERVALS               ----
# ---------------------------------------------------------------------------- #

# Dataset for the Founta et al. (2018),"Large Scale Crowdsourcing and Characterization of Twitter Abusive Behavior" paper, published in ICWSM 2018. 
# Data is accessed from: https://zenodo.org/records/3678559#.Xk_23y97FhE.
# The dataset provided here includes an hated version of the original dataset, 

# DATA & SETUP
hate.retweets <- read.csv("./Data/hate.retweets.csv",
    header=FALSE)
num.retweets <- rep(NA,nrow(hate.retweets))
for (i in 1:nrow(hate.retweets))  
    num.retweets[i] <- sum(!is.na(hate.retweets[i,]))
y <- num.retweets[num.retweets < 100]
n <- length(y)
# summary(y)
# var(y)


# REMINDER: inverse gamma mean = b/(a-1); inverse gamma variance = b^2/((a-1)^2 * (a-2))
# HYPERPRIOR VALUES
m <- 5; a <- 50; b <- 10


# POSTERIOR PARAMETERS from {G}(9379,1966)
post.a <- a + sum(y)
post.b <- b + n
post.mean <- post.a/post.b
post.var <- post.a/(post.b^2)


# GRAPH OF PRIOR-POSTERIOR AND POSTERIOR QUANTILES
pdf("./Images/poisson.gamma.hate.pdf")
par(oma=c(5,5,2,2), mar=c(0,0,0,0),cex.lab=1.25,mfrow=c(1,2))
ruler <- seq(from=3,to=7,length=500)
plot(ruler,dgamma(ruler,a,b),type="l",lwd=3,col="grey70", ylab="",xlim=c(3,7),ylim=c(0,8))
mtext(side=1,outer=FALSE,expression(paste(theta," Support")),cex=1.5,line=3)
mtext(side=2,outer=TRUE,"Density",cex=1.5,line=3)
lines(ruler,dgamma(ruler,post.a,post.b),lwd=4,col="grey30")
text(4,0.75,"Prior",col="grey70",cex=1.25,adj=0.5)
text(5.72,6,"Posterior",col="grey10",cex=1.25,adj=0.5)
curve1.x <- seq(5.25,7.4,length=20); curve1.y <- 4.50+sin(curve1.x)
lines(curve1.x,curve1.y,lwd=3,lty=2,col="red")
plot(ruler,dgamma(ruler,post.a,post.b),lwd=4,col="grey30",ylab="",xlab="",yaxt="n",
    type="l",xlim=c(4.55,5.0),ylim=c(0,8))
mtext(side=1,outer=FALSE,expression(paste("Posterior ",theta," Support")),cex=1.5,line=3)
g.quantiles <- qgamma(c(0.25,0.5,0.75),post.a,post.b)
for (i in ruler[1:259]) segments(i,0,i,dgamma(i,post.a,post.b), col="grey85",lwd=5)
for (i in ruler[260:264]) segments(i,0,i,dgamma(i,post.a,post.b), col="grey75",lwd=5)
for (i in ruler[264:268]) segments(i,0,i,dgamma(i,post.a,post.b), col="grey50",lwd=5)
for (i in ruler[269:500]) segments(i,0,i,dgamma(i,post.a,post.b), col="grey30",lwd=5)
lines(ruler,dgamma(ruler,post.a,post.b),lwd=5,col="grey30")
abline(h=0,lwd=3)
curve2.x <- seq(4.40,4.70,length=20); curve2.y <- 4.27+cos(curve1.x)
lines(curve2.x,curve2.y,lwd=3,lty=2,col="red")
segments(curve2.x[20],curve2.y[20],curve2.x[20]-0.009,curve2.y[20]+0.30,lwd=3,col="red")
segments(curve2.x[20],curve2.y[20],curve2.x[20]-0.022,curve2.y[20]-0.08,lwd=3,col="red")
dev.off()
system("open   ./Images/poisson.gamma.hate.pdf")
system("pdf2ps ./Images/poisson.gamma.hate.pdf ./Images/poisson.gamma.hate.ps")


# POSTERIOR DENSITY TO THE RIGHT OF 4.75
1-pgamma(4.75,shape=post.a,rate=post.b)


# QUANTILES OF THE POSTERIOR FOR theta
n.sims <- 1000000
theta.large.sample <- rgamma(n.sims,post.a,post.b)
summary(theta.large.sample)


# CREDIBLE INTERVALS FOR theta
vals <- c(0.001,0.01,0.05,0.10)
sort.theta.sample <- sort(theta.large.sample)
round(sort.theta.sample[c(n.sims*vals,n.sims*(1-vals))],3)


# HPD INTERVAL for theta
n.sims <- 10000
mix.dat <- c(rnorm(n.sims/2,1,1), rnorm(n.sims/2,7,2)) 
mix.dens <- density(mix.dat)
alpha <- 0.05
decrement <- 10000
target <- sum(mix.dens$y * mix.dens$x) * alpha
exclude <- sum(mix.dens$y * mix.dens$x)
k <- max(mix.dens$y)
while (exclude > target) {
    k <- k - k/decrement
    exclude <- sum(mix.dens$y[mix.dens$y < k]* mix.dens$x[mix.dens$y < k]) 
    print(paste("exclude: ",exclude," k: ",k))
}


# COMPARING MODELS WITH DIFFERENT HYPERPRIOR VALUES
m1 <- 5; a1 <- 50; b1 <- 10
m2 <- 2; a2 <- 1; b2 <- 1000
post.a1 <- a1 + sum(y); post.b1 <- b1 + n
post.a2 <- a2 + sum(y); post.b2 <- b2 + n
theta1.vals <- rgamma(100000,shape=post.a1,rate=post.b1)
theta2.vals <- rgamma(100000,shape=post.a2,rate=post.b2)
y1 <- y2 <- NULL
for (i in 1:1000)  {
    y1 <- c(y1,rpois(n,sample(theta1.vals,1,replace=TRUE)))
    y2 <- c(y2,rpois(n,sample(theta2.vals,1,replace=TRUE)))
}
y1 <- y1[y1 > 1]; y2 <- y2[y2 > 1]
rbind(summary(y),summary(y1),summary(y2))
 
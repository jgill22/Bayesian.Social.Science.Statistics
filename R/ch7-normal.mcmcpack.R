# ---------------------------------------------------------------------------- #
#                    CHAPTER 7. NORMAL-NORMAL MODEL WITH MCMCPACK           ----
# ---------------------------------------------------------------------------- #

library(MCMCpack)

# DATA
salary <- scan("./Data/glassdoor.dat")
salary <- salary/1000

# HYPERPRIOR VALUES
## Normal distribution mean
m <- 170; 
## Alpha and beta for inverse gamma distribution
a <- 2; b <- 550

# POSTERIOR SAMPLES
posterior_samples <- MCMCregress(salary ~ 1, 
                                 n.samples = 10000, 
                                 b0 = m, B0 = 1,
                                 c0 = a*2, d0 = b*2)
post.mu <- mean(posterior_samples[,1])
post.var <- mean(posterior_samples[,2])


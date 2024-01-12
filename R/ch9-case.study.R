################################################################################
#                              CHAPTER 9. CASE STUDY                           #
################################################################################

library(xtable)

# POSTERIOR DISTRIBUTION
## Polling Data
polls <- read.csv("./Data/polls2020.csv")
polls$end_date <- as.Date(polls$end_date)
election2016 <- read.csv("./Data/election2016.csv")
ga <- subset(polls, state=="Georgia")

## Parameters
kappa <- 500; w0 <- 0.1
ruler <- seq(0,1,length=5000)
days <- as.numeric(as.Date("2020-11-02")-ga$end_date)

## Prior
alpha <- 0.473*kappa; beta <- kappa-alpha

## Long Memory Temporal Weights
wt <- ifelse(days > 56, 0.2, 1-days/70)

## Posterior
sum_n <- sum(ga$sample_size*w0*wt)
sum_y <- sum(ga$dem_share*ga$sample_size*w0*wt)
prior <- dbeta(ruler,alpha,beta)
post_alpha <- alpha+sum_y
post_beta <- sum_n-sum_y+beta
posterior <- dbeta(ruler,post_alpha,post_beta)

# BIDEN'S SUPPORT
## Point Estimate
post_mean <- post_alpha / (post_alpha + post_beta)

## Credible Interval
n_sims <- 1000000
post_samples <- rbeta(n_sims, post_alpha, post_beta)
sorted_samples <- sort(post_samples)
vals <- rev(c(0.001,0.01,0.05,0.10))
round(sorted_samples[c(n_sims*vals, n_sims*(1-vals))],3)

### USE HDInterval PACKAGE
library(HDInterval)
hdi(post_samples, credMass = 0.95)
sapply(1-vals, function(vals) hdi(post_samples, credMass = vals))


# DYNAMIC VOTER PREFERENCES
months <- seq(1,11,1)
posteriors <- matrix(NA, nrow=length(months),ncol=5000)

## Placeholder
post_est <- rep(NA, length(months))
post_ci <-  matrix(NA, nrow=length(months),ncol=2)

## Prior
alpha <- 0.473*kappa; beta <- kappa-alpha
priors <- dbeta(ruler,alpha,beta)

## Iterate through each month
for (m in 1:length(months)){ 
  today <- as.Date(paste0("2020-",months[m],"-03"))
  ga <- polls[polls$state=="Georgia" & 
              polls$end_date <= today,]
  days <- as.numeric(max(ga$end_date)-ga$end_date)
  # Weights
  w0 <- 0.1
  wt <- ifelse(days > 56, 0.2, 1-days/70)
  # Posterior
  sum_n <- sum(ga$sample_size*w0*wt)
  sum_y <- sum(ga$dem_share*ga$sample_size*w0*wt)
  post_alpha <- alpha+sum_y
  post_beta <- sum_n-sum_y+beta
  posteriors[m,] <- dbeta(ruler,post_alpha,post_beta)
  post_est[m] <- post_alpha / (post_alpha+post_beta)
  post_ci[m,] <- hdi(rbeta(n_sims,post_alpha,post_beta),
                     credMass=0.95)
}

# SIMULATING ELECTORAL COLLEGE OUTCOMES
## 2016 Election Data
election2016 <- read.csv("data/election2016.csv")
states <- unique(election2016$state)
n_sims <- 50000; n_state <- length(states)

## Dates
months <- seq(4,11,1)
dates <- as.Date(c(paste0("2020-",months,"-03"), 
                   paste0("2020-",months[-length(months)],"-10"),
                   paste0("2020-",months[-length(months)],"-17"),
                   paste0("2020-",months[-length(months)],"-24")))
dates <- dates[order(dates)]; n_date <- length(dates)
## Kappa
kappa <- 500
sim_res <- array(data=NA,dim=c(n_state,n_sims,n_date))

## For each state
for (i in 1:n_state){
  cat(states[i], "\n")
  state_dat <- polls[polls$state==states[i],]
  state_dat <- state_dat[order(state_dat$end_date),]
  alpha <- election2016[election2016$state==states[i],]$dem_share*kappa
  beta <- kappa - alpha
  ## For each select date
  for (d in 1:length(dates)){
    sub_dat <- state_dat[state_dat$end_date < dates[d],]
    if (nrow(sub_dat) > 0) {
      days <- as.numeric(max(sub_dat$end_date)-sub_dat$end_date)
      w0 <- 0.1
      wt <- ifelse(days > 56, 0.2, 1-days/70)
      sum_n <- sum(sub_dat$sample_size*w0*wt)
      sum_y <- sum(sub_dat$dem_share*sub_dat$sample_size*w0*wt)
      post_alpha <- alpha+sum_y
      post_beta <- sum_n-sum_y+beta
    } else {
      # For states with no polls at the point, use the prior
      post_alpha <- alpha
      post_beta <- beta
    }
    pis <- rbeta(n_sims, post_alpha, post_beta)
    outcomes <- rbinom(length(pis), 2000, pis)/2000 > 0.5
    evs <- ifelse(outcomes, 
                  election2016[election2016$state == states[i],]$ev, 
                  0)
    sim_res[i,,d] <- evs
  }
}

ev_sum <- apply(sim_res, c(2,3), sum)
biden_win <- apply(ev_sum, 2, function(x) sum(x>=270))/n_sims

#biden_win
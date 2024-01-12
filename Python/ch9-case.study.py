"""\
CHAPTER 9. CASE STUDY
"""

# %%
# LIBRARY
import pandas as pd
import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import arviz as az

# POSTERIOR DISTRIBUTION
# %%
polls = pd.read_csv("./Data/polls2020.csv")
election2016 = pd.read_csv("./Data/election2016.csv")
polls['end_date'] = pd.to_datetime(polls['end_date'])

ga = polls[polls['state'] == "Georgia"]
ruler = np.linspace(0, 1, 5000)
sum_n = ga['sample_size'].sum()
sum_y = (ga['dem_share'] * ga['sample_size']).sum()
n_poll = ga.shape[0]
alpha = 473
beta = 1000 - alpha
prior = stats.beta.pdf(ruler, alpha, beta)
post_alpha = alpha + sum_y
post_beta = sum_n - sum_y + beta
posterior = stats.beta.pdf(ruler, post_alpha, post_beta)

#prior_rs = prior / np.max(prior)
#posterior_rs = posterior / np.max(posterior)

# %%
# BIDEN'S SUPPORT
post_mean = post_alpha / (post_alpha + post_beta)
print(post_mean)

# %%
## Credible Intervals
n_sims = 1000000
post_samples = stats.beta.rvs(post_alpha, post_beta, size=n_sims)
sorted_samples = np.sort(post_samples)
vals = np.array([0.001, 0.01, 0.05, 0.1])
lower = [np.round(sorted_samples[int(n_sims * val)], 3) for val in vals]
upper = [np.round(sorted_samples[int(n_sims * (1 - val))], 3) for val in vals]
print(list(zip(lower, upper)))

## Use az.hdi() to calculate the HDI
hdi = az.hdi(post_samples, hdi_prob=0.95)
print(hdi)

## Iterate through each values
ci_tab = [az.hdi(post_samples, hdi_prob=val) for val in 1 - vals]
print(ci_tab)

ci_tab2 = pd.DataFrame({
    "99.9%": [f"[{round(ci_tab[0][0], 3)}, {round(ci_tab[0][1], 3)}]"],
    "99%"  : [f"[{round(ci_tab[1][0], 3)}, {round(ci_tab[1][1], 3)}]"],
    "95%"  : [f"[{round(ci_tab[2][0], 3)}, {round(ci_tab[2][1], 3)}]"],
    "90%"  : [f"[{round(ci_tab[3][0], 3)}, {round(ci_tab[3][1], 3)}]"],
})
print(ci_tab2)
###############################################################

# %%
# DYNAMIC VOTER PREFERENCES
months = np.arange(1, 12, 1)
posteriors = np.empty((len(months), 5000))
post_est = np.empty(len(months))
post_ci = np.empty((len(months), 2))
ruler = np.linspace(0, 1, 5000)
alpha = 473
beta = 1000 - alpha
priors = stats.beta.pdf(ruler, alpha, beta)

for m in range(len(months)):
    today = pd.Timestamp(2020, months[m], 3)
    ga = polls[(polls['state'] == "Georgia") & 
               (polls['end_date'] <= today)]
    sum_n = ga['sample_size'].sum()
    sum_y = (ga['dem_share'] * ga['sample_size']).sum()
    post_alpha = alpha + sum_y
    post_beta = sum_n - sum_y + beta
    posteriors[m, :] = stats.beta.pdf(ruler, post_alpha, post_beta)
    post_est[m] = post_alpha / (post_alpha + post_beta)
    post_samples = stats.beta.rvs(post_alpha, post_beta, size=n_sims)
    post_ci[m, :] = az.hdi(post_samples, hdi_prob=0.95)


# SIMULATING ELECTORAL VOTES
# %%
election2016 = pd.read_csv("./Data/election2016.csv")
states = election2016['state'].unique()
n_sims = 10000; n_state = len(states)
months = range(3, 12)
dates = pd.to_datetime([f"2020-{month}-03" for month in months] + [f"2020-{month}-17" for month in months[:-1]])
dates = sorted(dates)
n_date = len(dates)

# %%
sim_res = np.empty((n_state, n_sims, n_date))
for i, state in enumerate(states):
    print(state)
    state_dat = polls[polls['state'] == state].sort_values('end_date')
    alpha = election2016[election2016['state'] == state]['dem_share'].item() * 1000
    beta_value = 1000 - alpha

    for d, date in enumerate(dates):
        sub_dat = state_dat[state_dat['end_date'] < date]
        sum_n = sub_dat['sample_size'].sum()
        sum_y = (sub_dat['dem_share'] * sub_dat['sample_size']).sum()

        post_alpha = alpha + sum_y
        post_beta = sum_n - sum_y + beta_value

        pis = stats.beta.rvs(post_alpha, post_beta, size=n_sims)
        outcomes = stats.binom.rvs(n=1000, p=pis, size=n_sims) / 1000 > 0.5
        evs = np.where(outcomes, election2016[election2016['state'] == state]['ev'].item(), 0)

        sim_res[i, :, d] = evs

ev_sum = sim_res.sum(axis=0)
biden_win = np.apply_along_axis(lambda x: np.bincount(x > 269, minlength=2), 0, ev_sum) / n_sims

# %%
#print(biden_win)

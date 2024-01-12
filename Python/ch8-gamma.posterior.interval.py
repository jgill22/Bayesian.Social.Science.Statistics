"""\
CHAPTER 8. GAMMA POSTERIOR INTERVALS 
"""

# Dataset for the Founta et al. (2018),"Large Scale Crowdsourcing and Characterization of Twitter Abusive Behavior" paper, published in ICWSM 2018. 
# Data is accessed from: https://zenodo.org/records/3678559#.Xk_23y97FhE.

# %%
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import ConnectionPatch
from scipy.stats import gamma, poisson, gaussian_kde

# %%
hate_retweets = pd.read_csv("./data/hate.retweets.csv", header=None)
n = hate_retweets.shape[0]

# %%
num_retweets = hate_retweets.count(axis=1).values
num_retweets = num_retweets[num_retweets < 100]
n = len(num_retweets)
y = num_retweets

# %%
# Hyperprior values
m = 5; a = 50; b = 10

# Posterior parameters
post_a = a + np.sum(y)
post_b = b + n
post_mean = post_a / post_b
post_var = post_a / (post_b**2)

# %%
# POSTERIOR DENSITY TO THE RIGHT OF 4.75
p = 1 - gamma.cdf(4.75, post_a, scale=1/post_b)
print(p)

# %%
fig, axs = plt.subplots(1, 2, figsize=(12, 6))
ruler = np.linspace(3, 7, 500)
axs[0].plot(ruler, gamma.pdf(ruler, a, scale=1/b), 
            color='0.7', linewidth=3, label='Prior')
axs[0].plot(ruler, gamma.pdf(ruler, post_a, 
            scale=1/post_b), color='black', 
            linewidth=3, label='Posterior')
axs[0].text(4, 0.75, "Prior", color='0.7', fontsize=12)
axs[0].text(5, 6, "Posterior", color='0.3', fontsize=12)
axs[0].set_xlabel('$\Theta$  Support')
axs[0].set_ylabel('Density')
axs[0].set_ylim(-0.25, 8.25)
axs[1].plot(ruler, gamma.pdf(ruler, post_a, 
            scale=1/post_b), color='black', linewidth=3)
axs[1].set_xlim(4.55, 5.0)
axs[1].set_ylim(-0.25, 8.25)
axs[1].set_xlabel('Posterior $\Theta$ Support')
axs[1].tick_params(which='both', left=False, 
                   labelleft=False)
axs[1].fill_between(ruler, gamma.pdf(ruler, post_a, 
                     scale=1/post_b), color='0.85')
con = ConnectionPatch(
    xyA=(0.5, 3.55), coordsA=axs[0].get_yaxis_transform(),
    xyB=(0.3, 5), coordsB=axs[1].get_yaxis_transform(), 
    linestyle='dashed', arrowstyle="->", lw=2, 
    color='red', connectionstyle="angle,angleA=-150,angleB=-20,rad=50")
axs[1].add_artist(con)
plt.subplots_adjust(wspace=0)
plt.show()

# %%
# QUANTILES OF THE POSTERIOR FOR theta 
n_sims = 1000000
theta_large_sample = np.random.gamma(post_a, 1/post_b, size=n_sims)
#theta_large_sample = gamma.rvs(post_a, scale=1/post_b, size=n_sims)
pd.DataFrame(theta_large_sample).describe()

# %%
# CREDIBLE INTERVALS FOR theta
vals = np.array([0.001,0.01,0.05,0.10]) 
sorted_theta_sample = np.array(sorted(theta_large_sample)) 
print(np.round(sorted_theta_sample[np.floor(n_sims*vals).astype(int)], 3))
print(np.round(sorted_theta_sample[np.floor(n_sims*(1-vals)).astype(int)], 3))

# %%
# HPD INTERVAL for theta
n_sims = 10000
mix_dat = np.concatenate((np.random.normal(1, 1, int(n_sims/2)), np.random.normal(7, 2, int(n_sims/2))))
mix_dens = gaussian_kde(mix_dat)
x = np.linspace(min(mix_dat), max(mix_dat), n_sims)
y = mix_dens(x)

alpha = 0.05
decrement = 10000
target = np.sum(y * x) * alpha
exclude = np.sum(y * x)
k = max(y)

while exclude > target:
    k -= k / decrement
    mask = y < k
    exclude = np.sum(y[mask] * x[mask])
    print(f"exclude: {exclude}   k: {k}")

# %%
# Model Comparison
m1, a1, b1 = 5, 50, 10
m2, a2, b2 = 2, 1, 1000

post_a1 = a1 + np.sum(y)
post_b1 = b1 + len(y)
post_a2 = a2 + np.sum(y)
post_b2 = b2 + len(y)

theta1_vals = gamma.rvs(a=post_a1, scale=1/post_b1, size=100000)
theta2_vals = gamma.rvs(a=post_a2, scale=1/post_b2, size=100000)

y1 = []
y2 = []
for _ in range(1000):
    y1.extend(poisson.rvs(mu=np.random.choice(theta1_vals, 1, replace=True), size=len(y)))
    y2.extend(poisson.rvs(mu=np.random.choice(theta2_vals, 1, replace=True), size=len(y)))

y1 = np.array(y1)
y2 = np.array(y2)

y1 = y1[y1 > 1]
y2 = y2[y2 > 1]

# Summary of y
print(np.percentile(y, [0, 25, 50, 75, 100]))
# Summary of y1
print(np.percentile(y1, [0, 25, 50, 75, 100]))
# Summary of y2
print(np.percentile(y2, [0, 25, 50, 75, 100]))
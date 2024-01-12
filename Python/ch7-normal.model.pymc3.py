"""\
CHAPTER 7. NORMAL-NORMAL MODEL WITH PYMC3
"""

# %%
import numpy as np
import pymc as pm

# %%
salary = np.loadtxt("./data/glassdoor.dat")
salary /= 1000
m = 170; a = 2; b = 550

# %%
with pm.Model() as model:
    # Priors
    sigma_sq = pm.InverseGamma('sigma_sq', alpha=a, beta=b)
    mu = pm.Normal('mu', mu=m)

    # Likelihood
    obs = pm.Normal('obs', mu=mu, tau=1/sigma_sq, observed=salary)

    # Sampling
    trace = pm.sample(10000, tune=1000, chains=3)

# %%
post_mu = np.mean(trace.posterior["mu"])
post_var = np.mean(trace.posterior["sigma_sq"])

# %%
print(post_mu)
print(post_var)

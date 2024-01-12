"""\
CHAPTER 3. POISSON MLE
"""

# %%
import numpy as np
from scipy.stats import poisson
import matplotlib.pyplot as plt

# %%
def llhfunc(X, p, do_log=True):
    lX, lp = len(X), len(p)
    d = np.tile(X, lp)
    u = np.repeat(p, lX)
    p_pmf = [poisson.pmf(d[i:i+lX], u[i:i+lX])
             for i in range(0, lX*lp, lX)]
    d_mat = np.log(p_pmf).T if do_log else \
            np.array(p_pmf).T
    return np.sum(d_mat, axis=0) if do_log else \
           np.prod(d_mat, axis=0)

# EXAMPLE RUN FOR TWO POSSIBLE VALUES OF THETA: 4 AND 30
llhfunc(y_vals,np.array([4, 30]))

# %%
y_vals = np.array([1, 3, 1, 5, 2, 6, 8, 11, 0, 0])

ruler = np.arange(.01, 20.01, .01)
poison_ll = llhfunc(y_vals, ruler)
poison_l = llhfunc(y_vals, ruler, do_log=False)

# %%
fig, axs = plt.subplots(2, 1, figsize=(8, 12))

# Poisson Likelihood Function
axs[0].plot(ruler, poison_l, linewidth=3)
axs[0].annotate('Poisson Likelihood Function', 
                xy=(np.mean(ruler), np.mean(poison_l)), 
                xytext=(np.mean(ruler)-2, np.mean(poison_l)))
axs[0].tick_params(which='both', bottom=False, labelbottom=False)

# Poisson Log-Likelihood Function
axs[1].plot(ruler, poison_ll, linewidth=3)
axs[1].set_xlabel('Support of $\Theta$')
axs[1].annotate('Poisson Log-Likelihood Function', 
                xy=(np.mean(ruler), np.mean(poison_ll)), 
                xytext=(np.mean(ruler)+2, np.mean(poison_ll)+20))

plt.subplots_adjust(hspace=0)
plt.show()

"""\
CHAPTER 5. NORMAL-NORMAL MODEL  
"""

# %%
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import norm, invgamma

# %%
# Load and process salary data
salary = np.loadtxt("./Data/glassdoor.dat")
salary /= 1000
n = len(salary)

# %%
m = 170; a = 2; b = 550

# Calculate posterior parameters
post_a = a + n/2 + 1/2
post_b = b + 0.5*sum(salary**2) - \
         0.5*n*np.mean(salary)**2
post_mu = (n*np.mean(salary) + m)/n
post_var = post_b/(post_a - 1)


# %%
fig, axs = plt.subplots(2, 1, figsize=(8, 12))
ruler = np.linspace(60, 300, num=500)
prior_mu = norm.pdf(ruler, m, scale=np.sqrt(b/(a-1)))
post_mu = norm.pdf(ruler, post_mu, np.sqrt(post_var))
axs[0].plot(ruler, prior_mu, color='grey', 
            linewidth=3, label='Prior')
axs[0].plot(ruler, post_mu, color='black', 
            linewidth=3, label='Posterior')
axs[0].set_ylabel(r'$\mu$ Density')
axs[0].text(125, 0.010, 'Prior', color='grey', 
            fontsize=12, ha='center')
axs[0].text(248, 0.0050, 'Posterior', color='black', 
            fontsize=12, ha='center')
ruler = np.linspace(0, 2000, num=500)
prior_s2 = invgamma.pdf(ruler, a, scale=b)
post_s2 = invgamma.pdf(ruler, post_a, scale=post_b)
axs[1].plot(ruler, prior_s2, color='grey', 
            linewidth=3, label='Prior')
axs[1].plot(ruler, post_s2, color='black', 
            linewidth=3, label='Posterior')
axs[1].set_ylabel(r'$\sigma^2$ Density')
axs[1].text(0, 0.0020, 'Prior', color='grey', 
            fontsize=12, ha='center')
axs[1].text(1050, 0.0010, 'Posterior', color='black', 
            fontsize=12, ha='center')
plt.subplots_adjust(hspace=0.15)
plt.show()

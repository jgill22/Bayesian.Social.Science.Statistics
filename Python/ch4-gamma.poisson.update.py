"""\
CHAPTER 4. POISSON GAMMA UPDATE 
"""

# %%
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import gamma

# %%
y = np.array([3,10,7,12,5,11,12,14,9,19,27,13,
              20,18,19,19,19,31,30,30,40,61])
ruler = np.linspace(0, 25, num=300)

# Define parameters
alpha = 14; beta = 2

# gamma's scale parameter in scipy.stats is 1/rate
d_val_prior = gamma.pdf(ruler, alpha, scale=1/beta)
d_val_post = gamma.pdf(ruler, alpha+sum(y), 
                       scale=1/(beta+len(y)))

# %%
fig, ax = plt.subplots(figsize=(8, 6))
ax.plot(ruler, d_val_prior, color='grey', 
        linewidth=3, label="Prior")
ax.plot(ruler, d_val_post, color='black', 
        linewidth=4, label="Posterior")
ax.set_xlabel('Support')
ax.set_ylabel('Density')
ax.text(6.5, 0.235, 'Prior', color='grey', 
        fontsize=12, ha='center')
ax.text(18.46, 0.475, 'Posterior', color='black', 
        fontsize=12, ha='center')
plt.ylim([0, 0.51])
plt.show()

# %%

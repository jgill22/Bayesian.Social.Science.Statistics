"""\
CHAPTER 2. SIMULATED PROBABILITY CALCULATIONS
"""

import numpy as np
n_sims = 1000000
y = np.random.normal(3,2,n_sims)
sum(y>0)/n_sims
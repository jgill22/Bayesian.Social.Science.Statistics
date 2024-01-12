"""\
CHAPTER 6. MIXTURE DISTRIBUTION
"""


import numpy as np
y = np.concatenate((
    np.random.normal(loc=10,scale=10,size=15000), 
    np.random.gamma(shape=4,scale=6,size=85000)))
np.mean(y)
import csv
import numpy as np
import pandas as pd

from matplotlib import pyplot as plt
from matplotlib.widgets import CheckButtons

df = pd.read_csv('region.csv', skiprows=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
df = df[df.columns[df.columns.str.contains('\.\.')]]
df.columns = ['target_pos', 'region0_rdaddr', 'region0_rddata', 'region1_rdaddr', 'region1_rddata', 'region2_rdaddr', 'region2_rddata', 'alarm']
df = df[df.target_pos != ' X']

"""
data = pd.to_numeric(df.region0_rdaddr)
fig, ax = plt.subplots(4, sharex=True)
l0, = ax[0].plot(data, 'go-', label='addr')

ax[0].grid(True)
ax[1].plot(pd.to_numeric(df.region0_rddata), 'ro-', label='region0 data')
ax[1].plot(pd.to_numeric(df.target_pos), 'bo-', label='target')
ax[2].plot(pd.to_numeric(df.region1_rddata), 'ro-', label='region1 data')
ax[2].plot(pd.to_numeric(df.target_pos), 'bo-', label='target')
ax[3].plot(pd.to_numeric(df.region2_rddata), 'ro-', label='region2 data')
ax[3].plot(pd.to_numeric(df.target_pos), 'bo-', label='target')
"""

theta = 2*np.pi * ((pd.to_numeric(df.region0_rdaddr)*0.333+45)/360)
ax = plt.subplot(111, projection='polar')
ax.plot(theta, pd.to_numeric(df.region0_rddata))


plt.show()


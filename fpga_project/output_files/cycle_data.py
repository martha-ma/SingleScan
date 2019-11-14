import csv
import pandas as pd
import numpy as np

from matplotlib import pyplot as plt
from matplotlib.widgets import CheckButtons

df = pd.read_csv('cycle_data.csv', skiprows=[0, 1, 2, 3, 5])

df.drop('time unit: s', axis=1, inplace = True)
laser = df[' pos_buffer:pos_bufferEx01|target_pos[17..0]'][710:1200]
laser.reset_index(drop=True)

def ave(data):
    result = []
    for i in range(0, len(data)-1):
        if abs(data[i]-data[i+1]) < 75:
            result.append((data[i+1] + data[i])//2)
        else:
            result.append(data[i])
    result.append(0)
    return result

#print(laser.values)
after = laser.values
after = ave(after)
after = pd.Series(after)

fig, ax = plt.subplots(2, sharex=True)
ax[0].plot(range(len(after)), laser, 'ro-', label='origin')
ax[0].plot(range(len(after)), after, 'go-', label='after')
ax[0].grid(True)
ax[0].legend()

ax[1].plot(range(len(after)), laser.diff(), 'ro-', label='origin')
ax[1].plot(range(len(after)), after.diff(), 'go-', label='after')
#ax[1].set_ylim(-100, 100)
ax[1].grid(True)
ax[1].legend()
#print(df[' single_target_pos[17..0]'].describe())

plt.show()

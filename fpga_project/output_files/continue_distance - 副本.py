import csv
import pandas as pd

from matplotlib import pyplot as plt
from matplotlib.widgets import CheckButtons

df = pd.read_csv('continue_distance.csv', skiprows=[0, 1, 2, 3, 4, 5, 6, 8])

df.drop('time unit: s', axis=1, inplace = True)

fig, ax = plt.subplots(4, sharex=True)
ax[0].plot(df[' step_cnt[7..0]'], 'bo-', label='step_cnt')
ax[1].plot(df[' calc_distance:calc_distanceEx01|zero_sub:zero_subEx01|final_diatance[17..0]'], 'go-', label='final data')
ax[2].plot(df[' calc_distance:calc_distanceEx01|zero_sub:zero_subEx01|zero_distance[17..0]'], 'go-', label='zero data')
ax[3].plot(df[' single_target_pos[17..0]'], 'ro-', label='')
print(df[' single_target_pos[17..0]'].describe())

plt.show()

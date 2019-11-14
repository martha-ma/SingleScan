import csv
import pandas as pd
import numpy as np

from matplotlib import pyplot as plt
from matplotlib.widgets import CheckButtons

df = pd.read_csv('continue_distance.csv', skiprows=[0, 1, 2, 3, 4, 5,  7])
"""
第一圈数据188:16183
第二圈数据16183:32191
"""

df.drop('time unit: s', axis=1, inplace = True)

# fig, ax = plt.subplots(3, sharex=True)
# ax[0].plot(df[' step_cnt[7..0]'], 'bo-', label='step_cnt')
# ax[1].plot(df[' calc_distance:calc_distanceEx01|zero_sub:zero_subEx01|final_diatance[17..0]'], 'yo-', label='final data')
# ax[2].plot(df[' single_target_pos[17..0]'], 'ro-', label='')
# plt.show()

first_df = df[' single_target_pos[17..0]'][188:16183].reset_index(drop=True)
second_df = df[' single_target_pos[17..0]'][16183:32191].reset_index(drop=True)

def slice_ave(data):
    p = np.array([])
    slice_num = len(data)//1081         # 分割1081次
    for i in range(1081):
        div = data[i*slice_num:(i+1)*slice_num]

        #if len(div[div < 25000 and div > 500]) > 1:
            #p = np.append(p, div[div < 30000].mean())
        #else:
            #p = np.append(p, 250000)

        d = div[div < 25000]
        d = d[d > 500]
        if len(d) > 1:
            p = np.append(p, d.mean())
        else:
            p = np.append(p, 250000)
    
    return p

first = slice_ave(first_df)
second = slice_ave(second_df)
print(len(first))
print(len(second))

fig, ax = plt.subplots(2, sharex=False)
ax[0].plot(first, 'bo-', label='first')
ax[0].plot(second, 'ro-', label='second')
ax[0].legend()

ax[1].plot(first_df[:1081*14], 'bo-', label='first cycle')
ax[1].plot(second_df[:1081*14], 'ro-', label='second cycle')
ax[1].legend()
plt.show()



import csv
import pandas as pd

from matplotlib import pyplot as plt
from matplotlib.widgets import CheckButtons

df = pd.read_csv('../para.csv', skiprows=[0, 1, 2, 3, 4, 6])

df.drop('time unit: s', axis=1, inplace = True)
#df1 = df[' step_cnt[7..0]']
#df2 = df[' data_select:data_selectEx01|offset_cnt[15..0]']
#df3 = df[' test_cnt[20..0]']

df1 = df[' target_1us_pos[17..0]']
df2 = df[' step_cnt[7..0]']

#df2 = df2- df2.shift(1)
#print(df1.min())
fig, ax = plt.subplots(2, sharex=True)

ax[0].plot(df1, 'bo-', label='pos')
ax[1].plot(df2, 'ro-', label='pluse')
#ax[2].plot(df3, 'go-', label='pluse')
ax[0].grid(True)
ax[1].grid(True)
#ax[2].grid(True)

plt.show()


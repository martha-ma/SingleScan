import csv

with open('step_cnt.csv', 'r') as infile, open('result.csv', 'w') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)

    line = 0
    for row in reader:
        if line <= 5 or line == 7:
            pass
        else:
            writer.writerow(row)
        line = line+1

import pandas as pd

from matplotlib import pyplot as plt
csvframe = pd.read_csv('result.csv')
# column = csvframe[' motor_top:motor_topEx01|sub_cnt[31..0]']
column = csvframe[' sub_cnt[31..0]']

df = column[column > 100000]
# plt.subplot(2,1,1)
plt.plot(range(0, len(df)), df)
plt.scatter(range(0, len(df)), df, color='r')

data = [ x for x in column if x > 100000 ]  # 去掉0 和 每圈的阻力点

result = []
for i in range(0, len(data)):
    if i < len(data) - 10:
        result.append(data[i+1] - data[i])
    else:
        break

print('max diff is {0}, min diff is {1}'.format(max(result), min(result)))
x = list(range(0, len(result)))

# plt.subplot(2,1,2)
# plt.plot(x, result, 'r')
plt.show()
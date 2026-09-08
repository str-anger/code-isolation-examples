import numpy as np

info = np.finfo(np.longdouble)
print(*list(info.__dict__.items()), sep="\n")

total = np.longdouble(0.0)
for _ in range(10):
    total += np.longdouble("0.1")

print("SUM:", float(total))
print("Float 128:", np.float128("0.01"))

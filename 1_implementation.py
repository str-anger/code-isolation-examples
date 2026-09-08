import math

tenths = [0.1] * 10
total = sum(tenths)
print(f"sum([0.1] * 10)        : {total}")
print(f"            ... == 1.0 : {total == 1.0}")

# Catastrophic cancellation:
# the 1.0 is lost entirely unless the sum compensates.
cancel = sum([1e100, 1.0, -1e100])
print(f" sum([1e100,1,-1e100]) : {cancel}")

# it was always there
print(f"math.fsum([0.1] * 10)  : {math.fsum(tenths)}")
math.fsum(tenths)

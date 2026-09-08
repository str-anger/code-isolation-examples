# PEP 695 (3.12+): inline type parameters and the `type` statement.
type Sample = tuple[float, float]


def largest[T](values: list[T]) -> T:
    return max(values)


print("largest:", largest([3, 1, 4, 1, 5]))
print("alias  :", Sample)

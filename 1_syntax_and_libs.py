# added in 3.11
import tomllib

elements = [31, 1, 4, 1, 5]
str_elements = list(map(str, elements))

# PEP 701 (3.12+): reusing the outer quote
# character inside the f-string expression.
print(f"elements: {", ".join(str_elements)}")


# PEP 695 (3.12+): inline type parameters
# and the `type` statement.
type Sample = tuple[float, float]

def largest[T](values: list[T]) -> T:
    return max(values)

print("largest:", largest(elements))
print("largest string:", largest(str_elements))

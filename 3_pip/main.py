import numpy as np

from adder import add


def main():
    print(f"numpy      {np.__version__}")
    print(f"add(2, 3)  {add(2, 3)}")
    print(f"add arrays {add(np.array([1, 2, 3]), np.array([10, 20, 30]))}")


if __name__ == "__main__":
    main()

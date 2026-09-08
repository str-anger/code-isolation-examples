"""A perfectly ordinary 2015-era test. assertEquals was removed in 3.12 (gh-89325)."""

import sys
import unittest


class TestArithmetic(unittest.TestCase):
    def test_addition(self):
        self.assertEquals(2 + 2, 4)


if __name__ == "__main__":
    print(f"  python : {sys.version.split()[0]}")
    unittest.main(verbosity=1, exit=False)

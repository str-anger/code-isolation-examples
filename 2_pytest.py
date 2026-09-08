class TestExperiment:
    def setup(self):
        self.samples = [1.0, 2.0, 3.0]

    def test_mean(self):
        assert sum(self.samples) / len(self.samples) == 2.0

    def test_count(self):
        assert len(self.samples) == 3

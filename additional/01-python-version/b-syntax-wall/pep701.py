names = ["alice", "bob", "carol"]

# PEP 701 (3.12+): reusing the outer quote character inside the f-string expression.
print(f"team: {", ".join(names)}")

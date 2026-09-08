#!/usr/bin/env bash
# Prints the commands. Does not run them.

cat <<'EOF'

  # 1. create the venv with an explicit interpreter
  python3.12 -m venv .venv

  # 2. use it — either activate it...
  source .venv/bin/activate

  #    ...or skip activation and call its pip directly:
  #    ./.venv/bin/pip install -e .

  # 3. install this project in editable mode, with its dependencies
  pip install --upgrade pip
  pip install -e .

  # 4. run it
  demo-add
  #    or, without the console script:
  python main.py

  # 5. inspect what landed
  pip list
  pip show demo-add

  # 6. leave the venv
  deactivate

EOF

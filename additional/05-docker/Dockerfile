# The lock is copied in before the source so dependency layers cache independently.
FROM python:3.12-slim

RUN pip install --no-cache-dir uv==0.9.30

WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

ENV PATH="/app/.venv/bin:$PATH" \
    UV_NO_SYNC=1

COPY probe.py ./

RUN useradd --create-home --uid 10001 app
USER app

CMD ["python", "probe.py"]

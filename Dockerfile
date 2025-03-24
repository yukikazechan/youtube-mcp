FROM python:3.11-slim as builder

WORKDIR /app

COPY pyproject.toml setup.py ./

RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip wheel --no-cache-dir --wheel-dir /app/wheels -e .

FROM python:3.11-slim

WORKDIR /app

LABEL org.opencontainers.image.title="YouTube MCP"
LABEL org.opencontainers.image.description="MCP server for YouTube video analysis"
LABEL org.opencontainers.image.source="https://github.com/Prajwal-ak-0/youtube-mcp"

COPY --from=builder /app/wheels /app/wheels

COPY . .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir /app/wheels/*.whl && \
    python -m pip install --no-cache-dir python-dotenv && \
    rm -rf /app/wheels && \
    groupadd -r mcp && \
    useradd -r -g mcp -d /app -s /bin/bash mcp && \
    chown -R mcp:mcp /app

USER mcp

ENV PYTHONUNBUFFERED=1

CMD ["python", "main.py"]

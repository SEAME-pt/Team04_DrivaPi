FROM python:3.13-slim

# Install minimal packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Install doorstop in the container
RUN pip install --no-cache-dir doorstop

# Create workdir and entrypoint
WORKDIR /workspace
COPY doorstop-entrypoint.sh /usr/local/bin/doorstop-entrypoint.sh
RUN chmod +x /usr/local/bin/doorstop-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/doorstop-entrypoint.sh"]
CMD ["--help"]

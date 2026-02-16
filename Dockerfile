FROM geopython/pygeoapi:latest

RUN pip3 install --no-cache-dir --break-system-packages --ignore-installed opensearch-py opensearch-dsl

# Download the latest iventoy version
FROM alpine:3.20 AS init
RUN apk add --no-cache wget tar
ARG IVENTOY
WORKDIR /iventoy
RUN wget -q https://github.com/ventoy/PXE/releases/download/v${IVENTOY}/iventoy-${IVENTOY}-linux-x86_64-free.tar.gz && \
    tar -xzf iventoy-${IVENTOY}-linux-x86_64-free.tar.gz && \
    rm iventoy-${IVENTOY}-linux-x86_64-free.tar.gz && \
    if [ -d "iventoy-${IVENTOY}" ]; then mv "iventoy-${IVENTOY}" iventoy_dir; else mv iventoy iventoy_dir; fi && \
    mv iventoy_dir iventoy

# Build image
FROM ubuntu:22.04
ENV AUTO_START_PXE=true
WORKDIR /app
# Copy iventoy
COPY --from=init /iventoy/iventoy /app
RUN chmod +x /app/iventoy.sh

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Webui
EXPOSE 26000/tcp
# HTTP server
EXPOSE 16000/tcp
CMD /entrypoint.sh

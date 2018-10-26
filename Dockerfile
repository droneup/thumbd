
FROM jrottenberg/ffmpeg as builder
MAINTAINER Charles Russell <charles.russell@dartflet.com>

FROM ubuntu 
ENV  LD_LIBRARY_PATH=/usr/local/lib
COPY --from=builder /usr/local/ /usr/local
# Install Thumbd
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    imagemagick \
    checkinstall \
    libssl-dev \
    vim \
    nano \
    build-essential \
    wget \
    ca-certificates \
    awscli \
    jq  && rm -rf /var/lib/apt/lists/*
RUN cd /tmp && wget https://nodejs.org/dist/v0.10.29/node-v0.10.29-linux-x64.tar.gz && tar -xvf node-v0.10.29-linux-x64.tar.gz
RUN cd /tmp/node-v0.10.29-linux-x64 && cp -R * /usr/local 
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
      libssl1.0 \
 && rm -rf /var/lib/apt/lists/*
#  mkdir -p /srv/node/thumbd && cd /srv/node/thumbd && \
#  npm install nan && npm install thumbd && npm cache clear && \
#  chown -R node:node /srv/node && \
#  /root/post-install
RUN wget --quiet https://github.com/envkey/envkey-source/releases/download/v1.2.2/envkey-source_1.2.2_linux_amd64.tar.gz
RUN tar -xvf envkey-source_1.2.2_linux_amd64.tar.gz && mv envkey-source /usr/local/bin && chmod +x /usr/local/bin/envkey-source
ADD . /src
WORKDIR /src
RUN NODE_ENV=production npm install
ADD ./.droneup /.droneup
CMD ["/.droneup/process_files.sh"]

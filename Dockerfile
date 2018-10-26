
FROM jrottenberg/ffmpeg as builder
MAINTAINER Charles Russell <charles.russell@dartflet.com>

FROM ubuntu 
ENV  LD_LIBRARY_PATH=/usr/local/lib
COPY --from=builder /usr/local/ /usr/local
# Install Thumbd
RUN apt-get update -qq && apt-get install -y tzdata --no-install-recommends \
    && ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    imagemagick \
    groff \
    checkinstall \
    vim \
    nano \
    build-essential \
    wget \
    ca-certificates \
    awscli \
    libssl1.0 \
    jq \
    && rm -rf /var/lib/apt/lists/*
RUN cd /tmp && wget https://nodejs.org/dist/v0.10.29/node-v0.10.29-linux-x64.tar.gz && tar -xvf node-v0.10.29-linux-x64.tar.gz
RUN cd /tmp/node-v0.10.29-linux-x64 && cp -R * /usr/local 
RUN wget --quiet https://github.com/envkey/envkey-source/releases/download/v1.2.2/envkey-source_1.2.2_linux_amd64.tar.gz
RUN tar -xvf envkey-source_1.2.2_linux_amd64.tar.gz && mv envkey-source /usr/local/bin && chmod +x /usr/local/bin/envkey-source
ADD . /src
WORKDIR /src
RUN NODE_ENV=production npm install
ADD ./.droneup /.droneup
CMD ["/.droneup/process_files.sh"]

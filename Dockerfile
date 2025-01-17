# Prepare the base environment.
FROM ubuntu:24.04 as builder_base_ubuntudev
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Perth

RUN apt-get clean
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install --no-install-recommends -y curl wget git libmagic-dev gcc binutils libproj-dev gdal-bin python3 python3-setuptools python3-dev python3-pip tzdata rsyslog gunicorn virtualenv
RUN apt-get install --no-install-recommends -y libpq-dev patch libreoffice
RUN apt-get install --no-install-recommends -y postgresql-client mtr htop vim nano npm sudo
RUN apt-get install --no-install-recommends -y bzip2 unzip
RUN apt-get install --no-install-recommends -y graphviz libgraphviz-dev pkg-config
RUN ln -s /usr/bin/python3 /usr/bin/python 
RUN apt remove -y libnode-dev
RUN apt remove -y libnode72

# Install nodejs
RUN update-ca-certificates

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
    | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs

# Install nodejs
COPY startup.sh /
COPY ./timezone /etc/timezone
RUN chmod 755 /startup.sh && \
    chmod +s /startup.sh && \
    groupadd -g 1200 coder && \
    useradd -g 1200 -u 1200 coder -s /bin/bash -d /app && \
    usermod -a -G sudo coder && \    
    mkdir /app && \
    chown -R coder.coder /app && \    
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
        
# Install Python libs from requirements.txt.
FROM builder_base_ubuntudev as python_libs_ubuntudev
WORKDIR /app
USER coder

EXPOSE 8080
HEALTHCHECK --interval=1m --timeout=5s --start-period=10s --retries=3 CMD ["wget", "-q", "-O", "-", "http://localhost:8080/"]
CMD ["/startup.sh"]

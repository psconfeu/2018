FROM ubuntu:artful

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        ca-certificates \
        curl \
        apt-transport-https \
        python \
        libffi6 \
        libffi-dev \
        openssl \
        jq \
        dirmngr \
        iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
RUN curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/17.04/prod.list
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ artful main" | tee /etc/apt/sources.list.d/azure-cli.list

RUN apt-get update \
    && apt-get install -y --no-install-recommends powershell azure-cli

CMD [ "pwsh" ]
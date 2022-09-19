FROM ubuntu:latest

# Pre-install required debian packages to save time in local tests
RUN apt update && apt install -y \
    wget \
    curl \
    jq \
    zip \
    gdebi \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    lsb-release \
    vim \
    zsh \
    fzf \
    tilix \
    openjdk-11-jdk \
    python3 \
    python3-pip \
    python3-venv \
    flameshot

ENTRYPOINT ["tail", "-f", "/dev/null"]
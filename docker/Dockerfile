FROM ubuntu:latest

# Creates a regular user and add it to the sudo group
RUN useradd -m -G sudo johndoe \
    && echo johndoe:johndoe | chpasswd

# Pre-install required debian packages to save time in local tests
RUN apt update && apt install -y sudo \
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
    python3 \
    python3-pip

USER johndoe

ENTRYPOINT ["tail", "-f", "/dev/null"]
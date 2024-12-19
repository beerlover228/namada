FROM ubuntu:latest
RUN apt-get update && apt-get upgrade -y
RUN apt-get install curl wget make git-core libssl-dev pkg-config libclang-18-dev build-essential protobuf-compiler -y

ENV HOME=/app

WORKDIR /app

ENV NAMADA_PORT="26"
ENV ALIAS="Stake Shark"
ENV WALLET="wallet"
ENV GO_VER="1.22.5"
ENV PATH="/usr/local/go/bin:/app/go/bin:${PATH}"
ENV CHAIN_ID="namada.5f5de2dd1b88cba30586420"
ENV BASE_DIR="$HOME/.local/share/namada"
ENV NAMADA_NETWORK_CONFIGS_SERVER="https://github.com/anoma/namada-mainnet-genesis/releases/download/mainnet-genesis"

RUN wget "https://golang.org/dl/go$GO_VER.linux-amd64.tar.gz" && \
tar -C /usr/local -xzf "go$GO_VER.linux-amd64.tar.gz" && \
rm "go$GO_VER.linux-amd64.tar.gz" && \
mkdir -p go/bin && \
mkdir -p "$BASE_DIR"

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
. "$HOME/.cargo/env"

RUN git clone https://github.com/cometbft/cometbft.git && \
cd cometbft && \
git checkout v0.37.9 && \
make build && \
cp $HOME/cometbft/build/cometbft /usr/local/bin/

RUN git clone https://github.com/anoma/namada && \
cd namada && \
wget https://github.com/anoma/namada/releases/download/v1.0.0/namada-v1.0.0-Linux-x86_64.tar.gz && \
tar -xvf namada-v1.0.0-Linux-x86_64.tar.gz && \
rm namada-v1.0.0-Linux-x86_64.tar.gz && \
cd namada-v1.0.0-Linux-x86_64 && \
mv namad* /usr/local/bin/ && \
mkdir -p "$BASE_DIR"

RUN namadac utils join-network --chain-id $CHAIN_ID && \
sed -i 's#persistent_peers = ".*"#persistent_peers = "tcp://05309c2cce2d163027a47c662066907e89cd6b99@74.50.93.254:26656,tcp://2bf5cdd25975c239e8feb68153d69c5eec004fdb@64.118.250.82:46656"#' $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/config.toml && \
sed -i.bak -e "s%:26658%:${NAMADA_PORT}658%g; \
s%:26657%:${NAMADA_PORT}657%g; \
s%:26656%:${NAMADA_PORT}656%g; \
s%:26545%:${NAMADA_PORT}545%g; \
s%:8545%:${NAMADA_PORT}545%g; \
s%:26660%:${NAMADA_PORT}660%g" $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/config.toml

RUN echo '#!/bin/sh' > /app/entrypoint.sh && \
    echo 'sleep 10000' >> /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]

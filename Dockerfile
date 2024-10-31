FROM ubuntu:latest

RUN apt-get update && apt-get upgrade -y && apt-get install make git-core libssl-dev pkg-config libclang-12-dev build-essential protobuf-compiler

ENV HOME=/app

WORKDIR /app

ENV GO_VER="1.22.5"
ENV PATH="/usr/local/go/bin:/app/go/bin:${PATH}"
ENV WALLET="wallet"
ENV ALIAS="Stake Shark"
ENV CHAIN_ID="housefire-cotton.d3c912fee7462"
ENV NAMADA_PORT="26"
ENV BASE_DIR="$HOME/.local/share/namada"

RUN wget "https://golang.org/dl/go$GO_VER.linux-amd64.tar.gz" && \
tar -C /usr/local -xzf "go$GO_VER.linux-amd64.tar.gz" && \
rm "go$GO_VER.linux-amd64.tar.gz" && \
mkdir -p go/bin && \
mkdir -p "$BASE_DIR

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
source $HOME/.cargo/env

RUN git clone https://github.com/cometbft/cometbft.git && \
cd cometbft && \
git checkout v0.37.9 && \
make build && \
cp $HOME/cometbft/build/cometbft /usr/local/bin/

RUN git clone https://github.com/anoma/namada && \
cd namada && \
wget https://github.com/anoma/namada/releases/download/v0.44.1/namada-v0.44.1-Linux-x86_64.tar.gz && \
tar -xvf namada-v0.44.1-Linux-x86_64.tar.gz && \
rm namada-v0.44.1-Linux-x86_64.tar.gz && \
cd namada-v0.44.1-Linux-x86_64 && \
sudo mv namad* /usr/local/bin/

RUN cp -r $HOME/.namada/pre-genesis $BASE_DIR/
namada client utils join-network --chain-id $CHAIN_ID --genesis-validator $ALIAS
sed -i 's#persistent_peers = ".*"#persistent_peers = "tcp://b3224caeb473ace90228b6c278e64aec43ed4925@165.227.42.204:26656"#' $HOME/.local/share/namada/housefire-cotton.d3c912fee7462/config.toml

ENTRYPOINT ["wardend", "start", "--home", "/app/.warden"]

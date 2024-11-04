FROM ubuntu:latest

RUN apt-get update && apt-get upgrade -y && apt-get install make git-core libssl-dev pkg-config libclang-12-dev build-essential protobuf-compiler

ENV HOME=/app

WORKDIR /app

ENV NAMADA_PORT="26"
ENV ALIAS="Stake Shark"
ENV WALLET="wallet"
ENV GO_VER="1.22.5"
ENV PATH="/usr/local/go/bin:/app/go/bin:${PATH}"
ENV CHAIN_ID="housefire-cotton.d3c912fee7462"
ENV BASE_DIR="$HOME/.local/share/namada"
ENV NAMADA_NETWORK_CONFIGS_SERVER="https://testnet.knowable.run/configs"
ENV PEERS="tcp://9ceec8b9889dbe25259e14e2efd5fb5615434512@namada-testnet-peer.itrocket.net:33656,tcp://b3224caeb473ace90228b6c278e64aec43ed4925@165.227.42.204:26656"

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
sudo mv namad* /usr/local/bin/ && \
mkdir -p "$BASE_DIR"

RUN namadac utils join-network --chain-id $CHAIN_ID && \
sed -i 's#persistent_peers = ".*"#persistent_peers = "tcp://ba3e08d76ce95549927a2a3f4cf379f4969a945c@165.227.42.204:26656"#' $HOME/.local/share/namada/housefire-cotton.d3c912fee7462/config.toml && \
sed -i.bak -e "s%:26658%:${NAMADA_PORT}658%g; \
s%:26657%:${NAMADA_PORT}657%g; \
s%:26656%:${NAMADA_PORT}656%g; \
s%:26545%:${NAMADA_PORT}545%g; \
s%:8545%:${NAMADA_PORT}545%g; \
s%:26660%:${NAMADA_PORT}660%g" $HOME/.local/share/namada/housefire-cotton.d3c912fee7462/config.toml && \
sed -i 's#persistent_peers = ".*"#persistent_peers = "tcp://d6691dc866be3de0be931d2018e8fdc6a564de20@165.227.42.204:26656"#' $HOME/.local/share/namada/housefire-cotton.d3c912fee7462/config.toml && \
sed -i 's#persistent_peers = ".*"#persistent_peers = "'$PEERS'"#' $HOME/.local/share/namada/housefire-cotton.d3c912fee7462/config.toml && \
wget -O $HOME/.local/share/namada/housefire-cotton.d3c912fee7462/cometbft/config/addrbook.json https://server-4.itrocket.net/testnet/namada/addrbook.json

RUN echo sleep 10000 > entrypoint.sh && chmod +x entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]

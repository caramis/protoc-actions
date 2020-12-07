FROM ubuntu:latest

# Prepare
ENV DEBIAN_FRONTEND noninteractive

# For dart
RUN apt-get update -qq && apt-get install -y -qq apt-transport-https gnupg2 wget
RUN wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list

# Install required packages
RUN apt-get update -qq && \
    apt-get install -y -qq git wget curl tar protobuf-compiler npm apt-transport-https dart
RUN wget -qO- https://golang.org/dl/go1.15.6.linux-amd64.tar.gz | tar -xz -C /usr/local
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Clean-up
RUN apt-get purge -y wget curl && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Default protobuf-compiler supports C / C++ / C# / Java / Python / JavaScript / PHP / Ruby plug-in

# Golang and grpc, grpc-gateway
ENV GOPATH /root/go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH:bin

RUN go get google.golang.org/grpc
RUN go get github.com/golang/protobuf/protoc-gen-go
RUN go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway

# TypeScript
RUN npm install -g typescript protoc-gen-ts google-protobuf

# Dart
ENV PATH $PATH:/usr/lib/dart/bin
ENV PATH $PATH:/root/.pub-cache/bin
RUN pub global activate protoc_plugin

# Rust
ENV PATH $PATH:/root/.cargo/bin
RUN rustup toolchain install nightly
RUN rustup default nightly
RUN cargo install protobuf-codegen

RUN protoc --version

COPY "entrypoint.sh" "/entrypoint.sh"

ENTRYPOINT ["/entrypoint.sh"]

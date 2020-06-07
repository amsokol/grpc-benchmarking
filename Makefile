#!/usr/bin/env make

server-rust: build-rust start-rust

build-rust:
	cargo build --release --manifest-path=./rust/Cargo.toml

start-rust:
	./rust/target/release/grpc-benchmarking-rust-server

bench-rust:
	ghz --insecure \
		--proto ./proto/hello.proto \
		--call hello.Greeter.SayHello \
		--total=1000000 \
		--concurrency=100 \
		--data='{"name":"some_string"}' \
		0.0.0.0:50051

server-go: build-go start-go

build-go:
	protoc --proto_path=./proto --go_out=plugins=grpc:./go/cmd/grpc-benchmarking-go-server hello.proto
	cd ./go && go build ./cmd/grpc-benchmarking-go-server

start-go:
	./go/grpc-benchmarking-go-server

bench-go:
	ghz --insecure \
		--proto ./proto/hello.proto \
		--call hello.Greeter.SayHello \
		--total=1000000 \
		--concurrency=100 \
		--data='{"name":"some_string"}' \
		0.0.0.0:50052

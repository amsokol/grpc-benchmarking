#!/usr/bin/env make

server-rust: build-rust start-rust

build-rust:
	cargo build --release --manifest-path=./rust/Cargo.toml

start-rust:
	./rust/target/release/grpc-benchmarking-rust-server

bench-rust:
	GOMAXPROCS=2 ghz --insecure \
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
	GOMAXPROCS=2 ghz --insecure \
		--proto ./proto/hello.proto \
		--call hello.Greeter.SayHello \
		--total=1000000 \
		--concurrency=100 \
		--data='{"name":"some_string"}' \
		0.0.0.0:50052

server-java: 
	cd ./java && ./gradlew run

bench-java:
	GOMAXPROCS=2 ghz --insecure \
		--proto ./proto/hello.proto \
		--call hello.Greeter.SayHello \
		--total=1000000 \
		--concurrency=100 \
		--data='{"name":"some_string"}' \
		0.0.0.0:50053

server-dotnet: 
	cd ./dotnet && dotnet run --configuration Release

bench-dotnet:
	GOMAXPROCS=2 ghz --insecure \
		--proto ./proto/hello.proto \
		--call hello.Greeter.SayHello \
		--total=1000000 \
		--concurrency=100 \
		--data='{"name":"some_string"}' \
		0.0.0.0:50054

server-node: build-node start-node

build-node:
	cd ./node && npx grpc_tools_node_protoc \
    	--js_out=import_style=commonjs,binary:./src/protogen \
    	--grpc_out=./src/protogen \
    	--plugin=protoc-gen-grpc=./node_modules/.bin/grpc_tools_node_protoc_plugin \
    	-I ../proto \
    	../proto/*.proto
	cd ./node && npx grpc_tools_node_protoc \
    	--plugin=protoc-gen-ts=./node_modules/.bin/protoc-gen-ts \
    	--ts_out=./src/protogen \
    	-I ../proto \
    	../proto/*.proto
	cd ./node && npx tsc

start-node:
	cd ./node && node ./dist/server.js

bench-node:
	GOMAXPROCS=2 ghz --insecure \
		--proto ./proto/hello.proto \
		--call hello.Greeter.SayHello \
		--total=1000000 \
		--concurrency=100 \
		--data='{"name":"some_string"}' \
		0.0.0.0:50055

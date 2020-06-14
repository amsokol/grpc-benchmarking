#!/usr/bin/env make

bench:
	taskset --cpu-list 0-3 ghz --insecure \
		--proto ./proto/hello.proto \
		--call hello.Greeter.SayHello \
		--total=1000000 \
		--concurrency=100 \
		--data='{"name":"some_string"}' \
		localhost:50051


server-rust: build-rust start-rust

build-rust:
	cargo build --release --manifest-path=./rust/Cargo.toml

start-rust:
	taskset --cpu-list 4 ./rust/target/release/grpc-benchmarking-rust-server

bench-rust: bench


server-go: build-go start-go

build-go:
	protoc --proto_path=./proto --go_out=plugins=grpc:./go/cmd/grpc-benchmarking-go-server hello.proto
	cd ./go && go build ./cmd/grpc-benchmarking-go-server

start-go:
	 taskset --cpu-list 4 ./go/grpc-benchmarking-go-server

bench-go: bench


server-java: build-java start-java

build-java: 
	cd ./java && ./gradlew build

start-java: 
	cd ./java && taskset --cpu-list 4 ./gradlew run

bench-java: bench


server-dotnet: build-dotnet start-dotnet

build-dotnet: 
	cd ./dotnet && dotnet build --configuration Release

start-dotnet: 
	cd ./dotnet && taskset --cpu-list 4 dotnet run --configuration Release

bench-dotnet: bench


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
	cd ./node && taskset --cpu-list 4 node ./dist/server.js

bench-node: bench

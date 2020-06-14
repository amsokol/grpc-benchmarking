package main

import (
	context "context"
	"log"
	"math/rand"
	"net"
	sync "sync"
	"time"

	grpc "google.golang.org/grpc"
)

type greeter struct {
}

const charset = "abcdefghijklmnopqrstuvwxyz" +
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

var _rand = rand.New(rand.NewSource(time.Now().UnixNano()))
var _muxRand sync.Mutex

// SayHello rpc accepts HelloRequests and returns HelloReplies.
func (g *greeter) SayHello(ctx context.Context, req *HelloRequest) (*HelloReply, error) {
	_muxRand.Lock()
	cap := _rand.Intn(801) + 200
	_muxRand.Unlock()

	b := make([]byte, cap)
	for i := range b {
		_muxRand.Lock()
		b[i] = charset[_rand.Intn(len(charset))]
		_muxRand.Unlock()
	}

	// return &HelloReply{Message: *(*string)(unsafe.Pointer(&b))}, nil
	return &HelloReply{Message: string(b)}, nil
}

func main() {
	const endpoint = "0.0.0.0:50051"

	lis, err := net.Listen("tcp", endpoint)
	if err != nil {
		log.Fatalf("failed to create listener: %v", err)
	}

	srv := grpc.NewServer()
	RegisterGreeterServer(srv, &greeter{})

	log.Printf("Starting Go gRPC server at %s", endpoint)

	if err := srv.Serve(lis); err != nil {
		log.Fatalf("gRPC server stopped: %v", err)
	}
}

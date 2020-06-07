package main

import (
	context "context"
	"log"
	"math/rand"
	"net"
	"time"

	grpc "google.golang.org/grpc"
)

type greeter struct {
}

const charset = "abcdefghijklmnopqrstuvwxyz" +
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

// SayHello rpc accepts HelloRequests and returns HelloReplies.
func (g *greeter) SayHello(ctx context.Context, req *HelloRequest) (*HelloReply, error) {
	var seededRand *rand.Rand = rand.New(
		rand.NewSource(time.Now().UnixNano()))

	cap := seededRand.Intn(801) + 200

	b := make([]byte, cap)
	for i := range b {
		b[i] = charset[seededRand.Intn(len(charset))]
	}

	// return &HelloReply{Message: *(*string)(unsafe.Pointer(&b))}, nil
	return &HelloReply{Message: string(b)}, nil
}

func main() {
	const endpoint = "0.0.0.0:50052"

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

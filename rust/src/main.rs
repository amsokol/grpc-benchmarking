use rand::Rng;
use tonic::{transport::Server, Request, Response, Status};

use hello::greeter_server::{Greeter, GreeterServer};
use hello::{HelloReply, HelloRequest};

pub mod hello {
    tonic::include_proto!("hello"); // The string specified here must match the proto package name
}

const CHARSET: &[u8] = b"abcdefghijklmnopqrstuvwxyz\
                        ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

#[derive(Debug, Default)]
pub struct GreeterService {}

#[tonic::async_trait]
impl Greeter for GreeterService {
    async fn say_hello(
        &self,
        request: Request<HelloRequest>, // Accept request of type HelloRequest
    ) -> Result<Response<HelloReply>, Status> {
        // Return an instance of type HelloReply

        let mut rng = rand::thread_rng();
        let cap = rng.gen_range(200, 1001);

        let mut b = Vec::with_capacity(cap);
        unsafe {
            b.set_len(cap);
        }

        for c in b.iter_mut() {
            *c = CHARSET[rng.gen_range(0, CHARSET.len())];
            // s.push(rand::random::<u8>() as char);
        }

        let reply = hello::HelloReply {
            // message: format!("Hello {}!", request.into_inner().name), // We must use .into_inner() as the fields of gRPC requests and responses are private
            message: String::from_utf8(b).unwrap(),
        };

        Ok(Response::new(reply)) // Send back our formatted greeting
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "0.0.0.0:50051".parse()?;
    let greeter = GreeterService::default();

    println!("Starting Rust gRPC server at {:?}", addr);

    Server::builder()
        .add_service(GreeterServer::new(greeter))
        .serve(addr)
        .await?;

    Ok(())
}

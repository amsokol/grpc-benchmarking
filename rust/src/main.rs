use rand::distributions::Alphanumeric;
use rand::rngs::ThreadRng;
use rand::Rng;
use std::cell::RefCell;
use tonic::{transport::Server, Request, Response, Status};

use hello::greeter_server::{Greeter, GreeterServer};
use hello::{HelloReply, HelloRequest};

pub mod hello {
    tonic::include_proto!("hello"); // The string specified here must match the proto package name
}

thread_local! {
    pub static RAND: RefCell<ThreadRng> = RefCell::new(rand::thread_rng());
}

#[derive(Debug, Default)]
pub struct GreeterService {}

#[tonic::async_trait]
impl Greeter for GreeterService {
    async fn say_hello(
        &self,
        _request: Request<HelloRequest>, // Accept request of type HelloRequest
    ) -> Result<Response<HelloReply>, Status> {
        // Return an instance of type HelloReply

        let mut msg = String::new();

        RAND.with(|f| {
            let mut rng = *f.borrow_mut();

            msg = rng
                .sample_iter(&Alphanumeric)
                .take(rng.gen_range(200, 1001))
                .collect();
        });

        Ok(Response::new(hello::HelloReply { message: msg }))

        /*
        let reply = hello::HelloReply {
            message: format!("Hello {}!", request.into_inner().name), // We must use .into_inner() as the fields of gRPC requests and responses are private
        };
        Ok(Response::new(reply)) // Send back our formatted greeting
        */
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

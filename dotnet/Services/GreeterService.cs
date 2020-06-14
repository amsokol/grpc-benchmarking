using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Grpc.Core;
using Microsoft.Extensions.Logging;

namespace GrpcGreeter
{
    public class GreeterService : Greeter.GreeterBase
    {
        private readonly Random _random = new Random();

        private readonly ILogger<GreeterService> _logger;
        public GreeterService(ILogger<GreeterService> logger)
        {
            _logger = logger;
        }

        const string charSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

        public override Task<HelloReply> SayHello(HelloRequest request, ServerCallContext context)
        {
            var len = _random.Next(200, 1001);
            var s = new char[len];
            for (int i = 0; i < len; i++)
            {
                s[i] = charSet[_random.Next(charSet.Length)];
            }

            return Task.FromResult(new HelloReply
            {
                Message = new String(s)
            });
        }
    }
}

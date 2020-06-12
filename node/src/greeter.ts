import * as grpc from 'grpc'

import { HelloRequest, HelloReply } from './protogen/hello_pb'
import { GreeterService, IGreeterServer } from './protogen/hello_grpc_pb'

const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
const charactersLength = characters.length

class GreeterHandler implements IGreeterServer {
    /**
     * Greet the user nicely
     * @param call
     * @param callback
     */
    sayHello = (call: grpc.ServerUnaryCall<HelloRequest>, callback: grpc.sendUnaryData<HelloReply>): void => {
        const reply: HelloReply = new HelloReply()

        var len = Math.floor(Math.random() * 800 + 200)
        var res = [...Array(len)].map((_, x) => String.fromCharCode(characters.charCodeAt(
            Math.floor(Math.random() * charactersLength))))
        reply.setMessage(res.join(''))

        callback(null, reply)
    };
}

export default {
    service: GreeterService,                // Service interface
    handler: new GreeterHandler(),          // Service interface definitions
}

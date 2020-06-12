import * as grpc from 'grpc'

import { HelloRequest, HelloReply } from './protogen/hello_pb'
import { GreeterService, IGreeterServer } from './protogen/hello_grpc_pb'

const characters =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
const charactersLength = characters.length

/**
 * GreeterHandler is implementation of IGreeterServer.
 *
 */
class GreeterHandler /* implements IGreeterServer */ {
    /**
     * Greet the user nicely
     * @param {grpc.ServerUnaryCall<HelloRequest>} call
     * @param {grpc.sendUnaryData<HelloReply>} callback
     */
    sayHello = (call: grpc.ServerUnaryCall<HelloRequest>,
        callback: grpc.sendUnaryData<HelloReply>): void => {
        const reply: HelloReply = new HelloReply()

        const len = Math.floor(Math.random() * 800 + 200)
        const res = [...Array(len)].map((_) =>
            String.fromCharCode(characters.charCodeAt(
                Math.floor(Math.random() * charactersLength))))
        reply.setMessage(res.join(''))

        callback(null, reply)
    };
}

export default {
    service: GreeterService, // Service interface
    handler: new GreeterHandler(), // Service interface definitions
}

from __future__ import print_function

import grpc
import helloworld_pb2
import helloworld_pb2_grpc

class GreeterClient:
    def __init__(self, target):
        self.channel = grpc.insecure_channel(target)
        self.stub = helloworld_pb2_grpc.GreeterStub(self.channel)

    def say_hello(self, name):
        request = helloworld_pb2.HelloRequest(name=name)
        response = self.stub.SayHello(request)
        return response.message

if __name__ == '__main__':
    import sys

    target = "localhost:50051"
    if len(sys.argv) > 1:
        arg = sys.argv[1]
        if arg.startswith("--target="):
            target = arg.split("=")[1]

    client = GreeterClient(target)
    user = "123123123" if len(sys.argv) == 1 else sys.argv[1]
    print("Greeter client received: " + client.say_hello(user))

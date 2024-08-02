const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');
const path = require('path');

const PROTO_PATH = path.resolve(__dirname, '../proto/helloworld.proto');
const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true,
});
const helloworldProto = grpc.loadPackageDefinition(packageDefinition).helloworld;

function main() {
  const target = process.argv.length > 2 ? process.argv[2].split('=')[1] : 'localhost:50050';
  const client = new helloworldProto.Greeter(target, grpc.credentials.createInsecure());
  
  const request = { name: 'test node' };

  client.sayHello(request, (err, response) => {
    if (err) {
      console.error(`Error: ${err.code} - ${err.message}`);
    } else {
      console.log(`Greeter received: ${response.message}`);
    }
  });
}

main();

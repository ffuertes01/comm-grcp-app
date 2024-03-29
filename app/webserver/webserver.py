from flask import Flask, request, jsonify
import grpc
import comm_pb2
import comm_pb2_grpc

app = Flask(__name__)
# server_address = 'grpc-server:50051'
server_address = 'grpcserver-svc.default.svc.cluster.local:50051'
channel = grpc.insecure_channel(server_address)
stub = comm_pb2_grpc.CommunicationStub(channel)

@app.route("/message")
def main():
    return "Hola! Escribe un mensaje para el servidor en formato JSON usando el methodo POST en esta misma URL"


@app.route('/message', methods=['POST'])
def send_message():
    data = request.get_json()
    message = data.get('message')
    response = stub.SendMessage(comm_pb2.MessageRequest(message=message))
    return jsonify({'response': response.message})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

from concurrent import futures
import grpc
import logging
import comm_pb2
import comm_pb2_grpc

class CommunicationServicer(comm_pb2_grpc.CommunicationServicer):
    def SendMessage(self, request, context):
        logging.info("Solicitud Recibida: %s", request)
        logging.info("Enviando respuesta")
        return comm_pb2.MessageResponse(message="El mensaje recibido es: " + request.message)

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    comm_pb2_grpc.add_CommunicationServicer_to_server(CommunicationServicer(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    print("Servidor escuchando en el puerto 50051")
    server.wait_for_termination()

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    serve()
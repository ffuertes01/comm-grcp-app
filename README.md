# Despliegue de Aplicación GRPC en AWS EKS

Esta documento proporciona instrucciones para el despliegue y el uso de una aplicación básica en Python alojada en AWS EKS, junto con una explicación de la arquitectura de Red y Despliegue (CI/CD). La aplicación comprende un servidor gRPC expone su servicio, el cual es consumido por un cliente gRPC. Admás, el cliente a su vez expone un servicio HTTP (webserver) para que los usuarios accedan a la aplicación desde Internet.

## Descripción de la Aplicación

La aplicación consta de dos partes principales:

1. **Servidor gRPC**: Escucha las solicitudes del cliente, procesa los mensajes y devuelve una respuesta.
2. **Cliente HTTP**: Proporciona la interfaz para que los usuarios interactúen con el servidor gRPC a través de HTTP.

## Arquitectura de Red

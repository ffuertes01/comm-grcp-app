# Despliegue de Aplicación GRPC en AWS EKS

Esta documento proporciona instrucciones para el despliegue y el uso de una aplicación básica en Python alojada en AWS EKS, junto con una explicación de la arquitectura de Red y Despliegue (CI/CD). La aplicación comprende un servidor gRPC expone su servicio, el cual es consumido por un cliente gRPC. Admás, el cliente a su vez expone un servicio HTTP (webserver) para que los usuarios accedan a la aplicación desde Internet.

## Descripción de la Aplicación

La aplicación consta de dos partes principales:

1. **Servidor gRPC**: Escucha las solicitudes del cliente, procesa los mensajes y devuelve una respuesta.
2. **Cliente HTTP**: Proporciona la interfaz para que los usuarios interactúen con el servidor gRPC a través de HTTP.

## Arquitectura de Red
La siguiente imagen muestra la arquitectura general de red de la aplicación:
![Arquitectura de red](https://github.com/ffuertes01/comm-grcp-app/blob/main/diagrams/network.png)

La arquitectura de red del proyecto se compone de una VPC que incluye tres subredes privadas y tres subredes públicas. Las subredes privadas cuentan con un NAT Gateway que permite el acceso a Internet para descargas de aplicaciones, actualizaciones, etc., sin embargo, no permiten el acceso desde Internet hacia estas subredes. Por otro lado, las subredes públicas cuentan con un Internet Gateway que posibilita el acceso desde y hacia Internet de los recursos desplegados en ellas.

El cluster de EKS se despliega en las subredes privadas, donde se desplegará el grupo de nodos (node group) que alberga los worker nodes deseados en el cluster.

Una vez instalado el cluster EKS, se procede al despliegue de los recursos de la aplicación en este cluster, que consisten en:

- **Deployment para el servidor gRPC y el servidor web**: Contiene los pods donde se ejecutan los códigos de la aplicación.
- **Services para el servidor gRPC y el servidor web**: Se encargan de exponer los servicios de los pods de la aplicación, con gRPC en el puerto 50051 y el servidor web en el puerto 8080.
- **Ingress**: Crea un Application Load Balancer (ALB) en AWS, ubicado en una de las subredes públicas de la VPC. Este ALB expone el servicio en el puerto 80 a Internet y redirecciona el tráfico entrante al servicio del servidor web en el puerto 8080.

De esta manera, cuando un usuario accede a la URL del ALB con la ruta configurada en el Ingress, será dirigido al servicio del servidor web. Desde allí, se realizará la petición al servicio del servidor gRPC, y la respuesta se enviará en dirección contraria.



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

El cluster de EKS se instala en las subredes privadas, donde se implementará el node group que alojará los worker nodes necesarios para el funcionamiento del cluster.

Una vez instalado el cluster EKS, se procede al despliegue de los recursos de la aplicación en este cluster, que consisten en:

- **Deployment para el servidor gRPC y el servidor web**: Contiene los pods donde se ejecutan los códigos de la aplicación.
- **Services para el servidor gRPC y el servidor web**: Se encargan de exponer los servicios de los pods de la aplicación, con gRPC en el puerto 50051 y el servidor web en el puerto 8080.
- **Ingress**: Crea un Application Load Balancer (ALB) en AWS, ubicado en una de las subredes públicas de la VPC. Este ALB expone el servicio en el puerto 80 a Internet y redirecciona el tráfico entrante al servicio del servidor web en el puerto 8080.

De esta manera, cuando un usuario accede a la URL del ALB con la ruta configurada en el Ingress, será dirigido al servicio del servidor web. Desde allí, se realizará la petición al servicio del servidor gRPC, y la respuesta se enviará en dirección contraria.

## Despliegue de la Infraestructura

La infraestructura de la aplicación se implementa utilizando Terraform. Este proyecto consta principalmente de 3 módulos reutilizables, los cuales son invocados desde el archivo principal (main.tf). Estos módulos son:

- **Network**: Este módulo implementa la VPC con las subredes públicas y privadas. En estas subredes se habilitan el NAT Gateway, el Internet Gateway, las tablas de rutas, entre otros componentes.

- **EKS**: Aquí se realiza el despliegue del cluster de EKS y del grupo nodegroup donde se instalan las instancias que actuarán como worker nodes en el cluster. Una vez desplegado el cluster, se configura el controlador de Application Load Balancer (ALB) para que EKS pueda generar recursos tipo ALB en AWS mediante Ingress. Finalmente, se establecen los permisos necesarios para que AWS CodeBuild pueda desplegar recursos en el cluster.

- **CICD**: En este módulo se crean los proyectos de AWS CodeBuild y AWS CodePipeline, los cuales se encargan de realizar la integración continua y la entrega continua (CI/CD) del código de la aplicación desde el repositorio de GitHub hacia el cluster EKS. Asimismo, se crea el repositorio en ECR donde se guardarán las imágenes de Docker, y los buckets de Amazon S3 para almacenar los artefactos.

## CI/CD del Proyecto

Para la integración continua y el despliegue continuo de la aplicación, se hace uso de un Repositorio en GitHub como controlador de versiones y fuente del pipeline, AWS ECR como repositorio de imagenes de Docker, AWS Codebuild para las fases de construcción y despliegue del codigo y AWS Codepipeline como orquestador de todo el proceso. se sigue el siguiente flujo:

Para lograr la integración continua y el despliegue continuo de la aplicación, se emplean herramientas especializadas para cada etapa del ciclo de desarrollo. Utilizamos un Repositorio en GitHub como sistema de control de versiones y fuente central del pipeline. AWS ECR sirve como repositorio para las imágenes de Docker generadas durante el proceso. Además, AWS CodeBuild se encarga de las fases de construcción y despliegue del código, mientras que AWS CodePipeline actúa como orquestador de todo el proceso. El flujo se muestra en la siguiente imagen y se describe mas adelante:

https://github.com/ffuertes01/comm-grcp-app/blob/main/diagrams/cicd.png

![Flujo CI/CD](https://github.com/ffuertes01/comm-grcp-app/blob/main/diagrams/cicd.png)

1. Cuando un desarrollador realiza un cambio o actualización en el código, realiza un commit desde su entorno local hacia el repositorio de GitHub, cuando este commit se integra en la rama "Main" del repositorio CodePipeline inicia el pipeline para el despliegue.

2. CodePipeline detecta los cambios en el repositorio de GitHub, descarga el código del proyecto hacia un bucket de Amazon S3 como un artefacto y activa Codebuild para continuar con las siguientes fases.

3. El proyecto de CodeBuild se compone de tres fases. Comienza con "pre_build", donde se realiza el inicio de sesión en AWS ECR y en el cluster de Amazon Elastic Kubernetes Service (EKS).

4. A continuación, continúa con la fase "build", donde se construyen las imágenes de Docker y se les asigna el respectivo tag.

5. En la fase final "post_build", se envían las imágenes de Docker al repositorio de ECR y, finalmente, se aplican los manifiestos de Kubernetes en el cluster EKS. Esto implica la construcción o modificación de los recursos de la aplicación según lo definido en los manifiestos.





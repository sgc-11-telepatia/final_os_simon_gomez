# Examen Final - Simon Gomez

Repositorio con las soluciones del examen final.

## Estructura del Proyecto

```
EXAMEN_FINAL_SIMON_GOMEZ/
├── punto1/              # Solución Punto 1
│   └── README.md
├── punto2/              # Solución Punto 2 - API FastAPI con EC2 y S3
│   ├── main.py
│   ├── requirements.txt
│   ├── app.service
│   ├── deploy.sh
│   ├── Solution/        # Capturas de pantalla
│   └── README.md
└── README.md           # Este archivo
```

## Punto 1: FastAPI en AWS Lambda

Aplicación FastAPI desplegada en AWS Lambda usando Mangum como adaptador ASGI.

**Características:**
- Endpoint GET / para mensaje de bienvenida
- Endpoint GET /saludo/{nombre} para saludo personalizado
- Arquitectura serverless
- API Gateway para acceso público

Ver detalles completos en [punto1/README.md](./punto1/README.md)

## Punto 2: API FastAPI con EC2 y S3

Aplicación FastAPI desplegada en AWS EC2 que interactúa con S3 para gestionar un archivo CSV con datos de personas.

**Características:**
- Endpoint POST para agregar personas
- Endpoint GET para obtener número de filas
- Integración con AWS S3
- Despliegue automatizado con systemd

**Acceso:**
- Swagger UI: http://3.150.111.184:8000/docs
- Bucket S3: final-se-simoneia-so
- Región: us-east-2

Ver detalles completos en [punto2/README.md](./punto2/README.md)

## Tecnologías Utilizadas

- Python 3.12
- FastAPI
- AWS EC2
- AWS S3
- Boto3
- Pandas
- Systemd

## Autor

Simon Gomez

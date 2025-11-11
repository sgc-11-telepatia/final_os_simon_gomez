# Simón Gómez

Link del uso de IA:
https://apps.abacus.ai/chatllm/?convoId=153c75b350&appId=155f730eaa

Las imágenes de solución en la carpeta Solution


# Punto 2: API FastAPI con EC2 y S3

Aplicación FastAPI desplegada en EC2 que interactúa con Amazon S3 para gestionar datos de personas en formato CSV.

## Descripción

Esta aplicación implementa una API REST con dos endpoints principales:
- **POST /persona**: Agrega una nueva persona al archivo CSV en S3
- **GET /filas**: Retorna el número total de filas en el archivo CSV

## Estructura del Proyecto

```
punto2/
├── main.py              # Código principal de la aplicación FastAPI
├── requirements.txt     # Dependencias de Python
├── app.service         # Archivo de servicio systemd para EC2
├── deploy.sh           # Script automatizado de despliegue
├── Solution/           # Capturas de pantalla de la solución
└── README.md           # Este archivo
```

## Requisitos

- Python 3.12+
- AWS Account con:
  - Instancia EC2 (Ubuntu 24.04)
  - Bucket S3
  - IAM Role con permisos S3FullAccess

## Instalación Local

```bash
# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar la aplicación
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Acceder a: `http://localhost:8000/docs`

## Despliegue en EC2

### Configuración Previa

1. **Crear bucket S3**
   - Nombre: `final-se-simoneia-so`
   - Región: `us-east-2` (Ohio)

2. **Configurar Security Group en EC2**
   - Puerto 22 (SSH): Para conexión remota
   - Puerto 8000 (HTTP): Para acceso a la API

3. **Asignar IAM Role a EC2**
   - Política: `AmazonS3FullAccess`

### Opción 1: Despliegue Automatizado

```bash
# Desde tu máquina local
chmod +x deploy.sh
./deploy.sh
```

### Opción 2: Despliegue Manual

#### Paso 1: Subir archivos a EC2

```bash
scp -i llavepem.pem -r punto2/ ubuntu@<EC2-IP>:/home/ubuntu/
```

#### Paso 2: Conectar a EC2

```bash
ssh -i llavepem.pem ubuntu@<EC2-IP>
```

#### Paso 3: Configurar entorno en EC2

```bash
# Actualizar sistema
sudo apt update
sudo apt install python3-pip -y

# Crear entorno virtual
cd /home/ubuntu
python3 -m venv venv
source venv/bin/activate

# Instalar dependencias
pip install -r punto2/requirements.txt
```

#### Paso 4: Configurar servicio systemd

```bash
# Crear archivo de servicio
sudo bash -c 'cat > /etc/systemd/system/app.service << EOF
[Unit]
Description=FastAPI EC2 S3 App
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/punto2
ExecStart=/home/ubuntu/venv/bin/python -m uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Habilitar y arrancar el servicio
sudo systemctl daemon-reload
sudo systemctl enable app.service
sudo systemctl start app.service

# Verificar estado
sudo systemctl status app.service
```

#### Paso 5: Verificar despliegue

Acceder a: `http://<EC2-IP-PUBLICA>:8000/docs`

## Uso de la API

### Endpoint POST /persona

Agrega una nueva persona al CSV en S3.

**Request:**
```json
{
  "nombre": "Simon Gomez",
  "edad": 22,
  "altura": 175.5
}
```

**Response:**
```json
{
  "mensaje": "Persona agregada exitosamente",
  "total_filas": 1
}
```

### Endpoint GET /filas

Retorna el número de filas en el CSV.

**Response:**
```json
{
  "numero_filas": 5
}
```

## Configuración

La aplicación utiliza las siguientes configuraciones en `main.py`:

- **BUCKET_NAME**: `final-se-simoneia-so`
- **CSV_KEY**: `datos.csv`
- **AWS Region**: `us-east-2`

## Troubleshooting

### Error: "address already in use"
```bash
sudo pkill -f uvicorn
sudo systemctl restart app.service
```

### Error: "No module named uvicorn"
```bash
# Verificar que el servicio use el Python del venv
sudo systemctl cat app.service
# ExecStart debe apuntar a: /home/ubuntu/venv/bin/python
```

### Ver logs del servicio
```bash
sudo journalctl -u app.service -f
```

### Verificar acceso a S3
```bash
aws s3 ls s3://final-se-simoneia-so/
```

## Tecnologías Utilizadas

- **FastAPI**: Framework web moderno para Python
- **Uvicorn**: Servidor ASGI
- **Pydantic**: Validación de datos
- **Boto3**: SDK de AWS para Python
- **Pandas**: Manipulación de datos CSV
- **AWS EC2**: Hosting de la aplicación
- **AWS S3**: Almacenamiento de archivos CSV
- **systemd**: Gestión de servicios en Linux

## Información del Despliegue

- **EC2 IP**: 3.150.111.184
- **Swagger UI**: http://3.150.111.184:8000/docs
- **Bucket S3**: final-se-simoneia-so
- **Región**: us-east-2 (Ohio)

## Autor

Simon Gomez - Examen Final

## Capturas de Pantalla

Las capturas de pantalla de la solución funcionando se encuentran en el directorio `Solution/`:
- Swagger UI con endpoints
- POST request exitoso
- GET request mostrando número de filas
- Bucket S3 con archivo datos.csv

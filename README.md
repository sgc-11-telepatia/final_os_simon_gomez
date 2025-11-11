# Punto 1: FastAPI en AWS Lambda con Mangum

Despliegue de una aplicación FastAPI en AWS Lambda usando Mangum como adaptador y API Gateway para acceso público.

## Plan de Implementación

1. **Empaquetar aplicación**: Crear ZIP con app.py + dependencias (fastapi, mangum) compiladas para Linux x86_64
2. **Crear función Lambda**: Runtime Python 3.12, Handler `app.mangum`
3. **Configurar API Gateway**: HTTP API como trigger para acceso público
4. **Probar endpoints**: GET / y GET /saludo/{nombre}

Ver detalles técnicos en [NOTAS_IMPLEMENTACION.md](./NOTAS_IMPLEMENTACION.md)

## Descripción

Esta aplicación implementa dos endpoints simples:
- **GET /**: Retorna un mensaje de bienvenida
- **GET /saludo/{nombre}**: Retorna un saludo personalizado

## Estructura del Proyecto

```
punto1/
├── app.py              # Código FastAPI (proporcionado por el profesor)
├── requirements.txt    # Dependencias mínimas
├── package.sh         # Script para empaquetar la aplicación
├── Solution/          # Capturas de pantalla
└── README.md          # Este archivo
```

## Requisitos

- Python 3.12+
- AWS Account con acceso a:
  - AWS Lambda
  - API Gateway
- AWS CLI configurado (opcional)

## Paso 1: Empaquetar la Aplicación

Desde tu terminal, en el directorio `punto1/`:

```bash
cd /Users/sgc-11/Documents/Universidad/2025/EXAMEN_FINAL_SIMON_GOMEZ/punto1
./package.sh
```

Esto creará el archivo `lambda_function.zip` que contiene:
- El código `app.py`
- Las dependencias `fastapi` y `mangum`

## Paso 2: Crear la Función Lambda

### 2.1 Ir a AWS Console → Lambda

1. Abre https://console.aws.amazon.com/lambda
2. Asegúrate de estar en la región **us-east-2** (Ohio)
3. Click en **"Create function"**

### 2.2 Configurar la Función

- **Opción**: Author from scratch
- **Function name**: `fastapi-lambda-punto1`
- **Runtime**: Python 3.12
- **Architecture**: x86_64
- **Permissions**: Create a new role with basic Lambda permissions
- Click **"Create function"**

### 2.3 Subir el Código

1. En la sección **"Code source"**
2. Click **"Upload from"** → **".zip file"**
3. Selecciona el archivo `lambda_function.zip`
4. Click **"Save"**

### 2.4 Configurar el Handler

1. Scroll hasta **"Runtime settings"**
2. Click **"Edit"**
3. Cambiar **Handler** a: `app.mangum`
4. Click **"Save"**

### 2.5 Ajustar Configuración (opcional)

1. Ve a **"Configuration"** → **"General configuration"**
2. Click **"Edit"**
3. **Timeout**: Aumentar a 30 segundos (opcional pero recomendado)
4. Click **"Save"**

## Paso 3: Crear API Gateway

### 3.1 Agregar Trigger a Lambda

1. En tu función Lambda, click **"Add trigger"**
2. Selecciona **"API Gateway"**

### 3.2 Configurar API Gateway

- **API type**: HTTP API (más simple)
- **Security**: Open (sin autenticación)
- Click **"Add"**

### 3.3 Obtener URL Pública

Después de crear el trigger, verás una **API endpoint URL** como:
```
https://xxxxxxxxxx.execute-api.us-east-2.amazonaws.com/default/fastapi-lambda-punto1
```

**Copia esta URL** - la necesitarás para probar.

## Paso 4: Probar los Endpoints

### Endpoint 1: GET /

Abre en tu navegador:
```
https://xxxxxxxxxx.execute-api.us-east-2.amazonaws.com/default/fastapi-lambda-punto1/
```

**Respuesta esperada:**
```json
{
  "mensaje": "Hola desde FastAPI en AWS Lambda"
}
```

### Endpoint 2: GET /saludo/{nombre}

Abre en tu navegador (reemplaza "Simon" por tu nombre):
```
https://xxxxxxxxxx.execute-api.us-east-2.amazonaws.com/default/fastapi-lambda-punto1/saludo/Simon
```

**Respuesta esperada:**
```json
{
  "saludo": "Hola, Simon. Bienvenido a la API!"
}
```

## Paso 5: Documentación Swagger (FastAPI Docs)

FastAPI incluye documentación automática, pero para verla en Lambda necesitas:

```
https://xxxxxxxxxx.execute-api.us-east-2.amazonaws.com/default/fastapi-lambda-punto1/docs
```

**Nota**: Puede que no funcione perfectamente en Lambda debido a las rutas. Los endpoints directos funcionan correctamente.

## Capturas de Pantalla Requeridas

Guarda las siguientes capturas en `Solution/`:

1. **Lambda Function creada** (mostrando código y configuración)
2. **API Gateway configurado** (mostrando trigger y URL)
3. **Endpoint GET /** funcionando en el navegador
4. **Endpoint GET /saludo/{nombre}** funcionando en el navegador
5. **(Opcional)** CloudWatch Logs mostrando ejecución

## Troubleshooting

### Error: "Internal Server Error"

Verifica el Handler en Runtime settings:
```
app.mangum
```

### Error: "Task timed out"

Aumenta el timeout en Configuration → General configuration.

### Ver Logs de Errores

1. Ve a **CloudWatch** en AWS Console
2. **Logs** → **Log groups**
3. Busca `/aws/lambda/fastapi-lambda-punto1`
4. Click en el stream más reciente

### Probar la Función Directamente

1. En Lambda, ve a la pestaña **"Test"**
2. Crea un nuevo evento de prueba:
```json
{
  "rawPath": "/",
  "requestContext": {
    "http": {
      "method": "GET"
    }
  }
}
```
3. Click **"Test"** y verifica la respuesta

## Alternativa: Deploy con AWS CLI

Si prefieres usar la línea de comandos:

```bash
# Crear la función
aws lambda create-function \
  --function-name fastapi-lambda-punto1 \
  --runtime python3.12 \
  --role arn:aws:iam::YOUR_ACCOUNT_ID:role/lambda-basic-role \
  --handler app.mangum \
  --zip-file fileb://lambda_function.zip \
  --region us-east-2

# Actualizar código (si ya existe)
aws lambda update-function-code \
  --function-name fastapi-lambda-punto1 \
  --zip-file fileb://lambda_function.zip \
  --region us-east-2
```

## Tecnologías Utilizadas

- **FastAPI**: Framework web moderno para Python
- **Mangum**: Adaptador ASGI para AWS Lambda
- **AWS Lambda**: Servicio serverless de AWS
- **API Gateway**: Puerta de enlace HTTP para Lambda

## Comparación con Punto 2

| Aspecto | Punto 1 (Lambda) | Punto 2 (EC2) |
|---------|------------------|---------------|
| Infraestructura | Serverless | Servidor persistente |
| Escalado | Automático | Manual |
| Costo | Por invocación | Por hora |
| Mantenimiento | Bajo | Alto |
| Inicio en frío | Sí (delay inicial) | No |

## Autor

Simon Gomez - Examen Final

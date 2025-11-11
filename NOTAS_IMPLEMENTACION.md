# Notas de Implementación - Punto 1

## Proceso de Empaquetado

Para desplegar FastAPI en AWS Lambda, se intentaron varios métodos debido a incompatibilidades de dependencias binarias entre macOS y Linux (Lambda usa Linux).

### Métodos Intentados

#### 1. **package_simple.sh** - Descarga de wheels pre-compilados
Descarga paquetes específicos para Linux usando pip download con flags de plataforma.

#### 2. **package.sh** - Método con Docker (Recomendado)
Usa contenedor oficial de AWS Lambda para compilar dependencias en el entorno correcto.

```bash
docker run --rm -v "$PWD":/var/task public.ecr.aws/lambda/python:3.12 \
    pip install -r requirements.txt -t package/
```

#### 3. **Método Final Usado** - Instalación directa con flags de plataforma
```bash
pip3 install --platform manylinux2014_x86_64 \
    --target=package \
    --implementation cp \
    --python-version 312 \
    --only-binary=:all: \
    fastapi mangum
```

Este método instala los paquetes binarios compilados específicamente para la arquitectura de Lambda (x86_64 Linux).

## Problemas Encontrados

### 1. Error: "No module named 'pydantic_core._pydantic_core'"
- **Causa**: Dependencias compiladas para macOS, no para Linux
- **Solución**: Usar flag `--platform manylinux2014_x86_64` para instalar binarios de Linux

### 2. Error: "Unable to infer a handler"
- **Causa**: Formato de evento de prueba en Lambda no compatible con Mangum
- **Solución**: Probar directamente con API Gateway en navegador, no con test de Lambda

### 3. Zip muy pequeño (376 bytes)
- **Causa**: pip no instalado o comando pip falló silenciosamente
- **Solución**: Usar pip3 y verificar tamaño del zip (debe ser ~3MB)

## Archivos del Proyecto

- **app.py**: Código FastAPI (proporcionado por el profesor)
- **requirements.txt**: Dependencias mínimas (fastapi, mangum)
- **package.sh**: Script de empaquetado con Docker
- **package_simple.sh**: Script alternativo sin Docker
- **lambda_function.zip**: Paquete final subido a Lambda (~3MB)

## Configuración en AWS

### Lambda Function
- **Runtime**: Python 3.12
- **Handler**: `app.mangum`
- **Timeout**: 30 segundos (recomendado)
- **Memory**: 128 MB (suficiente)

### API Gateway
- **Tipo**: HTTP API
- **Security**: Open
- **Integration**: Lambda proxy

## Comandos Útiles

```bash
# Empaquetar con Docker (requiere Docker instalado)
./package.sh

# Empaquetar sin Docker
./package_simple.sh

# Verificar tamaño del zip
ls -lh lambda_function.zip

# Subir a Lambda con AWS CLI
aws lambda update-function-code \
  --function-name fastapi-lambda-punto1 \
  --zip-file fileb://lambda_function.zip \
  --region us-east-2
```

## Referencias

- [AWS Lambda Python Runtimes](https://docs.aws.amazon.com/lambda/latest/dg/lambda-python.html)
- [Mangum Documentation](https://mangum.io/)
- [FastAPI on Lambda Guide](https://fastapi.tiangolo.com/deployment/lambda/)

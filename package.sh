#!/bin/bash

echo "=== Empaquetando para AWS Lambda ==="

# Limpiar directorio anterior
rm -rf package
rm -f lambda_function.zip

# Crear directorio para dependencias
mkdir package

# Usar Docker para crear el paquete con dependencias Linux
docker run --rm -v "$PWD":/var/task public.ecr.aws/lambda/python:3.12 \
    pip install -r requirements.txt -t package/

# Copiar el código
cp app.py package/

# Crear ZIP
cd package
zip -r ../lambda_function.zip .
cd ..

# Limpiar
rm -rf package

echo ""
echo "=== Paquete creado: lambda_function.zip ==="
ls -lh lambda_function.zip

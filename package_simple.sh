#!/bin/bash

echo "=== Método Simple: Descargando dependencias pre-compiladas ==="

# Limpiar
rm -rf package lambda_function.zip

# Crear directorio
mkdir -p package

# Descargar wheels para Linux desde PyPI
pip3 download --platform manylinux2014_x86_64 --only-binary=:all: --python-version 312 --implementation cp fastapi mangum -d wheels/

# Descomprimir wheels
cd wheels
for file in *.whl; do
    unzip -q -o "$file" -d ../package/
done
cd ..

# Copiar código
cp app.py package/

# Crear ZIP
cd package
zip -r9 ../lambda_function.zip .
cd ..

# Limpiar
rm -rf wheels package

echo ""
echo "=== Paquete creado ==="
ls -lh lambda_function.zip

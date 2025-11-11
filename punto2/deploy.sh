#!/bin/bash

echo "=== Paso 1: Subir archivos a EC2 ==="
scp -i ../llavepem.pem -r . ubuntu@3.150.111.184:/home/ubuntu/punto2/
if [ $? -ne 0 ]; then
    echo "Error al subir archivos. Verifica tu conexión."
    exit 1
fi

echo ""
echo "=== Paso 2: Configurar EC2 ==="
ssh -i ../llavepem.pem ubuntu@3.150.111.184 << 'EOF'
# Actualizar sistema
sudo apt update
sudo apt install python3-pip -y

# Crear y activar entorno virtual
cd /home/ubuntu
python3 -m venv venv
source venv/bin/activate

# Instalar dependencias en el venv
pip install -r punto2/requirements.txt

# Matar procesos existentes en puerto 8000
sudo pkill -f uvicorn || true

# Crear archivo de servicio con la ruta correcta del venv
sudo bash -c 'cat > /etc/systemd/system/app.service << SERVICEFILE
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
SERVICEFILE'

# Configurar servicio
sudo systemctl daemon-reload
sudo systemctl enable app.service
sudo systemctl start app.service

# Verificar estado
sleep 2
sudo systemctl status app.service --no-pager

echo ""
echo "=== Instalación completa ==="
echo "Accede a: http://3.150.111.184:8000/docs"
EOF

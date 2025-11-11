from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import boto3
import pandas as pd
from io import StringIO

app = FastAPI(title="API EC2-S3")

# Configuración S3
BUCKET_NAME = "final-se-simoneia-so"
CSV_KEY = "datos.csv"
s3_client = boto3.client('s3', region_name='us-east-2')

# Modelo Pydantic para validación
class Persona(BaseModel):
    nombre: str = Field(..., min_length=1)
    edad: int = Field(..., gt=0, le=150)
    altura: float = Field(..., gt=0, le=300)

@app.post("/persona")
async def agregar_persona(persona: Persona):
    try:
        # Intentar descargar CSV existente
        try:
            response = s3_client.get_object(Bucket=BUCKET_NAME, Key=CSV_KEY)
            df = pd.read_csv(StringIO(response['Body'].read().decode('utf-8')))
        except:
            # Si no existe, crear DataFrame vacío
            df = pd.DataFrame(columns=['nombre', 'edad', 'altura'])

        # Agregar nueva fila
        nueva_fila = pd.DataFrame([persona.dict()])
        df = pd.concat([df, nueva_fila], ignore_index=True)

        # Guardar en S3
        csv_buffer = StringIO()
        df.to_csv(csv_buffer, index=False)
        s3_client.put_object(
            Bucket=BUCKET_NAME,
            Key=CSV_KEY,
            Body=csv_buffer.getvalue()
        )

        return {"mensaje": "Persona agregada exitosamente", "total_filas": len(df)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/filas")
async def obtener_numero_filas():
    try:
        response = s3_client.get_object(Bucket=BUCKET_NAME, Key=CSV_KEY)
        df = pd.read_csv(StringIO(response['Body'].read().decode('utf-8')))
        return {"numero_filas": len(df)}
    except s3_client.exceptions.NoSuchKey:
        return {"numero_filas": 0}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"mensaje": "API funcionando correctamente"}

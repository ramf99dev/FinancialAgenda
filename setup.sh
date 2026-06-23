#!/bin/bash
# ==============================================================================
# Script de Configuración Inicial - Agenda Financiera iOS
# ==============================================================================

# Detiene la ejecución si ocurre algún error
set -e

echo "=== Configurando entorno de desarrollo de Agenda Financiera ==="

# Ruta al archivo de secretos y su plantilla
SECRETS_TEMPLATE="Core/Networking/Secrets.swift.example"
SECRETS_FILE="Core/Networking/Secrets.swift"

# Validar que existe la plantilla
if [ ! -f "$SECRETS_TEMPLATE" ]; then
    echo "Error: No se pudo encontrar el archivo plantilla '$SECRETS_TEMPLATE'."
    echo "Asegúrate de estar ejecutando este script desde la raíz del proyecto."
    exit 1
fi

# Copiar el archivo si no existe
if [ ! -f "$SECRETS_FILE" ]; then
    echo "Creando '$SECRETS_FILE' a partir de la plantilla..."
    cp "$SECRETS_TEMPLATE" "$SECRETS_FILE"
    echo "Archivo Secrets.swift creado exitosamente."
    echo "IMPORTANTE: Abre '$SECRETS_FILE' y coloca tu URL y Key reales de Supabase."
else
    echo "El archivo '$SECRETS_FILE' ya existe. No se realizaron cambios."
fi

echo "=== Configuración completada con éxito ==="

#!/bin/bash
# Script para desplegar PrensAI API en Google Cloud Run
# Uso: ./bin/deploy-cloud-run.sh [environment]
# Ejemplo: ./bin/deploy-cloud-run.sh production

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar que gcloud esté instalado
if ! command -v gcloud &> /dev/null; then
    log_error "gcloud CLI no está instalado. Instálalo desde: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Configuración
ENVIRONMENT=${1:-production}
PROJECT_ID=${GCP_PROJECT_ID}
REGION=${GCP_REGION:-us-central1}
SERVICE_NAME="prensai-api"

log_info "Iniciando deployment en Cloud Run..."
log_info "Proyecto: $PROJECT_ID"
log_info "Región: $REGION"
log_info "Servicio: $SERVICE_NAME"
echo ""

# Verificar que el proyecto esté configurado
if [ -z "$PROJECT_ID" ]; then
    log_error "La variable GCP_PROJECT_ID no está definida"
    log_info "Configúrala con: export GCP_PROJECT_ID=tu-project-id"
    exit 1
fi

# Configurar proyecto
log_info "Configurando proyecto de GCP..."
gcloud config set project $PROJECT_ID

# Autenticar (si es necesario)
log_info "Verificando autenticación..."
gcloud auth application-default print-access-token > /dev/null 2>&1 || {
    log_warning "No estás autenticado. Ejecutando gcloud auth login..."
    gcloud auth login
}

# Habilitar APIs necesarias
log_info "Verificando APIs habilitadas..."
gcloud services enable \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    sql-component.googleapis.com \
    sqladmin.googleapis.com \
    storage-api.googleapis.com \
    secretmanager.googleapis.com

log_success "APIs habilitadas correctamente"

# Build y deploy usando Cloud Build
log_info "Iniciando build con Cloud Build..."
gcloud builds submit --config cloudbuild.yaml \
    --substitutions=_CLOUD_RUN_REGION=$REGION

log_success "Deployment completado exitosamente!"

# Obtener URL del servicio
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
    --platform managed \
    --region $REGION \
    --format 'value(status.url)')

echo ""
log_success "🚀 Tu API está disponible en:"
echo -e "${GREEN}${SERVICE_URL}${NC}"
echo ""
log_info "Para ver los logs:"
echo "gcloud logs tail --service=$SERVICE_NAME"
echo ""
log_info "Para ver el estado del servicio:"
echo "gcloud run services describe $SERVICE_NAME --region=$REGION"


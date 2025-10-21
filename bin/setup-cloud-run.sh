#!/bin/bash
# Script de configuración inicial para Google Cloud Run
# Este script ayuda a configurar todos los servicios necesarios en GCP
# Uso: ./bin/setup-cloud-run.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         PrensAI - Configuración de Cloud Run              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar gcloud
if ! command -v gcloud &> /dev/null; then
    log_error "gcloud CLI no está instalado"
    log_info "Instálalo desde: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Solicitar información del proyecto
echo ""
log_info "Por favor, ingresa la información de tu proyecto:"
echo ""

read -p "Project ID de GCP: " PROJECT_ID
read -p "Región (default: us-central1): " REGION
REGION=${REGION:-us-central1}

# Configurar proyecto
log_info "Configurando proyecto: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# Autenticar
log_info "Verificando autenticación..."
gcloud auth application-default print-access-token > /dev/null 2>&1 || {
    log_warning "Autenticando..."
    gcloud auth login
    gcloud auth application-default login
}

# Habilitar APIs
log_info "Habilitando APIs necesarias (esto puede tardar unos minutos)..."
gcloud services enable \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    sql-component.googleapis.com \
    sqladmin.googleapis.com \
    storage-api.googleapis.com \
    secretmanager.googleapis.com \
    compute.googleapis.com \
    cloudresourcemanager.googleapis.com

log_success "APIs habilitadas"

# Crear instancia de Cloud SQL
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "Configuración de Cloud SQL (PostgreSQL)"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "Nombre de la instancia de Cloud SQL (default: prensai-db): " SQL_INSTANCE
SQL_INSTANCE=${SQL_INSTANCE:-prensai-db}

read -p "Tier de la instancia (default: db-f1-micro): " SQL_TIER
SQL_TIER=${SQL_TIER:-db-f1-micro}

log_info "Creando instancia Cloud SQL: $SQL_INSTANCE..."
gcloud sql instances create $SQL_INSTANCE \
    --database-version=POSTGRES_16 \
    --tier=$SQL_TIER \
    --region=$REGION \
    --edition=STANDARD \
    --root-password=$(openssl rand -base64 32) \
    --database-flags=max_connections=100 \
    --backup-start-time=03:00 \
    --enable-bin-log \
    --maintenance-window-day=SUN \
    --maintenance-window-hour=4 || log_warning "La instancia $SQL_INSTANCE ya existe o hubo un error"

log_success "Cloud SQL configurado"

# Crear base de datos
log_info "Creando base de datos production..."
gcloud sql databases create prensai_production \
    --instance=$SQL_INSTANCE || log_warning "La base de datos ya existe"

# Crear usuario de base de datos
read -p "Usuario de PostgreSQL (default: prensai_user): " DB_USER
DB_USER=${DB_USER:-prensai_user}

DB_PASSWORD=$(openssl rand -base64 32)

log_info "Creando usuario de base de datos..."
gcloud sql users create $DB_USER \
    --instance=$SQL_INSTANCE \
    --password=$DB_PASSWORD || log_warning "El usuario ya existe"

log_success "Usuario de base de datos creado"
log_warning "Guarda esta contraseña: $DB_PASSWORD"

# Crear bucket de Cloud Storage
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "Configuración de Cloud Storage"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "Nombre del bucket (default: $PROJECT_ID-prensai-storage): " BUCKET_NAME
BUCKET_NAME=${BUCKET_NAME:-$PROJECT_ID-prensai-storage}

log_info "Creando bucket: $BUCKET_NAME..."
gcloud storage buckets create gs://$BUCKET_NAME \
    --location=$REGION \
    --uniform-bucket-level-access || log_warning "El bucket ya existe"

log_success "Cloud Storage configurado"

# Configurar Secret Manager
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "Configuración de Secret Manager"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log_info "Por favor, ingresa los valores de los secretos:"

# RAILS_MASTER_KEY
if [ -f "config/master.key" ]; then
    RAILS_MASTER_KEY=$(cat config/master.key)
    log_info "RAILS_MASTER_KEY encontrado en config/master.key"
else
    read -sp "RAILS_MASTER_KEY (desde config/master.key): " RAILS_MASTER_KEY
    echo ""
fi

echo -n "$RAILS_MASTER_KEY" | gcloud secrets create rails-master-key \
    --data-file=- \
    --replication-policy=automatic || \
    echo -n "$RAILS_MASTER_KEY" | gcloud secrets versions add rails-master-key --data-file=-

# DATABASE_URL
CONNECTION_NAME="$PROJECT_ID:$REGION:$SQL_INSTANCE"
DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@localhost/prensai_production?host=/cloudsql/$CONNECTION_NAME"

echo -n "$DATABASE_URL" | gcloud secrets create database-url \
    --data-file=- \
    --replication-policy=automatic || \
    echo -n "$DATABASE_URL" | gcloud secrets versions add database-url --data-file=-

log_success "Secretos configurados en Secret Manager"

# Crear service account para Cloud Run
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "Configuración de Service Account"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

SA_NAME="prensai-cloud-run-sa"
SA_EMAIL="$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"

log_info "Creando service account: $SA_NAME..."
gcloud iam service-accounts create $SA_NAME \
    --display-name="PrensAI Cloud Run Service Account" || log_warning "Service account ya existe"

# Asignar permisos
log_info "Asignando permisos necesarios..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/cloudsql.client"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/secretmanager.secretAccessor"

log_success "Service account configurado"

# Generar archivo de configuración
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "Generando archivo de configuración"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat > .env.cloud-run << EOF
# Generado automáticamente por setup-cloud-run.sh
# Fecha: $(date)

GCP_PROJECT_ID=$PROJECT_ID
GCP_REGION=$REGION
CLOUDSQL_INSTANCE_CONNECTION_NAME=$CONNECTION_NAME
GCS_BUCKET_NAME=$BUCKET_NAME
DATABASE_URL=$DATABASE_URL
POSTGRES_USER=$DB_USER
POSTGRES_PASSWORD=$DB_PASSWORD
EOF

log_success "Archivo .env.cloud-run creado"

# Resumen final
echo ""
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              ✅ Configuración Completada                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
log_info "Resumen de la configuración:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Proyecto:              $PROJECT_ID"
echo "Región:                $REGION"
echo "Cloud SQL:             $SQL_INSTANCE"
echo "Connection Name:       $CONNECTION_NAME"
echo "Base de datos:         prensai_production"
echo "Usuario DB:            $DB_USER"
echo "Cloud Storage Bucket:  $BUCKET_NAME"
echo "Service Account:       $SA_EMAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_success "Próximos pasos:"
echo "1. Revisa el archivo .env.cloud-run con la configuración"
echo "2. Ejecuta: ./bin/deploy-cloud-run.sh"
echo "3. O configura GitHub Actions para deployment automático"
echo ""
log_warning "IMPORTANTE: Guarda la contraseña de la base de datos en un lugar seguro:"
echo "$DB_PASSWORD"
echo ""


#!/bin/bash

set -euo pipefail

#################################################
# CONFIG
#################################################

DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

#################################################
# COLORS
#################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

#################################################
# FUNCTIONS
#################################################

info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

run_cmd() {

  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] $*"
  else
    eval "$@"
  fi
}

#################################################
# ROOT PROJECT
#################################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

#################################################
# .ENV
#################################################

if [ ! -f ".env" ]; then
  error ".env non trovato"
  exit 1
fi

source .env

#################################################
# REQUIRED VARS
#################################################

REQUIRED_VARS=(
  SUPABASE_URL
  SUPABASE_SERVICE_ROLE_KEY
  ADMIN_EMAIL
  ADMIN_PASSWORD
  ADMIN_NOME
  ADMIN_COGNOME
)

for var in "${REQUIRED_VARS[@]}"; do

  if [ -z "${!var:-}" ]; then
    error "Variabile mancante: $var"
    exit 1
  fi

done

#################################################
# OPTIONAL SECRETS
#################################################

OPTIONAL_SECRETS=(
  RESEND_API_KEY
  SMTP_USERNAME
  SMTP_PASSWORD
  BREVO_API_KEY
)

for secret in "${OPTIONAL_SECRETS[@]}"; do

  if [ -z "${!secret:-}" ]; then
    warn "Secret non valorizzato: $secret"
  fi

done

#################################################
# REQUIREMENTS
#################################################

command -v supabase >/dev/null 2>&1 \
  || { error "Supabase CLI non installata"; exit 1; }

command -v node >/dev/null 2>&1 \
  || { error "Node.js non installato"; exit 1; }

#################################################
# PROJECT INFO
#################################################

echo
echo "=================================="
echo "SUPABASE PROVISIONING"
echo "=================================="
echo

info "Progetto collegato"

supabase projects list

echo

if [ "$DRY_RUN" = false ]; then

  read -p "Continuare? [y/N]: " CONFIRM

  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Operazione annullata"
    exit 0
  fi

fi

#################################################
# APPLY MIGRATIONS
#################################################

echo
echo "=================================="
echo "1. APPLY MIGRATIONS"
echo "=================================="

if [ ! -d "supabase/migrations" ]; then
  error "Cartella supabase/migrations non trovata"
  exit 1
fi

run_cmd "supabase db push"

#################################################
# LOAD SEED
#################################################

echo
echo "=================================="
echo "2. LOAD SEED DATA"
echo "=================================="

if [ ! -f "supabase/seed.sql" ]; then
  error "supabase/seed.sql non trovato"
  exit 1
fi

run_cmd "supabase db query --linked -f supabase/seed.sql"

#################################################
# VERIFY ROLES
#################################################

echo
echo "=================================="
echo "3. VERIFY SEED"
echo "=================================="

if [ "$DRY_RUN" = false ]; then

  ADMIN_COUNT=$(
    supabase db query \
      --linked \
      "select count(*) from public.roles where code = 'admin';" \
      --output csv \
      | tail -n 1
  )

  if [ "$ADMIN_COUNT" != "1" ]; then

    error "Ruolo 'admin' non presente"

    echo
    echo "Verificare seed.sql"
    echo

    exit 1

  fi

  info "Ruolo admin verificato"

fi

#################################################
# DEPLOY SECRETS
#################################################

echo
echo "=================================="
echo "4. DEPLOY SECRETS"
echo "=================================="

SECRET_ARGS=()

[ -n "${RESEND_API_KEY:-}" ] \
  && SECRET_ARGS+=("RESEND_API_KEY=$RESEND_API_KEY")

[ -n "${SMTP_USERNAME:-}" ] \
  && SECRET_ARGS+=("SMTP_USERNAME=$SMTP_USERNAME")

[ -n "${SMTP_PASSWORD:-}" ] \
  && SECRET_ARGS+=("SMTP_PASSWORD=$SMTP_PASSWORD")

[ -n "${BREVO_API_KEY:-}" ] \
  && SECRET_ARGS+=("BREVO_API_KEY=$BREVO_API_KEY")

if [ ${#SECRET_ARGS[@]} -gt 0 ]; then

  CMD="supabase secrets set"

  for s in "${SECRET_ARGS[@]}"; do
    CMD="$CMD \"$s\""
  done

  run_cmd "$CMD"

else

  warn "Nessun secret da deployare"

fi

#################################################
# DEPLOY FUNCTIONS
#################################################

echo
echo "=================================="
echo "5. DEPLOY EDGE FUNCTIONS"
echo "=================================="

if [ -d "supabase/functions" ]; then

  for dir in supabase/functions/*; do

    [ -d "$dir" ] || continue

    FUNCTION_NAME=$(basename "$dir")

    info "Deploy funzione: $FUNCTION_NAME"

    run_cmd "supabase functions deploy $FUNCTION_NAME"

  done

else

  warn "Cartella functions non trovata"

fi

#################################################
# CREATE ADMIN
#################################################

echo
echo "=================================="
echo "6. CREATE ADMIN USER"
echo "=================================="

if [ -f "supabase/provision-admin-new.js" ]; then

  run_cmd "node supabase/provision-admin-new.js"

else

  error "supabase/provision-admin-new.js non trovato"
  exit 1

fi

#################################################
# FINAL CHECK
#################################################

echo
echo "=================================="
echo "7. FINAL CHECK"
echo "=================================="

if [ "$DRY_RUN" = false ]; then

  supabase secrets list || true

fi

#################################################
# SUMMARY
#################################################

echo
echo "=================================="
echo "PROVISIONING COMPLETED"
echo "=================================="

echo
echo "Admin:"
echo "  Email : $ADMIN_EMAIL"

echo
echo "Dry Run:"
echo "  $DRY_RUN"

echo
echo "Verifiche consigliate:"
echo "  - Login amministratore"
echo "  - Policy RLS"
echo "  - Edge Functions"
echo "  - Menu e permessi"
echo "  - Secrets"
echo "  - Bucket Storage"
echo
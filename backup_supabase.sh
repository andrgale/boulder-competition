#!/bin/bash

set -euo pipefail

########################################
# CONFIG
########################################

source .env
if [ -z "${SRC_DB_URL:-}" ]; then
    echo "Errore: SRC_DB_URL non definita nel file .env"
    exit 1
fi

MIGRATIONS_DIR="./supabase/migrations"

TIMESTAMP=$(date +%Y%m%d%H%M%S)

OUTPUT_FILE="${MIGRATIONS_DIR}/${TIMESTAMP}_remote_schema.sql"

########################################
# START
########################################

echo ""
echo "=================================="
echo "SUPABASE REMOTE SCHEMA BACKUP"
echo "=================================="
echo ""

echo "Database sorgente:"
echo "$SRC_DB_URL"
echo ""

echo "File destinazione:"
echo "$OUTPUT_FILE"
echo ""

########################################
# BACKUP SCHEMA
########################################

echo "Estrazione schema remoto..."

supabase db dump \
  --db-url "$SRC_DB_URL" \
  -f "$OUTPUT_FILE"

########################################
# CLEANUP HEADER
########################################

# Alcune versioni del dump inseriscono istruzioni
# che possono dare fastidio nelle migration.

TMP_FILE="${OUTPUT_FILE}.tmp"

grep -v "^SET statement_timeout" "$OUTPUT_FILE" \
| grep -v "^SET lock_timeout" \
| grep -v "^SET idle_in_transaction_session_timeout" \
| grep -v "^SET client_encoding" \
| grep -v "^SET standard_conforming_strings" \
| grep -v "^SET check_function_bodies" \
| grep -v "^SET xmloption" \
| grep -v "^SET client_min_messages" \
| grep -v "^SET row_security" \
> "$TMP_FILE"

mv "$TMP_FILE" "$OUTPUT_FILE"

########################################
# INFO
########################################

echo ""
echo "=================================="
echo "BACKUP COMPLETATO"
echo "=================================="
echo ""

echo "Migration generata:"
echo "$OUTPUT_FILE"
echo ""

echo "Contenuto:"
echo "  - Tabelle"
echo "  - View"
echo "  - Function"
echo "  - Trigger"
echo "  - Policies RLS"
echo "  - Grants"
echo "  - Extensions"
echo "  - Storage schema"
echo ""

echo "Non inclusi:"
echo "  - Edge Functions"
echo "  - Secrets"
echo "  - Dati delle tabelle"
echo ""
#!/bin/bash

set -e

source .env

echo ""
echo "=================================="
echo "1. APPLY MIGRATIONS"
echo "=================================="

supabase db push

echo ""
echo "=================================="
echo "2. LOAD SEED DATA"
echo "=================================="

psql "$DATABASE_URL" -f supabase/seed.sql

echo ""
echo "=================================="
echo "3. CREATE ADMIN USER"
echo "=================================="

node supabase/provision-admin.js

echo ""
echo "=================================="
echo "4. DEPLOY EDGE FUNCTIONS"
echo "=================================="

for dir in supabase/functions/*; do

    if [ -d "$dir" ]; then

        function_name=$(basename "$dir")

        echo ""
        echo "Deploying: $function_name"

        supabase functions deploy "$function_name"

    fi

done

echo ""
echo "=================================="
echo "PROVISIONING COMPLETED"
echo "=================================="
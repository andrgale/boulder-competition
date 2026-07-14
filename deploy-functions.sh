#!/bin/bash

set -e

echo ""
echo "=================================="
echo "DEPLOY EDGE FUNCTIONS"
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
echo "FUNCTIONS DEPLOYED"
echo "=================================="
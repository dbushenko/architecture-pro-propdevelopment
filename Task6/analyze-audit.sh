#!/bin/bash

INPUT_FILE="audit.log"
OUTPUT_FILE="audit-extract.json"

if [ ! -f "$INPUT_FILE" ]; then
    echo "No $INPUT_FILE found!"
    exit 1
fi

TEMP_FILE=$(mktemp)

# 1. Access to secrets
grep '"resource":"secrets".*"kube-system"' "$INPUT_FILE" >> "$TEMP_FILE"

# 2. privileged=true
grep -i 'privileged.*true' "$INPUT_FILE" >> "$TEMP_FILE"

# 3. kubectl exec
grep 'exec' "$INPUT_FILE" | grep 'coredns\|kube-apiserver\|etcd' >> "$TEMP_FILE"

# Remove dublicates
if [ -s "$TEMP_FILE" ]; then
    {
        echo "{"
        echo "  \"suspicious_events\": ["
        sed 's|$|,|' "$TEMP_FILE" | sed '$s|,$||'
        echo "  ]"
        echo "}"
    } > "$OUTPUT_FILE"
else
    echo '{"suspicious_events": []}' > "$OUTPUT_FILE"
fi

rm "$TEMP_FILE"

echo "Success"

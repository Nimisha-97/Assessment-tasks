#!/bin/bash
VAULT_ADDR="${VAULT_ADDR}"
VAULT_TOKEN="${VAULT_TOKEN}"
SECRET_PATH="${SECRET_PATH}"

if [ -z "$VAULT_TOKEN" ]; then
  echo "ERROR: VAULT_TOKEN is not set"
  echo "Usage: export VAULT_TOKEN=your-token"
  exit 1
fi

echo "Fetching secret from: $VAULT_ADDR/$SECRET_PATH"

RESPONSE=$(curl -s \
  --max-time 10 \
  --header "X-Vault-Token: $VAULT_TOKEN" \
  "$VAULT_ADDR/v1/$SECRET_PATH")

# ─── Handle failures ───
if [ $? -ne 0 ]; then
  echo "ERROR: Could not connect to Vault at $VAULT_ADDR"
  exit 1
fi

ERRORS=$(echo "$RESPONSE" | grep -o '"errors":\[[^]]*\]')
if [ -n "$ERRORS" ]; then
  echo "ERROR: Vault returned an error — $ERRORS"
  exit 1
fi

echo "Secret fetched successfully:"
echo "$RESPONSE" | grep -o '"data":{[^}]*}' | sed 's/"data"://'

#Bonus:Renew token
echo ""
echo "Renewing Vault token..."
RENEW=$(curl -s \
  --max-time 10 \
  --request POST \
  --header "X-Vault-Token: $VAULT_TOKEN" \
  "$VAULT_ADDR/v1/auth/token/renew-self")

if echo "$RENEW" | grep -q '"lease_duration"'; then
  echo "Token renewed successfully"
else
  echo "Warning: Token renewal failed"
fi
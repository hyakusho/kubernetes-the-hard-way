#!/bin/bash
set -eo pipefail

BASE_DIR="$(cd $(dirname $0)/..; pwd -P)"
TMP_DIR="$BASE_DIR/tmp"
cd $TMP_DIR

# The Encryption Key
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

# The Encryption Config File
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

# Distribute
for instance in controller-0 controller-1 controller-2; do
  if [ "$instance" = "controller-0" ]; then
    zone="asia-northeast1-a"
  elif [ "$instance" = "controller-1" ]; then
    zone="asia-northeast1-b"
  else
    zone="asia-northeast1-c"
  fi
  gcloud compute scp --zone $zone encryption-config.yaml ${instance}:~/
done

cd -

# Kubernetes the hard way
## 環境

## 事前準備
```
gcloud
terraform
ansible
direnv
```

## Terraformを実行するサービスアカウントの作成
```
GCP_PROJECT=$(gcloud config get-value core/project)
SERVICE_ACCOUNT=terraform
gcloud iam service-accounts create $SERVICE_ACCOUNT --display-name $SERVICE_ACCOUNT
gcloud iam service-accounts keys create ./${SERVICE_ACCOUNT}-key.json \
  --iam-account ${SERVICE_ACCOUNT}@${GCP_PROJECT}.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding $GCP_PROJECT \
  --member serviceAccount:${SERVICE_ACCOUNT}@${GCP_PROJECT}.iam.gserviceaccount.com \
  --role roles/compute.admin \
  --role roles/iam.serviceAccountUser
```

## Ansibleを実行するサービスアカウントの作成
```
GCP_PROJECT=$(gcloud config get-value core/project)
SERVICE_ACCOUNT=ansible
gcloud iam service-accounts create $SERVICE_ACCOUNT --display-name $SERVICE_ACCOUNT
gcloud iam service-accounts keys create ./${SERVICE_ACCOUNT}-key.json \
  --iam-account ${SERVICE_ACCOUNT}@${GCP_PROJECT}.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding $GCP_PROJECT \
  --member serviceAccount:${SERVICE_ACCOUNT}@${GCP_PROJECT}.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser \
  --role roles/compute.osAdminLogin \
  --role roles/compute.instanceAdmin \
  --role roles/compute.instanceAdmin.v1
```

## Terraformの実行
```
cd terraform
terraform init
terraform plan
terraform apply
```

## Dnyamic inventory
```
pip install --upgrade --user -r requirements.txt
```

## 環境変数の作成
```
export GCP_AUTH_KIND="serviceaccount"
export GCP_SERVICE_ACCOUNT_FILE="<path/to/file>"
export GCP_SCOPES="https://www.googleapis.com/auth/compute"
```

## cfssl, cfssljsonのインストール
```
% wget -q --show-progress --https-only --timestamping \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssl \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssljson
% chmod +x cfssl cfssljson
% sudo mv cfssl cfssljson /usr/local/bin/
% cfssl version
% cfssljson --version
```


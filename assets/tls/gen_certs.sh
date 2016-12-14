#!/bin/bash

set -e

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
echo "Cleaning up: $SCRIPTPATH"

cd $SCRIPTPATH

rm *.pem || true
rm *.csr || true
rm *.srl || true

openssl genrsa -out ca-key.pem 2048
openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"

openssl genrsa -out apiserver-key.pem 2048
openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=kube-apiserver" -config api-server.cnf
openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 10000 -extensions v3_req -extfile api-server.cnf

openssl genrsa -out admin-key.pem 2048
openssl req -new -key admin-key.pem -out admin.csr -subj "/CN=kube-admin"
openssl x509 -req -in admin.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out admin.pem -days 10000

kubectl config set-cluster default-cluster --server=https://$MASTER_FQDN --certificate-authority=$(pwd)/ca.pem
kubectl config set-credentials default-admin --certificate-authority=$(pwd)/ca.pem --client-key=$(pwd)/admin-key.pem --client-certificate=$(pwd)/admin.pem
kubectl config set-context default-system --cluster=default-cluster --user=default-admin
kubectl config use-context default-system

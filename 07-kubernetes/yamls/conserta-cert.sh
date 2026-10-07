#!/bin/bash
# captura o certificado atual, instala no minikube e reinicia o containerd
minikube ssh -- "openssl s_client -connect production.cloudfront.docker.com:443 -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM | sudo tee /usr/local/share/ca-certificates/cloudflare.crt >/dev/null && sudo update-ca-certificates && sudo systemctl restart containerd"

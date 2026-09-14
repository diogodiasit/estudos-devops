# Projeto: Webserver com Docker Compose

## O que é
Servidor web Nginx, containerizado, construído a partir de um Dockerfile próprio,
orquestrado junto com um banco Postgres via docker-compose.yml.

## Imagem publicada no Docker Hub
docker.io/diogojdiasit/estudos-devops-webserver

Como baixar e rodar:
docker pull diogojdiasit/estudos-devops-webserver
docker run -d -p 8080:80 diogojdiasit/estudos-devops-webserver

## Vídeo demonstrando o processo
https://drive.google.com/file/d/1iAQM2N8m5RQ0xifzyF-sENz_NpfXmMSV/view?usp=drive_link

## Conceitos aplicados nesse projeto
- Dockerfile (FROM, COPY)
- Docker Compose (services, build, image, ports, environment, volumes)
- Volumes para persistência de dados
- Publicação de imagem própria no Docker Hub (tag + push)
- Indentação YAML (2 espaços por nível de aninhamento)

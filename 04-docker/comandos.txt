# Comandos praticados - Fase 04 Docker

## Verificar instalação
docker --version

## Rodar um container simples (baixa a imagem se não tiver)
docker run hello-world

## Rodar um servidor web real, em segundo plano, com porta mapeada
docker run -d -p 8080:80 nginx
# -d = detached, roda em segundo plano
# -p 8080:80 = mapeia porta 8080 da máquina para porta 80 do container

## Ver containers em execução agora
docker ps

## Ver TODOS os containers, incluindo parados
docker ps -a

## Entrar dentro de um container rodando (tipo SSH, mas local)
docker exec -it <CONTAINER_ID> bash

## Ver as imagens já baixadas/construídas na máquina
docker images

## Religar um container que já existe, mas está parado (mantém config, incluindo porta)
docker start <CONTAINER_ID>

## Parar um container em execução
docker stop <CONTAINER_ID>

## Remover um container (só funciona se estiver parado)
docker rm <CONTAINER_ID>

## Construir uma imagem própria a partir de um Dockerfile
docker build -t meu-webserver .
# -t = nomeia a imagem
# . = usa a pasta atual como contexto de build

## Rodar a imagem própria numa porta diferente
docker run -d -p 8081:80 meu-webserver

## Conceito-chave: Dockerfile (a receita)
# FROM nginx:alpine -> parte de uma imagem base já pronta
# COPY index.html /usr/share/nginx/html/index.html -> copia arquivo local para dentro da imagem
# Arquivos usados no COPY precisam estar dentro do "contexto de build"
# (a pasta onde o build é rodado, incluindo subpastas - nunca fora dela, tipo ../)

## Diferença importante
# docker run = cria um container NOVO (porta precisa ser escolhida de novo)
# docker start = religa um container EXISTENTE (mantém a config de antes)
# container parado (Exited) ainda existe; container removido (rm) some de vez

## Ver logs de um container em tempo real
docker logs -f <nome_ou_id_do_container>
# -f = follow, mostra em tempo real conforme acontece
# Equivalente ao journalctl -f, mas para dentro de containers
# (containers geralmente nao rodam systemd, entao journalctl nao funciona la dentro)

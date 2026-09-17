# =========================================================
# Dockerfile
# Receita para construir a imagem do sistema de agendamento
# =========================================================

# Imagem base: já vem com o Python 3.12 instalado.
# "slim" é uma versão enxuta, sem ferramentas extras que não
# vamos usar - deixa a imagem final menor e mais rápida de baixar.
FROM python:3.12-slim

# Define a pasta de trabalho DENTRO do container.
# Tudo que vier depois (COPY, RUN) vai acontecer relativo a essa pasta.
# Se ela não existir dentro da imagem, o Docker cria automaticamente.
WORKDIR /app

# Copia só o requirements.txt primeiro (antes do resto do código).
# Isso é proposital: se só o código mudar (não as dependências),
# o Docker reaproveita o cache dessa camada, tornando builds futuros
# mais rápidos - só reinstala tudo se o requirements.txt mudar.
COPY requirements.txt .

# Instala tudo que está listado no requirements.txt, nas versões
# exatas que foram fixadas (pytest, e as dependências dele).
RUN pip install -r requirements.txt

# Agora sim copia o código da aplicação e os testes para dentro
# da imagem, na pasta de trabalho definida acima (/app).
COPY sistema_agendamento.py test_agendamento.py ./

# Comando padrão executado quando o container for iniciado com
# "docker run". Aqui, já roda os testes automaticamente.
CMD ["pytest"]

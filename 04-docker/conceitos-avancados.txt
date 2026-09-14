# Conceitos avançados - Fase 04 Docker

## RUN vs CMD
- RUN: executa durante o BUILD da imagem. Roda uma vez, fica gravado permanentemente.
  Usado para instalar dependências, ajustar permissões, etc.
- CMD: executa quando o container LIGA (docker run). Roda toda vez.
  É o processo principal que mantém o container vivo.
- Exemplo real (do nginx): CMD ["nginx", "-g", "daemon off;"]
  "daemon off" mantém o Nginx em primeiro plano - necessário porque o container
  morre no instante em que o processo principal (CMD) termina.

## Politicas de restart
docker run -d --restart unless-stopped -p 8080:80 nginx
- no = nunca reinicia (padrão)
- always = reinicia sempre, até depois de reiniciar a máquina
- unless-stopped = reinicia sempre, a menos que eu tenha parado manualmente
- on-failure = só reinicia se terminou com erro

## Camada gravável do container (writable layer)
- A imagem é composta de camadas FIXAS, somente leitura.
- Quando um container liga, o Docker adiciona uma camada fina e GRAVÁVEL em cima.
- Mudanças manuais feitas dentro do container (ex: editar um arquivo na mão)
  ficam SÓ nessa camada gravável, não na imagem.

## O que sobrevive e o que não sobrevive
- docker start (religar o MESMO container que só estava parado):
  a camada gravável continua existindo -> mudanças manuais sobrevivem
- Container removido e recriado a partir da imagem (ex: Kubernetes substituindo
  um container com problema):
  a camada gravável é descartada -> mudanças manuais somem, volta ao estado da imagem

## Filosofia: infraestrutura imutável ("cattle, not pets")
- Servidor tradicional (VM, físico) = "pet": você cuida dele, corrige direto nele,
  a correção fica.
- Container = "cattle" (gado): é descartável por natureza. Corrigir "no lugar"
  não é confiável, porque o container pode ser substituído a qualquer momento.
- Prática correta: NUNCA corrigir de forma permanente dentro de um container rodando.
  Corrigir na ORIGEM (código-fonte ou configuração), gerar uma imagem nova,
  e deixar essa imagem nova substituir o container antigo.

## Fluxo correto de troubleshooting em containers
1. Diagnosticar dentro do container rodando (docker exec, docker stats, logs) - OK fazer isso
2. Identificar ONDE está a causa real:
   - Código da aplicação -> repassar para o time de dev, gerar imagem nova depois
   - Dockerfile (dependência, variável, permissão) -> corrigir a receita
   - Configuração de execução (docker run/compose: limite de recurso, porta,
     variável de ambiente) -> ajustar o compose/comando de run
3. Pode aplicar correção temporária direto no container só para estancar
   o problema, sabendo que ela NÃO é permanente
4. Corrigir na origem certa, gerar imagem nova (docker build)
5. Substituir o container antigo pelo novo

## Exemplos: problema de imagem vs problema de código

Problema de IMAGEM (ambiente):
- Versão errada de dependência instalada
- Variável de ambiente faltando
- Pacote do sistema faltando (ex: falta uma lib)
- Limite de recurso não configurado (sem --memory)
- Porta errada exposta
- Permissão de arquivo errada (ex: esqueceu RUN chmod)
Sinal: geralmente aparece JÁ NA INICIALIZAÇÃO (arquivo não encontrado, permission denied)

Problema de CÓDIGO (aplicação):
- Vazamento de memória
- Query de banco mal otimizada
- Erro de lógica
- Falta de tratamento de erro
- Vulnerabilidade de segurança (ex: SQL injection)
Sinal: geralmente o container liga normal, funciona um tempo, e o problema
aparece SOB USO (não é "não iniciou", é "começou e se comportou errado depois")

Pergunta rápida para diferenciar:
"Isso aconteceria mesmo se eu rodasse essa aplicação direto na minha máquina,
sem Docker nenhum?"
- Sim -> problema de código
- Não (só acontece por causa de como o container foi montado/configurado) -> problema de imagem

## Permissões no Dockerfile
- RUN chmod 644 /caminho/arquivo   (ajusta depois de copiar)
- COPY --chown=usuario:grupo origem destino   (já ajusta dono na hora de copiar)
- USER nome_usuario   (define que o CMD final roda como esse usuário, não como root -
  boa prática de segurança, limita o estrago em caso de invasão)

## Divisão de responsabilidade (resumo para entrevista)
- DevOps/SRE é dono do "COMO isso roda": ambiente, dependências, permissões,
  recursos, configuração de deploy (tudo que vive no Dockerfile/compose).
- Time de Dev é dono do "O QUE isso faz": lógica de negócio, regras da aplicação,
  bugs de código.
- DevOps/SRE diagnostica problemas em produção e direciona a correção para o
  lugar certo - não tenta corrigir lógica de aplicação sozinho.

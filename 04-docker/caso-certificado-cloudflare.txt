# Caso de investigação: Docker não conseguia baixar imagens (erro de certificado)

## Sintoma
docker run hello-world falhava com:
x509: certificate signed by unknown authority

## Causa raiz
O Docker baixa imagens em duas etapas, com hosts diferentes:
- registry-1.docker.io -> metadados (esse estava OK)
- production.cloudfront.docker.com -> conteúdo pesado da imagem (esse tinha o problema)

A rede/Windows tem um Cloudflare Gateway fazendo INSPEÇÃO DE TRÁFEGO HTTPS.
Ele intercepta a conexão, se passa pelo destino real, e entrega um certificado
próprio no lugar do certificado original.

## Como funciona a interceptação (analogia da carta/crachá)
1. Eu mando o pedido (ex: baixar imagem do Docker)
2. Cloudflare intercepta, se passa por mim, fala com o Docker de verdade
3. Recebe a resposta real do Docker
4. Na hora de me devolver, CRIA um certificado na hora, dizendo:
   "sou um terceiro (Cloudflare) e falo em nome do Docker"
5. Como o Linux não conhecia esse terceiro, recusou (erro de certificado)

## Diagnóstico (comandos usados para investigar)

# Ver certificado de um host específico (subject = quem alega ser, issuer = quem assinou)
openssl s_client -connect production.cloudfront.docker.com:443 -showcerts \
  </dev/null 2>/dev/null | grep -E "subject=|issuer="

# Resultado que revelou o problema:
# subject=CN = production.cloudfront.docker.com
# issuer=... O = "Cloudflare, Inc." ... CN = Gateway CA - Cloudflare Managed G2
#
# O nome (subject) dizia ser do Docker, mas quem assinou (issuer) foi a Cloudflare.
# Divergência = sinal de interceptação de tráfego.

## Solução

# 1) Capturar a cadeia de certificados numa conexão real (ao vivo, não é algo pré-pronto)
openssl s_client -connect production.cloudfront.docker.com:443 -showcerts \
  </dev/null 2>/dev/null | awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/' > /tmp/chain.pem

# 2) Conferir quantos certificados vieram na cadeia (esperado: número pequeno, ex: 2)
grep -c "BEGIN CERTIFICATE" /tmp/chain.pem

# 3) Registrar esse certificado como confiável no sistema
cp /tmp/chain.pem /usr/local/share/ca-certificates/cloudflare-gateway.crt
update-ca-certificates

# 4) Reiniciar o Docker para ele carregar a nova lista de confiança
service docker restart

# 5) Testar de novo
docker run hello-world   # funcionou

## Lição para entrevista
- TLS/SSL inspection é comum em redes corporativas (antivírus, proxy, Cloudflare Gateway etc).
- Regra de ouro: nunca confiar só no "subject" de um certificado, sempre checar o "issuer".
- Um certificado não é "baixado de um site oficial" para resolver isso - ele é CAPTURADO
  ao vivo, da própria conexão interceptada, e depois adicionado à lista de confiança local.
- Raciocínio de troubleshooting usado: testar host por host, eliminando hipóteses
  (testamos registry-1.docker.io primeiro, descartamos; só depois achamos o host real
  com problema, production.cloudfront.docker.com).

## Analogia da carta/crachá (para relembrar o conceito)

Certificado = crachá de identidade que um site te entrega numa conexão HTTPS.
O crachá tem duas informações principais:
- "Eu sou..." (subject) -> quem ele ALEGA ser
- "...e quem garante isso sou eu" (issuer) -> quem ASSINOU/carimbou o crachá

No golpe da interceptação:
1. Eu mando uma carta (peço pra acessar o Docker)
2. O Cloudflare intercepta essa carta no caminho
3. Ele mesmo entrega a carta pro Docker de verdade, se passando por mim
4. Recebe a resposta real do Docker
5. Na hora de me devolver, o Cloudflare fabrica uma carta NOVA, na hora, dizendo:
   "Eu sou um terceiro chamado Cloudflare, e estou respondendo em nome do Docker.
    Pode me aceitar."
6. Como eu nunca tinha sido apresentado a esse terceiro, eu recuso (erro de certificado)

Resolução = "apresentação formal":
Eu peguei essa carta que o Cloudflare mandou, registrei no meu sistema dizendo
"esse aqui pode falar em nome de outros sites, eu confio nele" - e a partir
daí toda vez que ele aparece se identificando assim, eu aceito.

Ponto-chave para não esquecer:
A carta NÃO é algo pronto, guardado em algum lugar, esperando ser baixado.
Ela é CRIADA NA HORA, toda vez que o Cloudflare faz a devolutiva no lugar do
site de destino. Por isso "capturamos" a carta (vimos ela sendo entregue,
ao vivo, numa conexão de teste) - não "baixamos" de nenhum site oficial.

Regra de ouro: nunca olhar só o "subject" (quem alega ser) - sempre checar o
"issuer" (quem realmente assinou). Se o issuer não for uma autoridade
conhecida, é sinal de que tem alguém no meio do caminho lendo/interceptando
o tráfego.

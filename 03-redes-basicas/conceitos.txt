# Módulo 02 - Redes básicas

## Por que isso importa
No dia a dia de DevOps/SRE, boa parte dos problemas reais soam assim:
"a aplicação não está respondendo", "não consigo acessar o servidor", "o site caiu".
Pra resolver isso, preciso entender como a informação viaja de um computador pro outro.

Toda rede resolve 3 coisas: um endereço, um caminho, e uma linguagem combinada.

---

## DNS (Domain Name System)
- Traduz nome (google.com) em número (IP).
- Analogia: agenda de contatos do celular - você salva o nome, o celular busca o número.
- Comando pra testar: dig google.com

## Endereço IP
- Número único que identifica um computador na rede (ex: 142.250.218.14).
- Analogia: CEP + número da casa.

## Portas
- Um mesmo servidor (IP) pode rodar vários serviços ao mesmo tempo.
- A porta diz PRA QUAL serviço a mensagem deve ir.
- Analogia: IP = endereço do prédio, porta = número do apartamento.
- Portas mais usadas:
  - 80  -> HTTP (sem criptografia)
  - 443 -> HTTPS (com criptografia)
  - 22  -> SSH (acesso remoto seguro)

## HTTP vs HTTPS
- HTTP = linguagem que navegador e servidor usam pra conversar (sem proteção, tipo cartão postal).
- HTTPS = mesma linguagem, só que criptografada (tipo carta lacrada num cofre).
- A cada acesso HTTPS, navegador e servidor fazem um "handshake" (aperto de mão):
  1. Navegador pede conexão segura na porta 443
  2. Servidor manda um certificado (prova de identidade)
  3. Os dois calculam juntos uma chave TEMPORÁRIA, só pra aquela sessão
  4. A conversa toda passa a ser criptografada com essa chave

## SSH (Secure Shell)
- Serve pra ENTRAR de verdade dentro de um servidor (não só olhar de fora, como no HTTP).
- Uma vez dentro, uso os mesmos comandos de Linux do Módulo 1, só que rodando no servidor remoto.
- Usa a porta 22, com toda comunicação criptografada.
- Comando básico: ssh usuario@ip-do-servidor

### Autenticação por chave (par de chaves)
- Chave PRIVADA: fica só na minha máquina, nunca sai dela, nunca é compartilhada.
- Chave PÚBLICA: posso compartilhar livremente, vai para o servidor.
- Analogia: chave pública = cadeado que qualquer um pode fechar; chave privada = a única
  chave que abre aquele cadeado específico.
- A chave privada NUNCA é enviada pela rede. O servidor manda um desafio matemático,
  só quem tem a chave privada certa consegue resolver, e só a RESPOSTA volta pro servidor.

### Como a chave pública chega no servidor
1. Gero o par de chaves localmente: ssh-keygen
2. Guardo a chave privada com segurança (nunca compartilho)
3. Levo a chave pública até o servidor, de uma das formas:
   - ssh-copy-id usuario@ip-do-servidor (usa senha só nessa primeira vez, depois nunca mais)
   - colar manualmente no arquivo ~/.ssh/authorized_keys do servidor
   - colar direto na criação da VM na cloud (Azure, AWS, etc.) - forma mais comum em produção
4. Dali em diante, ssh usuario@ip-do-servidor conecta sem pedir senha

Importante: quem "guarda" a informação depois de configurado é o SERVIDOR
(diferente de senha salva no navegador, que fica guardada no meu computador).

---

## Resumo do fluxo completo (exemplo: acessar um site HTTPS)
1. DNS traduz o nome do site em IP
2. IP leva a mensagem até o servidor certo
3. Porta 443 leva a mensagem até o serviço certo dentro do servidor
4. Handshake HTTPS estabelece uma chave temporária de criptografia
5. Conversa acontece protegida até eu sair do site


## TTL (Time To Live) do DNS
- Cada resposta de DNS vem com um tempo de cache (visto no "dig", ex: 300 segundos).
- Mudancas de DNS NAO sao instantaneas em todo mundo - cada maquina/rede guarda
  a resposta antiga em cache ate esse tempo expirar.
- Por isso, apos mudar um registro DNS, algumas maquinas atualizam antes de outras -
  parece "aleatorio", mas e so o TTL de cada uma vencendo em momentos diferentes.
- Isso explica sintomas tipo "a aplicacao atualizou, mas so parou de funcionar em
  algumas maquinas" - times diferentes de cache expirando em horarios diferentes.

## Códigos HTTP mais comuns
2xx = sucesso (200 OK)
3xx = redirecionamento (301 permanente, 302 temporario)
4xx = erro do CLIENTE (400 pedido mal formatado, 401 nao autenticado,
      403 autenticado mas sem permissao, 404 nao encontrado)
5xx = erro do SERVIDOR (500 erro generico na aplicacao, 502 Bad Gateway -
      proxy/gateway recebeu resposta invalida do backend, 503 servico indisponivel)

Diferenca importante 401 vs 403:
- 401 = "nao sei quem voce e, se identifique"
- 403 = "sei quem voce e, mas voce nao tem permissao"

Diferenca importante 500 vs 502 (relevante para Application Gateway/proxy reverso):
- 500 = a aplicacao respondeu, mas quebrou por dentro (bug no codigo)
- 502 = o proxy/gateway nao conseguiu resposta valida do backend
  (VM caida, health probe reprovando, timeout)

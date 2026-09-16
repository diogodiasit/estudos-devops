# Conceitos - Fase 5 (CI/CD)

## CI/CD
CI (Integração Contínua): a cada push, roda testes automaticamente.
CD (Entrega/Deploy Contínuo): build e deploy automáticos, após os testes passarem.
Objetivo central: eliminar intervenção manual repetitiva.

## Runner
Máquina virtual temporária do GitHub - nasce, executa os passos do workflow, morre.
Não é o computador do usuário nem alguém controlando remotamente.

## Tipos de teste
- Unidade: código chamando código direto, sem UI (ex: verificar_horario()).
- Integração: várias peças juntas (ex: chamada de API real), ainda sem navegador.
- E2E/front-end: ferramentas (Cypress/Playwright) simulam cliques reais no navegador.

## Mock
Versão "falsa" de algo (hardware, API) que devolve uma resposta controlada,
pra testar a lógica sem precisar do recurso real. Ex: MockControladora.

## Fixture
Função que roda automaticamente antes de cada teste (com @pytest.fixture(autouse=True)),
garantindo que um teste não interfira nos dados de outro.

## venv (ambiente virtual)
Erro comum: "externally-managed-environment" ao tentar pip install direto no sistema.
Causa: Ubuntu protege o Python do sistema contra instalação de bibliotecas soltas.
Solução: criar um ambiente isolado, só para o projeto.
  python3 -m venv venv       -> cria
  source venv/bin/activate   -> ativa (mostra "(venv)" no terminal)
  deactivate                 -> sai
Isolamento é só da ferramenta (pip/python usados); o efeito do código sobre
os arquivos do projeto continua sendo real.

## Estrutura do .yml
on:            -> gatilho (o que dispara o workflow)
jobs:          -> lista de trabalhos a executar
runs-on:       -> sistema operacional do runner (ex: ubuntu-latest)
steps:         -> passos, executados em ordem
uses:          -> chama uma ação pronta (ex: actions/checkout@v4)
run:           -> executa comando de terminal direto

## on: push vs on: pull_request
push: dispara direto quando o código já foi enviado (mesmo que quebrado, já impactou a branch).
pull_request: dispara quando um PR é aberto, ANTES do código entrar na branch de destino.

## Pull Request e proteção de branch (ponto mais importante da fase)
Push direto na main só AVISA se o teste falhar - não impede o código de entrar.
Branch protection resolve isso, com duas regras:
  - "Require a pull request before merging": bloqueia push direto na main.
  - "Require status checks to pass before merging": trava o botão de merge
    até os testes passarem.
Sem essas duas regras, o CI/CD só serve como alarme, não como proteção real.

## GitHub Actions vs Azure DevOps
Mesmo conceito, nomes diferentes:
  - runner (GitHub) = agente (Azure)
  - .github/workflows/*.yml (GitHub) = azure-pipelines.yml (Azure)
  - jobs/steps (GitHub) = stages/tasks (Azure)

## paths (filtro de gatilho)
Em monorepos (várias pastas/projetos no mesmo repositório), o "on: push" sozinho
dispara para qualquer mudança, em qualquer pasta. "paths:" restringe o gatilho
a mudanças dentro de um caminho específico.

# Fase 6 - Azure DevOps - Conceitos e duvidas reais

## Tabela de traducao GitHub <-> Azure DevOps
- Actions -> Pipelines
- Repositorio -> Repos
- .github/workflows/nome.yml -> azure-pipelines.yml (raiz do repo)
- on: -> trigger: (push) ou pr: (pull request)
- runs-on: -> pool: vmImage:
- run: -> script:
- name: -> displayName:
- uses: -> task:
- Secrets -> Service Connection
- Branch protection -> Branch Policies

## Duvida real 1: pr: no YAML nao funciona no Azure Repos
O bloco "pr:" so funciona para repositorios GitHub e Bitbucket.
Para Azure Repos, o gatilho de Pull Request vem de uma Branch Policy
(Build Validation), configurada fora do arquivo YAML, em Repos > Branches.

## Duvida real 2: trigger: e o equivalente a push
No Azure, "trigger:" sozinho ja significa "gatilho de push" - nao precisa
escrever a palavra push em lugar nenhum. Por isso, para rodar SO em PR,
e preciso desligar o trigger com:
trigger:
  branches:
    exclude:
      - '*'

## Duvida real 3: conflito de merge nao resolvido
Um merge que gera conflito precisa ser resolvido manualmente (remover as
marcacoes <<<<<<<, =======, >>>>>>>). Se voce editar o arquivo com nano
sem perceber essas marcacoes, elas ficam salvas junto, e o arquivo vira
invalido sem nenhum erro aparente.

## Duvida real 4: push x abrir PR sao acoes diferentes
git push so envia o codigo. Abrir Pull Request e uma acao manual, feita
na interface, feita DEPOIS do push. Uma nao dispara a outra sozinha.

## Duvida real 5: pipeline roda como "preview" durante o PR
Quando existe uma Branch Policy configurada, pipelines com trigger na
branch de destino podem rodar automaticamente durante o PR, como um
"preview" do que aconteceria apos o merge - antes mesmo de clicar Complete.

## Service Connection
Equivalente ao par de secrets do GitHub (usuario + token), mas empacotado
num unico objeto reutilizavel, configurado em Project Settings > Service
connections. No YAML, referenciado so pelo nome (containerRegistry).
